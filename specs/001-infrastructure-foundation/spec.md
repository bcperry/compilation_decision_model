# Feature Specification: Infrastructure Foundation

**Feature Branch**: `001-infrastructure-foundation`<br>
**Created**: 2026-11-24<br>
**Status**: Draft<br>
**Input**: Establish the infrastructure needed for the compilation decision model, including a place for rule documents and durable storage for rules; identify other necessary infrastructure.

## Clarifications

### Session 2026-11-24

- Q: Should the deployment use an existing resource group or create one? → A: Create a new resource group.
- Q: Which Azure cloud should the infrastructure target? → A: Azure public cloud.
- Q: What is the first environment for? → A: Development and testing.
- Q: How should the deployment region be selected? → A: The assistant selects a region
  for owner review after verifying required services, the selected model, and quota.
- Q: How should the development environment be sized for cost? → A: Choose the
  lowest-cost supported options suitable for development and review the estimate
  before deployment.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prepare the infrastructure (Priority: P1)

As the project owner, I want the assistant to prepare the foundational environment after
I sign in and approve deployment, so the application can eventually host its interface,
extract rule documents, and use an approved decision model.

**Why this priority**: The application cannot be deployed reliably without these core
capabilities and a controlled approval process.

**Independent Test**: Review the proposed environment and its change preview, approve
a deployment separately, and verify that the required resources have been provisioned.

**Acceptance Scenarios**:

1. **Given** valid environment settings and verified service availability, **When** the
   assistant validates and previews the proposed changes, **Then** the expected resources
   and estimated ongoing costs are presented to the owner without creating resources.
2. **Given** the owner has signed in and explicitly approved deployment, **When** the
   assistant prepares the environment, **Then** the hosting, document extraction,
   decision-model, document storage, and rule persistence resources can each be checked
   independently and their provisioning status is reported.
3. **Given** an unavailable service, unsupported model deployment, insufficient quota, or
   failed preparation step, **When** provisioning is assessed, **Then** the affected
   resource is reported as blocked or failed with a reason.
4. **Given** a reviewed deployment and explicit approval, **When** the assistant
   prepares the environment, **Then** a new resource group is created for its resources.

---

### User Story 2 - Provide storage for future application data (Priority: P1)

As a project operator, I need infrastructure for storing rule documents and rules so
future application features have a durable place for their data.

**Why this priority**: Document and rule persistence are foundational capabilities that
must be considered alongside hosting and decision services.

**Independent Test**: Review the storage design and verify that the approved deployment
provisions the resources identified for documents and rules.

**Acceptance Scenarios**:

1. **Given** the proposed environment, **When** the storage design is reviewed,
   **Then** it identifies the resources intended for rule documents and rules and
   explains whether a database is needed.
2. **Given** explicit approval, **When** the environment is deployed, **Then** the
   identified storage resources are provisioned and their status is reported.
3. **Given** an existing environment, **When** configuration changes are previewed,
   **Then** any proposed deletion or replacement of persistent resources is visible
   before approval.

### Edge Cases

- An approved model or its required deployment is unavailable in the selected region,
  or quota is insufficient: report the blocker rather than claiming model provisioning
  or silently substituting another model.
- Reapplying configuration proposes replacement or deletion of persistent resources:
  flag the destructive change for review and do not proceed without explicit approval.
- A resource fails to provision: identify the affected resource and report the failure
  rather than presenting the environment as fully provisioned.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST define a repeatable, environment-parameterized way to
  provision the hosting, rule-document extraction, decision-model, document storage,
  and rule persistence resources required by this feature.
- **FR-002**: Before any deployment, the assistant MUST validate the proposed
  configuration and present the change preview and estimated cost to the owner.
  Actual provisioning and paid service use MUST require the owner's explicit approval.
- **FR-003**: The environment MUST provision durable storage intended for source rule
  documents in Azure Blob Storage.
- **FR-004**: The environment MUST provision PostgreSQL for PDF-extracted rules.
  The design MUST explain how the chosen persistence resources can support future rule
  versions and source references.
- **FR-005**: The change preview MUST identify proposed deletion or replacement of
  persistent resources; such changes MUST NOT proceed without explicit approval.
- **FR-006**: Microsoft-Decision-1.1 is the selected model candidate. Before its
  deployment is implemented or used, the project MUST verify
  model identity, suitability for the decision task, service compatibility, regional
  availability, quota, and deployment support against current official sources.
  Microsoft decision models are preferred; an alternative requires explicit approval
  and a documented rationale.
- **FR-007**: Provisioning results MUST identify each required resource as provisioned,
  failed, or blocked, with the reason for any failure or blocker.
- **FR-008**: The environment configuration MUST identify each resource's functional or
  operational purpose and document environment-specific settings, dependencies, and
  any manual prerequisites.
- **FR-009**: Application-dependent post-deployment checks for frontend serving, API
  health, PDF extraction, and model connectivity MUST be reported as blocked until the
  application and required access are available; provisioning alone MUST NOT be
  represented as a successful application check. The application deployment MUST
  perform these checks when its functionality is available.
- **FR-010**: Once the owner has signed in and approved deployment, the assistant MUST
  execute the deployment and report the resulting provisioning status and any blockers.
- **FR-011**: The deployment MUST create a new resource group for the environment;
  its creation MUST be included in the change preview and require explicit approval.
