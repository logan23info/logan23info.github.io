---
title: "Detection Coverage Metrics"
date: 2026-08-05
tags: ["detection-engineering", "metrics", "MTTD", "ATT&CK", "coverage", "KPIs"]
categories: ["detection-engineering"]
description: "How to measure detection programme effectiveness — MTTD, ATT&CK coverage, false positive rate, detection health score, and executive reporting."
showToc: true
layout: "single"
---

## Why measure detection?

"You can't improve what you can't measure." A detection engineering programme without metrics has no way to know whether it is improving, degrading, or missing entire attack categories. Metrics answer three questions:

1. **Are we covering the right threats?** (ATT&CK coverage)
2. **Are our detections working?** (MTTD, false positive rate)
3. **Is the programme getting better?** (trend over time)

---

## Core metric 1 — Mean Time to Detect (MTTD)

**Definition:** Average time from when an attack technique is executed to when an alert fires and reaches a SOC analyst.

**Formula:**
```
MTTD = Σ(time_alert_acknowledged - time_attack_started) / number_of_incidents
```

**Measurement:**
```python
# Track in your SIEM / ticketing system
def calculate_mttd(incidents: list[dict]) -> float:
    """
    incidents: list of {attack_start_time, alert_acknowledged_time}
    Returns MTTD in minutes
    """
    total_minutes = sum(
        (i["alert_acknowledged_time"] - i["attack_start_time"]).total_seconds() / 60
        for i in incidents
        if i.get("attack_start_time") and i.get("alert_acknowledged_time")
    )
    return total_minutes / len(incidents) if incidents else 0

# Target benchmarks
MTTD_TARGETS = {
    "critical": 15,    # 15 minutes
    "high":     60,    # 1 hour
    "medium":   240,   # 4 hours
    "low":      1440,  # 24 hours
}
```

**Industry benchmarks:**
| Maturity level | MTTD |
|---|---|
| Reactive (no programme) | 207 days (IBM 2023) |
| Basic SOC | 72 hours |
| Mature SOC | 4–8 hours |
| Advanced SOC | < 1 hour for critical |

---

## Core metric 2 — ATT&CK Coverage

**Definition:** Percentage of MITRE ATT&CK techniques (relevant to your threat profile) that have at least one detection rule.

**Measurement using ATT&CK Navigator:**

```python
import json
import requests

def calculate_attack_coverage(
    your_rules: list[str],   # list of ATT&CK technique IDs you detect
    threat_profile: list[str]  # techniques used by actors targeting your sector
) -> dict:
    """
    Returns coverage percentage and gap list
    """
    covered = set(your_rules) & set(threat_profile)
    gaps = set(threat_profile) - set(your_rules)

    return {
        "total_techniques_in_profile": len(threat_profile),
        "techniques_detected": len(covered),
        "coverage_percentage": len(covered) / len(threat_profile) * 100,
        "gaps": sorted(list(gaps)),
        "covered": sorted(list(covered))
    }

# Example
result = calculate_attack_coverage(
    your_rules=["T1003.001", "T1059.001", "T1078", "T1110"],
    threat_profile=["T1003.001", "T1059.001", "T1078", "T1110",
                    "T1566", "T1055", "T1021.002", "T1486"]
)
print(f"Coverage: {result['coverage_percentage']:.1f}%")
print(f"Gaps: {result['gaps']}")
```

**ATT&CK Navigator heat map** — visualise coverage:

```json
{
  "name": "Detection Coverage Q3 2026",
  "versions": {"attack": "14", "navigator": "4.9"},
  "techniques": [
    {
      "techniqueID": "T1003.001",
      "color": "#4CAF50",
      "comment": "Detected via Sysmon Event 10 — LSASS access rule",
      "score": 1
    },
    {
      "techniqueID": "T1566.001",
      "color": "#FF5722",
      "comment": "GAP — no phishing email detection rule",
      "score": 0
    }
  ]
}
```

Export this JSON to https://mitre-attack.github.io/attack-navigator/ to generate your coverage heat map.

---

## Core metric 3 — False Positive Rate

**Definition:** Percentage of alerts that are not genuine security incidents.

```
FPR = (false_positive_alerts / total_alerts) × 100
```

