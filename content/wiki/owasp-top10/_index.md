---
title: "OWASP Top 10 (2021)"
date: 2026-08-05
tags: ["OWASP", "web-security", "vulnerabilities", "reference"]
categories: ["owasp"]
description: "Complete reference for the OWASP Top 10 2021 — the most critical web application security risks, with STRIDE mapping, code examples, and detection methods."
showToc: true
layout: "single"
---

## What is the OWASP Top 10?

The OWASP Top 10 is the most widely referenced web application security standard in the world. Published by the Open Web Application Security Project, it represents a broad consensus on the most critical security risks to web applications. It is used as a baseline for security testing, compliance requirements (PCI-DSS, SOC 2), and developer training programmes worldwide.

The 2021 edition introduced three new categories and reorganised several existing ones based on data from over 500,000 real-world applications.

---

## The 10 categories

| Rank | ID | Name | STRIDE | CWEs |
|---|---|---|---|---|
| 1 | [A01](/wiki/owasp-top10/a01-broken-access-control/) | Broken Access Control | EoP, Info Disclosure | 34 CWEs |
| 2 | [A02](/wiki/owasp-top10/a02-cryptographic-failures/) | Cryptographic Failures | Info Disclosure | 29 CWEs |
| 3 | [A03](/wiki/owasp-top10/a03-injection/) | Injection | Tampering, EoP | 33 CWEs |
| 4 | [A04](/wiki/owasp-top10/a04-insecure-design/) | Insecure Design | All | 40 CWEs |
| 5 | [A05](/wiki/owasp-top10/a05-security-misconfiguration/) | Security Misconfiguration | Info Disclosure, EoP | 20 CWEs |
| 6 | [A06](/wiki/owasp-top10/a06-vulnerable-components/) | Vulnerable & Outdated Components | All | 3 CWEs |
| 7 | [A07](/wiki/owasp-top10/a07-auth-failures/) | Identification & Authentication Failures | Spoofing | 22 CWEs |
| 8 | [A08](/wiki/owasp-top10/a08-software-integrity/) | Software & Data Integrity Failures | Tampering | 10 CWEs |
| 9 | [A09](/wiki/owasp-top10/a09-logging-failures/) | Security Logging & Monitoring Failures | Repudiation | 4 CWEs |
| 10 | [A10](/wiki/owasp-top10/a10-ssrf/) | Server-Side Request Forgery (SSRF) | Info Disclosure, Tampering | 1 CWE |

---

## How OWASP Top 10 relates to STRIDE

| STRIDE category | Primary OWASP categories |
|---|---|
| Spoofing | A07 Authentication Failures |
| Tampering | A03 Injection, A08 Integrity Failures |
| Repudiation | A09 Logging Failures |
| Information Disclosure | A02 Cryptographic Failures, A05 Misconfiguration |
| Denial of Service | A04 Insecure Design (resource exhaustion) |
| Elevation of Privilege | A01 Broken Access Control, A03 Injection |

---

## How to use this in threat modelling

For each component in your DFD, apply the OWASP Top 10 as a checklist alongside STRIDE:

```
For every API endpoint:
□ A01 — Is every resource access checked against the caller's identity?
□ A02 — Is all sensitive data encrypted in transit and at rest?
□ A03 — Are all inputs parameterised/validated?
□ A04 — Were security requirements designed in from the start?
□ A05 — Are default credentials and debug features disabled?
□ A06 — Are all dependencies scanned for known CVEs?
□ A07 — Is authentication strong, with MFA and brute-force protection?
□ A08 — Are software updates and CI artifacts verified for integrity?
□ A09 — Are all security events logged and monitored?
□ A10 — Can the server be made to fetch attacker-controlled URLs?
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
</div>

</div>
