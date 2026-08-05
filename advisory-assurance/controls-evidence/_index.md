---
title: "Controls & Evidence Catalogue"
date: 2026-08-02
tags: ["controls", "evidence", "assurance", "audit", "catalogue"]
categories: ["governance"]
description: "Complete controls catalogue with evidence request templates for every security domain — ready to use for audits, SOC 2, ISO 27001, PCI-DSS, and DORA."
showToc: true
---

## How to use this catalogue

This catalogue lists security controls by domain, with:
- **What the control is** — plain description
- **Evidence to request** — exactly what to ask for
- **ToD / ToI / ToOE** — which test applies
- **Applicable frameworks** — SOC 2, ISO 27001, PCI-DSS, DORA

Use it as an audit evidence request list, a control self-assessment checklist, or an assurance planning tool.

---

## Domain 1 — Identity & Access Management

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| IAM-01 | MFA enforced for all user accounts | MFA enrollment report, screenshot of MFA prompt | ToI, ToOE | SOC2 CC6.1, PCI 8.4, ISO A.9.4 |
| IAM-02 | Privileged access managed via PAM | PAM tool config, admin account inventory, session logs | ToI, ToOE | SOC2 CC6.3, PCI 7.1, ISO A.9.2 |
| IAM-03 | Access reviews conducted quarterly | Completed access review sign-offs × 4, user list before/after | ToOE | SOC2 CC6.2, ISO A.9.2.5 |
| IAM-04 | Leaver access removed within SLA | HR termination list, access removal audit log, timestamps | ToOE | SOC2 CC6.2, PCI 8.1.3 |
| IAM-05 | Joiner access approved by manager | Onboarding tickets with manager approval, access provisioning log | ToI, ToOE | SOC2 CC6.1, ISO A.9.2.1 |
| IAM-06 | Service account credentials rotated | Key rotation policy, rotation logs, API key inventory with dates | ToI, ToOE | SOC2 CC6.1, PCI 8.6 |
| IAM-07 | Password policy enforced technically | Password policy config, screenshot of rejection for weak password | ToI | SOC2 CC6.1, PCI 8.3 |
| IAM-08 | SSO implemented for all applications | SSO config, application inventory vs SSO-enrolled list | ToI | SOC2 CC6.1, ISO A.9.4.2 |
| IAM-09 | Shared accounts prohibited | Account audit showing no shared accounts | ToI, ToOE | PCI 8.2.1, ISO A.9.2.1 |
| IAM-10 | Just-in-time admin access | PAM JIT policy, sample of JIT session approvals | ToI, ToOE | SOC2 CC6.3, DORA Art.9 |

**Sample evidence request — IAM-03 (Access reviews):**
```
Please provide:
1. Completed access review sign-off documents for Q1, Q2, Q3, Q4 2026
2. User access lists (before and after) for each review
3. Evidence of manager approval for any access retained
4. Log of access removed as a result of each review
5. Confirmation of review completion date relative to quarter end
```

---

## Domain 2 — Vulnerability Management

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| VM-01 | Vulnerability scans run monthly on all assets | Scan reports for last 6 months, asset inventory vs scan coverage | ToI, ToOE | PCI 11.3, ISO A.12.6 |
| VM-02 | Critical vulnerabilities patched within 24 hours | CVE discovery log, patch deployment log, timestamps | ToOE | PCI 6.3.3, DORA Art.9 |
| VM-03 | High vulnerabilities patched within 7 days | Vulnerability tracker, patch log with dates | ToOE | PCI 6.3.3, ISO A.12.6 |
| VM-04 | Annual penetration test conducted | Pen test report, remediation tracker, sign-off | ToOE | PCI 11.4, SOC2 CC7.1 |
| VM-05 | DAST integrated in CI/CD pipeline | Pipeline config, DAST scan report from recent build | ToI | PCI 6.2.4, ISO A.14.2 |
| VM-06 | SAST integrated in CI/CD pipeline | Pipeline config, SAST report, block-on-high evidence | ToI | PCI 6.2.4, ISO A.14.2 |
| VM-07 | Dependency scanning automated | Dependabot/Snyk config, alerts report, SLA evidence | ToI, ToOE | DORA Art.9, ISO A.12.6 |
| VM-08 | SBOM generated per release | SBOM file from 3 recent releases | ToI, ToOE | DORA Art.9 |
| VM-09 | Risk acceptance for unmitigated vulnerabilities | Risk acceptance log with business owner sign-off | ToOE | ISO A.12.6, SOC2 CC9.2 |

