#!/usr/bin/env bash
set -euo pipefail

FEATURE_ID="${1:-}"
TITLE="${2:-}"
INCREMENT="${3:-MVP}"

if [ -z "$FEATURE_ID" ]; then
  echo "Usage: scripts/create-fastflow.sh <feature-id> [title] [increment]" >&2
  exit 1
fi

if [ -z "$TITLE" ]; then
  TITLE="$FEATURE_ID"
fi

DATE="$(date +%F)"
BRANCH_NAME="fastflow/$FEATURE_ID"
TARGET_DIR="specs/fastflow"
TEMPLATE=".specify/templates/fastflow-create-template.md"
TARGET_FILE="$TARGET_DIR/$FEATURE_ID.md"

mkdir -p "$TARGET_DIR"

if [ ! -f "$TEMPLATE" ]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

cp "$TEMPLATE" "$TARGET_FILE"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

TITLE_ESCAPED="$(escape_sed "$TITLE")"
BRANCH_ESCAPED="$(escape_sed "$BRANCH_NAME")"
DATE_ESCAPED="$(escape_sed "$DATE")"
INCREMENT_ESCAPED="$(escape_sed "$INCREMENT")"

sed -i \
  -e "s|{{TITLE}}|$TITLE_ESCAPED|g" \
  -e "s|{{BRANCH_NAME}}|$BRANCH_ESCAPED|g" \
  -e "s|{{DATE}}|$DATE_ESCAPED|g" \
  -e "s|{{INCREMENT}}|$INCREMENT_ESCAPED|g" \
  "$TARGET_FILE"

echo "$TARGET_FILE"
