<!--
Sync Impact Report
Version: 1.1.0
Modified guidance: Technology and Deployment Constraints: infrastructure-only deployments
may defer application checks until the application is deployed.
Amendment impact: approved by the project owner; no deployed consumers or data
contracts identified. Infrastructure-only deployments must still validate, preview,
obtain approval, verify resource status and report blocked application checks. No
migration or exception is required; application deployments retain all required checks.
Added sections: None
Removed sections: None
Dependent artifacts:
- Updated: .specify/templates/plan-template.md, .specify/templates/tasks-template.md,
  specs/001-infrastructure-foundation/spec.md, specs/001-infrastructure-foundation/plan.md,
  and specs/001-infrastructure-foundation/tasks.md.
Follow-up TODOs: None in the constitution.
Planning decisions: model identity and availability, authentication, retention, rule approval,
localization semantics, and numeric execution budgets must be resolved before implementation.
-->
# Compilation Decision Model Constitution

**Status**: Approved

## Core Principles

### I. Foundry-Inspired Frontend and Python Proxy

The application MUST provide a TypeScript frontend with a Microsoft Foundry-inspired
visual hierarchy, navigation, spacing, and interaction patterns, using original or
appropriately licensed assets. It MUST support keyboard navigation, accessible labels,
and explicit loading, empty, success, and error states.

The Python backend MUST serve the built frontend and act as the sole application proxy
to document extraction and decision-model services. The browser MUST NOT receive cloud
credentials or call these services directly. Frontend and backend MUST use a documented,
validated API contract rather than exposing an unrestricted LLM proxy.

### II. Traceable PDF-Derived Rules

Azure AI Document Intelligence MUST extract the content of rule PDFs. The rule-processing
pipeline MUST turn extracted content into an explicit, versioned rule set and retain
source document identity, page references, and supporting extracted text for each rule.
Extraction and rule validation failures MUST be visible; missing or ambiguous rules
MUST NOT be silently invented or activated. The specification MUST define the rule
validation and activation procedure.

Every classification and localization run MUST reference the same immutable rule-set
version. Uploaded documents and submitted text MUST be treated as untrusted data, not
as instructions that can override application policy.

### III. Faithful Classification and Bounded Localization

The backend MUST classify the submitted text against the active rule set using a decision
model with a validated boolean result. Only an explicit `true` result MUST initiate
binary-search localization. A `false` result MUST skip localization. Malformed responses,
timeouts, and service failures MUST remain errors rather than being coerced to `false`.

Localization MUST recursively divide candidate text spans and evaluate them with the
same decision-model deployment, model version, decision instructions, rule-set version,
and inference configuration used for the initial classification. Both halves MUST be
eligible for evaluation so multiple positive regions are not discarded. Returned words
or spans MUST map to exact offsets in the original text, including repeated occurrences.

The specification MUST define tokenization, context preservation, terminal span size,
and handling of multiword interactions. Binary search MUST NOT assume that an LLM
predicate is monotonic: if neither half reproduces a positive parent, or results are
inconsistent, the application MUST report contextual or unresolved localization rather
than invent an offending word. Localized spans MUST be labeled as model-supported
evidence, not proof of causality or exhaustive identification.

Every run MUST have explicit limits for input size, model calls, retries, and elapsed
time, with cancellation and visible incomplete status when localization stops early.

### IV. Reproducible Azure Infrastructure

Bicep MUST define Azure AI Document Intelligence, Azure App Service hosting the Python
backend and built frontend, and Microsoft Foundry resources and decision-model
deployments. Additional resources MUST have a documented functional or operational need.
Environment-specific resource names, regions, SKUs, and model choices MUST be parameters,
not embedded credentials or undocumented portal configuration.

Microsoft decision models are the preferred choice. Before selecting a deployment, the
plan MUST verify the exact model identity, decision-task suitability, API compatibility,
regional availability, quota, and deployment support using current official sources.
An alternative model or deployment mechanism MUST receive explicit approval and a
documented rationale; no model name or Bicep capability may be assumed to exist.

### V. User Outcomes, Simplicity, and Safe Operations

Testing MAY be used sparingly to verify user outcomes, not code coverage, test counts,
or other proxy metrics. Changed behavior MAY have a few focused automated tests that
would fail without the change. Prefer the primary user journey and only edge cases tied
to a stated requirement, a known regression, or a credible failure with material user
impact. Tests MUST NOT merely restate implementation details or test framework behavior.
One outcome test may satisfy multiple requirements; do not duplicate it across test layers.

Tests MUST be generated and run by a separate subagent that did not implement the
production code under test. Give it only the relevant user outcomes, acceptance criteria,
public contracts, test commands, and file locations needed for the task. It may inspect
additional narrowly scoped context when necessary, but MUST NOT receive the full coding
conversation, implementation rationale, or suggested assertions derived from the solution.
Its expected results MUST come from requirements, not from copying current behavior.

