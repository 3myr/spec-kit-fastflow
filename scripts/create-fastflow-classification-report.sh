#!/usr/bin/env bash
set -euo pipefail

TASK_SLUG="${1:-}"
TASK_LABEL="${2:-}"
RECOMMENDATION="${3:-speckit.fastflow.create}"

if [ -z "$TASK_SLUG" ]; then
  echo "Usage: scripts/create-fastflow-classification-report.sh <task-slug> [task-label] [recommendation]" >&2
  exit 1
fi

if [ -z "$TASK_LABEL" ]; then
  TASK_LABEL="$TASK_SLUG"
fi

DATE="$(date +%F)"
TARGET_DIR="specs/fastflow/reports"
TEMPLATE=".specify/templates/fastflow-classify-template.md"
TARGET_FILE="$TARGET_DIR/${DATE}-${TASK_SLUG}-classification.md"

mkdir -p "$TARGET_DIR"

if [ ! -f "$TEMPLATE" ]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

cp "$TEMPLATE" "$TARGET_FILE"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

DATE_ESCAPED="$(escape_sed "$DATE")"
TASK_ESCAPED="$(escape_sed "$TASK_LABEL")"
RECOMMENDATION_ESCAPED="$(escape_sed "$RECOMMENDATION")"

sed -i \
  -e "s|{{DATE}}|$DATE_ESCAPED|g" \
  -e "s|{{TASK}}|$TASK_ESCAPED|g" \
  -e "s|{{RECOMMENDATION}}|$RECOMMENDATION_ESCAPED|g" \
  -e "s|{{COMPLEXITY}}|TBD|g" \
  -e "s|{{ESTIMATED_FILES}}|TBD|g" \
  -e "s|{{ESTIMATED_TASKS}}|TBD|g" \
  -e "s|{{RISK}}|TBD|g" \
  -e "s|{{ONION_FIT}}|TBD|g" \
  -e "s|{{TEMPLATE_FIT}}|TBD|g" \
  -e "s|{{WHY_1}}|TBD|g" \
  -e "s|{{WHY_2}}|TBD|g" \
  -e "s|{{WHY_3}}|TBD|g" \
  -e "s|{{NEXT_STEP}}|TBD|g" \
  "$TARGET_FILE"

echo "$TARGET_FILE"