# Development infrastructure

This Bicep configuration proposes an East US 2 resource group containing a Linux
App Service plan and app, Document Intelligence, a Foundry account and decision model,
a Blob Storage account and source-PDF container, and a PostgreSQL flexible server.
The owner approved the reviewed initial deployment on 2026-11-24. The deployment
partially succeeded: PostgreSQL B1ms failed with `SkuNotAvailable`; the other resources
listed below were provisioned. The owner subsequently approved and the assistant
deployed and verified an isolated B2s PostgreSQL server.

## Configuration

[dev.bicepparam](parameters/dev.bicepparam) contains the non-secret environment
settings. Globally unique names are generated from the subscription and resource
group; review the resolved names in what-if. The app and SCM endpoints are public
but deny inbound requests. Storage disallows anonymous blobs and shared-key access;
both AI accounts disable local authentication. PostgreSQL uses Entra-only
authentication, no firewall rules, and no HA standby. The application identity has
no service roles yet. Public endpoints do not imply application readiness.

Document Intelligence F0 is intended for development: it processes at most the first
two pages per analysis request, even when a PDF has more pages. The original workload
estimate of two 20-page PDFs per month does not mean all 40 pages will be processed
under this configuration. Review the tier again before full-document extraction.
See [service limits](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/service-limits?view=doc-intel-4.0.0).

PostgreSQL B2s uses 32 GiB of storage and version 17. Blob Storage is for source PDFs;
PostgreSQL is the planned location for extracted rules and can support future source
references and version records, but neither a schema nor immutability is implemented.
No application code, application role assignments, connectivity, or recovery workflows
are included.

## Validate and preview

Azure CLI, Bicep, a signed-in owner-selected subscription, and permission to validate
subscription-scoped deployments are required. The commands below use the active CLI
subscription; verify it is the intended public-cloud subscription before running them.
Resolve the signed-in user for the initial database administrator in the same PowerShell
process; no password is used or committed. For an existing environment, confirm that
this is the approved administrator: signing in as someone else changes the
administrator resource in the template and could add another database administrator.
Review and approve any such access change before deployment.

```powershell
az account show --query "{name:name,cloud:environmentName,user:user.name}" -o table
$admin = az ad signed-in-user show --query "{id:id,upn:userPrincipalName}" -o json | ConvertFrom-Json
if (-not $admin.id -or -not $admin.upn) { throw 'Cannot resolve the signed-in administrator.' }
$env:AZURE_POSTGRES_ADMIN_OBJECT_ID = $admin.id
$env:AZURE_POSTGRES_ADMIN_NAME = $admin.upn
az bicep build --file infra\main.bicep --stdout | Out-Null
az bicep build-params --file infra\parameters\dev.bicepparam --stdout | Out-Null
az deployment sub validate --location eastus2 --template-file infra\main.bicep --parameters infra\parameters\dev.bicepparam --name cdm-foundation-validation
az deployment sub what-if --location eastus2 --template-file infra\main.bicep --parameters infra\parameters\dev.bicepparam --name cdm-foundation-preview --no-pretty-print
```

Check each command's exit code and stop on failure. Review the preview, including all
nested resources, diagnostics, and storage/database deletion or replacement risks.
An incomplete preview is not approval, except for the owner-approved masked App Service
fields described below. Recheck group-name availability, service SKUs, model
availability and quota before deployment.

## Cost and deployment gate

On 2026-11-24, East US 2 [Azure retail prices](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)
give the following illustrative monthly estimate for this configuration:

| Item | Assumption | Estimated USD/month |
| --- | --- | ---: |
| App Service | F1, one plan | $0 |
| PostgreSQL compute | B2s, 730 hours at $0.068/hour | $49.64 |
| PostgreSQL storage | 32 GB at $0.115/GB-month | $3.68 |
| Backup overage | None; up to provisioned storage is included | $0 |
| Document Intelligence | F0; two PDFs, first two pages each | $0 |
| Decision model | 500 calls, 500 input tokens each at $0.046/million | $0.0115 |
| PDF Blob Storage | Assumed 1 GB at $0.0184/GB-month, 100 reads and 100 writes | $0.019 |
| **Total** | | **About $53.35** |

