---
title: "The Purdue Model"
date: 2026-08-05
tags: ["OT-security", "ICS", "Purdue-model", "network-segmentation", "SCADA"]
categories: ["ot-ics"]
description: "The Purdue Enterprise Reference Architecture — the six levels of OT/ICS network segmentation and how to secure the boundaries between them."
showToc: true
layout: "single"
---

## What is the Purdue Model?

The Purdue Enterprise Reference Architecture (PERA), commonly called the Purdue Model, is the foundational framework for segmenting OT and IT networks. It divides the environment into hierarchical levels, each with different security requirements, and defines how they should be separated.

It remains the mental model for OT network segmentation, even as modern architectures evolve.

---

## The Purdue Model levels

```
┌─────────────────────────────────────────────────────────────┐
│ LEVEL 5 — Enterprise Network                                │
│   Corporate IT, email, ERP, internet access                 │
│   (Standard IT security applies)                            │
├─────────────────────────────────────────────────────────────┤
│ LEVEL 4 — Site Business Planning & Logistics                │
│   Plant scheduling, MES, business systems                   │
├═════════════════════════════════════════════════════════════┤
│         ▲▲▲  INDUSTRIAL DEMILITARIZED ZONE (IDMZ)  ▲▲▲       │
│   The critical security boundary between IT and OT          │
│   Data historians (replicas), patch servers, jump hosts     │
├═════════════════════════════════════════════════════════════┤
│ LEVEL 3 — Site Operations                                   │
│   Production management, historians, OT domain controllers  │
├─────────────────────────────────────────────────────────────┤
│ LEVEL 2 — Area Supervisory Control                          │
│   HMIs, SCADA servers, engineering workstations             │
├─────────────────────────────────────────────────────────────┤
│ LEVEL 1 — Basic Control                                     │
│   PLCs, RTUs, controllers — the devices running the process │
├─────────────────────────────────────────────────────────────┤
│ LEVEL 0 — Physical Process                                  │
│   Sensors, actuators, valves, motors — the physical world   │
└─────────────────────────────────────────────────────────────┘

Safety Instrumented Systems (SIS) sit alongside Levels 0-1,
often on a physically separate network.
```

---

## The IDMZ — the critical boundary

The Industrial DMZ between Level 3 (OT) and Level 4 (IT) is the single most important security control in the Purdue Model. **No traffic should flow directly between IT and OT — everything passes through the IDMZ.**

```
IT (Level 4/5)          IDMZ                    OT (Level 3)
     │                    │                          │
     │── data request ───▶│                          │
     │                    │── replicated data ◀──────│
     │◀── from replica ───│                          │
     │                    │                          │
   No direct           Broker /                  OT systems
   connection          replica                   never directly
   to OT               servers                   exposed to IT
```

**IDMZ design principles:**
- No protocol passes straight through — traffic terminates in the IDMZ and a separate connection continues
- Data historians are replicated into the IDMZ; IT reads the replica, never the OT original
- Jump hosts in the IDMZ for administrative access, with MFA
- Patch and antivirus update servers staged in the IDMZ
- Default deny — only explicitly required flows permitted

---

## Securing each level

```
LEVEL 5/4 (Enterprise/Business):
  Standard IT security — see the rest of this wiki
  This is where most attacks begin before pivoting to OT

IDMZ:
  Default-deny firewalls both sides
  No direct IT-to-OT protocols
  Replicated historians, staged patches, MFA jump hosts
  Monitor all traffic crossing the boundary

LEVEL 3 (Site Operations):
  OT domain controllers separate from IT domain
  Historians, patch management for OT
  Application allowlisting on servers

LEVEL 2 (Supervisory):
  HMIs and SCADA servers hardened
  Engineering workstations locked down (biggest pivot risk)
  Application allowlisting

LEVEL 1 (Control):
  PLCs and controllers — often cannot be secured directly
  Protect via network segmentation and monitoring
  Change management for logic changes
  Physical security for controller access

LEVEL 0 (Physical):
  Sensors and actuators
  Protect via physical security and Level 1 controls
  Safety Instrumented Systems provide independent safety layer
```

---

## Modern evolution of the Purdue Model

The strict Purdue Model assumes clear boundaries, but modern trends challenge it:

```
Challenges:
  - IIoT devices connect directly to the cloud, bypassing levels
  - Remote access needs have exploded (especially post-2020)
  - Edge computing blurs the level boundaries

Modern approach:
  - Purdue Model as the baseline for segmentation
  - Zero Trust principles layered on top (verify every connection)
  - Micro-segmentation within levels
  - Software-defined networking for dynamic segmentation

The Purdue Model is not obsolete — it is the foundation on which
Zero Trust OT architectures are built.
```

---

## Purdue Model implementation checklist

```
Segmentation
□ Network segmented into Purdue levels
□ IDMZ deployed between IT (L4/5) and OT (L3)
□ Firewalls enforce default-deny between all levels
□ No direct IT-to-OT protocol connections
□ VLANs or physical separation between levels

IDMZ
□ Data historians replicated to IDMZ (IT reads replica only)
□ Jump hosts with MFA for administrative access
□ Patch/AV update servers staged in IDMZ
□ All boundary traffic logged and monitored

Access control
□ Separate OT domain (not joined to IT Active Directory)
□ Engineering workstations locked down and monitored
□ Remote access via IDMZ jump hosts only, with MFA
□ Vendor access controlled, time-limited, and logged

Monitoring
□ Passive OT network monitoring deployed (no active scanning)
□ Baseline of normal OT traffic established
□ Alerts on unexpected cross-level traffic
□ Alerts on new devices appearing on OT networks
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ot-ics/ics-threat-model/"><span class="ref-label">OT/ICS</span>ICS Threat Modelling</a>
  <a class="ref-card" href="/wiki/ot-ics/attack-ics/"><span class="ref-label">OT/ICS</span>MITRE ATT&CK for ICS</a>
  <a class="ref-card" href="/wiki/ot-ics/ot-network-security/"><span class="ref-label">OT/ICS</span>OT Network Security</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Network Segmentation</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
</div>

</div>
