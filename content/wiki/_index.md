---
title: "Wiki"
date: 2026-08-05
description: "A complete security engineering reference — threat modelling, OWASP, cloud, detection, AI/LLM, cryptography, privacy, compliance, incident response, OT/ICS, and more."
showToc: true
layout: "single"
---

## How to use this wiki

This is a **practitioner's reference** covering the full security engineering lifecycle — over 85 pages of working code, templates, and checklists. Jump to what you need:

| I want to… | Start here |
|---|---|
| Design a system securely | [Threat Modelling](/wiki/stride/) → [Secure Architecture](/wiki/secure-architecture/) |
| Find & fix web vulnerabilities | [OWASP Top 10](/wiki/owasp-top10/) |
| Secure my cloud | [Cloud Security](/wiki/cloud-security/) |
| Build detections & run a SOC | [Detection Engineering](/wiki/detection-engineering/) |
| Secure an AI / LLM feature | [AI & LLM Security](/wiki/ai-security/) |
| Get crypto right | [Cryptography](/wiki/crypto/) |
| Handle personal data lawfully | [Privacy](/wiki/privacy/) → [Compliance](/wiki/compliance/) |
| Prepare for an audit | [Compliance](/wiki/compliance/) → [Advisory & Assurance](/wiki/advisory-assurance/) |
| Respond to an incident | [Incident Response](/wiki/incident-response/) |
| Secure industrial systems | [OT / ICS Security](/wiki/ot-ics/) |
| Report security to the board | [Security Metrics & KPIs](/wiki/metrics/) |

---

## 🪜 Foundations — Threat Modelling & Maturity

The core discipline: understand your threats before you build. **[Maturity Ladder overview →](/wiki/maturity-ladder/)**

| Page | Focus |
|---|---|
| [STRIDE](/wiki/stride/) | Threat categorisation framework |
| [DREAD](/wiki/dread/) | Risk scoring and prioritisation |
| [PASTA](/wiki/pasta/) | Business-risk-aligned threat modelling |
| [Attack Trees](/wiki/attack-trees/) | Attack path analysis |
| [Attack Surface Management](/wiki/asm/) | Continuous asset discovery |
| [Red Teaming](/wiki/red-teaming/) | Adversary simulation |
| [Purple Teaming](/wiki/purple-teaming/) | Detection validation |
| [Threat Intelligence](/wiki/threat-intelligence/) | CTI, IOCs, actor profiles |
| [Zero Trust](/wiki/zero-trust/) | NIST SP 800-207 architecture |
| [Supply Chain Security](/wiki/supply-chain/) | SLSA, SBOM, Sigstore |

---

## 🔐 OWASP Top 10

One page per vulnerability — code, STRIDE mapping, detection. **[Overview →](/wiki/owasp-top10/)**

| | | |
|---|---|---|
| [A01 Broken Access Control](/wiki/owasp-top10/a01-broken-access-control/) | [A02 Cryptographic Failures](/wiki/owasp-top10/a02-cryptographic-failures/) | [A03 Injection](/wiki/owasp-top10/a03-injection/) |
| [A04 Insecure Design](/wiki/owasp-top10/a04-insecure-design/) | [A05 Security Misconfiguration](/wiki/owasp-top10/a05-security-misconfiguration/) | [A06 Vulnerable Components](/wiki/owasp-top10/a06-vulnerable-components/) |
| [A07 Auth Failures](/wiki/owasp-top10/a07-auth-failures/) | [A08 Software Integrity](/wiki/owasp-top10/a08-software-integrity/) | [A09 Logging Failures](/wiki/owasp-top10/a09-logging-failures/) |
| [A10 SSRF](/wiki/owasp-top10/a10-ssrf/) | | |

---

## 🏗️ Secure Architecture

Design patterns for cloud-native systems. **[Overview →](/wiki/secure-architecture/)**

| Page | Focus |
|---|---|
| [Microservices Security](/wiki/secure-architecture/microservices/) | mTLS, SPIFFE, service mesh |
| [API Security Design](/wiki/secure-architecture/api-security/) | JWT, OAuth2, BOLA, rate limiting |
| [Secrets Management](/wiki/secure-architecture/secrets-management/) | Vault, KMS, rotation |
| [Container Security](/wiki/secure-architecture/container-security/) | Hardening, scanning, signing |
| [Kubernetes Security](/wiki/secure-architecture/kubernetes-security/) | RBAC, network policies, admission |

