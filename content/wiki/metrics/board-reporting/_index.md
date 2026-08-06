---
title: "Board Reporting"
date: 2026-08-05
tags: ["metrics", "board-reporting", "governance", "CISO", "executive"]
categories: ["metrics"]
description: "Communicating security to the board and executives — what boards care about, how to frame risk in business terms, and a board report template."
showToc: true
layout: "single"
---

## What boards actually care about

Boards do not care about the number of blocked attacks or CVE counts. They have three core questions:

```
1. Are we spending the right amount on security? (not too much, not too little)
2. What is our actual risk exposure? (in business terms — money, reputation, continuity)
3. Are we better or worse than last quarter? (trend and trajectory)
```

Everything in a board report should answer one of these questions.

---

## Translating security into business language

| Don't say | Do say |
|---|---|
| "We blocked 4 million attacks" | "Our controls are working as designed; no material incidents this quarter" |
| "We have 200 critical CVEs" | "We reduced critical vulnerability exposure by 40%, on track to target by Q3" |
| "MTTD is 15 minutes" | "We can now detect a serious breach in minutes rather than the industry-average 200 days, limiting potential damage" |
| "We deployed EDR" | "We closed a gap that was our highest residual risk; this reduces our ransomware exposure significantly" |
| "We need budget for a SIEM" | "A £200k investment reduces our estimated breach cost exposure of £5M by roughly 60%" |

---

## Framing risk in financial terms

Boards think in money. Use quantified risk where possible.

```
Annualised Loss Expectancy (ALE):
  ALE = Single Loss Expectancy (SLE) × Annual Rate of Occurrence (ARO)

Example:
  Ransomware event cost (SLE): £2,000,000
  Likelihood per year (ARO): 0.15 (15% chance)
  ALE = £2,000,000 × 0.15 = £300,000/year

  Proposed control cost: £80,000/year
  Control reduces ARO to 0.05
  New ALE = £2,000,000 × 0.05 = £100,000/year
  Risk reduction: £200,000/year for £80,000 spend → strong ROI
```

This turns "we should buy EDR" into "spending £80k saves £200k in expected losses" — a language boards act on.

---

## Board report template

```markdown
# Security Update — [Quarter/Board Meeting Date]
# Prepared by: [CISO] | Classification: Board Confidential

## 1. Executive summary (1 paragraph)
[The single most important message. E.g. "Security posture improved this
quarter. No material incidents. We closed our highest residual risk (ransomware)
and are on track to achieve target maturity by year-end. One emerging risk
requires board attention: [X]."]

## 2. Risk posture — the headline

| Risk area | Last quarter | This quarter | Trend | Target |
|---|---|---|---|---|
| Overall risk rating | Medium-High | Medium | ↓ improving | Medium |
| Ransomware exposure | High | Medium | ↓ | Low |
| Third-party risk | Medium | Medium | → | Medium |
| Regulatory compliance | On track | On track | → | Compliant |

## 3. Key metrics (trend-focused)

| Metric | This Q | Last Q | Target | Status |
|---|---|---|---|---|
| Critical vulns open | 12 | 34 | < 10 | ↓ on track |
| MTTD (critical) | 14 min | 45 min | < 15 min | ✓ met |
| Security training completion | 96% | 89% | > 95% | ✓ met |
| Phishing click rate | 4.2% | 7.1% | < 5% | ✓ met |

## 4. Incidents this quarter
- [Number] incidents, [number] material
- [Brief description of any significant incident and resolution]
- No customer data compromised / [or specific detail]

## 5. Investment and budget
- Current spend vs budget: [on track / over / under]
- Key investments this quarter: [what and why, with ROI framing]
- Requested decisions: [any budget asks with business justification]

## 6. Emerging risks requiring board awareness
- [Risk 1: description, potential impact, proposed response]

## 7. Decisions requested from the board
- [Specific decision 1]
- [Specific decision 2]
```

---

## Presentation principles

```
□ Lead with the conclusion — boards read the first paragraph, then decide
   how much more to read
□ One page of key messages — detail in appendices
□ Trends over absolutes — "improving from X to Y" beats a raw number
□ Business impact, not technical detail — money, reputation, continuity
□ Be honest about bad news — boards distrust reports that are always green
□ Every ask has a business justification — quantify the ROI
□ Use a consistent format quarter-over-quarter — enables trend tracking
□ Traffic-light status (red/amber/green) for at-a-glance scanning
```

---

## Common board reporting mistakes

```
✗ Too technical — CVE numbers, tool names, jargon
✗ All green all the time — boards stop believing it
✗ No trend — a number with no comparison is meaningless
✗ No business context — "200 vulns" means nothing without impact
✗ Vanity metrics — attacks blocked, alerts generated
✗ No ask — reporting without decisions wastes board time
✗ Inconsistent format — prevents quarter-over-quarter comparison
✗ Fear-based — crying wolf erodes credibility over time
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/metrics/security-kpis/"><span class="ref-label">Metrics</span>Security KPIs</a>
  <a class="ref-card" href="/wiki/metrics/risk-appetite/"><span class="ref-label">Metrics</span>Risk Appetite</a>
  <a class="ref-card" href="/wiki/advisory-assurance/advisory-assurance/"><span class="ref-label">Assurance</span>Advisory & Assurance</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder</a>
  <a class="ref-card" href="/wiki/compliance/"><span class="ref-label">Compliance</span>Compliance Mappings</a>
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
</div>

</div>
