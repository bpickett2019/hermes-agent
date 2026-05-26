---
name: browser-qa-playwright
description: |
  Playwright-based browser QA skill for running headless browser tests against
  local or staging environments. Enforces strict boundaries: test files only, no
  production credentials, no raw PII/PHI in test data, and no side effects outside
  the test sandbox. Suitable for validating UI behavior, form submissions,
  navigation flows, and regression checks. All test runs produce a summary
  report and optional screenshots on failure. GATES: (1) Tests run against
  staging or local only — never against production without explicit approval.
  (2) No production secrets or credentials in test code. (3) No raw customer PII
  or PHI in test fixtures. (4) Playwright is the only permitted browser automation
  tool. (5) Approval required for any test run targeting external/staging URLs.
version: "1.0"
author: Hermes Platform Team
license: MIT
platforms: [macOS, Linux, Windows]
metadata:
  hermes:
    tags: [qa, playwright, browser, testing, dogfood, regression]
    related_skills:
      - safe-code-worker-aider
      - release-manager
---

# Browser QA (Playwright) Skill

## Overview

This skill runs Playwright-based browser QA tests against designated test
environments. It is used for dogfooding Hermes features, validating UI behavior,
and catching regressions before release.

## Usage

```
/skill browser-qa-playwright
```

Or invoke as a sub-agent task with a target URL and test scope.

## Governance Gates

| Gate | Rule |
|------|------|
| Environment | Tests target staging or local only; explicit approval for production |
| Credentials | No production secrets in test code; use `TEST_` prefixed env vars |
| Test data | No raw PII, PHI, or real customer data in fixtures |
| Tool | Playwright only; no Selenium, Puppeteer, or other browser automation |
| Approval | Human must confirm target URL and scope before each run |

## Workflow

1. **Target confirmation** — state the target URL(s) and test scope; wait for human approval.
2. **Environment check** — verify target is staging/local or has explicit production approval.
3. **Run tests** — execute `playwright test` with the specified config and scope.
4. **Report** — summarise pass/fail counts, attach screenshots for failures.
5. **Artifacts** — store test results in `~/.hermes/test-results/` with timestamp.

## Test File Conventions

- Test files live in `tests/playwright/` or the project-specific test directory.
- Use page objects for reusable selectors.
- Never hardcode credentials; inject via environment:

```python
import os
BASE_URL = os.environ.get("TEST_BASE_URL", "http://localhost:3000")
```

## Safety Constraints

- **No production push**: Tests must never modify production data.
- **No credential exposure**: Use `TEST_*` env vars; do not print them.
- **PHI/PII safe**: Use synthetic or masked test data only.
- **Screenshot on failure**: Capture failure screenshots for debugging; store locally only.

## Rollback

Browser tests are read-only by default. If a test causes side effects:
1. Identify the affected test.
2. Report the side effect to the human.
3. Do not rerun until root cause is understood.

## Constraints Summary

- **Environment**: Local/staging unless explicitly approved for production.
- **Credentials**: `TEST_*` env vars only; no hardcoded secrets.
- **Data**: Synthetic fixtures; no real PII or PHI.
- **Tool**: Playwright exclusively.
- **Approval**: Human confirmation required before each test run targeting external URLs.
