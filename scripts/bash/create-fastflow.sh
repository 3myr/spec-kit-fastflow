#!/usr/bin/env bash

set -e

JSON_MODE=false
DRY_RUN=false
ALLOW_EXISTING=false
SHORT_NAME=""
BRANCH_NUMBER=""
USE_TIMESTAMP=false
INCREMENT="MVP"
ARGS=()

i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json) JSON_MODE=true ;;
        --dry-run) DRY_RUN=true ;;
        --allow-existing-branch) ALLOW_EXISTING=true ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then echo 'Error: --short-name requires a value' >&2; exit 1; fi
            i=$((i + 1)); SHORT_NAME="${!i}"
            if [[ "$SHORT_NAME" == --* || -z "$SHORT_NAME" ]]; then echo 'Error: --short-name requires a value' >&2; exit 1; fi
            ;;
        --number)
            if [ $((i + 1)) -gt $# ]; then echo 'Error: --number requires a value' >&2; exit 1; fi
            i=$((i + 1)); BRANCH_NUMBER="${!i}"
            if [[ "$BRANCH_NUMBER" == --* || -z "$BRANCH_NUMBER" ]]; then echo 'Error: --number requires a value' >&2; exit 1; fi
            ;;
        --timestamp) USE_TIMESTAMP=true ;;
        --increment)
            if [ $((i + 1)) -gt $# ]; then echo 'Error: --increment requires a value' >&2; exit 1; fi
            i=$((i + 1)); INCREMENT="${!i}"
            case "$INCREMENT" in MVP|V1|V2|Hotfix) ;; *) echo 'Error: --increment must be MVP, V1, V2, or Hotfix' >&2; exit 1 ;; esac
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--dry-run] [--allow-existing-branch] [--short-name <name>] [--number N] [--timestamp] [--increment MVP|V1|V2|Hotfix] <feature_description>"
            exit 0
            ;;
        *) ARGS+=("$arg") ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