The implementation agent MUST retain responsibility for production code, integration,
and fixing failures. The testing subagent MUST report commands, results, and user-outcome
failures without modifying production code. The implementation agent MUST NOT weaken
tests to fit its implementation; genuine requirement conflicts MUST be raised for a user
decision. Documentation-only changes need no tests unless documentation tests exist.

For classification, prioritize whether users receive the right decision and useful
localization. Deterministic model doubles may verify orchestration but MUST NOT be
presented as evidence of actual model quality. Quality claims about real-model behavior
MUST identify the evaluated rule set, model configuration, and measured user outcomes;
live checks MUST remain opt-in.

Implementation MUST prefer the simplest option that satisfies the requirement. Keep
simple logic inline where practical; extract a shared method when the same logic is
used more than three times. Do not introduce helpers or abstractions for hypothetical
reuse. Defensive checks MUST be limited to trust boundaries, explicit contracts, and
known failure modes; do not repeatedly revalidate trusted internal data or add speculative
fallbacks and edge-case machinery. Simplicity MUST NOT suppress errors or remove required
security controls, boolean-result validation, or execution limits.

The application MUST validate inputs and enforce access control before non-local use.
Cloud service access MUST use managed identity and least-privilege roles where supported.
Any required secret MUST remain server-side in an approved secret store or secure
configuration, never source control or frontend bundles. Logs MUST record correlation
IDs, rule/model versions, durations, call counts, and failure categories without raw
documents, submitted text, model prompts, or credentials by default.

## Technology and Deployment Constraints

- TypeScript is the frontend language; Python is the backend language; Bicep is the
  infrastructure language. Frameworks and compatible runtime versions MUST be selected
  and recorded in the implementation plan, including App Service runtime support.
- Production flows MUST use Document Intelligence and Foundry-backed decision inference.
  Test doubles MUST be isolated from production paths and explicitly identified.
- The specification MUST define authentication, authorization, file and text size limits,
  supported PDF handling, data retention/deletion, and numeric latency and call budgets.
- Deployment MUST include Bicep validation, change preview, explicit deployment approval,
  and post-deployment checks. Infrastructure-only deployments MUST verify provisioned
  resource status and explicitly report unavailable application checks as blocked.
  When application functionality is deployed, post-deployment checks MUST cover frontend
  serving, API health, PDF extraction, and model access. This constitution does not
  authorize resource provisioning or paid service use.
- The project MUST be treated as not deployed until the user explicitly confirms it is
  deployed. Before that confirmation, backward compatibility is NOT a requirement:
  prefer direct changes over compatibility shims, legacy interfaces, or deprecation
  windows. Update affected call sites and contracts together to keep the current app
  working. After confirmation, plans MUST identify deployed consumers and data contracts
  affected by a change and obtain approval for breaking changes or required migrations.

## Development Workflow and Quality Gates

1. Specifications MUST define observable outcomes for rule ingestion, classification,
   localization, and UI states where relevant, including failure and incomplete results.
2. Plans MUST pass a Constitution Check before research and again after design. Unknown
   model capabilities and behavioral choices MUST be resolved before affected code is
   implemented; exceptions MUST be recorded with rationale and approval.
3. Tasks MAY use tests, and if they do, they MUST select the smallest set of tests and validation steps that demonstrates
   the changed user outcome. Do not generate a test per method, branch, contract, or
   test layer by default. Bug fixes MUST reproduce the user-visible failure where practical.
   Assign test generation and execution to an independent subagent with minimal relevant
   context; the implementation agent owns production changes and fixes.
4. Reviews MUST verify type checking/builds, user-outcome tests, rule provenance, model/rule
   consistency, bounded execution, safe error handling, and documentation alignment.
   Reviews MUST reject coverage-driven tests, speculative defensive code, and unnecessary
   indirection; prefer inline logic and extract shared methods after more than three uses.
5. Changes MUST remain scoped to the approved feature. Additional services, persistence,
   or architectural layers MUST be justified rather than introduced speculatively.

## Governance

This constitution is the project's authoritative engineering policy. Specifications,
plans, tasks, implementation, and reviews MUST comply with it. Contributors MUST use
the current feature plan and [README.md](../../README.md) for runtime guidance.

Amendments MUST document the proposed change, rationale, impact on existing features,
migration or exception handling, and project-owner approval. An amendment MUST update
the Sync Impact Report and all affected templates and guidance in the same change.
Reviews MUST identify violations; unapproved exceptions block the affected delivery.

Draft editing MUST NOT advance the version or amendment date. The implementation agent
MUST apply version bumps only as part of Git commits it makes for explicitly accepted
amendments. The initial committed constitution MUST use version 1.0.0.

Accepted amendments MUST follow semantic versioning: MAJOR for incompatible principle removal or
redefinition, MINOR for new principles or materially expanded guidance, and PATCH for
non-semantic clarification. Ratification remains the original adoption date; the
amendment date MUST change in the commit recording an accepted amendment.

**Version**: 1.1.0 | **Ratified**: 2026-11-24 | **Last Amended**: 2026-11-24
