---
description: Generate a single-file FastFlow spec for an MVP-ready feature increment
***

# FastFlow

Generate a single specification file for a feature increment that must be delivered quickly but remain evolvable across MVP, V1, V2, and later iterations. FastFlow combines intent, scope, architecture constraints, implementation plan, and tasks in one concise document.

## Arguments

You MUST consider the user input before proceeding if not empty.

The user describes the feature, increment, or application capability they want to build.

## Prerequisites

1. Verify a Spec Kit project exists by checking for `.specify`.
2. Verify git is available and the project is a git repository.
3. Verify the user has described the feature or increment. If not, ask for it.
4. Read `.specify/memory/constitution.md` if present.

## Workflow

### 1. Assess scope

Determine whether the task is suitable for FastFlow.

Good fit:

- A new feature increment.
- A first MVP slice of a new application.
- A medium-sized capability that should stay easy to evolve.
- Work that spans multiple layers but still fits in one coordinated plan.
- Work that can be described clearly in a single durable file.

Bad fit:

- A tiny change that can be implemented directly.
- A large initiative with high ambiguity, deep discovery, or many independent stories.
- Work that requires multiple coordinated increments before implementation can start.
- Work that cannot be expressed cleanly through Onion Architecture boundaries.

If the scope is too large, suggest prompts to break down the request.

### 2. Identify context

Scan the codebase or target structure to determine:

- Files to modify or create.
- Related modules, components, services, data models, routes, or tests.
- Constraints already defined by the constitution or existing architecture.
- Existing Onion boundaries, dependencies, and technical adapters.

### 3. Create the FastFlow file

Create a single file at `specs/fastflow/<feature-id>.md` using the template below.

```markdown
# FastFlow: <title>

- Branch: <branch-name>
- Date: YYYY-MM-DD
- Status: draft
- Increment: MVP | V1 | V2 | Hotfix
- Complexity: focused

## Why

1-3 sentences describing the user value, business need, or product goal.

## Scope now

- In scope item 1
- In scope item 2
- In scope item 3

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

1. Requirement 1, clear, testable, and business or user observable.
2. Requirement 2, clear, testable, and business or user observable.
3. Requirement 3, clear, testable, and business or user observable.

## Architecture guards

- Structure all work using Onion Architecture, for both backend and frontend code.
- Keep business rules and functional decision logic inside the Domain layer.
- Use the Application layer to orchestrate use cases and coordinate ports, without embedding technical details.
- Put technical concerns, frameworks, I/O, persistence, HTTP, UI bindings, and external integrations in Infrastructure or Presentation adapters.
- Dependencies must point inward: Presentation and Infrastructure may depend on Application and Domain, but Domain must not depend on framework or delivery details.
- On the frontend, do not place business rules directly in components, pages, stores, or framework-specific files when they belong to the domain or use-case level.
- Reuse existing patterns unless this FastFlow explicitly introduces a better and justified evolution.
- Avoid shortcuts that would block later evolution from MVP to V1 or V2.

## Test strategy

- Test business rules, domain invariants, and functional use cases first.
- Prefer tests that validate observable behavior and user-relevant outcomes.
- Do not add purely technical tests for framework glue, trivial mapping, generated code, or passive adapters unless they protect an essential risk.
- On the frontend, prioritize tests for user flows and business behavior over component internals.
- On the backend, prioritize tests for use cases, domain rules, and functional contracts over framework wiring.
- If a technical test is added, justify why the risk is essential.

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

- [ ] Feature behavior matches all requirements.
- [ ] Onion boundaries are respected across the impacted layers.
- [ ] Business rules and functional flows are covered by relevant tests.
- [ ] No purely technical tests were added unless they protect an essential risk.
- [ ] No lint, type, or build errors remain.
- [ ] Deferred items are documented in Not now or Follow-ups.

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