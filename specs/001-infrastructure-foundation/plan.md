# Implementation Plan: Infrastructure Foundation

**Branch**: `001-infrastructure-foundation` | **Date**: 2026-11-24 | **Spec**: [spec.md](spec.md)
**Status**: Planning complete with blocking verification/owner decisions; no deployment authorized.

## Summary

Plan parameterized Bicep provisioning for App Service hosting, Document Intelligence,
Microsoft Foundry with the selected Microsoft-Decision-1.1 model and Data Zone Standard
deployment type at one initial capacity unit, Azure Blob Storage
for source PDFs, and Azure Database for PostgreSQL flexible server for PDF-extracted
rules. The initial topology is one development/test environment and a new resource
group. First prepare, validate, preview and estimate; after the owner
signs in and separately approves the exact reviewed deployment, the assistant deploys
and records per-purpose status. This plan does not authorize implementation exceptions,
provisioning, paid use, application access configuration, recovery, database schema design,
application logic, or application readiness.

## Technical Context

- **Language/version**: Bicep/ARM; Azure CLI and PowerShell for operator commands.
  Existing Python requirement is >=3.14 (`.python-version`: 3.14). App Service's
  official Python guidance illustrates 3.14, but target runtime availability must be
  checked; do not silently downgrade the project requirement. Application framework,
  TypeScript tooling and compatibility are deferred to the application feature.
- **Dependencies**: Azure CLI with Bicep CLI; App Service Linux and plan; Document
  Intelligence account; Microsoft Foundry resource and Microsoft-Decision-1.1 model
  deployment; general-purpose v2 Blob Storage for source PDFs; Azure Database for
  PostgreSQL flexible server for extracted rules. Exact API versions and target
  compatibility are to be verified during implementation.
- **Persistence**: Blob Storage retains source PDFs; PostgreSQL is the planned durable
  store for PDF-extracted rules. Do not create a second blob container for rule artifacts.
  PostgreSQL uses a public endpoint with no allowed IP addresses initially; client
  connectivity is separate work. Use Entra-only database authentication and designate
  the owner-selected signed-in account as the initial PostgreSQL administrator. Use a
  single server without an HA standby, with the smallest, cheapest supported development
  compute and storage; development interruptions are acceptable. Verify
  deployment support without adding a password. This plan defines no database schema,
  rule-ingestion behavior, application access, or recovery policy. Blob versioning, if selected for
  source documents, is not by itself an immutability or recovery guarantee.
- **Validation**: Bicep build/lint, Azure provider validation and change preview, and
  post-deployment resource status checks. No separate automated test suite is planned;
  live deployment checks only after authorization.
- **Target platform**: Azure public cloud, owner-selected subscription and East US 2
  planning target, subscription-scope deployment creating a new resource group with
  resource-group-scoped service deployment; Linux App Service. The chosen group is
  `rg-compilation-decision-dev-eus2` and the resource-name prefix is `cdm-dev`.
  Selection does not approve deployment.
- **Project type**: Infrastructure-only feature for a future web application.
- **Performance/scale**: No SLA or peak-traffic target was supplied; do not assert
  capacity or price. For cost estimation, assume 2 PDFs per month at 20 pages each and
  500 model calls per month at 500 input tokens per call; these are not usage limits.
  One development/test environment is in scope; production is not.
  Propose the lowest-cost supported options suitable for development and show their
  estimated cost before approval, without waiving required security controls. The owner
  set an estimated monthly ceiling of USD 150; exceeding it blocks approval. This is
  not an automatic spending cap or a budget-alert requirement.
- **Constraints**: No paid usage or provisioning while planning; no unauthenticated
  resource exposure or credential disclosure. Exact SKU, configuration and security
  posture require verification before deployment. Catalog and quota checks are
  preliminary; final capacity and cost remain unknown. Public endpoints are selected; App Service app and deployment endpoints
  deny inbound traffic initially, cloud services use Entra authentication where
  supported, and anonymous blob access is disabled. If a tier lacks Entra-only support,
  select the next-cheapest compatible tier within budget or stop for owner review.
  Application user permissions and recovery are separate work; initial database
  administrator configuration is included.

## Constitution Check

