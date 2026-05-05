---
description: Classify task complexity and recommend tiny change, FastFlow, or full SDD workflow
***

# FastFlow Classify

Analyze a task description to determine whether it should use a tiny change workflow, the FastFlow single-file workflow, or the full SDD workflow.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding if not empty.

## Required scaffold workflow

The classification report MUST be created from the template by the script before the agent edits it.
Do not create the markdown report manually.
Do not paste the final template directly into a new file.
Do not bypass the script unless the script fails; if it fails, report the failure and stop.

## Prerequisites

1. Verify a Spec Kit project exists by checking for `.specify`.
2. Verify the user has described the task. If not, ask what they want to build or change.
3. If available, read `.specify/memory/constitution.md` before classifying.
4. If available, read `.specify/extensions/fastflow/templates/fastflow-classify-template.md` so classification stays aligned with the actual classification report model.
5. If available, read `.specify/extensions/fastflow/templates/fastflow-create-template.md` so the recommendation also reflects whether the request fits the FastFlow document model.

## Outline

1. **Setup**: Run `.specify/extensions/fastflow/scripts/bash/create-fastflow-classification-report.sh --json "$ARGUMENTS"` from the repository root and parse JSON for `REPORT_FILE`, `REPORT_DIR`, `TASK_SLUG`, and `DATE`.
   - For single quotes in arguments like `I'm Groot`, use shell-safe escaping: `'I'\''m Groot'`, or use double quotes when possible.
   - This script creates `specs/fastflow/reports/`, copies `.specify/extensions/fastflow/templates/fastflow-classify-template.md`, and returns the path of the copied report.
2. **Load context**: Read `REPORT_FILE` after the script has copied the template. Read the constitution and FastFlow create template if present.
3. **Analyze the task**: Estimate complexity, impacted files, implementation tasks, risk, Onion fit, and template fit.
4. **Edit the copied template**: Replace every `{{PLACEHOLDER}}` in `REPORT_FILE` with concrete classification content. The final report must not contain unresolved placeholders.
5. **Report**: Return the recommendation and exact saved report path.

## Classification Logic

### 1. Analyze the task

Evaluate the request using these signals.

#### Tiny change signals

- Single UI tweak.
- Bug fix with known location.
- Copy update.
- Small validation rule.
- Small config change.
- Single endpoint addition with no cross-cutting impact.
- Styling adjustment.
- Refactor limited to one clear area.

#### FastFlow signals

- New feature increment for an existing or new application.
- Small-to-medium scope spanning presentation, application, domain, or infrastructure in a controlled way.
- MVP-ready work that should evolve later without refactoring everything.
- Need for a single-file spec with enough structure to guide multiple implementation steps.
- Change likely affecting roughly 3 to 12 files.
- Requires design choices, but not a full discovery or architecture initiative.
- Can be expressed clearly through Onion Architecture layers.
- Can be represented cleanly through the existing FastFlow create template without bloating it.

#### Full SDD signals

- Multiple user stories or large feature set.
- Broad architectural refactor.
- New bounded context or major domain expansion.
- New database schema or migration strategy with significant impact.
- Cross-cutting concern across many modules.
- External integration with unclear behavior or high risk.
- Unknown scope requiring clarification and staged planning.
- Change likely affecting more than 12 files or many teams or areas.
- Cannot be expressed cleanly through Onion Architecture boundaries.
- Cannot fit cleanly in the FastFlow create template without turning into a large design dossier.

### 2. Estimate scope

Estimate:

- Files affected.
- Number of implementation tasks.
- Risk to existing functionality.
- Need for coordination across modules.
- Degree of ambiguity.
- Fit with Onion Architecture boundaries.
- Fit with the FastFlow create template.

### 3. Recommend workflow

Use this matrix as guidance.

| Complexity | Typical files | Typical tasks | Risk | Recommendation |
|---|---:|---:|---|---|
| Tiny | 1-3 | 1-5 | Low | Use a tiny change workflow or implement directly |
| Focused | 3-12 | 5-15 | Low to medium | Use `speckit.fastflow.create` |
| Large | 12+ | 15+ | Medium to high | Use full SDD with `speckit.specify` and optionally `speckit.clarify` |

### 4. Default behavior

- When in doubt between tiny and focused, recommend `speckit.fastflow.create`.
- When in doubt between FastFlow and full SDD, choose full SDD if ambiguity or architectural impact is high.
- This classification is a recommendation, not a hard gate.

## Output file contract

The script creates a markdown report at:

`specs/fastflow/reports/YYYY-MM-DD-<task-slug>-classification.md`

The file MUST follow `.specify/extensions/fastflow/templates/fastflow-classify-template.md`.
Do not rename the file after the script creates it.

The final report must contain:

```markdown
# Task Classification Report

- Date: YYYY-MM-DD
- Task: ...
- Recommendation: speckit.fastflow.create | speckit.specify | tiny change

| Factor | Assessment |
| --- | --- |
| Complexity | Tiny | Focused | Large |
| Estimated files | N |
| Estimated tasks | N |
| Risk | Low | Medium | High |
| Onion fit | Good | Partial | Poor |
| Template fit | Good | Partial | Poor |

## Why
- Reason 1
- Reason 2
- Reason 3

## Next step
Run ...
```

After writing the file, return a short markdown response with:
- Recommendation.
- Key reasons.
- Exact saved report path.

If the report file could not be created, do not return a successful classification. Explicitly report that file creation failed and why.

## Rules

- Always run `.specify/extensions/fastflow/scripts/bash/create-fastflow-classification-report.sh --json` first.
- Always edit the report copied by the script.
- Do not silently skip unresolved placeholders.
- Do not create reports outside `specs/fastflow/reports/`.
