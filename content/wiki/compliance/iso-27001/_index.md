---
title: "ISO 27001:2022"
date: 2026-08-05
tags: ["ISO-27001", "compliance", "ISMS", "information-security", "certification"]
categories: ["compliance"]
description: "ISO 27001:2022 compliance guide — ISMS requirements, Annex A controls mapped to engineering practices, and certification gap checklist."
showToc: true
layout: "single"
---

## What is ISO 27001?

ISO 27001 is the international standard for Information Security Management Systems (ISMS). It provides a framework for establishing, implementing, maintaining, and continually improving information security. The 2022 revision introduced 11 new controls and reorganised Annex A into 4 themes.

**Certification:** Third-party audit by accredited certification body (BSI, Bureau Veritas, SGS, etc.)
**Validity:** 3-year certificate with annual surveillance audits
**Scope:** You define what is in scope — can be a specific product, department, or the whole organisation

---

## The ISO 27001 structure

### Clauses 4–10 — Mandatory requirements (the ISMS)

| Clause | Topic | Key activities |
|---|---|---|
| 4 | Context | Understand the organisation and interested parties |
| 5 | Leadership | Top management commitment, ISMS policy |
| 6 | Planning | Risk assessment, risk treatment, Statement of Applicability |
| 7 | Support | Resources, competence, awareness, documented information |
| 8 | Operation | Implement risk treatment, manage security processes |
| 9 | Performance evaluation | Internal audits, management review, monitoring |
| 10 | Improvement | Nonconformity, corrective action, continual improvement |

### Annex A — 93 controls across 4 themes

| Theme | Controls | Examples |
|---|---|---|
| Organisational (5) | 37 | Information security policies, roles, supplier security |
| People (6) | 8 | Screening, training, disciplinary process |
| Physical (7) | 14 | Physical access controls, equipment security |
| Technological (8) | 34 | Access control, cryptography, vulnerability management |

---

## Key Annex A controls — engineering mapping

### A.5.7 — Threat intelligence (new in 2022)

> Collect and analyse information about information security threats.

```yaml
# threat-intelligence-programme.yml
sources:
  - name: "MISP Community"
    type: "open_source"
    feeds: ["CIRCL OSINT", "Abuse.ch"]
    update_frequency: "daily"

  - name: "Sector ISAC"
    type: "sector_specific"
    update_frequency: "real-time"

operationalisation:
  - IOCs ingested into SIEM within 1 hour of receipt
  - TTPs mapped to MITRE ATT&CK
  - Threat model updated quarterly based on intelligence
  - Red team scope informed by threat actor profiles

evidence_for_audit:
  - Threat intelligence platform screenshot
  - IOC ingestion logs
  - Quarterly threat intelligence report
  - Evidence of TI feeding into threat model
```

### A.8.8 — Management of technical vulnerabilities

```bash
# Vulnerability management process (evidence for A.8.8)

# 1. Discovery — scan all assets weekly
trivy image --severity CRITICAL,HIGH $(docker images -q)
aws inspector2 list-findings --filter-criteria file://inspector-filter.json

# 2. Prioritisation — CVSS + asset criticality
# Critical CVE on critical asset: remediate within 24 hours
# High CVE on critical asset: remediate within 7 days
# Critical CVE on low asset: remediate within 7 days
# High CVE on low asset: remediate within 30 days

# 3. Remediation tracking
# Every vulnerability tracked in ticketing system
# SLA compliance reported monthly to management

# 4. Verification — rescan after remediation
trivy image --severity CRITICAL,HIGH myapp:patched
```

### A.8.25 — Secure development lifecycle

```yaml
# SDLC security gates (evidence for A.8.25)
development_gates:
  design:
    - activity: "Threat model"
      when: "Before sprint starts for security-relevant features"
      evidence: "Threat model document in repo"

  code:
    - activity: "SAST scan"
      when: "Every commit"
      evidence: "CI pipeline SAST report"
    - activity: "Secret scanning"
      when: "Every commit"
      evidence: "Gitleaks scan results"

  test:
    - activity: "DAST scan"
      when: "Before release to staging"
      evidence: "OWASP ZAP report"
    - activity: "Dependency scan"
      when: "Every build"
      evidence: "SCA tool output"

  release:
    - activity: "Security sign-off"
      when: "Before production release"
      evidence: "Security review approval in ticket"
```

### A.8.16 — Monitoring activities (new in 2022)

```yaml
# Security monitoring programme evidence
monitoring_coverage:
  log_sources:
    - source: "Authentication systems"
      events: ["login_success", "login_failure", "mfa_failure", "account_locked"]
      retention: "12 months"

    - source: "Cloud trail (all regions)"
      events: ["all API calls"]
      retention: "12 months"

    - source: "Application audit log"
      events: ["data_access", "admin_actions", "config_changes"]
      retention: "12 months"

  alerts:
    - rule: "Brute force detection"
      threshold: ">20 failures in 5 minutes"
      response_time: "1 hour"

  review:
    - frequency: "Daily log review by SOC"
    - evidence: "SIEM dashboard screenshots, alert queue"
```

---

## Statement of Applicability (SoA)

The SoA is a mandatory document listing all 93 Annex A controls, whether each is applicable, and how it is implemented. Example extract:

```yaml
# statement-of-applicability.yml (extract)
controls:
  - id: "A.5.1"
    title: "Policies for information security"
    applicable: true
    justification: "Required for ISMS governance"
    implemented: true
    implementation: "Information Security Policy v3.2 approved by CEO 2026-01-15"
    evidence: "Policy document, board minutes"

  - id: "A.5.7"
    title: "Threat intelligence"
    applicable: true
    justification: "Required to understand threat landscape"
    implemented: true
    implementation: "MISP platform + sector ISAC feeds, quarterly TI report"
    evidence: "MISP screenshot, TI reports, threat model updates"

  - id: "A.7.4"
    title: "Physical security monitoring"
    applicable: false
    justification: "Organisation is fully cloud-based — no physical datacentre"
    compensating_control: "N/A — cloud provider manages physical security"
```

---

## ISO 27001 certification gap checklist

```
ISMS fundamentals (Clauses 4–10)
□ ISMS scope defined and documented
□ Information security policy approved by top management
□ Risk assessment methodology documented
□ Risk register maintained with asset-level risks
□ Risk treatment plan with accepted residual risks
□ Statement of Applicability (SoA) completed for all 93 controls
□ Internal audit programme — at least annual
□ Management review — at least annual
□ Nonconformity and corrective action procedure

Annex A — key controls
□ A.5.1: Information security policy — approved, communicated, reviewed annually
□ A.5.9: Inventory of assets — complete, classified, and owned
□ A.5.15: Access control — least privilege, reviewed quarterly
□ A.5.33: Protection of records — retention periods defined
□ A.6.1: Screening — background checks for relevant roles
□ A.6.3: Information security awareness — annual training
□ A.8.2: Privileged access rights — reviewed quarterly, MFA required
□ A.8.7: Protection against malware — EDR on all endpoints
□ A.8.8: Vulnerability management — quarterly scans, SLA for remediation
□ A.8.12: Data leakage prevention — DLP controls
□ A.8.15: Logging — all critical systems, 12-month retention
□ A.8.24: Use of cryptography — policy, approved algorithms only
□ A.8.25: Secure development — SDLC with security gates
□ A.8.28: Secure coding — training, SAST, code review
□ A.8.32: Change management — all changes tested and approved
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/soc2/"><span class="ref-label">Compliance</span>SOC 2 Type II</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
</div>

</div>