| Gate | Before research | After design |
|---|---|---|
| Accessible TypeScript frontend, Python proxy, validated API | Not applicable: application is out of scope; required in its future feature. | Same; no frontend or application-to-cloud access is configured. |
| PDF provenance, rule validation/activation and immutable versions | Not applicable to implementation here; persistence must support later design. | PostgreSQL is planned for extracted rules and Blob for source PDFs; neither resource choice by itself enforces provenance, validation, activation, or immutable rule versions. Those behaviors and schema remain future application work. |
| Boolean outcomes, localization and budgets | Not applicable: application behavior deferred, not waived. | Same. |
| Model identity, suitability, API, region, quota and deployment support; App Service runtime | **BLOCKED** pending research and target details. | Microsoft documentation identifies Microsoft-Decision-1.1, version 1, as suitable for classification and binary decisions through the Decision API; `noul` returns a probability. The selected subscription lists the model and quota in candidate regions; exact Bicep deployment/API-version compatibility and target validation remain unverified. Application-specific threshold and measured decision quality belong to the later application feature, not infrastructure provisioning. No substitute is authorized. |
| PostgreSQL persistence, service support and cost | **BLOCKED** pending research and target details. | Azure Database for PostgreSQL flexible server is a documented managed PostgreSQL service with Bicep support. East US 2 is the chosen planning target; exact engine version, compute tier/SKU, storage sizing and resulting cost remain unverified. Entra-only authentication and an initial administrator are included; no schema or recovery policy is included. |
| Bicep services, justified support, validation, preview and checks | Planned, subject to model and target verification. | Design covers required purposes; exact Bicep model-deployment compatibility must still be validated. Under the accepted draft infrastructure-only amendment, report frontend/API/PDF/model checks as blocked until the application and required access exist; the application deployment must perform them. |
| Focused tests and live model honesty | No model-quality claim. | Infrastructure is validated through Bicep, provider checks, preview and deployment status; no separate automated tests are planned. |
| Independent test author/runner | Required if tests are added. | No separate tests planned; if added, an independent tester authors and runs them. |
| Deployment and compatibility | User has not confirmed deployment. | No compatibility shims needed; after confirmation assess affected consumers/contracts and obtain breaking-change approval. |
| Simplicity and security | Planned with minimum provisioning controls. | One storage account for source PDFs and one PostgreSQL server for extracted rules; initial endpoint restrictions, service authentication, and a database administrator are in scope. No waiver of managed identity, least privilege, secret safety, access control or redacted logs before use. |
| Overall | **BLOCKED**, not an approved exception. | **ERROR / BLOCKED** for model-dependent implementation and deployment until evidence and owner decisions below resolve the gate. |

Other app-specific constitution requirements (retention/deletion, authentication,
authorization, PDF limits, execution budgets and redacted operational logs) are deferred
to the features that introduce those behaviors. No real data or non-local app use until
the required security and policy work is complete.

## Project Structure

### Documentation

```text
specs/001-infrastructure-foundation/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/provisioning.md
└── quickstart.md
```

### Planned implementation (not created by planning)

```text
infra/
├── main.bicep                 # subscription-scoped resource group and composition
├── modules/                   # only if needed for clarity
└── parameters/                # environment parameters; no secrets
```

**Structure Decision**: Keep infrastructure separate from the existing Python starter;
do not create application source, application user access configuration or recovery code.

## Phase 0: Research

See [research.md](research.md) for cited service, storage, deployment and cost choices.
Evidence does not resolve subscription-specific questions; do not convert unknowns into
assumptions or select an unsupported model.

## Phase 1: Design

See [data-model.md](data-model.md), [provisioning contract](contracts/provisioning.md)
and [quickstart.md](quickstart.md). The contract separates static validation, signed-in
preview, owner approval, deployment and status reporting. Cloud output is never a
substitute for application health.

## Phase 2: Implementation Planning (no implementation)

1. Use the owner-selected Azure public cloud subscription, East US 2 planning target,
   resource naming and workload assumptions. Propose lowest-cost supported development
   SKUs and present the estimate to the owner.
2. Verify service/SKU/runtime compatibility and record evidence. For
   Microsoft-Decision-1.1, verify the documented typed-decision API supports the
   intended class of task, selected-region availability, actual subscription quota,
   and exact Bicep deployment compatibility. The later application feature must define
   and validate the threshold and decision quality; those are not infrastructure tasks.
   If the selected model
   cannot be used and an alternative is proposed, obtain explicit owner approval and
   document the rationale before changing the model.
   Verify PostgreSQL version, region, compute tier/SKU, storage, availability choice,
   monitoring and maintenance needs against the workload and target.
3. Implement scoped Bicep with parameters and outputs conforming to the contract.
   Do not add a custom review tool, configure application access or recovery, create
   application logic, or add unneeded resources.
4. Run Bicep build/lint and signed-in provider validation, then produce complete what-if and
   estimated costs. Treat incomplete/uninterpretable preview as blocked; explicitly flag
   potential replacement/deletion of persistent resources.
5. Present the exact preview, cost, configuration and blockers; separately obtain explicit
   owner approval. Only then may the assistant deploy the approved configuration, collect
   status for all five purposes and report application checks as blocked until available.
   Any material change requires a fresh preview and approval.

## Owner Decisions and Blockers

- Verify remaining East US 2 service capacity, resource-name availability and policy.
- Identify realistic usage volumes and choose supported development SKUs so costs can be
  estimated, including PostgreSQL compute/storage and any optional high availability.
  Present assumptions and pricing to the owner for review. Retention, access and
  recovery decisions are separate work, not silently defaulted or implemented here.
- Verify Microsoft-Decision-1.1's target region/deployment type, actual quota and
  exact Bicep deployment support. The later application feature must establish the
  decision threshold and measured task-specific quality before application use.
  If a different model or deployment mechanism is needed, obtain explicit owner approval
  and document the rationale under the constitution; do not silently substitute.
- Approve the actual deployment only after sign-in, validation, review of complete
  change preview and cost. No approval has been given.
- The repository has no agent-context update script. Its absent script could not be run;
  the required marker update was made directly.

## Complexity Tracking

No constitution exception is requested. The model verification gate is blocked, not waived.
