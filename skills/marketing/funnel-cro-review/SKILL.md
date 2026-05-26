---
name: funnel-cro-review
description: |
  Read-only funnel and conversion rate optimisation (CRO) review skill. Analyses
  funnel data, user journey maps, and metrics to provide actionable CRO
  recommendations. No side effects — no writes to production systems, no sending
  of external communications, no access to raw customer PII/PHI. All analysis is
  performed on anonymised or aggregated data. Suitable for reviewing marketing
  funnels, identifying drop-off points, and suggesting conversion experiments.
  GATES: (1) Analysis only — no automated changes to live systems. (2) No raw
  customer PII or PHI used in any analysis. (3) No external send (email, SMS,
  webhook) without explicit approval. (4) Report findings to human for approval
  before any downstream action. (5) Aggregated/anonymised data only.
version: "1.0"
author: Hermes Platform Team
license: MIT
platforms: [macOS, Linux, Windows]
metadata:
  hermes:
    tags: [marketing, cro, funnel, analytics, read-only, review]
    related_skills:
      - lifecycle-marketing-klaviyo
      - growth-marketing-systems
---

# Funnel CRO Review Skill

## Overview

This skill performs read-only analysis of marketing funnels and conversion
metrics. It identifies drop-off points, surfaces high-impact optimisation
opportunities, and delivers actionable CRO recommendations — without making
any automated changes to live systems.

## Usage

```
/skill funnel-cro-review
```

Or as a sub-agent task with funnel data or access credentials provided by the
human.

## Governance Gates

| Gate | Rule |
|------|------|
| Read-only | No writes to any live system; analysis only |
| Data privacy | No raw PII/PHI; use aggregated or anonymised data only |
| External send | No email, SMS, webhook, or external communication without explicit approval |
| Action gate | All recommendations reported to human; no automated downstream changes |
| Data source | Only use data the human has explicitly provided or authorised access to |

## Workflow

1. **Data receipt** — receive funnel data (CSV, JSON, screenshot, or direct query) from the human.
2. **Confirm scope** — confirm which funnel stages and metrics are in scope.
3. **Analysis** — run dry-run analysis: drop-off rates, micro-conversion ratios, cohort comparisons.
4. **Report** — present findings with supporting data; highlight top 3-5 opportunities.
5. **Recommendation** — propose next steps for human review. No automatic implementation.

## Analysis Scope

Typical inputs:
- Session recordings (anonymised)
- Analytics funnel exports (Google Analytics, Mixpanel, Amplitude, etc.)
- A/B test results
- Landing page heatmaps (anonymised)
- CRM funnel stages

Never input:
- Raw customer lists with PII
- Unmasked transaction records
- Secrets or credentials

## Output Format

Provide:
1. **Executive summary** (3-5 bullet points)
2. **Funnel stage breakdown** with drop-off percentages
3. **Top 3 opportunities** with estimated impact and confidence level
4. **Recommended experiments** (A/B test hypotheses)
5. **Next steps** requiring human approval

## Constraints Summary

- **Side effects**: None — purely analytical.
- **Data**: Aggregated/anonymised only; no raw PII or PHI.
- **Communication**: No external send without approval.
- **Action**: Recommendations reported to human; no automated implementation.
- **Scope**: Limited to data explicitly provided by the human.
