# Research: Infrastructure Foundation

Research date: 2026-11-24. Public documentation is evidence of capabilities, not
proof that a particular subscription, region, model, quota or SKU is available.

## Topology and infrastructure as code

- **Decision**: Use subscription-scoped Bicep to create a new resource group, with
  group-scoped deployment for its resources in Azure public cloud; the initial scope is
  one development/test environment.
  Parameters identify names, locations, SKUs and verified model details.
- **Rationale**: The owner explicitly chose a new resource group. Verify the required
  subscription-scope permissions and preview its creation alongside the other changes.
- **Alternatives**: Reusing an existing group does not meet the owner's choice; Terraform
  conflicts with mandated Bicep.

## Hosting and extraction

- **Decision**: Plan Linux App Service plus App Service plan, with Python 3.14 as the
  candidate matching the existing project requirement; plan a Document Intelligence
  resource (`FormRecognizer` account kind).
- **Rationale**: Required by constitution. [App Service Python guidance](https://learn.microsoft.com/en-us/azure/app-service/configure-language-python)
  documents Linux and illustrates `PYTHON|3.14`; it also directs operators to list
  supported runtimes. [Document Intelligence client guide](https://learn.microsoft.com/en-us/dotnet/api/overview/azure/ai.documentintelligence-readme?view=azure-dotnet)
  shows a FormRecognizer account. Target availability and valid SKUs are unverified.
- **Alternatives**: Other hosting/extraction services do not meet the constitution.
  Python 3.13 does not meet the current `>=3.14` project requirement; changing it
  requires separate approval and compatibility work, not a silent fallback. The web
  framework and frontend runtime are outside this infrastructure feature.

## Decision model

- **Decision**: Use **Microsoft-Decision-1.1**, model version `1`, format/publisher
  `Microsoft`, deployed in Microsoft Foundry. Its documented Decision API endpoint is
  `<resource-endpoint>/providers/microsoft/v1/systemone`; requests name the deployment,
  submit `state` and typed `questions`, and can use a `noul` question for a yes/no
  judgment. The response is a probability from 0 to 1, not a literal Boolean.
- **Rationale / evidence**: Microsoft's [model-specific deployment and API guide](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/use-foundry-models-microsoft-decision)
  identifies the model as generally available in Foundry for classification and binary
  decisions; gives model/version/API type; documents the Microsoft format and version 1;
  shows an exact Azure CLI deployment command; and documents the endpoint and typed
  `noul` response. This verifies the provider identity and Azure Foundry deployment
  path, rather than assuming either from the model name. The guide lists
  `GlobalStandard` and `DataZoneStandard` in selected regions; Microsoft's
  [Foundry model region-availability guide](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure-region-availability)
  is the current cross-check for the selected deployment category and region. These
  sources alone do not prove availability or quota in the selected subscription. Check
  quota in the signed-in Foundry account/region (and, where applicable, the
  [model capacities API](https://learn.microsoft.com/en-us/rest/api/microsoftfoundry/accountmanagement/model-capacities/list))
  at deployment planning time; record its scope and timestamp.
  Microsoft's [Cognitive Services account deployment Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts/deployments)
  and [Foundry Bicep resource guidance](https://learn.microsoft.com/en-us/azure/foundry/how-to/create-resource-template)
  document the general resource types and Bicep workflow. The model-specific guide
  demonstrates exact deployment via CLI, not an exact model-specific Bicep declaration;
  the model's exact Bicep API version, SKU/capacity semantics and provider validation
  therefore remain an implementation gate.
- **Suitability limits**: The documented `noul` type is a good interface match for a
  bounded binary judgment, but it emits a probability that the application must turn
  into a validated Boolean using an explicit threshold. The later application feature
  must evaluate the threshold and decision quality for the project's extracted rules
  against labeled examples before application-use claims. The docs do not establish this task's
  accuracy, threshold, behavior on rule context, or suitability for the constitution's
  recursive localization workflow. No live or paid model test is authorized in planning.
- **Alternatives**: Do not silently substitute. If target availability, quota, Bicep
  support, or task validation makes this choice unusable, any alternative model or
  deployment mechanism requires explicit owner approval and documented rationale under
  the constitution.

## PDF-extracted rule persistence

- **Decision**: Keep one general-purpose v2 Blob Storage account/container for source
  PDFs and plan **Azure Database for PostgreSQL flexible server** for PDF-extracted rule
  data. Do not retain the former second blob container for rule artifacts. No database
  schema, application user permissions, recovery workflow, ingestion logic, or rule
  activation behavior is designed here. Initial endpoint controls and the PostgreSQL
  Entra administrator are in scope.
- **Rationale / service choice**: PostgreSQL is the user's selected persistence
  technology. Azure Database for PostgreSQL flexible server is a managed PostgreSQL
  service with a documented Bicep resource type and quickstart ([Bicep quickstart](https://learn.microsoft.com/en-us/azure/postgresql/development/create-server-bicep);
  [resource reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers)).
  It is therefore a grounded Azure service candidate for this Azure/Bicep project, not
  an assumption that any PostgreSQL service is automatically available in the target.
  Blob versioning may retain source-PDF object versions but does not itself enforce the
  constitution's immutable rule-set/provenance behavior. PostgreSQL's presence likewise
  does not implement those application guarantees.
- **Operational necessities**: Before deployment, choose a supported PostgreSQL major
  version, target region, compute tier/SKU and vCores, storage size/performance, and
  whether workload availability warrants same-zone or zone-redundant HA. Plan routine
  monitoring for CPU, storage free/used, database size and active connections; select a
  managed maintenance window because service patching can restart the server. These
  are sizing and service-operation choices only; application user permissions, recovery,
  schemas and application implementation remain separate work. Verify service/version/SKU/HA availability
  in the selected region and subscription.
- **Cost**: Azure prices the flexible server by server configuration (compute tier,
  vCores and provisioned storage); PostgreSQL inference is not involved. Optional HA
  adds a standby and Microsoft cost guidance says it can approximately double the
  deployment cost. A stopped server stops compute billing, but this is not a deployment
  recommendation or availability assumption. Produce a region/SKU/storage/HA-specific
  estimate in the Azure Pricing Calculator once workload, region and sizing are known;
  no defensible dollar estimate is possible yet. See [compute options](https://learn.microsoft.com/en-us/azure/postgresql/compute-storage/concepts-compute),
  [cost optimization](https://learn.microsoft.com/en-us/azure/postgresql/configure-maintain/how-to-cost-optimization),
  [service overview](https://learn.microsoft.com/en-us/azure/postgresql/overview), and the
  [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/).

## Safe review and cost

- **Decision**: Offline Bicep build/lint, then signed-in provider validation and what-if
  of the exact parameter set, independently review all persistent-resource deletions
  and possible replacements, and estimate recurring and usage costs before approval.
  Obtain a fresh approval for changed inputs or preview.
- **Rationale**: [ARM what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)
  doesn't change resources but can omit nested linked templates or report unevaluated
  changes; default what-if requires deployment-level permissions. Incomplete or ambiguous
  preview is blocked, not evidence of safety. What-if is not a cost estimate.
  Use the [Azure pricing calculator](https://azure.microsoft.com/pricing/calculator/)
  or current pricing pages with explicit region, SKU, quantities, usage, currency and
  assumptions; separately disclose unknowns, taxes and uncertainty.
- **Alternatives**: Deploy-and-inspect risks charges and destructive changes; no unattended
  create, no approval by implication, no default paid live inference.

## Evidence still required

PostgreSQL SKU and runtime deployment support, exact Bicep model-deployment
compatibility, final resource names, policy and pricing remain unverified. Recheck
region eligibility, quota and permissions near deployment. These are deployment or
implementation gates, not permission to invent answers.

## Read-only target checks — 2026-11-24

- The owner-selected subscription is enabled in Azure public cloud. Azure CLI reports
  subscription-scope Owner access. The Microsoft.Web provider was registered with
  explicit owner approval; Microsoft.CognitiveServices, Microsoft.Storage,
  Microsoft.DBforPostgreSQL and Microsoft.Resources were already registered.
- The signed-in Entra principal was successfully resolved and matched the account the
  owner selected as the initial PostgreSQL administrator. Provider acceptance of the
  Entra-only server and administrator configuration remains to be validated.
- In the selected subscription, the Azure model catalog lists Microsoft-Decision-1.1
  version 1, Microsoft format, `AIServices`, as generally available in East US, East US 2
  and Sweden Central, with GlobalStandard and DataZoneStandard SKUs. The East US 2
  usage response reports GlobalStandard 2,250 used of 4,500 and DataZoneStandard 0 used
  of 4,500. Quota is shared according to the deployment type, can change, and does not
  guarantee capacity or successful deployment.
- East US PostgreSQL flexible-server capability reports provisioning restricted for
  this subscription. East US 2 reports server versions 11–18 and lists Burstable B1ms
  and B2s; listing a SKU is not a guarantee of deployable capacity. East US 2 also lists
  Document Intelligence F0/S0, AI Services S0, and Linux App Service F1/B1. The Linux
  runtime catalog lists Python 3.14; target deployment still requires validation.
- A local Bicep 0.39.26 probe compiled an account deployment at API version
  `2025-06-01` with Microsoft-Decision-1.1 version 1, Microsoft format,
  GlobalStandard and capacity 1. Compilation verifies the template shape only; it does
  not establish provider acceptance for that specific combination or subscription.
- The owner selected East US 2 for planning and validation, not deployment approval.
  Provider registration and catalog/usage queries do not create application resources.
  Actual provider validation, policy and capacity checks, exact Bicep compatibility,
  naming, pricing and owner deployment approval remain outstanding.
- On 2026-11-24, the owner-selected resource-group name
  `rg-compilation-decision-dev-eus2` did not exist in the selected subscription;
  check again before deployment.

## Implementation checks — 2026-11-24

- The owner accepted Document Intelligence F0's two-page limit per analysis request
  for development. It does not process a complete 20-page PDF in one request. See
  [Document Intelligence limits](https://learn.microsoft.com/en-us/azure/ai-services/document-intelligence/service-limits?view=doc-intel-4.0.0).
- Bicep and parameters compiled. Separate subscription-scoped provider validations for
  the model, PDF storage, and PostgreSQL returned success, but do not guarantee
  creation or available capacity. A full provider validation and what-if failed on App
  Service quota. F1, B1, B2, B3, and S1 preflight attempts failed; regional usage
  listed zero total regional VMs despite per-SKU limits. See
  [App Service quota troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/azure/app-service/troubleshoot-non-zone-redundant-quota-requests).
  At that point deployment was blocked pending quota, complete validation, preview,
  cost review, and explicit approval.
- With owner approval, Microsoft.Quota was registered. The CLI quota API lists F1
  at 10 and Total Regional VMs at 0. An F1 increase to 11 was submitted via CLI,
  following Microsoft's guidance to request the individual SKU, and succeeded; the
  regional total became 11. Registration and the request did not deploy resources.
- Subsequent full provider validation succeeded; what-if showed all 11 intended
  resources as Create and no diagnostics or deletes. However, the response masked the
  app's entire `siteConfig` and identity, preventing property-level preview of its
  endpoint restrictions and identity. The owner approved a limited alternative:
  inspect those fields in the compiled template and verify them immediately after
  deployment. What-if did not reveal the masked values. Applied-value verification
  failure is a deployment failure and must be reported.
- Immediately before deployment, the approved template and parameter fingerprints
  matched, provider validation succeeded, and what-if again reported the same 11
  creates. East US 2 DataZoneStandard Microsoft-Decision-1.1 quota was 0 used of
  4,500; quota does not guarantee capacity.
- The initial deployment failed because PostgreSQL `Standard_B1ms` returned
  `SkuNotAvailable`; the other modules succeeded. The server was reported as dropping
  after failure. Regional SKU listing and validation were not proof of available
  capacity. A subsequent isolated PostgreSQL preview with `Standard_B2s` showed two
  creates and ignored the existing resources. An entire-template retry instead
  previewed changes to existing resources, including storage properties. The B2s
  alternative was approved for isolated deployment, which succeeded. Server state,
  configuration, Entra administrator and absence of firewall rules were verified.
  See the [infrastructure README](../../infra/README.md) for costs and per-purpose status.
