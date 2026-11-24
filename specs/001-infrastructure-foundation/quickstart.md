# Quickstart: Review and Future Provisioning

**Current state**: infrastructure templates exist; provider validation succeeds after an
App Service quota increase. Azure masks the app configuration in what-if; on 2026-11-24
the owner approved compiled-template review of those fields, immediate post-deployment
verification, and the reviewed initial deployment. The initial PostgreSQL B1ms
deployment failed; the owner then approved an isolated B2s deployment, which
succeeded and was verified. The other resources are provisioned; application checks
remain blocked. See the
[infrastructure README](../../infra/README.md) for commands, evidence, and cost assumptions.

## Prerequisites and decisions

1. Use the owner-selected Azure public cloud subscription, East US 2 planning target,
   resource naming and documented usage assumptions. Propose the lowest-cost supported development
   service SKUs, PostgreSQL version/compute/storage sizing, and availability settings
   for owner review with their estimated cost.
2. Owner signs in personally when ready for target checks. Verify the selected account,
   scope, permissions, policy, service/SKU/runtime availability and provider state.
   Recheck service and model availability and quota before deployment. What-if normally
   requires deployment-level permissions.
3. Use the selected Microsoft-Decision-1.1 identity (Microsoft publisher/format, version
   1), Data Zone Standard, and the documented Microsoft Foundry Decision API. Verify the intended region and
   deployment type, actual subscription quota, and exact Bicep deployment/API-version
   support. The `noul` API answer is a probability; the later application feature must
   validate its Boolean threshold and task-specific quality before application use.
   Infrastructure work does not require labeled rule examples. If this model cannot be used, a different model or
   deployment mechanism requires explicit owner approval and documented rationale.
4. Install or locate Azure CLI and Bicep. If Git/Azure CLI is missing from this Windows
   process, refresh `PATH` from machine and user environment variables without logging
   credentials. Do not change global environment as a side effect.
5. Plan Azure Database for PostgreSQL flexible server for extracted rules and Blob
   Storage for source PDFs only. Before target validation, choose a supported PostgreSQL
   version, compute tier/SKU and vCores, storage size/performance, availability choice,
   and a managed maintenance window; plan operational metric review for CPU, available
   storage, database size and connections. Estimate region- and sizing-specific cost
   with the Azure Pricing Calculator against the USD 150 monthly estimate ceiling.
   No database schema, application user permissions,
   or recovery workflow is defined here; initial endpoint controls and the PostgreSQL
   administrator are included.

## After the infrastructure implementation exists

1. Run Bicep build/lint. Use only non-secret environment parameters. If validation
   or the model gate fails, stop.
2. After owner sign-in and target confirmation, run provider validation and
   subscription-scope what-if against the exact template and parameters, including
   the group and its nested resources. Inspect diagnostics and
   all changes, including deletion/replacement risk of persistent resources. Incomplete
   or ambiguous results block deployment except for the owner-approved initial
   masked-field review and immediate verification described above. See [what-if documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if).
3. Present the owner the full preview and a pricing-calculator estimate with fixed and
   usage-based costs, currency, quantities, assumptions, uncertainty and date. Do not
   claim what-if is a cost estimate.
4. Ask for explicit approval of the reviewed configuration and any destructive changes.
   Only after approval may the assistant run the deployment. If the inputs or preview
   materially change, redo review and get new approval.
5. Report evidence-based results for hosting, extraction, model deployment, source-PDF
   Blob Storage and extracted-rule PostgreSQL persistence individually as
   provisioned/failed/blocked, explaining each non-success. Report frontend serving,
   API health, PDF extraction and model connectivity as blocked until the application
   and its required access are available. No live paid checks without separate
   authorization.

Application user permissions, recovery, application behavior and real-data readiness
are outside this feature. Security obligations including access control, least privilege,
managed identity where supported and safe secret handling are not waived.
