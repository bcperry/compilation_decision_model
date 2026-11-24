# Tasks: Infrastructure Foundation

**Scope**: One development environment in Azure public cloud, with a new resource group
in East US 2. Provision App Service, Document Intelligence, Microsoft Foundry with
Microsoft-Decision-1.1, Blob Storage for source PDFs, and PostgreSQL for rules.
Application code, data schemas, application user permissions, and recovery are separate
work; initial endpoint controls and the PostgreSQL administrator are included.

**Already checked**: The owner selected the subscription and East US 2 for planning;
Microsoft.Web is registered. Candidate service SKUs and model quota were listed.
See [research.md](research.md) for evidence and remaining limits.

## Setup

- [ ] T001 Create `infra/main.bicep` and `infra/parameters/dev.bicepparam` for a subscription-scoped deployment that creates a new resource group; parameterize names, region, SKUs, model settings and simple project/environment tags without embedding credentials.

## User Story 1: Application infrastructure

**Outcome**: Bicep defines hosting, document extraction, and the decision-model deployment.

- [ ] T002 [US1] Define the App Service plan, Linux app, Document Intelligence resource, Foundry resource, and Microsoft-Decision-1.1 Data Zone Standard deployment with one initial capacity unit in `infra/main.bicep` or supporting `infra/modules/` files. Use public endpoints with App Service app and deployment traffic denied initially, and Entra authentication for cloud services where supported. Verify model deployment compatibility; do not silently substitute another model or deployment type.

## User Story 2: Storage infrastructure

**Outcome**: Bicep defines storage for PDFs and PostgreSQL for extracted rules.

- [ ] T003 [P] [US2] Define public-endpoint Blob Storage and a source-PDF container in `infra/modules/pdf-storage.bicep`, with anonymous blob access disabled and Entra authentication where supported; no application ingestion or rule storage in Blob is required.
- [ ] T004 [P] [US2] Define a parameterized PostgreSQL flexible server in `infra/modules/postgresql.bicep`; select the smallest, cheapest supported development compute and storage, no HA standby, a public endpoint with no allowed IPs, Entra-only authentication and the signed-in account as initial administrator. Verify service support; do not add a schema, recovery workflow, or embedded credentials.
- [ ] T005 [US2] Connect the storage resources to `infra/main.bicep` and `infra/parameters/dev.bicepparam`, with non-secret outputs sufficient to identify all resources.

## Validate and deploy

- [ ] T006 Build and lint `infra/main.bicep`; validate it and `infra/parameters/dev.bicepparam` against Azure, recheck required service availability, model deployment support and quota, and review subscription-scope what-if including the new group and persistent-resource changes. Stop on failed or incomplete validation.
- [ ] T007 Present the preview and a sourced estimate for `infra/parameters/dev.bicepparam`, including fixed and usage-based costs and assumptions; propose the lowest-cost supported configuration within the USD 150/month estimate-review ceiling and obtain the owner's explicit approval before deployment. This ceiling is not an automatic spending cap. Stop if the estimate exceeds it; renew approval if the configuration changes.
- [ ] T008 After T006–T007 pass and the owner approves, deploy `infra/main.bicep` with `infra/parameters/dev.bicepparam`; report each resource as provisioned, failed, or blocked. Report frontend, API health, PDF extraction and model connectivity checks as blocked until the application and required access exist.
- [ ] T009 Document the parameters, validation, deployment, cost assumptions, and status checks in `infra/README.md`; keep secrets out of documentation and source control.

## Dependencies

T001 precedes T002–T005. T002, T003 and T004 can be developed independently; T005
integrates storage after T002–T004. T006–T007 require the complete configuration; T008 requires all
validation and explicit approval. T009 accompanies the work. No separate automated
test suite is planned; build/lint, provider validation, preview and deployment status
checks verify this infrastructure. If a chosen tier lacks Entra-only support, choose
the next-cheapest compatible tier within budget or stop for owner review. Live or paid
checks require authorization, and infrastructure provisioning does not establish
application readiness. Model thresholds and quality evaluation belong to the
application feature.
