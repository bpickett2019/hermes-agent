---
name: lifecycle-marketing-klaviyo
description: |
  Klaviyo lifecycle marketing skill for designing, reviewing, and auditing
  email/SMS lifecycle flows. Strict approval-first gate: no Klaviyo API call is
  made without explicit human approval of the specific campaign, flow, template,
  and recipient segment. Enforces PHI-safe data handling: no raw PII, no
  customer emails or phone numbers to any external system beyond Klaviyo itself.
  Suitable for reviewing existing flows, drafting new flow logic, auditing
  compliance, and producing change recommendation reports. GATES: (1)
  Approval-first — explicit human sign-off on every API call, campaign, and
  segment before any action. (2) PHI-safe — no raw PII/PHI to any observability
  backend. (3) No external send without human-confirmed recipient list and
  content. (4) Klaviyo API credentials stored in ~/.hermes/.env only. (5)
  Read-only audit mode is default; write mode requires additional approval step.
version: "1.0"
author: Hermes Platform Team
license: MIT
platforms: [macOS, Linux, Windows]
metadata:
  hermes:
    tags: [marketing, klaviyo, lifecycle, email, sms, approval-gated, phi-safe]
    related_skills:
      - funnel-cro-review
      - lifecycle-marketing-klaviyo
---

# Lifecycle Marketing (Klaviyo) Skill

## Overview

This skill works with Klaviyo lifecycle flows, campaigns, and segments.
It operates in an **approval-first** mode: every write operation (create,
update, trigger, or delete) requires explicit human confirmation before
execution. Read-only audits and drafting are the default mode.

## Usage

```
/skill lifecycle-marketing-klaviyo
```

Or as a sub-agent task with Klaviyo credentials and scope provided.

## Governance Gates

| Gate | Rule |
|------|------|
| Approval-first | Every API call (read or write) requires explicit human confirmation |
| PHI-safe | No raw PII, email addresses, or phone numbers to any backend except Klaviyo |
| Credentials | Klaviyo API key stored in `~/.hermes/.env` as `KLAVIYO_API_KEY` only |
| External send | No email/SMS send without human-approved recipient list and content |
| Read-only default | Audit and draft modes are read-only; write mode needs additional gate |
| Audit log | All Klaviyo interactions are logged to `~/.hermes/logs/` |

## Workflow

### Read-Only Audit (Default)

1. Human provides Klaviyo API key (or confirms it is in `~/.hermes/.env`).
2. Hermes lists all active flows, campaigns, and segments.
3. Hermes produces an audit report: active flows, enrollment criteria, current
   enrollment counts, last-triggered timestamps.
4. No changes made; report delivered to human for review.

### Draft Mode

1. Human requests a new flow or flow modifications.
2. Hermes drafts the flow logic, trigger conditions, and action steps.
3. Human reviews and approves the draft.
4. Hermes presents the exact API payload that would be sent — human approves
   before any write.

### Write Mode (Requires Additional Approval)

1. Human explicitly approves the specific campaign, segment, and content.
2. Hermes executes the exact approved action only.
3. Hermes reports the API response and any error.
4. Rollback steps are documented if the action is destructive.

## Data Handling Rules

| Allowed | Forbidden |
|---------|-----------|
| Klaviyo flow IDs and segment IDs | Raw customer email addresses or phone numbers |
| Aggregated open/click rates | Unmasked customer PII in analysis output |
| Template IDs and names | Customer names or addresses to external tools |
| Synthetic test data | Real customer data in any observability backend |

## Credentials

Klaviyo API key must be in `~/.hermes/.env`:

```
KLAVIYO_API_KEY=pk_xxxxx
```

Never pass the API key as a CLI argument or in a prompt.

## Constraints Summary

- **Approval**: Explicit sign-off required for every write operation.
- **PHI**: Raw PII stays in Klaviyo; no external exposure.
- **Credentials**: `~/.hermes/.env` only; never in code or prompts.
- **Send**: No external send without confirmed recipient list and content.
- **Mode**: Read-only audit is default; write mode is two-step approval.
