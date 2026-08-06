---
title: "SOC 2 Type II"
date: 2026-08-05
tags: ["SOC2", "compliance", "trust-service-criteria", "SaaS", "audit"]
categories: ["compliance"]
description: "SOC 2 Type II compliance guide — Trust Service Criteria, controls mapping, evidence requirements, and readiness checklist."
showToc: true
layout: "single"
---

## What is SOC 2?

SOC 2 (System and Organisation Controls 2) is an auditing standard developed by the AICPA for technology service providers. It evaluates controls over security, availability, processing integrity, confidentiality, and privacy. A SOC 2 Type II report covers a period of time (typically 6–12 months) and is the gold standard for SaaS security assurance.

**Who needs it:** SaaS companies, cloud service providers, managed service providers — any organisation storing or processing customer data.
**Auditor:** Licensed CPA firm.
**Type I vs Type II:** Type I = controls are suitably designed (point in time). Type II = controls operated effectively over a period (typically 6–12 months).

---

## Trust Service Criteria (TSC)

| Category | Required? | Description |
|---|---|---|
| **Security (CC)** | Always | Protection against unauthorised access |
| Availability (A) | Optional | System is available as committed |
| Processing Integrity (PI) | Optional | Processing is complete, accurate, timely |
| Confidentiality (C) | Optional | Confidential information is protected |
| Privacy (P) | Optional | Personal information is handled per AICPA privacy principles |

Most SaaS companies include Security + Availability + Confidentiality.

---

## Common Criteria — security engineering mapping

### CC6.1 — Logical access security

| Control | Engineering implementation | Evidence |
|---|---|---|
| Access control policy | RBAC with least privilege | IAM policy documents |
| MFA for all users | Conditional access / MFA enforcement | MFA compliance report |
| Privileged access managed | PAM solution, quarterly review | Access review sign-offs |
| New user provisioning | Approvals workflow documented | Onboarding tickets |
| User removal | Leaver process with SLA | HR termination list vs IAM |

```bash
# Evidence collection for CC6.1
# Monthly MFA compliance report
aws iam generate-credential-report
aws iam get-credential-report | base64 -d | \
  awk -F, 'NR>1 {print $1","$8}' > mfa-compliance-$(date +%Y%m).csv

# Quarterly access review — export for manager review
aws iam get-account-authorization-details > iam-access-review-$(date +%Y%m).json
```

### CC6.6 — Logical access from outside CDE

```
SOC 2 CC6.6 requires:
□ Logical access from outside the system boundaries uses multi-factor auth
□ Remote access requires VPN or Zero Trust network access
□ Access from unmanaged devices is restricted
□ Session timeout enforced for remote access
```

### CC7.1 — Detection and monitoring

```yaml
# SOC 2 CC7.1 evidence package
monitoring_programme:
  log_sources:
    - Authentication events (all success and failure)
    - Admin/privileged actions
    - Data access (create, read, update, delete)
    - System changes (config, deployments)
    - Security tool alerts (EDR, SIEM)

  alerting:
    - Brute force: >20 failures in 5 min
    - Privilege escalation: new admin role assigned
    - Bulk data access: >1000 records in 1 hour

  review:
    - SOC analyst reviews alert queue daily
    - Weekly detection rule review
    - Monthly FPR metrics to management

  evidence:
    - SIEM dashboard screenshots (monthly)
    - Alert queue with dispositions (30-day sample)
    - On-call rotation schedule
```

### CC8.1 — Change management

```yaml
# Change management controls for SOC 2
change_types:
  standard:
    definition: "Low-risk, pre-approved change type"
    approval: "Automated via CI/CD pipeline"
    testing: "Unit tests, integration tests, SAST"
    evidence: "Git PR with approvals, CI/CD log"

  normal:
    definition: "New feature or significant change"
    approval: "Tech lead + Security review"
    testing: "All standard + security review"
    evidence: "PR with 2+ approvals, security sign-off ticket"

  emergency:
    definition: "Critical fix for production incident"
    approval: "On-call engineer + retrospective approval within 24h"
    testing: "Minimal — full test in post-emergency window"
    evidence: "Incident ticket, retrospective approval record"

controls:
  - No direct commits to main branch — all changes via PR
  - Minimum 1 reviewer approval (2 for security-sensitive)
  - CI/CD blocks merge on failed tests or security scan
  - All deployments logged with who, what, when
  - Rollback procedure documented and tested quarterly
```

### CC9.2 — Risk assessment

```yaml
# Annual risk assessment process
risk_assessment:
  frequency: "Annual + after major changes"
  methodology: "Likelihood × Impact scoring (1–5 each)"

  assets_in_scope:
    - Customer data (PII, payment data)
    - Application source code
    - Infrastructure credentials
    - Authentication systems

  threat_categories:
    - External attack
    - Insider threat
    - Third-party/supply chain
    - Environmental (natural disaster, power)
    - Human error

  output:
    - Risk register with scores
    - Risk treatment decisions (accept/mitigate/transfer/avoid)
    - Residual risk accepted by business owner
    - Treatment plan with owners and due dates
```

---

## SOC 2 Type II — evidence collection calendar

| Month | Evidence to collect |
|---|---|
| Jan | Access review Q4, DR test results, security training completion |
| Feb | Penetration test (if annual), vulnerability scan Q1 |
| Mar | Vendor risk reviews, policy reviews due |
| Apr | Access review Q1, SOC 2 period start (if Apr–Mar) |
| May | Vulnerability scan Q2 |
| Jun | Mid-year risk assessment review |
| Jul | Access review Q2 |
| Aug | Vulnerability scan Q3, annual training due |
| Sep | Penetration test results, security awareness training |
| Oct | Access review Q3 |
| Nov | Vulnerability scan Q4, SOC 2 period end (if May–Oct) |
| Dec | Annual risk assessment, policy updates, DR test |

---

## SOC 2 readiness checklist

```
CC6 — Logical Access
□ All production systems require MFA
□ Least privilege enforced — no shared admin accounts
□ Access reviews: quarterly, documented, remediated
□ Leaver process: access removed within 24 hours
□ Privileged access: PAM or approved process

CC7 — System Operations
□ Vulnerability scans: quarterly, all findings tracked
□ Penetration test: annual, critical findings remediated
□ Change management: PR-based, mandatory review
□ Incident response plan: documented, tested annually

CC8 — Change Management
□ All changes via version control
□ No direct commits to main — branch + PR required
□ All deployments logged (who, what, when, outcome)
□ Rollback tested quarterly

CC9 — Risk Mitigation
□ Annual risk assessment documented
□ Risk register maintained with treatment decisions
□ Vendor risk assessments for critical suppliers
□ Business continuity plan tested

Availability (if in scope)
□ SLA defined and monitored (e.g., 99.9% uptime)
□ Uptime monitoring with alerting
□ Redundancy in critical infrastructure
□ DR tested — RTO/RPO documented

Confidentiality (if in scope)
□ Data classification scheme implemented
□ Encryption at rest for confidential data
□ Encryption in transit (TLS 1.2+)
□ Data destruction process documented
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/iso-27001/"><span class="ref-label">Compliance</span>ISO 27001:2022</a>
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS v4.0</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
</div>

</div>
