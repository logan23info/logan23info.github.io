---
title: "Test of Operating Effectiveness (ToOE)"
date: 2026-08-02
tags: ["ToOE", "test-of-operating-effectiveness", "assurance", "audit", "controls"]
categories: ["governance"]
description: "Test of Operating Effectiveness — validating that security controls have operated consistently and effectively over a defined period."
showToc: true
---

## What is a Test of Operating Effectiveness?

A Test of Operating Effectiveness (ToOE) is an assurance activity that validates whether a security control has **operated consistently and effectively over a defined review period** — typically 3, 6, or 12 months. It moves beyond point-in-time testing to assess whether the control is reliably embedded in day-to-day operations.

A control can pass ToD (well designed) and ToI (correctly implemented) but fail ToOE because:
- The control worked at implementation but was later misconfigured or disabled
- The control operates inconsistently — works sometimes, fails at other times
- The control is not being followed by staff (human controls)
- Exceptions to the control are not being managed
- The control has not kept pace with changes to the environment

ToOE is equivalent to **SOC 2 Type II** — an auditor's opinion that controls have operated effectively over a period.

---

## Review periods

| Assurance type | Typical review period | Used for |
|---|---|---|
| SOC 2 Type II | 6 or 12 months | Customer-facing assurance |
| ISO 27001 surveillance audit | 12 months | Certification maintenance |
| PCI-DSS | 12 months (continuous) | Card payment compliance |
| DORA ICT assurance | 12 months | EU financial regulation |
| Internal quarterly review | 3 months | Management reporting |
| Continuous monitoring | Real-time | Automated control monitoring |

---

## ToOE testing techniques

### 1. Population-based sampling

For controls that operate on transactions or events, test a statistically valid sample from the review period.

**Sampling approach:**
```
Population: All user access provisioning requests (Jan–Jun 2026)
Total population: 847 requests
Sample size: 25 (using AICPA attribute sampling at 5% tolerable deviation)

For each sample:
□ Was the request approved by the correct approver?
□ Was access granted within the defined SLA?
□ Was access granted matching only what was requested (least privilege)?
□ Was the access reviewed in the quarterly access review?
```

**Sampling sizes (risk-based):**

| Control risk | Population size | Sample size |
|---|---|---|
| High | Any | 25–40 |
| Medium | > 100 | 15–25 |
| Medium | 25–100 | 10–15 |
| Low | Any | 5–10 |

### 2. Continuous control monitoring

Automate ToOE by monitoring control metrics continuously:

```python
# Example: Automated MFA compliance monitoring
# Runs daily, reports to SIEM

import boto3
from datetime import datetime, timezone

def check_mfa_compliance():
    iam = boto3.client('iam')
    users = iam.list_users()['Users']

    non_compliant = []
    for user in users:
        mfa_devices = iam.list_mfa_devices(UserName=user['UserName'])['MFADevices']
        if not mfa_devices:
            non_compliant.append({
                'user': user['UserName'],
                'created': str(user['CreateDate']),
                'last_active': str(user.get('PasswordLastUsed', 'Never')),
                'finding': 'MFA_NOT_ENROLLED'
            })

    compliance_rate = (len(users) - len(non_compliant)) / len(users) * 100

    return {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'control': 'MFA_ENFORCEMENT',
        'total_users': len(users),
        'compliant': len(users) - len(non_compliant),
        'non_compliant': len(non_compliant),
        'compliance_rate': round(compliance_rate, 2),
        'findings': non_compliant
    }
```

### 3. Exception testing

Review the exception log for the control — cases where the control was bypassed, overridden, or failed — and assess whether exceptions were:
- Formally approved with documented business justification
- Time-limited (not permanent exceptions)
- Risk-accepted by an appropriate authority
- Reviewed and closed when no longer needed

**Exception register template:**

```yaml
control: "MFA_ENFORCEMENT"
exception_id: "EXC-2026-0042"
requestor: "team-legacy"
approver: "CISO"
business_justification: "Legacy integration system does not support MFA"
risk_acceptance: "Compensating control: IP allowlisting + API key rotation"
start_date: "2026-02-01"
expiry_date: "2026-08-01"
status: "active"
review_date: "2026-05-01"
reviewed_by: "security-team"
```

### 4. Trend analysis

Plot control performance metrics over the review period to identify:
- Degradation trends (control working less well over time)
- Seasonal patterns (control fails during high-change periods)
- Incident correlation (control failed before/during a security incident)