**Measurement:**
```python
from collections import Counter

def calculate_fpr_by_rule(alert_dispositions: list[dict]) -> dict:
    """
    alert_dispositions: list of {rule_id, disposition}
    disposition: "true_positive" | "false_positive" | "benign_true_positive"
    """
    by_rule = {}
    for alert in alert_dispositions:
        rule = alert["rule_id"]
        if rule not in by_rule:
            by_rule[rule] = Counter()
        by_rule[rule][alert["disposition"]] += 1

    results = {}
    for rule, counts in by_rule.items():
        total = sum(counts.values())
        fp = counts["false_positive"]
        results[rule] = {
            "total_alerts": total,
            "false_positives": fp,
            "fpr": fp / total * 100 if total > 0 else 0,
            "status": "NOISY" if fp / total > 0.3 else "OK"
        }

    return dict(sorted(results.items(), key=lambda x: x[1]["fpr"], reverse=True))
```

**Target false positive rates:**
| Rule level | Target FPR | Action if exceeded |
|---|---|---|
| Critical | < 5% | Immediate tuning |
| High | < 10% | Tune within 1 week |
| Medium | < 20% | Tune within 1 sprint |
| Low | < 30% | Acceptable — review quarterly |

---

## Core metric 4 — Detection Health Score

A composite score for each detection rule:

```python
def detection_health_score(rule: dict) -> float:
    """
    rule: {
        false_positive_rate: float (0-100),
        days_since_last_tp: int,
        has_playbook: bool,
        last_tested_days_ago: int,
        coverage_gap_priority: int (1-5, 5=critical gap)
    }
    Returns score 0-100 (higher = healthier)
    """
    score = 100.0

    # Penalise high false positive rate
    score -= rule["false_positive_rate"] * 0.5   # -50 if 100% FPR

    # Penalise if no true positive in 90 days (rule may be broken)
    if rule["days_since_last_tp"] > 90:
        score -= 20
    elif rule["days_since_last_tp"] > 180:
        score -= 40

    # Penalise if no playbook linked
    if not rule["has_playbook"]:
        score -= 10

    # Penalise if not tested recently
    if rule["last_tested_days_ago"] > 90:
        score -= 15

    return max(0, min(100, score))
```

---

## Core metric 5 — Detection Coverage by Tactic

Report coverage broken down by ATT&CK tactic — easier for leadership to understand:

```python
TACTIC_COVERAGE = {
    "Initial Access":        {"detected": 3, "total": 9,  "pct": 33},
    "Execution":             {"detected": 8, "total": 14, "pct": 57},
    "Persistence":           {"detected": 4, "total": 19, "pct": 21},
    "Privilege Escalation":  {"detected": 6, "total": 14, "pct": 43},
    "Defense Evasion":       {"detected": 5, "total": 43, "pct": 12},  # ← gap
    "Credential Access":     {"detected": 7, "total": 17, "pct": 41},
    "Discovery":             {"detected": 3, "total": 31, "pct": 10},  # ← gap
    "Lateral Movement":      {"detected": 4, "total": 9,  "pct": 44},
    "Collection":            {"detected": 2, "total": 17, "pct": 12},  # ← gap
    "Command and Control":   {"detected": 6, "total": 17, "pct": 35},
    "Exfiltration":          {"detected": 3, "total": 9,  "pct": 33},
    "Impact":                {"detected": 5, "total": 13, "pct": 38},
}
```

---

## Detection programme dashboard

Track these metrics monthly and present to leadership:

```yaml
# detection-metrics-report-template.yml
report_period: "Q3 2026 (Jul–Sep)"
generated: "2026-10-01"

summary:
  total_rules_in_production: 142
  rules_added_this_quarter: 18
  rules_retired: 3
  overall_attack_coverage: "38%"

mttd:
  critical_alerts: "12 minutes"   # target: 15
  high_alerts: "47 minutes"       # target: 60
  medium_alerts: "3.2 hours"      # target: 4

alert_volume:
  total_alerts: 4820
  true_positives: 312   # 6.5%
  false_positives: 4508 # 93.5% — too high, see noisy rules
  incidents_created: 28

noisy_rules_top5:
  - rule: "PowerShell Encoded Command"
    fpr: 87%
    action: "Adding filter for SCCM — deploy next week"
  - rule: "After-Hours Login"
    fpr: 72%
    action: "Adding shift worker exclusion list"

coverage_gaps_priority:
  - technique: "T1566 Phishing"
    priority: critical
    plan: "Email gateway use case in sprint 42"
  - technique: "T1055 Process Injection"
    priority: high
    plan: "Sysmon tuning required first"

purple_team_results:
  exercises_run: 2
  techniques_tested: 45
  detection_rate: "62%"   # target: 70%
  gaps_remediated: 8
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/detection-engineering/sigma-rules/"><span class="ref-label">Detection</span>Sigma Rule Writing Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/alert-fatigue/"><span class="ref-label">Detection</span>Alert Fatigue Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Case Library</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
</div>

</div>