FEATURE_DESCRIPTION=$(echo "$FEATURE_DESCRIPTION" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Error: Feature description cannot be empty" >&2
    exit 1
fi

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# FastFlow is installed as a Spec Kit extension, so this script usually lives in:
# .specify/extensions/fastflow/scripts/bash/
# The shared Spec Kit helpers live in:
# .specify/scripts/bash/common.sh
# Keep a same-directory fallback for development or vendored installs.
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
elif [ -f "$SCRIPT_DIR/../../../../scripts/bash/common.sh" ]; then
    source "$SCRIPT_DIR/../../../../scripts/bash/common.sh"
else
    echo "Error: Spec Kit common.sh not found. Expected either:" >&2
    echo "  $SCRIPT_DIR/common.sh" >&2
    echo "  $SCRIPT_DIR/../../../../scripts/bash/common.sh" >&2
    exit 1
fi

resolve_fastflow_template() {
    local template_name="$1"
    local repo_root="$2"
    local candidates=(
        "$repo_root/.specify/extensions/fastflow/templates/${template_name}.md"
        "$repo_root/.specify/templates/${template_name}.md"
        "$SCRIPT_DIR/../../templates/${template_name}.md"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}


REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

if [ ! -d "$REPO_ROOT/.specify" ]; then
    echo "Error: .specify directory not found. Run from a Spec Kit project." >&2
    exit 1
fi

if has_git; then HAS_GIT=true; else HAS_GIT=false; fi

clean_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

generate_slug() {
    local description="$1"
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set|create|implement|feature)$"
    local words=()
    local clean
    clean=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    for word in $clean; do
        [ -z "$word" ] && continue
        if ! echo "$word" | grep -qiE "$stop_words" && [ ${#word} -ge 3 ]; then
            words+=("$word")
        fi
    done
    if [ ${#words[@]} -eq 0 ]; then
        clean_name "$description" | cut -c1-60
        return
    fi
    local out=""; local count=0
    for word in "${words[@]}"; do
        [ $count -ge 4 ] && break
        [ -n "$out" ] && out="$out-"
        out="$out$word"
        count=$((count + 1))
    done
    echo "$out"
}

get_highest_from_fastflow() {
    local fastflow_dir="$1"
    local highest=0
    if [ -d "$fastflow_dir" ]; then
        for file in "$fastflow_dir"/*.md; do
            [ -f "$file" ] || continue
            base=$(basename "$file" .md)
            if echo "$base" | grep -Eq '^[0-9]{3,}-'; then
                number=$(echo "$base" | grep -Eo '^[0-9]+')
                number=$((10#$number))
                [ "$number" -gt "$highest" ] && highest=$number
            fi
        done
    fi
    echo "$highest"
}

_extract_highest_branch_number() {
    local highest=0
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        if echo "$name" | grep -Eq '^[0-9]{3,}-' && ! echo "$name" | grep -Eq '^[0-9]{8}-[0-9]{6}-'; then
            number=$(echo "$name" | grep -Eo '^[0-9]+' || echo 0)
            number=$((10#$number))
            [ "$number" -gt "$highest" ] && highest=$number
        fi
    done
    echo "$highest"
}

next_number() {
    local fastflow_dir="$1"
    local highest_fastflow highest_branch
    highest_fastflow=$(get_highest_from_fastflow "$fastflow_dir")
    highest_branch=0
    if [ "$HAS_GIT" = true ]; then
        highest_branch=$(git branch -a 2>/dev/null | sed 's/^[* ]*//; s|^remotes/[^/]*/||' | _extract_highest_branch_number)
    fi
    if [ "$highest_branch" -gt "$highest_fastflow" ]; then echo $((highest_branch + 1)); else echo $((highest_fastflow + 1)); fi
}

FASTFLOW_DIR="$REPO_ROOT/specs/fastflow"
mkdir -p "$FASTFLOW_DIR"

if [ -n "$SHORT_NAME" ]; then FEATURE_SLUG=$(clean_name "$SHORT_NAME"); else FEATURE_SLUG=$(generate_slug "$FEATURE_DESCRIPTION"); fi
[ -z "$FEATURE_SLUG" ] && FEATURE_SLUG="fastflow-feature"

if [ "$USE_TIMESTAMP" = true ]; then
    FEATURE_NUM=$(date +%Y%m%d-%H%M%S)
    BRANCH_NAME="$FEATURE_NUM-$FEATURE_SLUG"
elif [ -n "$BRANCH_NUMBER" ]; then
    FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
    BRANCH_NAME="$FEATURE_NUM-$FEATURE_SLUG"
else
    FEATURE_NUM=$(printf "%03d" "$(next_number "$FASTFLOW_DIR")")
    BRANCH_NAME="$FEATURE_NUM-$FEATURE_SLUG"
fi

FEATURE_ID="$BRANCH_NAME"
FASTFLOW_FILE="$FASTFLOW_DIR/$FEATURE_ID.md"
TEMPLATE=$(resolve_fastflow_template "fastflow-create-template" "$REPO_ROOT") || true

if [ -z "$TEMPLATE" ] || [ ! -f "$TEMPLATE" ]; then
    echo "Error: FastFlow create template not found. Expected .specify/extensions/fastflow/templates/fastflow-create-template.md" >&2
    exit 1
fi

if [ "$DRY_RUN" != true ]; then
    if [ "$HAS_GIT" = true ]; then
        current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
        if ! git checkout -q -b "$BRANCH_NAME" 2>/tmp/fastflow_branch_error; then
            if git branch --list "$BRANCH_NAME" | grep -q . && [ "$ALLOW_EXISTING" = true ]; then
                [ "$current_branch" = "$BRANCH_NAME" ] || git checkout -q "$BRANCH_NAME"
            else
                echo "Error: Failed to create git branch '$BRANCH_NAME'." >&2
                cat /tmp/fastflow_branch_error >&2 || true
                exit 1
            fi
        fi
    else
        echo "[fastflow] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME" >&2
    fi

    if [ -f "$FASTFLOW_FILE" ] && [ "$ALLOW_EXISTING" != true ]; then
        echo "Error: FastFlow file already exists: $FASTFLOW_FILE" >&2
        exit 1
    fi
    cp "$TEMPLATE" "$FASTFLOW_FILE"
fi

if $JSON_MODE; then
    if command -v jq >/dev/null 2>&1; then
        jq -cn --arg feature_id "$FEATURE_ID" --arg branch_name "$BRANCH_NAME" --arg fastflow_file "$FASTFLOW_FILE" --arg feature_num "$FEATURE_NUM" --arg increment "$INCREMENT" --arg has_git "$HAS_GIT" \
            '{FEATURE_ID:$feature_id,BRANCH_NAME:$branch_name,FASTFLOW_FILE:$fastflow_file,FEATURE_NUM:$feature_num,INCREMENT:$increment,HAS_GIT:$has_git}'
    else
        printf '{"FEATURE_ID":"%s","BRANCH_NAME":"%s","FASTFLOW_FILE":"%s","FEATURE_NUM":"%s","INCREMENT":"%s","HAS_GIT":"%s"}\n' "$FEATURE_ID" "$BRANCH_NAME" "$FASTFLOW_FILE" "$FEATURE_NUM" "$INCREMENT" "$HAS_GIT"
    fi
else
    echo "FEATURE_ID: $FEATURE_ID"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "FASTFLOW_FILE: $FASTFLOW_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
    echo "INCREMENT: $INCREMENT"
    echo "HAS_GIT: $HAS_GIT"
fi
