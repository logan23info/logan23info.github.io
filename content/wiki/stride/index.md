---
title: "STRIDE — Quick Reference"
date: 2026-08-02
tags: ["STRIDE", "reference", "threat-modelling"]
description: "Quick reference card for the STRIDE threat categorisation framework."
showToc: true
---

## Categories

| Category | Violated property | Key question | Common examples |
|---|---|---|---|
| Spoofing | Authentication | Who are you, really? | Fake JWT, ARP spoofing, phishing |
| Tampering | Integrity | Has this been modified? | SQL injection, MITM, log tampering |
| Repudiation | Non-repudiation | Can you prove who did it? | Missing audit logs, log deletion |
| Information Disclosure | Confidentiality | Who can read this? | Insecure S3, verbose errors |
| Denial of Service | Availability | Can it be made unavailable? | Credential stuffing, regex DoS |
| Elevation of Privilege | Authorisation | What can you do that you shouldn't? | IDOR, JWT role claim |

## Which categories apply to which elements

| Element | S | T | R | I | D | E |
|---------|---|---|---|---|---|---|
| External entity | ✓ | | ✓ | | | |
| Process | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Data store | | ✓ | ✓ | ✓ | ✓ | |
| Data flow | | ✓ | | ✓ | ✓ | |

## Standard mitigations

| Threat | Mitigation |
|---|---|
| Spoofing | Strong authentication, MFA, signed tokens |
| Tampering | Digital signatures, input validation, parameterised queries |
| Repudiation | Tamper-evident audit logging |
| Information Disclosure | Encryption, least privilege, data masking |
| Denial of Service | Rate limiting, circuit breakers, auto-scaling |
| Elevation of Privilege | Least privilege, server-side authorisation, RBAC |

See the [STRIDE deep-dive post](/posts/02-stride-methodology/) for a full worked example.

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/dread/"><span class="ref-label">Framework</span>DREAD — Risk Scoring</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Framework</span>PASTA — Full Methodology</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Framework</span>Attack Trees</a>
  <a class="ref-card" href="/wiki/tools/threat-dragon/"><span class="ref-label">Tool</span>OWASP Threat Dragon</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register</a>
  <a class="ref-card" href="/posts/02-stride-methodology/"><span class="ref-label">Post</span>STRIDE Deep-Dive</a>
</div>

</div>
