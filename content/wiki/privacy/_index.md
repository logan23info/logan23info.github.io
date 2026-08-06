---
title: "Privacy & Data Protection"
date: 2026-08-05
tags: ["privacy", "data-protection", "GDPR", "privacy-by-design", "DPIA"]
categories: ["privacy"]
description: "Privacy engineering reference — GDPR engineering, DPIA process, privacy by design, and data subject rights implementation."
showToc: true
layout: "single"
---

## Privacy engineering vs compliance

Privacy compliance asks "does our paperwork satisfy the regulation?" Privacy engineering asks "how do we build systems that protect people's data by default?" This section focuses on the engineering — turning privacy principles into code, architecture, and process.

Privacy engineering complements the [Compliance](/wiki/compliance/) section, which covers the regulatory frameworks themselves.

---

## Pages in this section

| Page | Description |
|---|---|
| [GDPR Engineering](/wiki/privacy/gdpr-engineering/) | Implementing GDPR requirements in code and architecture |
| [Data Protection Impact Assessment](/wiki/privacy/dpia/) | When and how to conduct a DPIA, with a full template |
| [Privacy by Design](/wiki/privacy/privacy-by-design/) | The 7 principles, LINDDUN threat modelling, and privacy patterns |
| [Data Subject Rights](/wiki/privacy/data-subject-rights/) | Implementing access, erasure, portability, and rectification |

---

## The privacy engineering toolkit

| Technique | Purpose | When to use |
|---|---|---|
| Data minimisation | Collect less | Always — design time |
| Pseudonymisation | Replace identifiers with tokens | Analytics, secondary use |
| Anonymisation | Irreversibly remove identity | Data sharing, research |
| Encryption | Protect confidentiality | All personal data |
| Differential privacy | Add noise to protect individuals | Aggregate statistics |
| Access control | Limit who sees data | All personal data |
| Retention limits | Delete when no longer needed | All personal data |
| Consent management | Track and honour consent | Consent-based processing |

---

## Privacy vs security — related but distinct

```
Security threats: unauthorised parties accessing data
    → STRIDE (Spoofing, Tampering, Info Disclosure...)

Privacy threats: authorised parties misusing data, or the system
                 itself creating privacy harm
    → LINDDUN (Linking, Identifying, Non-repudiation, Detecting,
               Data disclosure, Unawareness, Non-compliance)

A system can be perfectly secure and still violate privacy —
e.g. collecting far more data than needed, or using data for
purposes the person never agreed to.
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/privacy/gdpr-engineering/"><span class="ref-label">Privacy</span>GDPR Engineering</a>
  <a class="ref-card" href="/wiki/privacy/dpia/"><span class="ref-label">Privacy</span>Data Protection Impact Assessment</a>
  <a class="ref-card" href="/wiki/privacy/privacy-by-design/"><span class="ref-label">Privacy</span>Privacy by Design</a>
  <a class="ref-card" href="/wiki/privacy/data-subject-rights/"><span class="ref-label">Privacy</span>Data Subject Rights</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
</div>

</div>
