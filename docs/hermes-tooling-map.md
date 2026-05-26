# Hermes Tooling Map

Quick reference for the current Hermes/OpenClaw-oriented setup on Bailey's Mac mini. This is an operational map, not an installer. Prefer small, reversible additions over core rewrites.

## Status Legend

| Status | Meaning |
|---|---|
| Present | Repo/runtime support exists locally. |
| Configured | Present and current config/env appears ready enough to use. |
| Needs Credentials | Adapter/plugin exists, but secrets or service setup are intentionally absent. |
| Missing Optional | Not installed/configured; safe to defer until a real workflow needs it. |
| Guarded | Available only behind explicit approval or a skill/policy gate. |

## Core Runtime

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Hermes Agent | Configured | Gateway/runtime active; local repo is `/Users/bailey/.hermes/hermes-agent`. | Preserve as orchestrator. Do not replace core runtime. |
| OpenClaw data | Present | `~/.openclaw` exists separately from Hermes runtime. | Leave in place unless a migration is explicitly planned. |
| MiniMax delegation | Configured | `MINIMAX_API_KEY` is present in `~/.hermes/.env`; delegation profile is available for coder work. | Use for scoped implementation; controller still reviews and verifies. |
| Codex / gpt-5.5 | Configured | Primary planning/review/verification role for Bailey workflows. | Keep as controller/reviewer, not bulk implementer when worker delegation is appropriate. |

## MCP / External Tooling

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Higgsfield MCP | Configured | MCP server is configured and active. | Keep for approved creative/media workflows. |
| Klaviyo RO MCP | Configured | Read-only UR Meds Klaviyo server is active. | Use for audit/reporting only. |
| Klaviyo draft MCP | Configured | Drafting server is active. | Require approval before writes/sends. |
| Additional SaaS MCPs | Missing Optional | Not needed for this setup pass. | Add one at a time with OAuth/client identity verification. |

## Development / QA Tools

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Aider | Present | `aider --version` reports 0.86.2. Installed as an isolated `uv tool` using Python 3.11 after Homebrew `pipx` hit Python 3.14 inspection issues on macOS 26.2. | Use only through `safe-code-worker-aider` for scoped, review-gated coding work; no direct main pushes. |
| Playwright CLI | Present | `playwright --version` reports 1.58.2. | Use for browser QA only; not a replacement for Hermes browser/agent-browser. |
| Playwright skill | Present | `browser-qa-playwright` skill added in this pass. | Load for browser UAT/QA runs. |
| GSD SDK | Present | `gsd-sdk` is installed. | Keep for Bailey's GSD workflow discipline. |

## Observability

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Hermes logs | Configured | Local logs live under `~/.hermes/logs/`. | Use as default operational evidence. |
| Langfuse plugin | Present | Bundled plugin exists at `plugins/observability/langfuse/`. | Enable only after credentials and redaction policy are approved. |
| Langfuse credentials | Needs Credentials | Expected names include `HERMES_LANGFUSE_PUBLIC_KEY`, `HERMES_LANGFUSE_SECRET_KEY`, `HERMES_LANGFUSE_BASE_URL`; plugin also supports `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `LANGFUSE_BASE_URL`. | Do not add keys in repo. Store secrets only in `~/.hermes/.env`. |
| External telemetry | Guarded | No PHI, customer data, raw tool args with secrets, or private docs should be sent to external observability. | Use governance policy before enabling. |

## Memory / Context Engines

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Hermes memory/session search | Configured | Persistent memory and session search are active. | Default memory layer. |
| Honcho plugin/env | Present/partially configured | Honcho-related plugin/env support exists; exact runtime use should be verified before relying on it. | Treat as optional until a memory workflow specifically requires it. |
| mem0 | Missing Optional | No active setup required for this pass. | Defer. |
| Zep | Missing Optional | No `ZEP_*` credentials detected during audit. | Defer unless building a memory product workflow. |
| Graphiti | Missing Optional | No `GRAPHITI_*` credentials detected during audit. | Defer unless knowledge-graph memory is explicitly needed. |

## Scheduler / Durable Workflows

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Hermes cron | Configured | Built-in scheduler and jobs are available. | Default durable task runner. |
| Hermes Kanban | Present | Kanban plugin exists; current working tree has unrelated deleted generated dashboard dist files that should be handled separately. | Use for multi-agent routing; do not mix generated asset cleanup with this setup pass. |
| Trigger.dev | Missing Optional | CLI/env not present. | Defer until a TypeScript app specifically needs Trigger.dev. |
| Temporal | Missing Optional | CLI/env not present. | Defer; too heavy for current Hermes orchestrator setup unless a durable workflow service is required. |

## Sandbox / Execution Backends

| Tool | Status | Notes | Recommended action |
|---|---|---|---|
| Local terminal | Configured | Current backend is local. | Default for controller checks. |
| Docker | Present | Docker CLI is on PATH; Docker VM data has been rsynced to `/Volumes/HermesHD/app-data/Docker/vms/` but cutover/cleanup still needs separate approval. | Use when container isolation is needed. Do not delete original Docker VM yet. |
| SSH | Present | `ssh` is on PATH. | Use only with explicit target/scope. |
| Modal / Daytona / Vercel sandbox backends | Present in repo | Hermes environment adapters exist for some remote/sandbox backends. | Configure one at a time only when needed. |
| E2B | Missing Optional | No CLI/API key detected in audit. | Defer unless a sandboxed-execution feature specifically needs E2B. |

## Governance Skills Added

| Skill | Path | Purpose |
|---|---|---|
| safe-code-worker-aider | `skills/software-development/safe-code-worker-aider/` | Scoped Aider coding with no main push, no secrets, and controller review. |
| browser-qa-playwright | `skills/dogfood/browser-qa-playwright/` | Playwright browser QA/UAT with synthetic data and explicit production gates. |
| funnel-cro-review | `skills/marketing/funnel-cro-review/` | Read-only CRO/funnel review with compliance and no side effects. |
| lifecycle-marketing-klaviyo | `skills/marketing/lifecycle-marketing-klaviyo/` | Klaviyo lifecycle work with approval-first and PHI-safe gates. |
| release-manager | `skills/devops/release-manager/` | Source-only release coordination, verification, smoke tests, and rollback notes. |

## Recommended Next Actions

1. Run the read-only health check:
   ```bash
   ops/hermes-tool-health.sh
   ```
2. Aider is installed as an isolated user tool. Verify before use:
   ```bash
   aider --version
   ```
   If reinstall is needed on this Mac, prefer:
   ```bash
   uv tool install --python /opt/homebrew/bin/python3.11 aider-chat
   ```
   Homebrew `pipx` currently failed here under Python 3.14 inspection, so do not assume `pipx install aider-chat` works on this host without retesting.
3. If Langfuse becomes necessary, approve credentials and plugin enablement separately; do not store keys in the repo.
4. Treat Trigger.dev, Temporal, E2B, Daytona, Zep, and Graphiti as optional follow-up decisions, not default installs.
