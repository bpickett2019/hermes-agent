# Hermes Governance Policy

Operational governance rules for all Hermes agent sessions. These gates apply to every skill and tool invocation unless explicitly overridden by an approved exception.

---

## Risk Classification

| Level | Description | Examples |
|-------|-------------|----------|
| **Low** | Read-only, no external side effects | File reads, search, log inspection, linting |
| **Medium** | Local side effects, no external services | File writes, local builds, test runs, CI checks |
| **High** | External services, secrets, production | API calls, deployments, secret writes, customer data access |

---

## Approval Gates

| Action | Risk | Required Gate |
|--------|------|---------------|
| Code review, lint, search | Low | None |
| Local file edit (non-secret) | Medium | None — but must follow no-main-push rule |
| `aider` / code generation | Medium | Scoped to explicit file/directory; no main-branch push |
| Playwright QA test run | Medium | None |
| Klaviyo / marketing API call | High | Explicit approval before execution |
| Deployment / release | High | Release-manager skill gate + explicit human approval |
| Secret or PHI / customer data write | High | Explicit approval + `~/.hermes/.env` only (no hardcode) |
| External send (email, SMS, webhook) | High | Explicit approval before execution |
| Spend / billing action | High | Explicit approval required |

---

## Secrets and PHI Rules

1. **Never** hardcode secrets in any file under version control.
2. API keys, tokens, and credentials go in `~/.hermes/.env` only.
3. **No customer PII, PHI, or sensitive personal data** to any observability backend (Langfuse, external logs, telemetry).
4. If a tool prompts for a secret at runtime, cancel and route to `~/.hermes/.env` setup instead.
5. `hermes-tool-health.sh` must never print secret values. Dedicated secret scanning belongs in a separate approved audit script if needed.

---

## Observability Rules

| Allowed | Forbidden |
|---------|-----------|
| Hermes structured logs to `~/.hermes/logs/` | External log sinks without approval |
| Session metadata (non-PII) to Langfuse (if configured) | Raw tool args containing tokens/keys to Langfuse |
| `agent.log`, `errors.log`, `gateway.log` | Printing env vars or secrets to stdout/stderr |

---

## Deployment and Release Rules

1. **Source-only releases**: release-manager skill verifies artifacts are built from source, not uploaded binaries.
2. **Live smoke test**: any deployment skill must run a live smoke check against the deployed target.
3. **No direct `main`/`master` push** from any coding skill (aider, code review, etc.). Use feature branches + PR workflow.
4. **Rollback expectation**: any release must document a rollback procedure before executing.

---

## External Communication Rules

1. **Email / SMS / messaging**: explicit approval required; confirm recipient and content before sending.
2. **Webhooks**: confirm payload schema, destination, and authentication method with human approver.
3. **Social media posts**: not supported by any in-repo skill; require custom approval workflow.
4. **Billing / spend**: requires explicit approval with cost estimate before execution.

---

## Rollback and Verification

- Any automated change must be reversible or have a documented rollback step.
- After any high-risk action, Hermes should confirm success/failure and surface any error output.
- If a deployment fails, do not retry without human authorization.

---

## Skill Governance Summary

| Skill | Key Constraints |
|-------|----------------|
| `safe-code-worker-aider` | Aider-scoped only; no main push; no secrets in scope |
| `browser-qa-playwright` | Playwright/QA only; no prod data; no credentials in tests |
| `funnel-cro-review` | Read-only analysis; no customer data; no side effects |
| `lifecycle-marketing-klaviyo` | Approval-first gate; PHI-safe (no raw PII to Klaviyo) |
| `release-manager` | Source-only; smoke verification; rollback documented |

---

*Last reviewed: May 2026. Policy owner: Hermes platform team.*
