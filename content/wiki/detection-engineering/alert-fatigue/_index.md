---
title: "Alert Fatigue Guide"
date: 2026-08-05
tags: ["alert-fatigue", "SIEM", "tuning", "SOC", "detection-engineering", "triage"]
categories: ["detection-engineering"]
description: "Diagnosing and fixing alert fatigue — root causes, tuning methods, triage automation, and how to rebuild analyst trust in the alert queue."
showToc: true
layout: "single"
---

## What is alert fatigue?

Alert fatigue occurs when SOC analysts receive so many alerts that they become desensitised — missing genuine incidents buried in noise. It is one of the most dangerous conditions in a security operations centre, and it is almost entirely self-inflicted.

**The consequences:**
- Analysts begin ignoring alerts or closing them without investigation
- Genuine incidents are missed — average dwell time increases
- Analyst burnout and turnover increases
- Trust in the security programme collapses

**The numbers:** Studies consistently show that SOC teams receive hundreds to thousands of alerts per day, of which fewer than 10% are genuine incidents. In some environments, false positive rates exceed 99%.

---

## Diagnosing alert fatigue

### Step 1 — Measure your false positive rate

```python
# Query your SIEM/SOAR for alert dispositions over 30 days
def diagnose_alert_fatigue(alerts_30_days: list[dict]) -> dict:
    from collections import Counter
    dispositions = Counter(a["disposition"] for a in alerts_30_days)
    total = len(alerts_30_days)

    report = {
        "total_alerts": total,
        "per_day_average": total / 30,
        "true_positives": dispositions.get("true_positive", 0),
        "false_positives": dispositions.get("false_positive", 0),
        "closed_without_investigation": dispositions.get("closed", 0),
        "fpr_percent": dispositions.get("false_positive", 0) / total * 100,
    }

    # Diagnosis
    if report["per_day_average"] > 500:
        report["diagnosis"] = "CRITICAL: volume too high for human review"
    elif report["fpr_percent"] > 70:
        report["diagnosis"] = "SEVERE: most alerts are noise"
    elif report["closed_without_investigation"] / total > 0.3:
        report["diagnosis"] = "WARNING: analysts closing without investigating"
    else:
        report["diagnosis"] = "MANAGEABLE"

    return report
```

### Step 2 — Identify your noisiest rules

```sql
-- SIEM query: top 20 noisiest rules by false positive count
SELECT
    rule_name,
    COUNT(*) AS total_alerts,
    SUM(CASE WHEN disposition = 'false_positive' THEN 1 ELSE 0 END) AS fp_count,
    SUM(CASE WHEN disposition = 'false_positive' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS fpr,
    MAX(last_true_positive_date) AS last_tp
FROM alert_log
WHERE alert_time > NOW() - INTERVAL '30 days'
GROUP BY rule_name
HAVING fpr > 50
ORDER BY fp_count DESC
LIMIT 20
```

### Step 3 — Categorise the noise

| Noise type | Example | Fix |
|---|---|---|
| **Environmental** | Dev environment triggering prod rules | Add environment tag exclusion |
| **Tool-based** | Security scanner triggering brute force rule | Add scanner IP exclusion |
| **Threshold wrong** | 5 failed logins = alert (too low) | Raise threshold to 20 |
| **Logic flaw** | Rule fires on any admin action | Narrow to after-hours only |
| **Missing context** | No enrichment — analyst can't triage | Add GeoIP, asset owner, user context |
| **Duplicate** | 5 rules detect the same thing | Consolidate into one |

---

## Fixing alert fatigue — the tuning framework

### Method 1 — Add exclusions (fastest fix)

```yaml
# Before tuning — fires on every PowerShell with -enc
detection:
  selection:
    Image|endswith: '\powershell.exe'
    CommandLine|contains: '-EncodedCommand'
  condition: selection

# After tuning — excludes known-good sources
detection:
  selection:
    Image|endswith: '\powershell.exe'
    CommandLine|contains: '-EncodedCommand'
  filter_sccm:
    ParentImage|endswith: '\CCMExec.exe'    # SCCM client
  filter_intune:
    ParentImage|endswith: '\IntuneManagementExtension.exe'
  filter_chocolatey:
    CommandLine|contains: 'ChocolateyInstall'
  filter_legitimate_paths:
    CommandLine|contains:
      - 'C:\Program Files\WindowsPowerShell\Modules\'
      - 'C:\ProgramData\Microsoft\Windows Defender\'
  condition: selection and not 1 of filter_*
```

### Method 2 — Raise thresholds

```yaml
# Before — triggers on 5 failed logins (too low)
detection:
  selection:
    event_id: 4625
  condition: selection | count() > 5

# After — tuned to your environment baseline
detection:
  selection:
    event_id: 4625
  condition: selection | count() by SubjectUserName > 20
  timeframe: 5m
  # Also: different threshold per account type
  # Service accounts: > 3 (should never fail)
  # Regular users: > 20
  # Admin accounts: > 5
```

### Method 3 — Add enrichment to reduce triage time

The fastest way to reduce analyst time per alert is giving them context automatically:

