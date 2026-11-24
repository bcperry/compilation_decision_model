<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current
[implementation plan](../specs/001-infrastructure-foundation/plan.md).
<!-- SPECKIT END -->

Follow the [project constitution](../.specify/memory/constitution.md) and its mandatory
quality gates. Until a feature plan exists, use the [project overview](../README.md);
do not invent model availability, deployment support, or unresolved decision semantics.

Use a few user-outcome tests, not code-coverage targets or exhaustive edge-case matrices.
Choose the simplest implementation, inline simple logic where practical, and extract
shared methods when the same logic is used more than three times. Avoid speculative
defensive code while preserving trust-boundary validation and visible errors.

Have an independent subagent generate and run tests, with only relevant user outcomes,
acceptance criteria, public contracts, commands, and file locations. Do not pass the full
coding conversation or solution-derived assertions. The implementation agent owns
production code and fixes; the tester does not modify production code.

Backward compatibility is not required until the user explicitly confirms deployment.
Before then, prefer direct changes over legacy shims, keeping current callers/contracts
consistent. After confirmation, obtain approval for breaking deployed contracts or migrations.

Keep constitution version 1.0.0 during initial drafting. The implementation agent applies
version bumps and amendment dates only as part of Git commits it makes for explicitly
accepted amendments. Do not record drafting mistakes as release history.