```python
# Example metrics to track over time
control_metrics = {
    "patch_compliance": {
        "Jan": 94.2, "Feb": 96.1, "Mar": 91.8,  # Dip in March — change freeze lifted
        "Apr": 95.4, "May": 97.2, "Jun": 96.8
    },
    "mfa_compliance": {
        "Jan": 99.1, "Feb": 99.3, "Mar": 99.0,
        "Apr": 97.2,  # Dip — new joiners not enrolled within SLA
        "May": 99.4, "Jun": 99.6
    },
    "siem_alert_response_sla": {
        "Jan": 87.0, "Feb": 89.2, "Mar": 91.0,
        "Apr": 92.1, "May": 88.3, "Jun": 93.4
    }
}
```

### 5. Inquiry and observation

For human-operated controls, supplement evidence testing with:
- **Inquiry:** Interview the control owner — can they describe the control accurately?
- **Observation:** Watch the control being performed — does it match the documented procedure?
- **Re-performance:** Independently re-perform the control to verify the output

---

## ToOE by control domain

### Identity & Access Management

| Control | Review period | Evidence to request | Pass criteria |
|---|---|---|---|
| Quarterly access review | 12 months | 4 completed access review sign-offs | All 4 completed within 5 days of quarter end |
| Leaver access removal | 6 months | HR termination list vs access removal logs | 100% removed within 4-hour SLA |
| Privileged access review | 12 months | PAM session logs, admin account list | No unapproved admin accounts at any point |
| Service account rotation | 12 months | Key rotation logs, API key inventory | All keys rotated per policy (e.g. 90 days) |
| MFA compliance | 6 months | Monthly MFA compliance reports | >99% compliance throughout period |

### Vulnerability Management

| Control | Review period | Evidence to request | Pass criteria |
|---|---|---|---|
| Critical patch SLA | 6 months | Scan reports + patch deployment logs | 100% critical patches applied within 24h |
| High patch SLA | 6 months | Scan reports + patch deployment logs | 95%+ high patches applied within 7 days |
| Vulnerability scan coverage | 6 months | Monthly scan reports | 100% of in-scope assets scanned monthly |
| Penetration test | 12 months | Pen test report + remediation tracking | Annual test conducted, criticals remediated |

### Security Monitoring

| Control | Review period | Evidence to request | Pass criteria |
|---|---|---|---|
| SIEM alert response | 6 months | Alert queue, ticket logs, SLA report | >95% high alerts responded within SLA |
| Log source availability | 6 months | Monthly log source health reports | >99% uptime for critical log sources |
| Threat hunting | 12 months | Hunt reports, hypothesis log | At least 4 documented hunts per year |
| Incident response testing | 12 months | Tabletop exercise report | Annual exercise conducted |

### Change Management

| Control | Review period | Evidence to request | Pass criteria |
|---|---|---|---|
| Security review in SDLC | 6 months | Sample 25 change tickets — verify security review | 100% of high-risk changes have security sign-off |
| Threat model currency | 12 months | Threat model timestamps vs change log | TM reviewed within 90 days of significant change |
| Emergency change approval | 6 months | Emergency change log | All emergency changes retrospectively approved |

---

## ToOE finding classifications

| Finding | Definition | Impact |
|---|---|---|
| **Operating Deficiency** | Control failed to operate on one or more occasions | Material — requires remediation and root cause analysis |
| **Significant Deficiency** | Control failed systematically or repeatedly | High — report to senior management, remediation plan required |
| **Material Weakness** | Control failure resulted in or could result in material error | Critical — immediate escalation, compensating controls required |
| **Operating Observation** | Control operating but with minor gaps | Low — management recommendation |
| **Operating Pass** | Control operated effectively throughout period | No action required |

---

## Continuous control monitoring (CCM) framework

The most mature ToOE approach automates evidence collection and testing:

```yaml
# control-monitoring.yml — declarative CCM config
controls:
  - id: "CCM-001"
    name: "MFA Enforcement"
    owner: "identity-team"
    frequency: "daily"
    source: "aws-iam-mfa-report"
    threshold:
      metric: "compliance_rate"
      operator: ">="
      value: 99.0
    alert_on_breach: true
    evidence_retention: "12-months"
    report_to: ["security-team", "internal-audit"]

  - id: "CCM-002"
    name: "Critical Patch SLA"
    owner: "platform-team"
    frequency: "weekly"
    source: "vulnerability-scanner"
    threshold:
      metric: "critical_unpatched_over_24h"
      operator: "=="
      value: 0
    alert_on_breach: true
    evidence_retention: "12-months"
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/"><span class="ref-label">Assurance</span>Advisory & Assurance Overview</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation (ToI)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming — validates detection controls</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
</div>

</div>
