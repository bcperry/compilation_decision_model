# Compilation Decision Model

A planned text-classification application with a TypeScript frontend inspired by
Microsoft Foundry and a Python backend that serves the UI and proxies decision inference.
When a decision model returns `true`, the backend uses the same model and rule set for
bounded binary-search localization of model-supported offending words or spans.
Context-dependent or inconsistent results must remain explicitly unresolved.

## Intended Azure architecture

- **Azure AI Document Intelligence** extracts rule PDF content for traceable, versioned rules.
- **Azure App Service** hosts the Python backend and built TypeScript frontend.
- **Microsoft Foundry** hosts the selected decision model, preferably a Microsoft model
  whose suitability and deployment availability have been verified.
- **Bicep** defines cloud infrastructure and supported model deployments.

## Project status and guidance

The project currently contains a Python starter and Spec Kit configuration, not a working
frontend, classification API, or deployment. No feature implementation plan exists yet.

The [constitution](.specify/memory/constitution.md) defines the engineering requirements.
Next, create a feature specification and implementation plan resolving model selection,
rule activation, localization semantics, authentication, retention, and numeric budgets.
The plan must also verify framework/runtime compatibility with App Service.

Use a few tests that verify changed user outcomes, not code coverage or test counts.
Limit edge cases to requirements, known regressions, and material user risks. Prefer simple
inline logic; extract shared methods when the same logic is used more than three times.
Avoid speculative defensive code without hiding errors or weakening security controls.
Real-model evaluations must be distinguished from deterministic orchestration tests.
An independent subagent generates and runs tests using minimal relevant requirements
and public-contract context, not the implementation conversation. The implementation
agent owns production code and fixes; the tester does not modify production code.

Backward compatibility is not required until the user explicitly confirms deployment.
Until then, prefer direct changes without legacy shims, updating current callers and
contracts together. After confirmation, breaking deployed contracts or migrations need approval.

Provisioning requires explicit approval and infrastructure validation. No deployment or
paid service use is authorized by this document.