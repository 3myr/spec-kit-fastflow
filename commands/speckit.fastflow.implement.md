---
description: Implement a feature increment directly from its FastFlow file
***

# FastFlow Implement

Implement a feature increment by following the plan and tasks in a FastFlow file. This works like a streamlined implementation workflow: read one document, execute the tasks in order, keep the file updated, and stop when the scope no longer fits the single-file contract.

## Arguments

You MUST consider the user input before proceeding if not empty.

The user may specify a FastFlow name, feature id, or a direct path to the FastFlow file.

## Prerequisites

1. Verify a Spec Kit project exists by checking for `.specify`.
2. Verify git is available and the project is a git repository.
3. Locate the FastFlow file:
   - If the user specifies a name, look for `specs/fastflow/<name>.md`.
   - If no input is provided, look for the most recently created FastFlow file in `specs/fastflow`.
   - If no FastFlow file exists, suggest running `speckit.fastflow` first.

## Workflow

### 1. Read the FastFlow file

Parse the file and extract:

- Scope now.
- Not now.
- Context.
- Requirements.
- Architecture guards.
- Test strategy.
- Layer impacts.
- Plan.
- Tasks.
- Done when.
- Follow-ups.

### 2. Load context files

Read all files referenced in the Context table to understand:

- Existing architecture and boundaries.
- Current code patterns and naming.
- Existing tests and conventions.
- Dependencies and contracts.

### 3. Execute tasks in order

For each task:

- Follow the corresponding plan step.
- Implement only what belongs to `Scope now`.
- Respect `Architecture guards`.
- Update the FastFlow file by marking the completed task.
- If a task reveals an unplanned architectural shift, stop and ask whether to revise the FastFlow file or upgrade to full SDD.

### 4. Verify completion

After implementation:

- Check that all requirements are satisfied.
- Run relevant tests if test tasks exist.
- Run linting or type checks if configured.
- Update `Done when` checkboxes.
- Change `Status: draft` to `Status: done` if all criteria are met.

### 5. Handle scope creep

Stop and escalate when:

- The implementation exceeds `Scope now`.
- The number of changed files or tasks is significantly higher than expected.
- Core architecture decisions are no longer stable.
- New ambiguity appears that needs discovery or clarification.

In that case, recommend either:

- Updating the FastFlow file and continuing, if the shift is still moderate.
- Upgrading to `speckit.specify` and optionally `speckit.clarify`, if the shift is substantial.

## Output

Return a markdown report in this shape:

```markdown
# FastFlow Complete

| Field | Value |
|---|---|
| File | specs/fastflow/<feature-id>.md |
| Tasks completed | N / N |
| Files modified | ... |
| Tests | Pass / Fail / Not run |
| Status | done / partial / blocked |

## Changes made

1. Change summary 1
2. Change summary 2
3. Change summary 3

## Next step

- Review the diff.
- Decide whether follow-ups stay deferred or become a new FastFlow increment.
```

## Rules

- Follow the FastFlow file closely. Do not silently expand scope.
- Complete one task at a time.
- Keep the FastFlow file updated while implementing.
- Match existing project patterns and conventions.
- Stop on ambiguity instead of guessing.
- Escalate to full SDD when the work no longer fits a single-file increment.