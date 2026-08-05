---
title: "Security Engineering Maturity Ladder"
date: 2026-08-02
tags: ["maturity-ladder", "security-engineering", "overview"]
categories: ["fundamentals"]
description: "The complete Security Engineering Maturity Ladder — from Threat Modelling foundations through to advanced adversary simulation and Zero Trust Architecture."
showToc: true
weight: 1
---

## Overview

The Security Engineering Maturity Ladder describes how organisations evolve their security practices from reactive to proactive, from manual to automated, and from hypothetical to intelligence-driven. Each level builds on the previous one — you cannot effectively run a Red Team if you have not first modelled what you are defending.

```
┌─────────────────────────────────────────────────────────────────┐
│         SECURITY ENGINEERING MATURITY LADDER                   │
├───────┬─────────────────────────────────┬──────────────────────┤
│ Level │ Discipline                      │ Core question        │
├───────┼─────────────────────────────────┼──────────────────────┤
│   1   │ Threat Modelling                │ What could go wrong? │
│   2   │ Attack Surface Management       │ Where are we exposed?│
│   3   │ Red Teaming                     │ Can attacks succeed? │
│   4   │ Purple Teaming                  │ Can we detect them?  │
│   5   │ Threat Intelligence             │ Who is targeting us? │
│   6   │ Zero Trust Architecture         │ Trust nothing, ever  │
│  +1   │ Supply Chain Security           │ Is our code safe?    │
└───────┴─────────────────────────────────┴──────────────────────┘
```

Most organisations operate at Level 1–2. Reaching Level 4–5 puts you in the top 10% of security programmes globally. Level 6 is a multi-year architectural transformation.

---

## Level 1 — Threat Modelling

**What it is:** A structured process for identifying security risks during the design phase, before code is written or systems are built.

**Key frameworks:** STRIDE, DREAD, PASTA, Attack Trees

**Core output:** A prioritised threat register with mitigations mapped to each threat.

**Maturity indicators:**
- Threat models are produced for new features and services
- Findings are tracked as engineering tickets
- Threat model is stored as code alongside the system it describes
- Security checklist is part of every PR review

**Where it fits:** Design and development phase. The cheapest place to find and fix security issues.

**Detailed guide:** [Threat Modelling](/wiki/stride/) | [STRIDE](/wiki/stride/) | [DREAD](/wiki/dread/) | [PASTA](/wiki/pasta/)

---

## Level 2 — Attack Surface Management (ASM)

**What it is:** Continuous discovery, inventory, and monitoring of every externally exposed asset — including assets the organisation may not know it has.

**Key tools:** Censys, Shodan, Microsoft Defender EASM, Tenable ASM, CyCognito

**Core output:** A continuously updated inventory of exposed assets, with risk scores and change alerts.

**Maturity indicators:**
- All internet-facing assets are discovered automatically, not manually
- Unknown or shadow IT assets are detected and investigated
- New exposures trigger automated alerts within hours
- Asset inventory is integrated with the threat model

**Where it fits:** Continuous, runtime. Validates and extends threat models with real-world exposure data.

**Detailed guide:** [Attack Surface Management](/wiki/asm/)

---

## Level 3 — Red Teaming

**What it is:** Authorised simulation of real-world attackers against live systems. Goes beyond penetration testing to simulate full attack campaigns — from initial access through lateral movement to data exfiltration.

**Key frameworks:** MITRE ATT&CK, TIBER-EU, CBEST

**Core output:** An attack narrative showing exactly how far a real attacker could get, and what they could access.

**Maturity indicators:**
- Red team exercises run at least annually against critical systems
- Findings are mapped to MITRE ATT&CK techniques
- Red team scope is derived from threat intelligence, not just compliance
- Results feed directly back into threat models and defensive controls

**Where it fits:** Post-deployment validation. Tests real defensive controls against real attack techniques.

**Detailed guide:** [Red Teaming](/wiki/red-teaming/)

---

## Level 4 — Purple Teaming

**What it is:** Red team (attackers) and Blue team (defenders) working together simultaneously — the red team executes attack techniques while the blue team validates whether their detection and response controls actually work.

**Key frameworks:** MITRE ATT&CK, Atomic Red Team, VECTR

**Core output:** A detection coverage map showing which attack techniques are detected, which are missed, and which alerting rules need improvement.

**Maturity indicators:**
- Purple team exercises run regularly, not just annually
- Every red team technique is validated against SIEM detection rules
- Detection gaps are immediately addressed during the exercise
- Results drive SOC playbook improvements

