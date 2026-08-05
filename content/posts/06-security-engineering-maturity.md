---
title: "The Security Engineering Maturity Ladder — Complete Guide"
date: 2026-08-02
tags: ["maturity-ladder", "security-engineering", "red-teaming", "purple-teaming", "zero-trust", "threat-intelligence", "ASM", "supply-chain"]
categories: ["security-engineering"]
series: ["Security Engineering Maturity"]
description: "A complete guide to all six levels of the Security Engineering Maturity Ladder — from Threat Modelling through to Zero Trust Architecture."
showToc: true
weight: 6
---

## Overview

The Security Engineering Maturity Ladder describes how organisations evolve their security from reactive to proactive, from manual to automated, from hypothetical to intelligence-driven.

```
Level 1 — Threat Modelling           What could go wrong?
Level 2 — Attack Surface Management  Where are we exposed right now?
Level 3 — Red Teaming                Can attacks actually succeed?
Level 4 — Purple Teaming             Can we detect those attacks?
Level 5 — Threat Intelligence        Who is actually targeting us?
Level 6 — Zero Trust Architecture    Eliminate trust entirely
   +1   — Supply Chain Security      Is our code itself safe?
```

Most organisations operate at Level 1–2. Reaching Level 4–5 puts you in the top 10% of security programmes globally.

---

## Level 1 — Threat Modelling

**Core question:** What could go wrong with this system?

**What it is:** A structured design-time process for identifying security risks before code is written. Uses frameworks like STRIDE to enumerate threats per component and DREAD to score and prioritise them.

**Key outputs:**
- Data flow diagram (DFD) of the system
- Threat register with mitigations
- Security backlog for engineering

**Maturity signs:**
- Threat model produced for every new service
- Findings tracked as engineering tickets
- Security checklist on every PR

**Time investment:** 60–90 min per feature, 15 min per PR

**Full reference:** [Threat Modelling Wiki](/wiki/stride/) | [STRIDE](/wiki/stride/) | [DREAD](/wiki/dread/) | [PASTA](/wiki/pasta/)

---

## Level 2 — Attack Surface Management

**Core question:** What are we actually exposing to the internet right now?

**What it is:** Continuous discovery and monitoring of every internet-facing asset — including assets the organisation does not know it has. Validates and extends threat models with real-world exposure data.

**Key outputs:**
- Continuously updated asset inventory
- Risk-scored exposure list
- Alerts on new exposures within hours

**Maturity signs:**
- All internet-facing assets discovered automatically
- Unknown or shadow IT assets detected and investigated
- Certificate expiry monitored automatically
- New exposures trigger alerts within 4 hours

**Free tools to start:** Subfinder, Amass, Nuclei, httpx

**Time investment:** Initial setup 1–2 days, then automated

**Full reference:** [Attack Surface Management Wiki](/wiki/asm/)

---

## Level 3 — Red Teaming

**Core question:** If an attacker tried to compromise us using our threat model's attack scenarios, would they succeed?

**What it is:** Authorised simulation of a real-world adversary. A red team attempts to achieve a specific objective (steal data, deploy ransomware, access admin systems) using the same techniques real attackers use, mapped to MITRE ATT&CK.

**Key outputs:**
- Attack narrative — how far the red team got and how
- ATT&CK heat map of techniques used
- Detection gaps — what the blue team missed
- Business impact statement

**Maturity signs:**
- Red team exercises run at least annually
- Threat actor profile derived from threat intelligence
- Findings mapped to MITRE ATT&CK
- Results feed back into threat models

**Tools:** Sliver C2 (free), Metasploit (free), BloodHound (free), Cobalt Strike (commercial)

**Time investment:** 2–8 weeks per engagement

**Full reference:** [Red Teaming Wiki](/wiki/red-teaming/)

---

## Level 4 — Purple Teaming

**Core question:** Does our SIEM/EDR actually detect the attacks from the red team exercise?

**What it is:** Red and blue teams working together simultaneously. The red team executes one ATT&CK technique at a time while the blue team checks whether their detection tools catch it. Gaps are fixed in real time.

**Key outputs:**
- ATT&CK detection coverage map (% of techniques detected)
- Detection gap backlog (rules to write)
- SOC playbook improvements
- MTTD (Mean Time to Detect) trend over time

**Maturity signs:**
- Purple team exercises run quarterly
- Every technique validated against live SIEM rules
- Detection gaps addressed during the exercise
- Atomic Red Team tests run automatically in CI

**Tools:** VECTR (free), Atomic Red Team (free), ATT&CK Navigator (free), Sigma (free)

**Time investment:** 1–2 days per exercise, quarterly

**Full reference:** [Purple Teaming Wiki](/wiki/purple-teaming/)

---

## Level 5 — Threat Intelligence

