---
title: "Security Metrics & KPIs"
date: 2026-08-05
tags: ["metrics", "KPIs", "security-metrics", "board-reporting", "risk-appetite"]
categories: ["metrics"]
description: "Security metrics and KPIs — measuring programme effectiveness, board reporting, and risk appetite frameworks."
showToc: true
layout: "single"
---

## Why security metrics matter

Security programmes compete for budget and attention. Without metrics, security is a cost centre making unquantified claims. With good metrics, security becomes a measurable business function that demonstrates value, justifies investment, and drives improvement.

The challenge: measuring the *absence* of incidents is hard, and vanity metrics (number of blocked attacks, patches applied) don't reflect actual risk reduction.

---

## Pages in this section

| Page | Description |
|---|---|
| [Security KPIs](/wiki/metrics/security-kpis/) | The metrics that matter — operational, risk, and programme KPIs |
| [Board Reporting](/wiki/metrics/board-reporting/) | Communicating security to executives and the board |
| [Risk Appetite](/wiki/metrics/risk-appetite/) | Defining and operationalising risk appetite |

---

## Good vs vanity metrics

| Vanity metric (avoid) | Meaningful metric (use) |
|---|---|
| Number of attacks blocked | Mean time to detect (MTTD) |
| Number of patches applied | % critical vulns remediated within SLA |
| Number of alerts generated | False positive rate, alert-to-incident ratio |
| Number of training emails sent | Phishing simulation click rate trend |
| Number of firewall rules | % of critical assets with tested controls |
| Total vulnerabilities found | Vulnerability remediation velocity |

The test: does the metric drive a *decision* or *action*? If not, it's vanity.

---

## Metric categories

```
OPERATIONAL METRICS — how well the SOC/security ops run
  MTTD, MTTR, alert volume, false positive rate, coverage

RISK METRICS — how much risk the organisation carries
  Open critical risks, risk trend, control coverage, exposure

PROGRAMME METRICS — how the security programme matures
  Maturity level, training completion, policy compliance, audit findings

BUSINESS METRICS — security's impact on the business
  Cost per incident, security ROI, compliance status, downtime avoided
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/metrics/security-kpis/"><span class="ref-label">Metrics</span>Security KPIs</a>
  <a class="ref-card" href="/wiki/metrics/board-reporting/"><span class="ref-label">Metrics</span>Board Reporting</a>
  <a class="ref-card" href="/wiki/metrics/risk-appetite/"><span class="ref-label">Metrics</span>Risk Appetite</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
</div>

</div>
