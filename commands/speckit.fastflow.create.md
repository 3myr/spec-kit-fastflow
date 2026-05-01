---
description: Generate a single-file FastFlow spec for a focused, evolvable feature increment
***

# FastFlow Create

Generate one durable FastFlow document for a focused feature increment that must be delivered quickly, remain aligned with the project constitution, and stay easy to evolve from MVP to later versions.

## Arguments

You MUST consider the user input before proceeding if not empty.

The user describes the feature, increment, or application capability they want to build.

## Prerequisites

1. Verify a Spec Kit project exists by checking for `.specify`.
2. Verify git is available and the project is a git repository.
3. Verify the user has described the feature or increment. If not, ask for it.
4. Read `.specify/memory/constitution.md` if present.
5. If available, read the latest relevant file in `specs/fastflow/reports/` to align with the latest classification.
6. Scan the codebase only as much as needed to ground the FastFlow in real project structure and existing architecture.

## Goal

Create one focused FastFlow file that is:
- concise enough to support fast iteration,
- structured enough to guide implementation,
- strict enough to stay aligned with Onion Architecture,
- restrained enough to avoid over-designing the solution too early.

FastFlow is for a focused increment, not a full design dossier.

## Scope decision

Before writing the file, evaluate whether the request still fits FastFlow.

Good fit:
- A new feature increment.
- A first usable MVP slice.
- A capability spanning a limited number of layers in a controlled way.
- Work that should evolve later without refactoring everything.
- Work that can be guided by one durable file.

Not a good fit:
- A tiny change that should be implemented directly.
- A large initiative with multiple independent stories.
- A request with high ambiguity or major architecture uncertainty.
- A change that cannot be expressed clearly through Onion boundaries.
- A scope that would likely exceed a focused increment.

Focused increment target:
- Usually around 3 to 12 impacted files.
- Usually around 5 to 15 implementation tasks.
- Low to medium architectural risk.

If the request no longer fits FastFlow, do NOT force it into a large FastFlow file.
Instead:
- narrow the scope to the first usable slice, or
- recommend breaking it into multiple FastFlow prompts, or
- recommend full SDD when necessary.

## Context gathering

Use the following sources, in this order:
1. The user prompt.
2. The constitution.
3. The latest classification report, if available.
4. The existing codebase and directory structure.

When the prompt is short, you MUST rely more heavily on the constitution, classification, and codebase to keep the output aligned with the FastFlow model.

## Output file

You MUST create the directory `specs/fastflow/` if it does not already exist.

You MUST write exactly one markdown file at:
`specs/fastflow/<feature-id>.md`

The `<feature-id>` should be:
- short,
- stable,
- lowercase,
- hyphenated,
- based on the feature name,
- prefixed with an ordinal only if the repository already uses that convention.

Do not create separate `spec.md`, `plan.md`, or `tasks.md` files.

## Output template

The FastFlow file MUST use this structure:

```markdown
# FastFlow: <title>

- Branch: <branch-name>
- Date: YYYY-MM-DD
- Status: draft
- Increment: MVP | V1 | V2 | Hotfix
- Complexity: focused

## Why

1 to 3 short sentences describing the user value, business goal, or product need.

## Scope now

- In-scope item 1
- In-scope item 2
- In-scope item 3

## Not now

- Explicitly deferred item 1
- Explicitly deferred item 2

## Context

| File / Area | Role |
|---|---|
| src/... | Will be modified because ... |
| src/... | Provides context because ... |
| tests/... | Must be updated because ... |

## Requirements

1. Requirement 1, user-visible or business-observable, clear and testable.
2. Requirement 2, user-visible or business-observable, clear and testable.
3. Requirement 3, user-visible or business-observable, clear and testable.

## Architecture guards

- Guard 1
- Guard 2
- Guard 3

## Test strategy

- Test priority 1
- Test priority 2
- Test priority 3

## Layer impacts

### Presentation
- Components, routes, controllers, views, presenters, or handlers impacted.

### Application
- Use cases, orchestration services, commands, queries, or state coordinators impacted.

### Domain
- Entities, value objects, domain services, policies, rules, or invariants impacted.

### Infrastructure
- Repositories, APIs, persistence, framework adapters, external services, or technical gateways impacted.

## Plan

1. Step 1.
2. Step 2.
3. Step 3.
4. Step 4.

## Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
- [ ] Task 4

## Done when

- [ ] Outcome 1
- [ ] Outcome 2
- [ ] Outcome 3

## Follow-ups

- Candidate V1 improvement.
- Candidate V2 improvement.
- Technical debt explicitly accepted for now.
```

### 4. Report results

Return a short markdown summary:

```markdown
# FastFlow Created

| Field             | Value |
|---                |    ---|
| File              | specs/fastflow/<feature-id>.md |
| Tasks             | N |
| Files affected    | N |
| Increment         | MVP / V1 / V2 / Hotfix |

## Next steps

- Review the FastFlow file.
- Run `speckit.fastflow.implement` to execute it.
- Or implement manually using the file as the single source of truth.
```

## Rules

- One file only. Never generate separate `spec.md`, `plan.md`, and `tasks.md` for FastFlow.
- Keep it concise but durable.
- Always make scope boundaries explicit with `Scope now` and `Not now`.
- Every requirement must be testable.
- Every plan must be implementable in order.
- Prefer implementation plans that establish domain and application behavior before wiring presentation or infrastructure adapters, when the nature of the feature allows it.
- Always express the feature through Onion Architecture layers, including frontend work.
- Favor business and functional tests over technical tests; technical-only tests require explicit justification.
- Always include future-safe guidance through `Architecture guards` and `Follow-ups`.
- If the task grows beyond the single-file format, recommend prompts to break down the request.