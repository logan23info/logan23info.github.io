---
title: "The Security Engineering Landscape"
date: 2026-08-05
tags: ["overview", "roadmap", "security-engineering", "reference"]
categories: ["overview"]
description: "A single-page map of the entire security engineering discipline — how every domain in this wiki connects across the security lifecycle."
showToc: true
layout: "single"
---

## The security engineering lifecycle

Security is not a checklist — it is a lifecycle that runs continuously. Every domain in this wiki maps to a phase of that lifecycle. This page shows how they fit together.

```
      DESIGN            BUILD            OPERATE          RESPOND         GOVERN
        │                 │                 │                │              │
        ▼                 ▼                 ▼                ▼              ▼
  Threat Modelling   Secure Arch      Detection Eng    Incident Resp    Compliance
  STRIDE/DREAD       Cloud Security   Purple Teaming   IR Playbooks     Metrics/KPIs
  AI Threat Model    Cryptography     Threat Intel     Post-Incident    Risk Appetite
  Privacy by Design  OWASP fixes      SOC Playbooks    Data Breach      Advisory &
  Attack Trees       Secrets Mgmt     SIEM/Sigma       Ransomware        Assurance
        │                 │                 │                │              │
        └─────────────────┴────── continuously improve ──────┴──────────────┘
```

---

## How the domains connect

### Design feeds Build
Threat models produced during design ([STRIDE](/wiki/stride/), [AI Threat Modelling](/wiki/ai-security/ai-threat-modelling/), [ICS Threat Modelling](/wiki/ot-ics/ics-threat-model/)) define the security requirements that [Secure Architecture](/wiki/secure-architecture/), [Cloud Security](/wiki/cloud-security/), and [Cryptography](/wiki/crypto/) then implement.

### Build feeds Operate
The controls you build must be monitored. [Detection Engineering](/wiki/detection-engineering/) creates the detections, [Threat Intelligence](/wiki/threat-intelligence/) informs what to look for, and [Purple Teaming](/wiki/purple-teaming/) validates that detections actually fire.

### Operate feeds Respond
When detections fire, [Incident Response](/wiki/incident-response/) takes over — [SOC Playbooks](/wiki/detection-engineering/soc-playbooks/) and [IR Playbooks](/wiki/incident-response/ir-plan/) turn alerts into coordinated action.

### Respond feeds Govern
Every incident produces a [Post-Incident Review](/wiki/incident-response/post-incident-review/) whose lessons update [Metrics](/wiki/metrics/), inform [Risk Appetite](/wiki/metrics/risk-appetite/), and feed [Compliance](/wiki/compliance/) evidence.

### Govern feeds Design
[Advisory & Assurance](/wiki/advisory-assurance/) and [Compliance](/wiki/compliance/) findings become new requirements that feed back into the next design cycle — closing the loop.

---

## The wiki by numbers

| Domain | Pages | Covers |
|---|---|---|
| Foundations & Maturity | 11 | STRIDE, DREAD, PASTA, red/purple teaming, zero trust, supply chain |
| OWASP Top 10 | 11 | Every 2021 category with code and detection |
| Secure Architecture | 6 | Microservices, API, secrets, containers, K8s |
| Cloud Security | 6 | AWS, GCP, Azure baselines + misconfig + threat model |
| Detection Engineering | 6 | SIEM, Sigma, metrics, alert fatigue, SOC playbooks |
| AI & LLM Security | 5 | LLM Top 10, injection, threat modelling, red teaming |
| Cryptography | 6 | Fundamentals, PKI, TLS, key management, post-quantum |
| Privacy | 5 | GDPR engineering, DPIA, privacy by design, DSR |
| Compliance | 6 | GDPR, PCI-DSS, ISO 27001, SOC 2, DORA |
| Incident Response | 7 | IR plan + 5 playbooks + post-incident review |
| OT/ICS Security | 5 | Purdue, ICS threat model, ATT&CK for ICS, network |
| Security Metrics | 4 | KPIs, board reporting, risk appetite |
| Advisory & Assurance | 5 | ToD, ToI, ToOE, controls catalogue |
| Tools & Templates | 6 | Threat Dragon, Threagile, registers, checklists |

---

## Where to start

New to the wiki? Pick the entry point that matches your role on the [Wiki index](/wiki/) — there are tailored reading paths for developers, security engineers, AI/ML engineers, auditors, SOC analysts, and OT/ICS engineers.

<div class="references-section">

## 📚 Explore the domains

<div class="ref-grid">
  <a class="ref-card" href="/wiki/"><span class="ref-label">Start</span>Full Wiki Index</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Foundations</span>Maturity Ladder</a>
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">AppSec</span>OWASP Top 10</a>
  <a class="ref-card" href="/wiki/cloud-security/"><span class="ref-label">Cloud</span>Cloud Security</a>
  <a class="ref-card" href="/wiki/ai-security/"><span class="ref-label">AI</span>AI & LLM Security</a>
  <a class="ref-card" href="/wiki/detection-engineering/"><span class="ref-label">Detect</span>Detection Engineering</a>
</div>

</div>