- **FR-012**: The environment MUST target Azure public cloud.
- **FR-013**: The initial deployment MUST provision one development and testing
  environment; production environments are outside this feature.
- **FR-014**: After sign-in, the assistant MUST propose a region for owner review based
  on verified availability of the required services, selected model, and quota; an
  unavailable or unverified requirement MUST be reported as a blocker.
- **FR-015**: The proposed configuration MUST use the lowest-cost supported options
  suitable for development and MUST include their estimated cost for owner review
  before deployment, without waiving required security controls.
- **FR-016**: App, storage, extraction, and model endpoints MUST be public. The app
  and deployment endpoints MUST deny inbound traffic initially; anonymous blob access
  MUST be disabled, and storage, extraction, and model services MUST use Microsoft
  Entra authentication where supported.
- **FR-017**: PostgreSQL MUST use Entra-only authentication with the signed-in account
  as initial administrator, a public endpoint with no allowed IP addresses, and no
  high-availability standby.
- **FR-018**: The deployment estimate MUST remain within USD 150 per month using the
  documented workload assumptions; this is a review ceiling, not an enforced spending cap.

### Key Entities

- **Environment**: A named deployment context with settings, resources, cost
  expectations, and provisioning results.
- **Infrastructure resource**: A provisioned service with an identified purpose,
  configuration, and provisioning status.

### Decision Workflow and Operational Constraints *(mandatory when applicable)*

- This feature provisions infrastructure only. Initial endpoint restrictions, service
  authentication settings and the PostgreSQL administrator are included; application
  user access configuration, recovery,
  operational workflows, data schemas, document and rule ingestion, rule approval or
  activation, classification, localization, and UI are out of scope.
- The application features that implement those workflows must separately define
  boolean decision and error outcomes, rule validation and activation, localization
  semantics, execution limits, user authentication, and accessible UI states.
- The constitution's traceability and immutable-version requirements inform selection
  of persistence resources; implementing and verifying those data behaviors is separate.
- Provisioning does not establish readiness for real data or non-local application use.
  The constitution's access, managed identity, least-privilege, secret handling,
  retention, and other security requirements remain applicable when those capabilities
  are implemented; this feature does not waive them.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For an approved test deployment, all five foundational resource purposes
  (hosting, extraction, decision model, document storage, and rule persistence) have
  recorded provisioning results; none is silently omitted.
- **SC-002**: The documented design identifies storage for both documents and rules
  and explains the selection of PostgreSQL for rules.
- **SC-003**: In a provisioning exercise, 100% of failed or blocked resources are
  identified and do not appear as successfully provisioned.
- **SC-004**: An operator can locate the deployment preview, estimated cost, approval
  gate, and provisioning results within 15 minutes using the project documentation.

## Assumptions

- This is an infrastructure-only feature; application functionality, access
  configuration, recovery, and live model-quality evaluation are separate work.
  Application-dependent checks may remain blocked until that functionality exists.
- The constitution mandates Azure App Service, Azure AI Document Intelligence,
  Microsoft Foundry, and Bicep. The owner selected Microsoft-Decision-1.1 and
  PostgreSQL; exact service configurations, pricing, and availability remain subject
  to documented need, verification, and approval.
- The owner will sign in to an appropriate Azure environment for the assistant to use;
  the target environment and available permissions must be confirmed before deployment.
  No deployment or paid usage is authorized by this specification.
- The owner selected East US 2 for planning and validation; deployment still requires
  verification, cost review, and explicit approval.
- The selected model deployment type is Data Zone Standard with one initial capacity
  unit; occasional development throttling is acceptable. Provider validation and cost
  review are still required.
- The development environment has a maximum estimated budget of USD 150 per month;
  propose the lowest-cost supported options and obtain approval before deployment.
  This is an estimate-review ceiling, not an automatic spending cap or alert.
- Cost estimates assume 2 PDFs per month at 20 pages each, and 500 decision-model calls
  per month at 500 input tokens per call; these are estimates, not enforced limits.
- Use `rg-compilation-decision-dev-eus2` for the resource group and `cdm-dev` as the
  resource-name prefix, with unique suffixes where required.
- Use simple project and environment tags; provider and policy validation may identify
  additional requirements.
- PostgreSQL will use a public endpoint with no allowed IP addresses initially;
  connectivity will be configured in a later feature.
- PostgreSQL will use Microsoft Entra authentication only, with the signed-in account
  as its initial administrator; no PostgreSQL administrator password is needed.
- The app, storage, extraction, and model endpoints will be public, with appropriate
  access controls. App Service will deny inbound app and deployment-endpoint traffic
  until application access is designed.
- Storage, extraction, and model services will use Microsoft Entra authentication where
  supported, with anonymous blob access disabled. Application service permissions will
  be configured later. If the cheapest tier lacks Entra-only support, choose the next
  cheapest compatible tier within the budget; otherwise stop for owner review.
- The development database will use a single server without a high-availability standby;
  interruptions are acceptable. Select the smallest, cheapest supported development
  compute and storage configuration after checking availability and pricing.
- The first deployment is for development and testing, not production readiness.
- Deployment status remains not deployed until explicit user confirmation; backward
  compatibility is not required before that confirmation. After confirmation, identify
  affected deployed consumers and data contracts and approval needs for breaking changes.
