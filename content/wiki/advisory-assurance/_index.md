---
title: "Advisory & Assurance"
date: 2026-08-02
tags: ["advisory", "assurance", "audit", "governance", "controls"]
categories: ["governance"]
description: "Advisory and Assurance activities — Test of Design, Test of Implementation, Test of Operating Effectiveness, and controls evidence framework."
showToc: true
---

## What is Advisory & Assurance?

Advisory and Assurance are two complementary functions that provide independent validation that security controls are designed correctly, implemented properly, and operating effectively over time.

| Function | Who does it | What it answers |
|---|---|---|
| **Advisory** | Internal security team, consultants | "Are we building the right controls?" |
| **Assurance** | Internal audit, external auditors, regulators | "Do the controls actually work?" |

The two functions work together across three testing disciplines:

```
Test of Design (ToD)
  → Is the control designed to address the risk?

Test of Implementation (ToI)
  → Has the control been correctly implemented?

Test of Operating Effectiveness (ToOE)
  → Is the control working consistently over time?
```

These map directly to the security controls your engineering team builds using the [Security Engineering Maturity Ladder](/wiki/maturity-ladder/).

---

## How Advisory & Assurance relates to Security Engineering

| Security Engineering builds | Advisory & Assurance verifies |
|---|---|
| Threat model for Auth Service | ToD: Does the control address the identified threats? |
| MFA implemented on all apps | ToI: Is MFA actually enforced? Can you bypass it? |
| SIEM detection rules running | ToOE: Are alerts firing consistently over 6 months? |
| SBOM generated per build | ToI: Is the SBOM complete and accurate? |
| Zero Trust access policies | ToOE: Are policies applied to 100% of access requests? |

This is not a contradiction — it is the **full control lifecycle:**

```
Design → Implement → Operate → Assurance → Improve
  ↑                                              |
  └──────────────────────────────────────────────┘
```

---

## The four sections

| Section | Description |
|---|---|
| [Test of Design (ToD)](/wiki/advisory-assurance/tod/) | Validate control design against risk |
| [Test of Implementation (ToI)](/wiki/advisory-assurance/toi/) | Validate correct technical implementation |
| [Test of Operating Effectiveness (ToOE)](/wiki/advisory-assurance/tooe/) | Validate consistent operation over time |
| [Controls & Evidence](/wiki/advisory-assurance/controls-evidence/) | Evidence catalogue and request templates |

---

## Assurance frameworks this aligns with

| Framework | Relevance |
|---|---|
| SOC 2 Type I / Type II | ToD = Type I, ToOE = Type II |
| ISO 27001 | Controls testing maps to Annex A |
| PCI-DSS | Requirements testing = ToI + ToOE |
| NIST CSF | Identify → Protect → Detect → Respond → Recover |
| DORA (EU) | ICT risk controls testing for financial entities |
| CBEST / TIBER-EU | Red team assurance for financial sector |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation (ToI)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