**Sample evidence request — VM-02 (Critical patch SLA):**
```
Please provide for the period January–June 2026:
1. Vulnerability scan reports showing initial discovery date for all Critical CVEs
2. Patch deployment records showing remediation date for each Critical CVE
3. Calculation of time-to-patch for each Critical CVE
4. Any exceptions where SLA was breached — with approved risk acceptance
5. Total count: Critical CVEs discovered / patched within SLA / breached SLA
```

---

## Domain 3 — Network Security

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| NET-01 | TLS 1.2+ enforced on all endpoints | SSL scan report (sslyze/testssl.sh), certificate inventory | ToI, ToOE | PCI 4.2.1, ISO A.14.1 |
| NET-02 | No unrestricted inbound access (0.0.0.0/0) | Firewall ruleset, AWS Security Group export, Config report | ToI, ToOE | PCI 1.3, ISO A.13.1 |
| NET-03 | Network segmentation implemented | Network diagram, firewall policy, penetration test validating segmentation | ToI | PCI 1.3, ISO A.13.1 |
| NET-04 | WAF deployed and tuned | WAF config, block rate report, false positive rate | ToI, ToOE | PCI 6.4, ISO A.13.1 |
| NET-05 | DDoS protection in place | DDoS protection service config, incident response for DDoS | ToI | ISO A.17.2, SOC2 A1.2 |
| NET-06 | Remote access via approved VPN/ZTNA only | VPN/ZTNA config, remote access policy, user list | ToI, ToOE | PCI 8.6, ISO A.9.4 |
| NET-07 | Firewall rule review conducted annually | Firewall rule review sign-off, rules removed/changed | ToOE | PCI 1.2.7, ISO A.13.1 |
| NET-08 | Network traffic monitoring active | IDS/IPS config, alert log, coverage report | ToI, ToOE | PCI 10.7, ISO A.12.4 |

---

## Domain 4 — Data Protection

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| DAT-01 | Data classification policy implemented | Classification policy, data inventory with classifications | ToD, ToI | GDPR Art.5, ISO A.8.2 |
| DAT-02 | Encryption at rest for sensitive data | Storage encryption config (AWS KMS, Azure CMK), key policy | ToI, ToOE | PCI 3.5, ISO A.10.1 |
| DAT-03 | Encryption in transit (TLS) | TLS scan output, certificate inventory | ToI, ToOE | PCI 4.2, ISO A.14.1 |
| DAT-04 | Encryption key management | KMS policy, key rotation schedule, HSM config | ToI, ToOE | PCI 3.6, ISO A.10.1 |
| DAT-05 | Data retention policy enforced | Retention policy, automated deletion config, audit log | ToI, ToOE | GDPR Art.5(1)(e), ISO A.8.3 |
| DAT-06 | Backup tested and recoverable | Backup config, last test restore date, RTO/RPO evidence | ToI, ToOE | SOC2 A1.3, ISO A.12.3 |
| DAT-07 | DLP controls active | DLP policy config, incident log, false positive rate | ToI, ToOE | GDPR, ISO A.8.2 |
| DAT-08 | PII inventory maintained | PII data map, DPIA register | ToD, ToOE | GDPR Art.30 |

---

