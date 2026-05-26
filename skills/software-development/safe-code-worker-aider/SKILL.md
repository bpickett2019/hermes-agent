---
name: safe-code-worker-aider
description: |
  Aider-scoped code worker for safe, reviewable code changes. Applies targeted
  edits to files using the Aider LLM coding tool. Governed by strict gates: no
  direct main-branch push, no secrets or credentials in scope, no observability
  of sensitive data, and no side effects outside the agreed file/directory
  boundary. All changes are captured in a reviewable diff. Suitable for tasks
  such as implementing features, refactoring, bug fixes, and test writing where
  the human approver has explicitly agreed on the scope and the files in scope.
  Scope is limited to the specific files/directories the approver confirms.
  GATES: (1) No direct push to main or master branch. (2) No secrets, API keys,
  tokens, or credentials in any edited file. (3) No PII/PHI/customer data to any
  observability backend. (4) All changes require explicit human approval of the
  diff before being applied. (5) Aider is used for code generation and edit
  review only; no standalone CLI commands outside the agreed scope.
version: "1.0"
author: Hermes Platform Team
license: MIT
platforms: [macOS, Linux, Windows]
metadata:
  hermes:
    tags: [code, aider, development, safe-edit, review-gated]
    related_skills:
      - browser-qa-playwright
      - release-manager
---

# Safe Code Worker (Aider) Skill

## Overview

This skill uses Aider to make targeted code changes within an explicitly
approved scope. It is the primary coding skill for Hermes and enforces strict
governance before any change is applied.

## Usage

Invoke via skill command or as a sub-agent task:

```
/skill safe-code-worker-aider
```

Or as a sub-agent instruction in a parent conversation.

## Governance Gates

| Gate | Rule |
|------|------|
| Scope approval | Files/directories must be explicitly confirmed by a human before Aider touches them |
| No main push | Aider must never `git push` to `main` or `master` directly; feature-branch + PR only |
| No secrets | No API keys, tokens, passwords, or credentials in any edited file |
| No PHI/customer data | No raw PII or customer data to any external tool or observability backend |
| Human diff review | The full diff must be shown to and confirmed by the human before `git commit` |
| Aider-scoped only | All LLM edit operations must go through Aider; no ad-hoc `sed`/`perl`/etc. |

## Workflow

1. **Scope confirmation** — state the exact files/directories to be modified and wait for human confirmation.
2. **Diff preview** — run `aider --diff` or equivalent to show proposed changes before applying.
3. **Human approval** — human reviews the diff and explicitly approves.
4. **Apply** — Aider applies changes; Hermes reports the result.
5. **No push** — changes are left in the working tree or a feature branch for the human to review and merge.

## Safety Checks

- Before each session, confirm no `.env`, `*.key`, `token`, `secret`, `credential`, or similar patterns are in scope.
- If secrets are detected, abort and report: "Secrets detected in scope — aborting. Route credentials to `~/.hermes/.env`."
- Do not print or log the content of any file that may contain credentials.

## Rollback

If a change is applied incorrectly:
1. `git checkout -- <file>` to revert.
2. Report the revert to the human.
3. Do not retry without explicit instruction.

## Constraints Summary

- **Edit scope**: Only files explicitly approved by the human.
- **Push**: Never directly to `main`/`master`; feature branches only.
- **Secrets**: Hard fail if detected; route to `~/.hermes/.env`.
- **Observability**: No tokens, keys, or PII to Langfuse or any external telemetry.
- **Tool boundary**: Aider only; no ad-hoc shell tools for code edits.
