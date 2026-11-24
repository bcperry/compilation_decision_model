# Infrastructure Planning Data Model

These are planning and reporting concepts, not an application database schema or data
ingestion design. No sensitive identifiers, credentials, documents or prompts in reports.

## Environment

Fields: `environmentName`, `azureCloud`, `subscriptionId`, `resourceGroup`,
`region`, resource names, resource-specific regions if required, SKUs, parameters,
cost assumptions, and recorded deployment status. One parameter set specifies a new
resource group. Resource names and non-secret settings must meet Azure rules; all values
remain unconfirmed until owner review. Secrets are not parameters or outputs.

## Infrastructure Resource

Fields: `purpose` (hosting, extraction, decision model, source PDFs, extracted rules),
`resourceType`, `resourceId` when known, `name`, `location`, `sku`, dependencies,
and `status` with optional sanitized `reason`. App Service depends on an App Service
plan; the Microsoft-Decision-1.1 deployment depends on a compatible Foundry resource;
the source-PDF container depends on the Storage account; extracted-rule persistence
depends on the PostgreSQL flexible server. There is no separate blob container for
rule artifacts. A purpose may comprise multiple resources, and dependencies that fail
or are unverified block that purpose; provisioning a parent does not establish a
successful child.

## Model Candidate and Evidence

Selected identity: publisher/format `Microsoft`, exact model `Microsoft-Decision-1.1`,
version `1`, Microsoft Foundry Decision API. The documented `noul` answer is a probability
from 0 to 1, so a separate, validated threshold is needed to produce the constitution's
Boolean outcome in later application work. Record intended task, API contract, target region,
deployment type/SKU/capacity, Bicep API version, evidence sources/timestamps, and
subscription quota/capacity findings. Public docs establish a Microsoft Foundry model
and Azure CLI deployment path; they do not establish this task's accuracy, target-region
availability, subscription quota, or exact model-specific Bicep compatibility.

## PostgreSQL Service Choice

Plan an Azure Database for PostgreSQL flexible server as the resource for extracted-rule
persistence; source PDFs remain in Blob Storage. Record server version, region, compute
tier/SKU and vCores, provisioned storage/performance, availability choice, and cost
assumptions. These are service provisioning settings, not a database schema. Do not
define rule tables, application user permissions, retention, recovery, or ingestion
behavior in this feature. Include the selected initial Entra administrator and endpoint
controls without storing credentials. PostgreSQL availability or provisioning does not itself enforce
rule provenance, validation, activation, or immutable rule-set versions.

## Preview, Cost and Approval

Preview records scope, exact parameter/template fingerprint, timestamp, validation
result, full what-if changes/diagnostics and explicit persistent-resource
deletion/replacement/uncertainty, including the PostgreSQL server and PDF storage.
Cost estimate records currency, period, region/SKUs, PostgreSQL compute tier/vCores and
storage, optional HA, model/extraction usage assumptions, pricing sources/date, fixed
and variable amounts and unknowns; it is an estimate, not a guarantee. Approval
identifies the owner, timestamp and exact reviewed configuration, preview and estimate.
Never infer approval from login, specification or an earlier preview.

## Provisioning Result and Checks

For each of the five purposes (hosting, extraction, decision model, source-PDF storage,
and extracted-rule PostgreSQL persistence) record `provisioned`, `failed`, or `blocked` and reason
when not provisioned; include underlying resource status/evidence. Prior to a deployment
attempt, all purposes are `blocked: not deployed` (and list additional blockers).
`provisioned` requires evidence all necessary resources, including model deployment,
succeeded; missing or inaccessible results are blocked/unknown, never success. A partial
deployment must identify each affected resource. Post-deployment application checks
for frontend, API health, PDF extraction and model connectivity are separately
`blocked` until app and access exist; a provisioning result cannot satisfy them.

## Transitions

`draft → locally validated → signed-in validated/previewed → cost reviewed → explicitly
approved → deployment attempted → per-purpose result`. Failure, unavailable evidence,
unreviewed destructive changes or changed inputs return to a blocked/review state; a
material change invalidates prior approval. This describes the future workflow, not an
authorization to execute it now.
