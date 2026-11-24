# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] TypeScript frontend follows accessible, Foundry-inspired UX; Python serves its
  built assets and proxies cloud calls through a validated application API.
- [ ] PDF-derived rules have document/page provenance, validation/activation semantics,
  and immutable versions shared by initial classification and localization.
- [ ] Only validated `true` starts same-model binary localization; both halves, original
  offsets, context interactions, errors, incomplete results, and execution budgets are defined.
- [ ] Exact model identity, suitability, API, region, quota, deployment support, and
  App Service runtime compatibility are verified against current official sources.
  Any non-Microsoft model or deployment deviation has explicit approval.
- [ ] Bicep covers Document Intelligence, App Service, Foundry, model deployments, and
  justified supporting resources; validation, change preview, and smoke checks are planned.
- [ ] A few tests verify changed user outcomes, not coverage or test-count targets;
  edge cases have a requirement, regression, or material user-risk rationale. Model doubles
  are not evidence of real-model quality; any live evaluations are opt-in.
- [ ] An independent subagent generates and runs tests using only relevant outcomes,
  acceptance criteria, public contracts, commands, and file locations. The implementation
  agent owns production code and fixes; the tester does not modify production code.
- [ ] Deployment status comes from explicit user confirmation. Before confirmation,
  no backward-compatibility shims or deprecation windows are required; update current
  callers and contracts together. After confirmation, identify deployed consumers/data
  contracts and obtain approval for breaking changes or migrations.
- [ ] The simplest implementation is selected: inline simple logic, extract shared methods
  after more than three uses, and avoid speculative defenses or redundant internal validation.
  Required input/access controls, execution limits, accessibility, and redacted telemetry remain.
- [ ] All applicable gates pass; any exception has documented rationale and owner approval.
  Mark a gate not applicable only with a feature-specific explanation.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
