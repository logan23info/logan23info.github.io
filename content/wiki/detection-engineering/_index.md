---
title: "Detection Engineering"
date: 2026-08-05
tags: ["detection-engineering", "SIEM", "Sigma", "SOC", "alerts", "monitoring"]
categories: ["detection-engineering"]
description: "Detection Engineering reference — SIEM use case library, Sigma rule writing, detection coverage metrics, alert fatigue management, and SOC playbook templates."
showToc: true
layout: "single"
---

## What is Detection Engineering?

Detection Engineering is the discipline of **systematically designing, building, testing, and maintaining security detection rules** — the logic that turns raw security events into actionable alerts. It is the bridge between threat intelligence, threat modelling, and the SOC analyst who responds to alerts at 2am.

Done well, detection engineering means:
- Alerts fire on real threats, not noise
- Every alert has a clear playbook to follow
- Detection gaps are measured and systematically closed
- Detections are tested continuously, not just at deployment

---

## How detection engineering fits the maturity ladder

| Maturity level | Detection engineering role |
|---|---|
| Level 1 — Threat Modelling | Threat model findings define what to detect |
| Level 3 — Red Teaming | Red team TTPs become detection hypotheses |
| Level 4 — Purple Teaming | Purple team validates detection coverage |
| Level 5 — Threat Intelligence | IOCs and TTPs feed detection rule library |

Detection engineering operationalises threat intelligence and closes the loop from "we know this attack exists" to "we will detect it."

---

## Pages in this section

| Page | Description |
|---|---|
| [SIEM Use Case Library](/wiki/detection-engineering/siem-use-cases/) | 50+ use cases across authentication, network, endpoint, cloud, and insider threat |
| [Sigma Rule Writing Guide](/wiki/detection-engineering/sigma-rules/) | Writing, testing, and deploying vendor-neutral Sigma detection rules |
| [Detection Coverage Metrics](/wiki/detection-engineering/detection-metrics/) | Measuring MTTD, ATT&CK coverage, false positive rate, and detection health |
| [Alert Fatigue Guide](/wiki/detection-engineering/alert-fatigue/) | Diagnosing and fixing alert fatigue — tuning, triage, and automation |
| [SOC Playbook Templates](/wiki/detection-engineering/soc-playbooks/) | Response playbooks for the most common alert types |

---

## The detection engineering lifecycle

```
Threat Intel / Threat Model / Red Team Finding
              ↓
    Detection Hypothesis
    "If attacker does X, we would see Y in log Z"
              ↓
    Log Source Validation
    "Does log Z actually capture Y?"
              ↓
    Rule Development (Sigma)
              ↓
    Testing (Atomic Red Team / Purple Team)
              ↓
    Tuning (reduce false positives)
              ↓
    Deployment to SIEM
              ↓
    Continuous Monitoring (false positive rate, MTTD)
              ↓
    Regression Testing (weekly/monthly)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/owasp-top10/a09-logging-failures/"><span class="ref-label">OWASP</span>A09 Logging & Monitoring Failures</a>
</div>

</div>
