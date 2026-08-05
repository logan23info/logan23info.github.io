---
title: "Wiki"
date: 2026-08-05
description: "Complete security engineering reference — Threat Modelling, OWASP Top 10, Secure Architecture, Maturity Ladder, Advisory & Assurance, Tools and Templates."
showToc: true
layout: "single"
---

## How to use this wiki

This wiki is structured as a **practitioner's reference** — not a course. Use the section that matches what you are doing right now:

| I want to… | Start here |
|---|---|
| Design a new system securely | [Threat Modelling](/wiki/maturity-ladder/) → [STRIDE](/wiki/stride/) → [Secure Architecture](/wiki/secure-architecture/) |
| Find and fix web app vulnerabilities | [OWASP Top 10](/wiki/owasp-top10/) |
| Test whether controls are working | [Advisory & Assurance](/wiki/advisory-assurance/) |
| Understand a security discipline end-to-end | [Security Engineering Maturity Ladder](/wiki/maturity-ladder/) |
| Simulate a real attacker | [Red Teaming](/wiki/red-teaming/) → [Purple Teaming](/wiki/purple-teaming/) |
| Prepare for a SOC 2 / ISO 27001 audit | [Controls & Evidence Catalogue](/wiki/advisory-assurance/controls-evidence/) |

---

## 🪜 Security Engineering Maturity Ladder

The full lifecycle from threat modelling through to Zero Trust.

**[Full Maturity Ladder Overview →](/wiki/maturity-ladder/)**

| Level | Page | Description |
|---|---|---|
| 1 | [STRIDE](/wiki/stride/) | Threat categorisation framework |
| 1 | [DREAD](/wiki/dread/) | Risk scoring — prioritise your findings |
| 1 | [PASTA](/wiki/pasta/) | Business-risk-aligned threat modelling |
| 1 | [Attack Trees](/wiki/attack-trees/) | Attack path analysis |
| 2 | [Attack Surface Management](/wiki/asm/) | Continuous discovery of exposed assets |
| 3 | [Red Teaming](/wiki/red-teaming/) | Adversary simulation, MITRE ATT&CK |
| 4 | [Purple Teaming](/wiki/purple-teaming/) | Detection validation, VECTR, Sigma rules |
| 5 | [Threat Intelligence](/wiki/threat-intelligence/) | CTI tiers, IOCs, threat actor profiles |
| 6 | [Zero Trust Architecture](/wiki/zero-trust/) | NIST SP 800-207, five pillars, BeyondCorp |
| +1 | [Supply Chain Security](/wiki/supply-chain/) | SLSA, SBOM, Sigstore, dependency scanning |

---

## 🔐 OWASP Top 10 (2021)

One page per vulnerability — STRIDE mapping, vulnerable vs safe code, detection methods.

**[OWASP Top 10 Overview →](/wiki/owasp-top10/)**

| Rank | Page | Description |
|---|---|---|
| A01 | [Broken Access Control](/wiki/owasp-top10/a01-broken-access-control/) | IDOR, privilege escalation, path traversal |
| A02 | [Cryptographic Failures](/wiki/owasp-top10/a02-cryptographic-failures/) | Weak encryption, plaintext storage, bad TLS |
| A03 | [Injection](/wiki/owasp-top10/a03-injection/) | SQL injection, XSS, command injection, SSTI |
| A04 | [Insecure Design](/wiki/owasp-top10/a04-insecure-design/) | Missing security requirements, bad design patterns |
| A05 | [Security Misconfiguration](/wiki/owasp-top10/a05-security-misconfiguration/) | Default creds, debug mode, open cloud storage |
| A06 | [Vulnerable Components](/wiki/owasp-top10/a06-vulnerable-components/) | CVEs in dependencies, SCA scanning, SBOM |
| A07 | [Authentication Failures](/wiki/owasp-top10/a07-auth-failures/) | Brute force, credential stuffing, weak sessions |
| A08 | [Software Integrity Failures](/wiki/owasp-top10/a08-software-integrity/) | Insecure deserialization, unsigned updates |
| A09 | [Logging & Monitoring Failures](/wiki/owasp-top10/a09-logging-failures/) | Missing audit logs, no SIEM alerting |
| A10 | [SSRF](/wiki/owasp-top10/a10-ssrf/) | Server-side request forgery, cloud metadata |

---

## 🏗️ Secure Architecture Patterns

Design patterns for secure cloud-native systems.

**[Secure Architecture Overview →](/wiki/secure-architecture/)**

