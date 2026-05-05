#!/usr/bin/env bash

set -e

JSON_MODE=false
SHORT_NAME=""
ARGS=()

i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json) JSON_MODE=true ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then echo 'Error: --short-name requires a value' >&2; exit 1; fi
            i=$((i + 1)); SHORT_NAME="${!i}"
            if [[ "$SHORT_NAME" == --* || -z "$SHORT_NAME" ]]; then echo 'Error: --short-name requires a value' >&2; exit 1; fi
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--short-name <slug>] <task_description>"
            exit 0
            ;;
        *) ARGS+=("$arg") ;;
    esac
    i=$((i + 1))
done

TASK_DESCRIPTION="${ARGS[*]}"
TASK_DESCRIPTION=$(echo "$TASK_DESCRIPTION" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
if [ -z "$TASK_DESCRIPTION" ]; then
    echo "Error: Task description cannot be empty" >&2
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

clean_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

generate_slug() {
    local text="$1"
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set|create|implement|feature|task)$"
    local clean words=() out="" count=0
    clean=$(echo "$text" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    for word in $clean; do
        [ -z "$word" ] && continue
        if ! echo "$word" | grep -qiE "$stop_words" && [ ${#word} -ge 3 ]; then words+=("$word"); fi
    done
    for word in "${words[@]}"; do
        [ $count -ge 5 ] && break
        [ -n "$out" ] && out="$out-"
        out="$out$word"
        count=$((count + 1))
    done
    [ -n "$out" ] && echo "$out" || clean_name "$text" | cut -c1-70
}

if [ -n "$SHORT_NAME" ]; then TASK_SLUG=$(clean_name "$SHORT_NAME"); else TASK_SLUG=$(generate_slug "$TASK_DESCRIPTION"); fi
[ -z "$TASK_SLUG" ] && TASK_SLUG="task"

DATE=$(date +%F)
REPORT_DIR="$REPO_ROOT/specs/fastflow/reports"
REPORT_FILE="$REPORT_DIR/$DATE-$TASK_SLUG-classification.md"
TEMPLATE=$(resolve_fastflow_template "fastflow-classify-template" "$REPO_ROOT") || true

if [ -z "$TEMPLATE" ] || [ ! -f "$TEMPLATE" ]; then
    echo "Error: FastFlow classify template not found. Expected .specify/extensions/fastflow/templates/fastflow-classify-template.md" >&2
    exit 1
fi

mkdir -p "$REPORT_DIR"
cp "$TEMPLATE" "$REPORT_FILE"

if $JSON_MODE; then
    if command -v jq >/dev/null 2>&1; then
        jq -cn --arg report_file "$REPORT_FILE" --arg report_dir "$REPORT_DIR" --arg task_slug "$TASK_SLUG" --arg date "$DATE" \
            '{REPORT_FILE:$report_file,REPORT_DIR:$report_dir,TASK_SLUG:$task_slug,DATE:$date}'
    else
        printf '{"REPORT_FILE":"%s","REPORT_DIR":"%s","TASK_SLUG":"%s","DATE":"%s"}\n' "$REPORT_FILE" "$REPORT_DIR" "$TASK_SLUG" "$DATE"
    fi
else
    echo "REPORT_FILE: $REPORT_FILE"
    echo "REPORT_DIR: $REPORT_DIR"
    echo "TASK_SLUG: $TASK_SLUG"
    echo "DATE: $DATE"
fi
