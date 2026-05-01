---
description: Classify task complexity and recommend tiny change, FastFlow, or full SDD workflow
***

# FastFlow Classify

Analyze a task description to determine whether it should use a tiny change workflow, the FastFlow single-file workflow, or the full SDD workflow. The goal is to keep iteration fast for scoped work while preserving the option to escalate to full Spec Kit when complexity, ambiguity, or architectural impact is too high.

## Arguments

You MUST consider the user input before proceeding if not empty.

The user describes what they want to build, change, fix, or evolve.

## Prerequisites

1. Verify a Spec Kit project exists by checking for `.specify`.
2. Verify the user has described the task. If not, ask what they want to build or change.
3. If available, read `.specify/memory/constitution.md` before classifying.

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
- Requires extensive technical validation beyond business or functional testing.

### 2. Estimate scope

Estimate:

- Files affected.
- Number of implementation tasks.
- Risk to existing functionality.
- Need for coordination across modules.
- Degree of ambiguity.
- Fit with Onion Architecture boundaries.

### 3. Recommend workflow

Use this matrix as guidance.

| Complexity | Typical files | Typical tasks | Risk | Recommendation |
|---|---:|---:|---|---|
| Tiny | 1-3 | 1-5 | Low | Use a tiny change workflow or implement directly |
| Focused | 3-12 | 5-15 | Low to medium | Use `speckit.fastflow` |
| Large | 12+ | 15+ | Medium to high | Use full SDD with `speckit.specify` and optionally `speckit.clarify` |

### 4. Default behavior

- When in doubt between tiny and focused, recommend `speckit.fastflow`.
- When in doubt between FastFlow and full SDD, choose full SDD if ambiguity or architectural impact is high.
- This classification is a recommendation, not a hard gate.

## Output

Return a markdown report in this shape:

```markdown
# Task Classification

| Factor             | Assessment |
|---                 |         ---|
| Task               | ... |
| Complexity         | Tiny / Focused / Large |
| Estimated files    | N |
| Estimated tasks    | N |
| Risk               | Low / Medium / High |
| Onion fit          | Good / Partial / Poor |
| Recommendation     | `speckit.fastflow` / `speckit.specify` / tiny change |

## Why

- Reason 1
- Reason 2
- Reason 3

## Next step

Run `...`
```

## Rules

- Read-only: never modify files.
- Explain the reasoning clearly.
- Prefer FastFlow for feature increments that need speed and future evolution.
- Recommend full SDD whenever architecture, ambiguity, or scope exceeds a single-file workflow.