| Page | Description |
|---|---|
| [Microservices Security](/wiki/secure-architecture/microservices/) | mTLS, SPIFFE/SPIRE, service mesh, Istio |
| [API Security Design](/wiki/secure-architecture/api-security/) | JWT, OAuth2, BOLA prevention, rate limiting, Kong |
| [Secrets Management](/wiki/secure-architecture/secrets-management/) | Vault, AWS Secrets Manager, rotation, injection |
| [Container Security](/wiki/secure-architecture/container-security/) | Dockerfile hardening, Trivy, Falco, Cosign |
| [Kubernetes Security](/wiki/secure-architecture/kubernetes-security/) | RBAC, NetworkPolicy, Pod Security, OPA Gatekeeper |

---

## 🔍 Advisory & Assurance

Independent validation that controls are designed, implemented, and operating correctly.

**[Advisory & Assurance Overview →](/wiki/advisory-assurance/)**

| Page | Description |
|---|---|
| [Test of Design (ToD)](/wiki/advisory-assurance/tod/) | Is the control designed to address the risk? |
| [Test of Implementation (ToI)](/wiki/advisory-assurance/toi/) | Has the control been correctly implemented? |
| [Test of Operating Effectiveness (ToOE)](/wiki/advisory-assurance/tooe/) | Is the control working consistently over time? |
| [Controls & Evidence Catalogue](/wiki/advisory-assurance/controls-evidence/) | 40+ controls across 6 domains — evidence request templates |

---

## 🛠 Tools

| Tool | Description |
|---|---|
| [OWASP Threat Dragon](/wiki/tools/threat-dragon/) | Free DFD + STRIDE tool — web, desktop, Docker |
| [Microsoft Threat Modelling Tool](/wiki/tools/ms-tmt/) | Windows, extensive Azure threat library |
| [Threagile](/wiki/tools/threagile/) | Threat modelling as YAML — generate full report from code |

---

## 📋 Templates

| Template | Description |
|---|---|
| [Threat Register](/wiki/templates/threat-register/) | Markdown + YAML threat register — copy and use |
| [PR Security Checklist](/wiki/templates/pr-checklist/) | GitHub PR template with STRIDE checklist |
| [Data Flow Diagram Guide](/wiki/templates/dfd/) | DFD notation, examples, Mermaid code |

---

## 📖 Suggested reading paths

### Path 1 — "I'm a developer who wants to write more secure code"
1. [Introduction to Threat Modelling](/posts/01-intro-to-threat-modelling/)
2. [STRIDE](/wiki/stride/) → [DREAD](/wiki/dread/)
3. [OWASP Top 10](/wiki/owasp-top10/) — all 10 pages
4. [API Security Design](/wiki/secure-architecture/api-security/)
5. [Secrets Management](/wiki/secure-architecture/secrets-management/)
6. [PR Security Checklist](/wiki/templates/pr-checklist/)

### Path 2 — "I'm a security engineer building a programme"
1. [Security Engineering Maturity Ladder](/wiki/maturity-ladder/)
2. [Threat Modelling in DevSecOps](/posts/05-threat-modelling-in-devsecops/)
3. [Attack Surface Management](/wiki/asm/)
4. [Red Teaming](/wiki/red-teaming/) → [Purple Teaming](/wiki/purple-teaming/)
5. [Threat Intelligence](/wiki/threat-intelligence/)
6. [Zero Trust Architecture](/wiki/zero-trust/)

### Path 3 — "I'm preparing for a SOC 2 / ISO 27001 audit"
1. [Advisory & Assurance Overview](/wiki/advisory-assurance/)
2. [Test of Design](/wiki/advisory-assurance/tod/)
3. [Test of Implementation](/wiki/advisory-assurance/toi/)
4. [Test of Operating Effectiveness](/wiki/advisory-assurance/tooe/)
5. [Controls & Evidence Catalogue](/wiki/advisory-assurance/controls-evidence/)

### Path 4 — "I'm a red teamer / pen tester"
1. [Red Teaming](/wiki/red-teaming/)
2. [OWASP Top 10](/wiki/owasp-top10/) — A01, A03, A07, A10 priority
3. [Attack Trees](/wiki/attack-trees/)
4. [Purple Teaming](/wiki/purple-teaming/)
5. [Threat Intelligence](/wiki/threat-intelligence/)

---

## 🗺️ Coming soon

Content being added next:

| Section | Status |
|---|---|
| Compliance Mappings (GDPR, PCI-DSS, ISO 27001, SOC 2, DORA, NIST CSF) | Planned |
| Incident Response (IR plan, playbooks, ransomware, data breach) | Planned |
| Detection Engineering (SIEM use cases, Sigma library, SOC playbooks) | Planned |
| AI / LLM Security (OWASP LLM Top 10, prompt injection, AI red team) | Planned |
| Privacy & Data Protection (GDPR, DPIA, privacy by design) | Planned |
| Cryptography (PKI, TLS, key management, post-quantum) | Planned |
| Security Metrics & KPIs (board reporting, MTTD/MTTR, risk appetite) | Planned |
| OT / ICS Security (Purdue model, ATT&CK for ICS, OT network) | Planned |