```python
# SOAR playbook — auto-enrich every alert before routing to analyst
def enrich_alert(alert: dict) -> dict:
    enriched = alert.copy()

    # GeoIP for source IP
    if alert.get("source_ip"):
        enriched["geo"] = geoip_lookup(alert["source_ip"])
        enriched["is_vpn"] = check_vpn_list(alert["source_ip"])
        enriched["is_tor"] = check_tor_exit(alert["source_ip"])
        enriched["threat_intel"] = check_threat_intel(alert["source_ip"])

    # User context
    if alert.get("username"):
        enriched["user_department"] = hr_api.get_department(alert["username"])
        enriched["user_manager"] = hr_api.get_manager(alert["username"])
        enriched["user_on_leave"] = hr_api.is_on_leave(alert["username"])
        enriched["user_recent_travel"] = travel_api.get_recent(alert["username"])
        enriched["user_last_login_country"] = auth_logs.get_last_country(alert["username"])

    # Asset context
    if alert.get("hostname"):
        enriched["asset_owner"] = cmdb.get_owner(alert["hostname"])
        enriched["asset_criticality"] = cmdb.get_criticality(alert["hostname"])
        enriched["asset_environment"] = cmdb.get_environment(alert["hostname"])  # prod/dev/test
        enriched["asset_in_scope"] = cmdb.is_in_pci_scope(alert["hostname"])

    # Previous alert history
    enriched["previous_alerts_30d"] = siem.count_alerts(
        username=alert.get("username"),
        days=30
    )

    return enriched
```

### Method 4 — Automated triage (close the easy ones automatically)

```python
def auto_triage_alert(alert: dict) -> str:
    """
    Returns: "auto_close" | "escalate" | "human_review"
    """
    # Auto-close: alert from development environment
    if alert.get("asset_environment") == "development":
        if alert["rule_level"] not in ["critical"]:
            return "auto_close", "dev_environment"

    # Auto-close: known scanner IP
    if alert.get("source_ip") in KNOWN_SCANNER_IPS:
        return "auto_close", "known_scanner"

    # Auto-close: user on approved travel
    if alert.get("rule_id") == "impossible-travel":
        if alert.get("user_recent_travel"):
            return "auto_close", "approved_travel"

    # Auto-escalate: any critical from production
    if alert["rule_level"] == "critical" and alert.get("asset_environment") == "production":
        return "escalate", "critical_production"

    # Auto-escalate: matches active threat intel IOC
    if alert.get("threat_intel", {}).get("matched"):
        return "escalate", "threat_intel_match"

    return "human_review", "standard_triage"
```

### Method 5 — Alert grouping / correlation

```python
# Group related alerts into a single incident
def correlate_alerts(alerts: list[dict], window_minutes: int = 30) -> list[dict]:
    """
    Groups alerts by (username, source_ip) within time window
    Returns list of incident groups
    """
    groups = {}
    for alert in sorted(alerts, key=lambda a: a["timestamp"]):
        key = (
            alert.get("username", "unknown"),
            alert.get("source_ip", "unknown")
        )
        if key not in groups:
            groups[key] = {
                "alerts": [],
                "first_seen": alert["timestamp"],
                "tactics": set(),
                "severity": alert["rule_level"]
            }
        groups[key]["alerts"].append(alert)
        groups[key]["tactics"].add(alert.get("tactic", "unknown"))
        # Escalate severity if multiple tactics involved
        if len(groups[key]["tactics"]) > 2:
            groups[key]["severity"] = "critical"

    return list(groups.values())
```

---

## Rebuilding analyst trust

After fixing the noise, you need to rebuild the habit of investigating alerts:

### The alert quality contract

Publish this commitment to your analysts:

```
Detection Engineering ↔ SOC Analyst Contract

We commit to:
□ Any rule with FPR > 30% will be tuned within 5 business days
□ Every alert includes: context, enrichment, and a playbook link
□ We will not add new rules without testing them first
□ You can flag any alert as "too noisy" and we will investigate within 48 hours

You commit to:
□ Every alert disposition is recorded (TP, FP, BTP)
□ False positives include a comment explaining why
□ Escalation happens within SLA (Critical: 15 min, High: 1 hour)
```

### Weekly alert quality review

```
Every Monday, 30 minutes:
1. Review top 5 noisiest rules from previous week
2. One tuning ticket created for each rule > 50% FPR
3. Review any rules with 0 TPs in 30 days — consider disabling
4. Review new ATT&CK techniques — any new detections to write?
5. Review purple team findings — which gaps to close this sprint?
```

---

## Alert triage decision tree

```
Alert fires
    │
    ▼
Is this from a dev/test environment?
    ├── YES → Auto-close (dev noise)
    └── NO ↓
Is the source IP a known scanner / tool?
    ├── YES → Auto-close (tool noise)
    └── NO ↓
Does it match active threat intel?
    ├── YES → Immediate escalation
    └── NO ↓
Is the asset critical (Tier 1)?
    ├── YES → Human review within 15 min
    └── NO ↓
Is it Critical/High severity?
    ├── YES → Human review within 1 hour
    └── NO → Human review within 4 hours
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/detection-engineering/sigma-rules/"><span class="ref-label">Detection</span>Sigma Rule Writing Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/detection-engineering/soc-playbooks/"><span class="ref-label">Detection</span>SOC Playbook Templates</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Case Library</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/owasp-top10/a09-logging-failures/"><span class="ref-label">OWASP</span>A09 Logging Failures</a>
</div>

</div>