## Domain 5 — Application Security

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| APP-01 | Threat modelling in SDLC | TM procedure, sample TM outputs for last 3 features | ToD, ToOE | ISO A.14.2, DORA Art.9 |
| APP-02 | Secure coding standards defined | Secure coding policy, developer training completion | ToD, ToI | PCI 6.2, ISO A.14.2 |
| APP-03 | Code review for security-sensitive changes | PR review log showing security sign-off, CODEOWNERS config | ToI, ToOE | SOC2 CC8.1, ISO A.14.2 |
| APP-04 | Security testing gates in CI/CD | Pipeline config, failed build examples, gate criteria | ToI | PCI 6.2, DORA Art.9 |
| APP-05 | No secrets in source code | Secret scanning config, Trufflehog/gitleaks output | ToI, ToOE | SOC2 CC6.1, ISO A.14.2 |
| APP-06 | Input validation implemented | Code review, DAST scan showing no injection vulnerabilities | ToI | PCI 6.2.4, OWASP A03 |
| APP-07 | API authentication enforced | API gateway config, test showing 401 without token | ToI | PCI 8.6, ISO A.9.4 |
| APP-08 | Error handling does not leak info | Manual test — trigger errors, observe responses | ToI | OWASP A05, ISO A.14.2 |

---

## Domain 6 — Security Monitoring & Response

| # | Control | Evidence to request | Test type | Frameworks |
|---|---|---|---|---|
| MON-01 | SIEM centralises all critical log sources | Log source inventory, SIEM source config, coverage map | ToI | PCI 10.4, ISO A.12.4 |
| MON-02 | Log retention 12 months minimum | Retention policy, oldest log date, storage config | ToI, ToOE | PCI 10.5, ISO A.12.4 |
| MON-03 | Security alerts responded within SLA | Alert queue, ticket log, SLA compliance report | ToOE | SOC2 CC7.3, ISO A.16.1 |
| MON-04 | Incident response plan documented | IR plan, playbooks, contact list, escalation matrix | ToD | SOC2 CC7.4, ISO A.16.1 |
| MON-05 | IR plan tested annually | Tabletop exercise report, lessons learned log | ToOE | SOC2 CC7.4, PCI 12.10.2 |
| MON-06 | Security incidents tracked to closure | Incident register, closure evidence, MTTD/MTTR metrics | ToOE | ISO A.16.1, DORA Art.18 |
| MON-07 | Threat hunting conducted | Hunt hypothesis log, hunt reports, findings | ToOE | DORA Art.9 |
| MON-08 | Detection rule tuning (purple team) | Purple team exercise report, rule update log | ToOE | DORA Art.9 |

---

## Evidence request email template

Use this template when requesting evidence from control owners:

```
Subject: Assurance Evidence Request — [Control Domain] — [Review Period]

Hi [Control Owner],

As part of our [quarterly / annual / SOC2 / ISO27001 / PCI-DSS] assurance 
review covering [start date] to [end date], I need to collect evidence for 
the following controls in your area:

Control ID: [e.g. IAM-03]
Control: [e.g. Quarterly access reviews]
Evidence required:
  1. [Specific evidence item 1]
  2. [Specific evidence item 2]
  3. [Specific evidence item 3]

Please provide this evidence by [date — typically 5 business days].

Evidence should be sent to [secure channel / evidence management tool].
Please do not send sensitive evidence via unencrypted email.

If you have questions or need to discuss any items, please reply to this email
or book time at [calendar link].

Thank you,
[Your name]
[Security Assurance Team]
```

---

## Evidence quality checklist

When receiving evidence, verify it meets these quality criteria:

```
□ Complete — covers the full review period, not just a subset
□ Authentic — sourced directly from the system (not manually prepared spreadsheets)
□ Timely — dated within the review period
□ Relevant — directly demonstrates the control operating
□ Sufficient — sufficient to draw a conclusion (adequate sample size)
□ Unaltered — not post-dated or modified after the fact
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation (ToI)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — control design basis</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