This estimate assumes no billable outbound transfer or other features and excludes
taxes. PDF size, operation count, backup overage and actual usage are unknown;
overages and subscription-specific rates may increase the bill. Backup usage above
the included allocation costs extra; see [backup pricing](https://learn.microsoft.com/en-us/azure/postgresql/backup-restore/concepts-backup-restore#backup-storage-cost).
The 20-page PDF workload is not fully analyzed by F0 in a single request. The
USD 150/month review ceiling is not a spending cap.

On 2026-11-24, F1, B1, B2, B3 and S1 initially failed preflight due to a zero
regional App Service limit. The Microsoft.Quota provider was registered with owner
approval; an F1 increase from the listed limit of 10 to 11 was requested through Azure
CLI and succeeded, raising the regional total to 11. Subsequent full provider
validation succeeded and what-if returned 11 Create actions, no deletes, modifications,
or diagnostics:

- Resource group `rg-compilation-decision-dev-eus2`.
- Linux F1 plan `cdm-dev-plan` and app `cdm-dev-app-txzlrr4zybffy`.
- F0 Document Intelligence `cdm-dev-doc-txzlrr4zybffy`.
- S0 Foundry account `cdm-dev-ai-txzlrr4zybffy` and its `decision` model deployment.
- LRS storage account `cdmdevtxzlrr4zybffy`, its default blob service and
  `source-pdfs` container.
- PostgreSQL server `cdm-dev-pg-txzlrr4zybffy` and its Entra administrator.

Azure masked the app's entire `siteConfig` and identity in the what-if response. The
template specifies deny-by-default for both app and SCM, Python 3.14 and a system
identity, but the preview does not show those properties. On 2026-11-24, the owner
approved reviewing those masked fields in the compiled template and immediately
verifying them after the initial deployment. The compiled template confirms the
submitted values but cannot prove the provider will apply them. Microsoft notes that
[`siteConfig` can contain sensitive information](https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.management.websites.models.siteproperties.siteconfig?view=az-ps-latest)
and isn't returned in normal create/read responses. Validation and what-if do not
guarantee provisioning or capacity.

Only after complete validation, preview, cost review and explicit owner approval of
that exact configuration may the assistant run:

```powershell
az deployment sub create --location eastus2 --template-file infra\main.bicep --parameters infra\parameters\dev.bicepparam --name cdm-foundation
```

Use the same verified subscription and administrator environment variables as for the
approved preview. Changes to inputs or a material preview require a fresh approval.
Inspect deployment operations and resource states, including child deployments,
container and PostgreSQL administrator, and report each of hosting, extraction,
model, PDF storage and PostgreSQL as provisioned, failed or blocked. Frontend, API,
PDF extraction and model connectivity checks remain blocked until the application and
its access are configured. Do not send live paid requests without authorization.

## Initial deployment outcome

The 2026-11-24 subscription deployment failed because Azure rejected PostgreSQL
`Standard_B1ms` with `SkuNotAvailable`, despite regional capability listing and
successful preflight. Azure initially reported the failed server as dropping.

- **Hosting provisioned:** the F1 plan and running app were created. App configuration
  and identity were inspected immediately: both app and SCM default to Deny, neither
  has an allow rule, HTTPS is required, TLS minimum is 1.2, the configured runtime is
  Python 3.14 and the system-assigned identity is present.
- **Document Intelligence provisioned:** F0 account succeeded with local auth disabled.
- **Decision model provisioned:** the S0 Foundry account and Microsoft-Decision-1.1
  version 1 DataZoneStandard deployment succeeded; local auth is disabled.
- **PDF storage provisioned:** the LRS account succeeded with anonymous blobs and shared
  keys disabled, and the `source-pdfs` container exists with public access set to None.
- **PostgreSQL provisioned:** the separately approved B2s deployment succeeded. The
  server is Ready on PostgreSQL 17 with 32 GiB storage, no HA, Entra-only
  authentication, the approved administrator and no firewall rules.

Application, extraction and model-connectivity checks are blocked by missing application
code and access; no paid requests were made. A full-template retry preview reported
modifications to existing resources, including persistent storage properties, so it
must not be treated as the original all-create preview.

As a possible alternative, a resource-group-scoped preview of the same PostgreSQL
module with `Standard_B2s` reported only two creates (server and administrator), with
the other five top-level resources ignored; it reported no deletes or modifications.
That preview does not guarantee capacity. Microsoft retail pricing for B2s is
$0.068/hour, yielding approximately $53.35/month total under the same earlier
assumptions (730 hours), rather than $16.12. The owner approved this SKU and isolated
deployment after reviewing the alternative; provider validation, the refreshed
isolated preview and the deployment subsequently succeeded.