---

## ☁️ Cloud Security

Baselines and threat models for AWS, GCP, Azure. **[Overview →](/wiki/cloud-security/)**

| Page | Focus |
|---|---|
| [AWS Security Baseline](/wiki/cloud-security/aws-baseline/) | IAM, S3, VPC, CloudTrail, GuardDuty |
| [GCP Security Baseline](/wiki/cloud-security/gcp-baseline/) | IAM, Workload Identity, SCC |
| [Azure Security Baseline](/wiki/cloud-security/azure-baseline/) | Entra ID, RBAC, Defender, Sentinel |
| [Cloud Misconfiguration Top 10](/wiki/cloud-security/cloud-misconfig-top10/) | The 10 most dangerous misconfigs |
| [Cloud Threat Model Template](/wiki/cloud-security/cloud-threat-model/) | Ready-to-use STRIDE template |

---

## 🎯 Detection Engineering

Build detections and run a SOC. **[Overview →](/wiki/detection-engineering/)**

| Page | Focus |
|---|---|
| [SIEM Use Case Library](/wiki/detection-engineering/siem-use-cases/) | 25+ ready detection use cases |
| [Sigma Rule Writing](/wiki/detection-engineering/sigma-rules/) | Vendor-neutral detection-as-code |
| [Detection Coverage Metrics](/wiki/detection-engineering/detection-metrics/) | MTTD, ATT&CK coverage, FPR |
| [Alert Fatigue Guide](/wiki/detection-engineering/alert-fatigue/) | Tuning and triage automation |
| [SOC Playbook Templates](/wiki/detection-engineering/soc-playbooks/) | Response playbooks by alert type |

---

## 🤖 AI & LLM Security

Securing AI systems. **[Overview →](/wiki/ai-security/)**

| Page | Focus |
|---|---|
| [OWASP LLM Top 10](/wiki/ai-security/llm-top10/) | The ten critical LLM risks |
| [Prompt Injection](/wiki/ai-security/prompt-injection/) | Direct & indirect injection defence |
| [AI Threat Modelling](/wiki/ai-security/ai-threat-modelling/) | STRIDE for AI, MAESTRO |
| [AI Red Teaming](/wiki/ai-security/ai-red-teaming/) | Adversarial testing of AI |

---

## 🔑 Cryptography

Applied crypto for engineers. **[Overview →](/wiki/crypto/)**

| Page | Focus |
|---|---|
| [Cryptography Fundamentals](/wiki/crypto/fundamentals/) | Symmetric, asymmetric, hashing |
| [PKI & Certificates](/wiki/crypto/pki-certificates/) | CAs, chains, X.509 |
| [TLS Best Practices](/wiki/crypto/tls-best-practices/) | Versions, ciphers, HSTS, mTLS |
| [Key Management](/wiki/crypto/key-management/) | KMS, HSM, envelope encryption |
| [Post-Quantum Cryptography](/wiki/crypto/post-quantum/) | ML-KEM, ML-DSA, migration |

---

## 🔏 Privacy & Data Protection

Privacy engineering. **[Overview →](/wiki/privacy/)**

| Page | Focus |
|---|---|
| [GDPR Engineering](/wiki/privacy/gdpr-engineering/) | GDPR requirements in code |
| [DPIA](/wiki/privacy/dpia/) | Impact assessment template |
| [Privacy by Design](/wiki/privacy/privacy-by-design/) | 7 principles, LINDDUN |
| [Data Subject Rights](/wiki/privacy/data-subject-rights/) | Access, erasure, portability |

---

## 📋 Compliance

Framework mappings for engineers. **[Overview →](/wiki/compliance/)**

| Page | Focus |
|---|---|
| [GDPR](/wiki/compliance/gdpr/) | EU data protection |
| [PCI-DSS v4.0](/wiki/compliance/pci-dss/) | Payment card security |
| [ISO 27001:2022](/wiki/compliance/iso-27001/) | ISMS certification |
| [SOC 2 Type II](/wiki/compliance/soc2/) | Trust Service Criteria |
| [DORA](/wiki/compliance/dora/) | EU financial resilience |

---

## 🚨 Incident Response

Respond when things go wrong. **[Overview →](/wiki/incident-response/)**