**Where it fits:** Validation layer. Proves whether defensive investments are actually working.

**Detailed guide:** [Purple Teaming](/wiki/purple-teaming/)

---

## Level 5 — Threat Intelligence

**What it is:** The use of structured, curated information about real-world threat actors — their identities, motivations, capabilities, and specific tactics — to drive security decisions. Transforms threat modelling from hypothetical to intelligence-driven.

**Key sources:** MITRE ATT&CK Groups, MISP, OpenCTI, Recorded Future, Mandiant Advantage

**Core output:** Threat actor profiles, TTP (Tactics, Techniques, Procedures) mappings, and intelligence-driven threat models.

**Maturity indicators:**
- Threat models reference real attacker groups relevant to your sector
- IOCs (Indicators of Compromise) are ingested and acted on automatically
- Intelligence is operationalised — it drives detection rules, not just reports
- Threat intelligence is shared with sector peers (ISACs)

**Where it fits:** Strategic layer. Makes every other level more precise and relevant.

**Detailed guide:** [Threat Intelligence](/wiki/threat-intelligence/)

---

## Level 6 — Zero Trust Architecture

**What it is:** An architectural philosophy where no user, device, or network location is trusted by default. Every request is authenticated, authorised, and validated — regardless of where it originates. The architectural implementation of the principle of least privilege at every layer.

**Key standards:** NIST SP 800-207, CISA Zero Trust Maturity Model, Google BeyondCorp

**Core output:** An architecture where lateral movement is structurally prevented, not just detected.

**Maturity indicators:**
- Identity is the new perimeter — every access decision is identity-based
- Microsegmentation prevents lateral movement between services
- Devices are continuously validated, not trusted after initial login
- All traffic is encrypted and inspected, including internal east-west traffic

**Where it fits:** Architectural transformation. Eliminates entire categories of threats rather than mitigating them one by one.

**Detailed guide:** [Zero Trust Architecture](/wiki/zero-trust/)

---

## +1 — Supply Chain Security

**What it is:** Securing not just your own code but every dependency, tool, and third-party component your software relies on. Addresses the reality that most modern software is 80–90% open source code written by others.

**Key frameworks:** SLSA (Supply chain Levels for Software Artifacts), SSDF (NIST), SBOM

**Core output:** A verified, signed, and continuously monitored software supply chain with full dependency visibility.

**Maturity indicators:**
- SBOM (Software Bill of Materials) is generated for every build
- All dependencies are scanned for known vulnerabilities on every build
- Build artifacts are cryptographically signed (Sigstore/Cosign)
- Third-party code is reviewed before adoption

**Where it fits:** Underlies all levels. A compromised dependency undermines every other security control.

**Detailed guide:** [Supply Chain Security](/wiki/supply-chain/)

---

## How the levels interact

The ladder is not strictly sequential — most mature organisations run all levels simultaneously. But each level amplifies the others:

- **Threat Intelligence → Threat Modelling:** Real attacker TTPs make threat models more accurate
- **Threat Modelling → Red Teaming:** Threat models define what red teams should try to do
- **Red Teaming → Purple Teaming:** Red team findings define what blue teams need to detect
- **Purple Teaming → Detection Engineering:** Coverage gaps drive SIEM rule development
- **ASM → All levels:** Real exposure data keeps threat models, red team scope, and detection rules current
- **Zero Trust → All levels:** Architectural controls reduce the blast radius when other levels miss something
- **Supply Chain → All levels:** Secure the foundation that everything else runs on

---

## Where to start

| Organisation size | Starting point | Next step |
|---|---|---|
| Startup / small team | Threat Modelling (Level 1) | ASM (Level 2) |
| Mid-size / scale-up | ASM + basic Threat Intel | Red Teaming |
| Enterprise | Purple Teaming + Threat Intel | Zero Trust roadmap |
| Regulated (finance, health) | All levels + compliance mapping | TIBER-EU / CBEST |

<div class="references-section">

## 📚 All wiki pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Level 1</span>STRIDE</a>
  <a class="ref-card" href="/wiki/dread/"><span class="ref-label">Level 1</span>DREAD</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Level 1</span>PASTA</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Level 1</span>Attack Trees</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Level 2</span>Attack Surface Management</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Level 3</span>Red Teaming</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Level 4</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Level 5</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Level 6</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">+1</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/tools/threat-dragon/"><span class="ref-label">Tool</span>OWASP Threat Dragon</a>
  <a class="ref-card" href="/wiki/tools/threagile/"><span class="ref-label">Tool</span>Threagile</a>
</div>

</div>
