# Provisioning Interface Contract

This is the planned operator/IaC contract, not an implemented CLI or API. No application
endpoint, data schema, application user permissions or recovery contract is introduced.

## Inputs

An explicit environment parameter set supplies Azure public cloud, subscription, new
resource-group name, location(s), unique names, hosting/extraction/storage SKUs, and
PostgreSQL server version, compute tier/SKU, vCores, storage and availability choice.
The selected model identity is Microsoft publisher/format, `Microsoft-Decision-1.1`,
version `1`, with Data Zone Standard selected; its deployment name, SKU and capacity must be verified
against the chosen region, quota and exact Bicep resource/API version. Its Decision API
uses typed questions (including `noul` for binary judgments) and returns probabilities,
so any application threshold is a separate validated application behavior. Environment
parameters contain no credentials or secrets. Verify exact Bicep resource schemas and
target support before implementation. This contract provisions PostgreSQL as a service
with Entra-only authentication, the signed-in account as initial administrator, and
no permitted client IPs. It does not define a database schema, application access
configuration, recovery policy or application behavior. App Service app and deployment
endpoints deny inbound traffic initially; storage, extraction and model endpoints use
Entra authentication where supported, and anonymous blob access is disabled. Blob
Storage is for source PDFs; no separate rule-artifact
container is planned.

## Required sequence and outcomes

1. **Validate locally**: Bicep compiles and lints with the chosen parameters. A failure
   blocks preview/deployment; this does not prove service availability.
2. **Signed-in validation and preview**: The owner signs in and confirms the target;
   validate against the provider and run subscription-scope what-if for the exact
   template and parameters, including group creation and its nested resources. Record
   changes and diagnostics. What-if does not deploy but typically
   requires deployment-level permissions. Review delete and modify actions and
   replacement risks for storage account/containers and other persistent resources;
   inspect property-level changes and provider behavior. If replacement cannot be ruled
   out, flag uncertainty and block until resolved. Never call an incomplete preview safe.
   For the initial new-group deployment only, the owner approved an exception to the
   property-level preview requirement on 2026-11-24: Azure masks the new App Service
   `siteConfig` and identity, so review their exact compiled template values before
   deployment and immediately verify their applied values afterward. This does not
   waive resource-level preview, other property review, or deployment approval.
   Report a failed or unavailable verification as a failure, not success.
3. **Cost**: Before approval, report estimated recurring fixed charges plus usage-based
   storage, extraction and model consumption, plus PostgreSQL compute, provisioned
   storage and any optional HA, assumptions, source, currency and time period. Explicitly
   flag unknowns; no paid operations to calculate an estimate. Calculate the database
   estimate only after region, sizing and availability choices are supplied.
4. **Approval**: The owner explicitly approves the exact configuration, preview, cost
   and any identified persistent-resource deletion or replacement. Sign-in, validation,
   an earlier approval or this plan is not approval. If materially changed, repeat review.
5. **Deployment**: Only after all gates and approval, the assistant executes the approved
   Bicep deployment; do not silently omit blocked services or substitute a model. Partial
   failure must be reported, not represented as a successful environment.
6. **Results**: Return all five purpose rows and underlying resource results: hosting,
   extraction, model deployment, source-PDF Blob Storage, and extracted-rule PostgreSQL
   persistence. Each has `provisioned`, `failed`, or `blocked` and a reason where
   applicable. Use ARM/deployment state evidence, not assumed success. Separate rows for
   frontend, API health, PDF extraction and model connectivity remain `blocked` until
   application and required access prerequisites exist. Do not issue paid requests
   without explicit authorization.

Never place raw documents, prompts, credentials, access tokens or account keys in
parameters, output, status or logs. Security controls required for real data/non-local
application use remain mandatory but are separate work.
