---
name: release-manager
description: |
  Release manager skill for orchestrating software releases with strict source-only
  verification, live smoke testing, and rollback documentation. Governed by
  strong gates: (1) source-only — release artifacts must be built from source in
  the repo, no uploaded pre-built binaries. (2) Live smoke test — every release
  must run a smoke test against the deployed target before declaring success.
  (3) Rollback documented — every release plan must include a rollback procedure
  before any deployment step is taken. (4) No direct production push without
  explicit approval. (5) No secrets or credentials in release scripts — use
  ~/.hermes/.env only. Suitable for coordinating staged rollouts, hotfixes, and
  feature releases across environments.
version: "1.0"
author: Hermes Platform Team
license: MIT
platforms: [macOS, Linux, Windows]
metadata:
  hermes:
    tags: [devops, release, deployment, smoke-test, rollback, source-only]
    related_skills:
      - safe-code-worker-aider
      - browser-qa-playwright
---

# Release Manager Skill

## Overview

This skill orchestrates software releases with governance gates that ensure
every release is traceable to source, verifiable via smoke test, and reversible
via a documented rollback. It is the authoritative skill for any deployment
action triggered by Hermes.

## Usage

```
/skill release-manager
```

Or as a sub-agent task with release target, version, and environment specified.

## Governance Gates

| Gate | Rule |
|------|------|
| Source-only | All artifacts built from source in the repo; no uploaded pre-built binaries |
| Smoke test | Live smoke test required against deployed target before success is declared |
| Rollback doc | Rollback procedure must be documented before any deployment step |
| Approval | No production push without explicit human approval of the full release plan |
| Credentials | Secrets in `~/.hermes/.env` only; never in release scripts |
| No main push | Release scripts must not push directly to `main`/`master` |

## Workflow

### 1. Release Plan (Read-only)

Human specifies:
- Target environment (staging, production, etc.)
- Version or Git ref to release
- Any migration or pre-deployment steps

Hermes produces a **Release Plan** containing:
- Changelog / commit list since last release
- Build steps (from source)
- Deployment steps
- Smoke test commands
- Rollback procedure (step-by-step)

### 2. Human Approval

Human reviews and approves the Release Plan. Hermes does not proceed
to step 3 without explicit approval.

### 3. Build (Source-only)

- Clone/checkout the specified Git ref.
- Run build commands from source (e.g., `python -m build`, `docker build`).
- Verify build artifacts were produced, not uploaded.
- Log build output location.

### 4. Deploy

- Execute deployment steps from the approved plan.
- Use credentials from `~/.hermes/.env` only.
- Log each step as it completes.

### 5. Smoke Test

Run the documented smoke test against the deployed target:
- HTTP health endpoint check
- Basic functional check (login, read, or write depending on scope)
- Log smoke test result

Report smoke test result to human. If smoke test fails:
1. Do not continue.
2. Execute rollback procedure.
3. Report failure and rollback to human.

### 6. Success Report

Provide:
- Release version / Git ref
- Deployment timestamp
- Smoke test result
- Rollback link (if ever needed)
- Any post-deploy steps remaining

## Rollback Procedure Template

Every release plan must include:

```
## Rollback Procedure

1. Revert deployment to previous version:
   <specific command or step>
2. Run smoke test against previous version:
   <command>
3. Verify:
   <expected outcome>
4. Notify:
   <channels/contacts>
```

## Source-Only Verification

Before building, Hermes confirms:
- No artifact URL pointing to an external binary host (S3, GitHub Releases, etc.)
- Build commands run from local source tree
- Git working tree is clean or the diff is expected

## Constraints Summary

- **Source-only**: All artifacts from repo source; no external binaries.
- **Smoke required**: Live smoke test passes before release is declared complete.
- **Rollback doc**: Rollback procedure documented before any deployment.
- **Approval**: Human approves full release plan before any action.
- **Credentials**: `~/.hermes/.env` only; no hardcoded secrets.
- **No main push**: Feature branch or tag push only; no direct `main`/`master` push.