| Page | Focus |
|---|---|
| [IR Plan](/wiki/incident-response/ir-plan/) | NIST phases, roles, governance |
| [Ransomware Playbook](/wiki/incident-response/ransomware-playbook/) | Isolate, decide, recover |
| [Data Breach Playbook](/wiki/incident-response/data-breach-playbook/) | 72-hour notification |
| [DDoS Playbook](/wiki/incident-response/ddos-playbook/) | Defensive escalation |
| [Insider Threat Playbook](/wiki/incident-response/insider-threat-playbook/) | Covert investigation |
| [Post-Incident Review](/wiki/incident-response/post-incident-review/) | Blameless retrospective |

---

## ⚙️ OT / ICS Security

Securing industrial control systems. **[Overview →](/wiki/ot-ics/)**

| Page | Focus |
|---|---|
| [Purdue Model](/wiki/ot-ics/purdue-model/) | OT network segmentation |
| [ICS Threat Modelling](/wiki/ot-ics/ics-threat-model/) | Safety-first threat analysis |
| [MITRE ATT&CK for ICS](/wiki/ot-ics/attack-ics/) | ICS attack techniques |
| [OT Network Security](/wiki/ot-ics/ot-network-security/) | Segmentation, monitoring |

---

## 📊 Security Metrics & KPIs

Measure and communicate security. **[Overview →](/wiki/metrics/)**

| Page | Focus |
|---|---|
| [Security KPIs](/wiki/metrics/security-kpis/) | Metrics that matter |
| [Board Reporting](/wiki/metrics/board-reporting/) | Communicating to executives |
| [Risk Appetite](/wiki/metrics/risk-appetite/) | Defining risk thresholds |

---

## 🔍 Advisory & Assurance

Independent control validation. **[Overview →](/wiki/advisory-assurance/)**

| Page | Focus |
|---|---|
| [Test of Design (ToD)](/wiki/advisory-assurance/tod/) | Is the control well designed? |
| [Test of Implementation (ToI)](/wiki/advisory-assurance/toi/) | Was it built correctly? |
| [Test of Operating Effectiveness (ToOE)](/wiki/advisory-assurance/tooe/) | Does it work over time? |
| [Controls & Evidence Catalogue](/wiki/advisory-assurance/controls-evidence/) | 40+ controls, evidence templates |

---

## 🛠 Tools & Templates

| Tools | Templates |
|---|---|
| [OWASP Threat Dragon](/wiki/tools/threat-dragon/) | [Threat Register](/wiki/templates/threat-register/) |
| [Microsoft TMT](/wiki/tools/ms-tmt/) | [PR Security Checklist](/wiki/templates/pr-checklist/) |
| [Threagile](/wiki/tools/threagile/) | [Data Flow Diagram Guide](/wiki/templates/dfd/) |

---

## 📖 Reading paths by role

**Developer:** [Threat Modelling](/posts/01-intro-to-threat-modelling/) → [OWASP Top 10](/wiki/owasp-top10/) → [API Security](/wiki/secure-architecture/api-security/) → [Cryptography](/wiki/crypto/) → [PR Checklist](/wiki/templates/pr-checklist/)

**Security Engineer:** [Maturity Ladder](/wiki/maturity-ladder/) → [Cloud Security](/wiki/cloud-security/) → [Detection Engineering](/wiki/detection-engineering/) → [Zero Trust](/wiki/zero-trust/)

**AI/ML Engineer:** [AI Security](/wiki/ai-security/) → [Prompt Injection](/wiki/ai-security/prompt-injection/) → [AI Threat Modelling](/wiki/ai-security/ai-threat-modelling/) → [AI Red Teaming](/wiki/ai-security/ai-red-teaming/)

**Auditor / GRC:** [Compliance](/wiki/compliance/) → [Advisory & Assurance](/wiki/advisory-assurance/) → [Privacy](/wiki/privacy/) → [Metrics](/wiki/metrics/)

**SOC Analyst:** [Detection Engineering](/wiki/detection-engineering/) → [SOC Playbooks](/wiki/detection-engineering/soc-playbooks/) → [Incident Response](/wiki/incident-response/) → [Threat Intelligence](/wiki/threat-intelligence/)

**OT/ICS Engineer:** [OT/ICS Security](/wiki/ot-ics/) → [Purdue Model](/wiki/ot-ics/purdue-model/) → [ICS Threat Modelling](/wiki/ot-ics/ics-threat-model/) → [ATT&CK for ICS](/wiki/ot-ics/attack-ics/)
