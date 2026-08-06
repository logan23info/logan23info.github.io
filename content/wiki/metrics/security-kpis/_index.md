---
title: "Security KPIs"
date: 2026-08-05
tags: ["metrics", "KPIs", "MTTD", "MTTR", "security-metrics"]
categories: ["metrics"]
description: "The security KPIs that matter — operational, vulnerability, risk, and programme metrics, with formulas, targets, and how to calculate them."
showToc: true
layout: "single"
---

## Operational KPIs

### Mean Time to Detect (MTTD)
```
MTTD = Σ(detection_time - incident_start_time) / number_of_incidents

Target: Critical < 15 min, High < 1 hour
Why it matters: the longer an attacker is undetected, the more damage
```

### Mean Time to Respond / Contain (MTTR / MTTC)
```
MTTR = Σ(containment_time - detection_time) / number_of_incidents

Target: Critical < 1 hour, High < 4 hours
Why it matters: measures how fast you stop an active attack
```

### Mean Time to Remediate (MTTRem)
```
MTTRem = Σ(remediation_time - detection_time) / number_of_incidents

Target: varies by severity
Why it matters: full recovery time, not just containment
```

### Alert quality metrics
```
False Positive Rate = false_positives / total_alerts × 100
  Target: < 10% for high-severity rules

Alert-to-Incident Ratio = incidents / total_alerts
  Very low ratio = too much noise (alert fatigue risk)

Escalation Rate = escalated_alerts / total_alerts
  Tracks how many alerts need human analyst time
```

---

## Vulnerability management KPIs

### Remediation SLA compliance
```
SLA Compliance = vulns_remediated_within_SLA / total_vulns × 100

Target SLAs:
  Critical: 100% within 24 hours
  High:     95% within 7 days
  Medium:   90% within 30 days
  Low:      80% within 90 days
```

### Vulnerability remediation velocity
```
Velocity = vulns_closed_this_period / vulns_opened_this_period

> 1.0 = closing faster than opening (good — backlog shrinking)
< 1.0 = backlog growing (bad)
```

### Mean Time to Remediate Vulnerabilities
```python
def calculate_mttr_vulns(vulnerabilities: list[dict]) -> dict:
    """Group remediation time by severity"""
    from collections import defaultdict
    times = defaultdict(list)
    for v in vulnerabilities:
        if v.get("remediated_at"):
            days = (v["remediated_at"] - v["discovered_at"]).days
            times[v["severity"]].append(days)
    return {sev: sum(t)/len(t) for sev, t in times.items() if t}
```

---

## Risk KPIs

### Open risk exposure
```
Track over time:
  - Number of open critical/high risks
  - Total risk score (sum of likelihood × impact)
  - Risks past their remediation due date
  - Trend: is total exposure increasing or decreasing?
```

### Control coverage
```
Control Coverage = assets_with_control / total_applicable_assets × 100

Examples:
  % endpoints with EDR
  % critical systems with MFA
  % repos with secret scanning
  % of ATT&CK techniques with detection coverage

Target: 100% for critical controls on critical assets
```

### Security debt
```
Security Debt = sum of (accepted risk × time outstanding)

Tracks risks that have been accepted but not remediated —
the security equivalent of technical debt
```

---

## Programme KPIs

### Security training
```
Training Completion Rate = completed / required × 100
  Target: > 95%

Phishing Simulation Click Rate = clicked / delivered × 100
  Target: < 5% and decreasing over time
  Track trend, not just absolute — improvement matters most

Phishing Report Rate = reported / delivered × 100
  Target: > 70% (people actively reporting is a strong signal)
```

### Maturity progression
```
Track your position on a maturity model over time:
  See the Security Engineering Maturity Ladder

Measure:
  - Current maturity level per domain
  - Progression rate (levels gained per year)
  - Domains below target maturity
```

---

## Building a KPI dashboard

```python
# security-kpi-dashboard.py — monthly metrics snapshot

def generate_monthly_kpis(month: str) -> dict:
    return {
        "period": month,
        "operational": {
            "mttd_critical_minutes": calculate_mttd("critical"),
            "mttr_critical_hours": calculate_mttr("critical"),
            "false_positive_rate": calculate_fpr(),
            "incidents_total": count_incidents(month),
            "incidents_by_severity": incidents_by_severity(month),
        },
        "vulnerabilities": {
            "critical_open": count_open_vulns("critical"),
            "sla_compliance_pct": vuln_sla_compliance(),
            "remediation_velocity": vuln_velocity(),
            "mean_age_critical_days": mean_vuln_age("critical"),
        },
        "risk": {
            "open_critical_risks": count_open_risks("critical"),
            "total_risk_score": total_risk_exposure(),
            "risks_past_due": count_overdue_risks(),
            "risk_trend": risk_trend_vs_last_month(),
        },
        "coverage": {
            "endpoints_edr_pct": control_coverage("edr"),
            "critical_systems_mfa_pct": control_coverage("mfa"),
            "attack_coverage_pct": attack_technique_coverage(),
        },
        "programme": {
            "training_completion_pct": training_completion(),
            "phishing_click_rate": phishing_click_rate(),
            "phishing_report_rate": phishing_report_rate(),
        },
    }
```

---

## KPI selection checklist

```
For each metric you track, verify:
□ It drives a specific decision or action (not vanity)
□ It has a defined target or threshold
□ It has a clear owner responsible for it
□ It is trended over time, not just a point-in-time value
□ It can be calculated reliably and consistently
□ It is understood by its audience (ops vs board need different metrics)
□ Gaming the metric would not create perverse incentives
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/metrics/board-reporting/"><span class="ref-label">Metrics</span>Board Reporting</a>
  <a class="ref-card" href="/wiki/metrics/risk-appetite/"><span class="ref-label">Metrics</span>Risk Appetite</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review</a>
</div>

</div>
