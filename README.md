# FastFlow

FastFlow is a Spec Kit extension for teams who want a single-file workflow that stays lightweight but is still strong enough for MVP-ready feature increments.

It sits between tiny one-off changes and the full Spec-Driven Development workflow:

- Tiny changes can stay tiny.
- Feature increments use one durable FastFlow file.
- Large or ambiguous work escalates to full SDD.

## Commands

- `speckit.fastflow.classify`: classify the task and recommend the right workflow.
- `speckit.fastflow.create`: generate a single FastFlow file under `specs/fastflow/`.
- `speckit.fastflow.implement`: implement directly from a FastFlow file.

## Positioning

Use FastFlow when:

- you want speed,
- you want one main file instead of separate spec, plan, and tasks files,
- you are building MVP increments that should evolve into V1 and V2,
- you still need architecture guardrails and explicit scope boundaries.

Use full SDD when:

- scope is broad,
- architecture is unstable,
- multiple independent stories need coordinated planning,
- discovery and clarification are required.

## Architectural stance

FastFlow assumes Onion Architecture for both backend and frontend work.

- Domain contains business rules and invariants.
- Application orchestrates use cases.
- Infrastructure handles technical adapters.
- Presentation handles delivery concerns and UI interaction.

Dependencies must always point inward.

## Testing stance

FastFlow prioritizes business and functional testing.

- Test domain rules, use cases, and critical user flows first.
- Avoid purely technical tests for framework glue, trivial adapters, or passive wiring.
- Add technical tests only when they protect an essential risk.

## Typical workflow

1. Start with `speckit.fastflow.classify`.
2. Run `speckit.fastflow.create` for focused feature increments.
3. Review the generated file.
4. Run `speckit.fastflow.implement`.
5. Split deferred work into later FastFlow increments.