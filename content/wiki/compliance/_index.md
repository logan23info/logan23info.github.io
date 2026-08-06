---
title: "Compliance Mappings"
date: 2026-08-05
tags: ["compliance", "GDPR", "PCI-DSS", "ISO-27001", "SOC2", "DORA", "governance"]
categories: ["compliance"]
description: "Compliance framework reference — GDPR, PCI-DSS, ISO 27001, SOC 2, and DORA mapped to security engineering controls and assurance activities."
showToc: true
layout: "single"
---

## How to use this section

Each compliance framework page covers:
- **What the framework requires** — the key obligations in plain language
- **Mapping to security controls** — how each requirement maps to engineering controls
- **Mapping to STRIDE** — which threat categories each control addresses
- **Evidence to collect** — exactly what an auditor will ask for
- **Gap assessment checklist** — self-assess your current posture

These pages are designed to be used alongside the [Controls & Evidence Catalogue](/wiki/advisory-assurance/controls-evidence/) and [Advisory & Assurance](/wiki/advisory-assurance/) section.

---

## Frameworks covered

| Framework | Scope | Mandatory? | Audit type |
|---|---|---|---|
| [GDPR](/wiki/compliance/gdpr/) | Any org processing EU personal data | Yes (EU law) | Regulator investigation, DPA audit |
| [PCI-DSS v4.0](/wiki/compliance/pci-dss/) | Any org storing/processing payment card data | Yes (contractual) | QSA audit or SAQ |
| [ISO 27001:2022](/wiki/compliance/iso-27001/) | Any org wanting a certified ISMS | Voluntary (often required by clients) | Third-party certification audit |
| [SOC 2 Type II](/wiki/compliance/soc2/) | SaaS and service providers | Voluntary (customer-driven) | CPA firm audit |
| [DORA](/wiki/compliance/dora/) | EU financial entities and ICT providers | Yes (EU law, Jan 2025) | Regulatory supervisory review |

---

## How compliance maps to the maturity ladder

| Maturity level | GDPR | PCI-DSS | ISO 27001 | SOC 2 | DORA |
|---|---|---|---|---|---|
| 1 — Threat Modelling | Art.25 Privacy by Design | Req 6.2 Security in SDLC | A.8.25 Secure development | CC6.1 Logical access | Art.9 ICT risk management |
| 2 — ASM | Art.32 Technical measures | Req 11.3 External scanning | A.8.8 Vulnerability mgmt | CC7.1 Change monitoring | Art.9 Asset management |
| 3 — Red Teaming | Art.32 Risk assessment | Req 11.4 Penetration testing | A.8.8 Pen testing | CC7.1 Security testing | Art.26 TLPT |
| 4 — Purple Teaming | Art.32 Monitoring | Req 10.7 Audit log monitoring | A.8.16 Monitoring | CC7.2 Anomaly detection | Art.26 Advanced testing |
| 5 — Threat Intel | Art.32 Risk assessment | Req 12.3 Risk assessment | A.5.7 Threat intelligence | CC9.2 Risk assessment | Art.13 Threat intelligence |
| 6 — Zero Trust | Art.32 Access control | Req 7 Access control | A.8.3 Info access restriction | CC6.1 Logical access | Art.9 Network segmentation |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS v4.0</a>
  <a class="ref-card" href="/wiki/compliance/iso-27001/"><span class="ref-label">Compliance</span>ISO 27001:2022</a>
  <a class="ref-card" href="/wiki/compliance/soc2/"><span class="ref-label">Compliance</span>SOC 2 Type II</a>
  <a class="ref-card" href="/wiki/compliance/dora/"><span class="ref-label">Compliance</span>DORA</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
</div>

</div>