**Core question:** Which real-world threat actors are targeting organisations like ours, and what techniques are they using right now?

**What it is:** Structured, curated information about real threat actors — their identities, motivations, and specific tactics — used to make every other security level more precise and relevant. Transforms threat models from hypothetical to intelligence-driven.

**Three tiers:**
- **Strategic:** What threats should we prepare for this year? (Board/C-suite)
- **Operational:** What campaigns are active right now? (Security managers)
- **Tactical:** What IOCs should we block today? (SOC analysts)

**Key outputs:**
- Threat actor profiles for your sector
- TTP mappings to MITRE ATT&CK
- IOC feeds integrated with SIEM and firewall
- Intelligence-driven threat models and red team scope

**Maturity signs:**
- Threat models reference real attacker groups
- IOCs ingested and actioned within 1 hour
- Threat hunting hypotheses derived from intelligence
- Intelligence shared with sector peers (ISACs)

**Free tools:** MISP, OpenCTI, OTX AlienVault, URLhaus, MalwareBazaar

**Time investment:** Initial setup 1 week, then ongoing

**Full reference:** [Threat Intelligence Wiki](/wiki/threat-intelligence/)

---

## Level 6 — Zero Trust Architecture

**Core question:** What if we never trusted any user, device, or network location by default — ever?

**What it is:** An architectural transformation based on "never trust, always verify." Every request — regardless of source — is authenticated, authorised, and continuously validated. Microsegmentation prevents lateral movement. Identity replaces the network as the security perimeter.

**Five pillars:**
1. **Identity** — MFA everywhere, passwordless for privileged accounts, continuous risk scoring
2. **Devices** — Every device registered, health-checked, and compliance-validated before access
3. **Network** — Microsegmentation, no implicit trust based on network location, encrypt east-west traffic
4. **Applications** — Per-app access control, SSO + MFA, session continuous validation
5. **Data** — Classification, encryption at rest and in transit, DLP

**Key outputs:**
- Architecture where lateral movement is structurally prevented
- Identity-based access replacing VPN
- Complete device inventory with compliance enforcement
- Microsegmented network

**Maturity signs:**
- MFA on 100% of applications
- VPN replaced by identity-aware proxy
- Device compliance checked before every access grant
- Privileged access managed via PAM solution
- All internal traffic encrypted

**Reference implementation:** Google BeyondCorp (published as open papers)
**Standard:** NIST SP 800-207

**Time investment:** Multi-year transformation — typically 3 years to full maturity

**Full reference:** [Zero Trust Architecture Wiki](/wiki/zero-trust/)

---

## +1 — Supply Chain Security

**Core question:** Is the third-party code we depend on safe, verified, and unmodified?

**What it is:** Securing not just your code but every dependency, build tool, and third-party component. Modern software is 80–90% open source written by others — a compromised dependency undermines every other security control.

**Key capabilities:**
- SBOM (Software Bill of Materials) — know every component
- SLSA framework — verify build integrity and provenance
- Dependency scanning — catch CVEs before they reach production
- Artifact signing — prove artifacts have not been tampered with
- Build pipeline hardening — protect the pipeline itself

**Key outputs:**
- SBOM for every production build
- Signed and verified build artifacts
- Hardened build pipeline
- Dependency vulnerability alerting

**Maturity signs:**
- SBOM generated for every release
- All dependencies scanned on every build
- Build artifacts signed with Cosign/Sigstore
- No dependency updates merged without automated security review

**Free tools:** Syft (SBOM), Grype (scanning), Cosign/Sigstore (signing), Dependabot (GitHub-native), pip-audit, npm audit

**Time investment:** 1–2 weeks initial setup, then automated

**Full reference:** [Supply Chain Security Wiki](/wiki/supply-chain/)

---

## How the levels reinforce each other

```
Threat Intelligence  ──feeds──▶  Threat Modelling  ──defines──▶  Red Team scope
        │                               │                               │
        │                               ▼                               ▼
        │                          ASM validates              Purple Team validates
        │                          real exposure              detection coverage
        │                               │                               │
        └───────────────────────────────┴───────────────────────────────┘
                                        │
                                        ▼
                              Zero Trust eliminates
                              entire threat categories
                                        │
                                        ▼
                              Supply Chain secures
                              the foundation everything runs on
```

---

## Where to start based on your organisation size

| Size | Start here | Next 6 months | Year 2 |
|---|---|---|---|
| Startup | Threat Modelling (STRIDE) | Dependabot + SBOM | ASM |
| Scale-up | Threat Modelling + ASM | Threat Intel feeds | First Red Team |
| Enterprise | Purple Teaming + Threat Intel | Zero Trust roadmap | TIBER-EU / CBEST |
| Regulated (finance/health) | All levels audit | DORA compliance | Continuous purple teaming |
