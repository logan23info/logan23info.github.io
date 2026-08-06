---
title: "OT / ICS Security"
date: 2026-08-05
tags: ["OT-security", "ICS", "SCADA", "Purdue-model", "critical-infrastructure"]
categories: ["ot-ics"]
description: "Operational Technology and Industrial Control Systems security — Purdue model, ICS threat modelling, MITRE ATT&CK for ICS, and OT network security."
showToc: true
layout: "single"
---

## Why OT security is different

Operational Technology (OT) controls physical processes — power grids, water treatment, manufacturing lines, pipelines. Industrial Control Systems (ICS) are the computers and networks that run them. Securing OT is fundamentally different from IT security because the priorities are inverted.

| Priority | IT security | OT security |
|---|---|---|
| 1st | Confidentiality | **Safety** (human life) |
| 2nd | Integrity | **Availability** (process continuity) |
| 3rd | Availability | Integrity |
| — | (Safety rarely a factor) | Confidentiality (often least important) |

In IT, you might take a system offline to patch it. In OT, taking a turbine controller offline could cause physical damage or endanger lives. **Availability and safety dominate.**

---

## Pages in this section

| Page | Description |
|---|---|
| [Purdue Model](/wiki/ot-ics/purdue-model/) | The reference architecture for OT network segmentation |
| [ICS Threat Modelling](/wiki/ot-ics/ics-threat-model/) | Threat modelling for industrial control systems |
| [MITRE ATT&CK for ICS](/wiki/ot-ics/attack-ics/) | The ICS-specific attack framework and notable incidents |
| [OT Network Security](/wiki/ot-ics/ot-network-security/) | Segmentation, monitoring, and secure remote access for OT |

---

## Key OT/ICS terminology

| Term | Meaning |
|---|---|
| ICS | Industrial Control System — umbrella term |
| SCADA | Supervisory Control and Data Acquisition — monitors/controls distributed processes |
| PLC | Programmable Logic Controller — the device that directly controls machinery |
| RTU | Remote Terminal Unit — field device collecting sensor data |
| HMI | Human-Machine Interface — the operator's screen |
| DCS | Distributed Control System — controls a single site/plant |
| Historian | Database recording process data over time |
| Safety Instrumented System (SIS) | Independent system that triggers safe shutdown |
| Fieldbus | Industrial network protocols (Modbus, Profibus, DNP3) |

---

## Why OT is uniquely hard to secure

```
Legacy systems:
  Equipment runs for 20-30 years. Systems may run Windows XP or
  unpatched firmware because the vendor no longer exists.

No patching windows:
  A refinery or power plant may run continuously for years.
  Downtime to patch can cost millions or be safety-critical.

Insecure-by-design protocols:
  Modbus, DNP3, and others were designed decades ago with NO
  authentication or encryption. Any device on the network can send commands.

Availability above all:
  Security controls that could interrupt the process are often rejected.
  You cannot "block" traffic that might be a safety command.

IT/OT convergence:
  Historically air-gapped OT networks are now connected to IT and the
  internet for efficiency — dramatically expanding the attack surface.
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ot-ics/purdue-model/"><span class="ref-label">OT/ICS</span>Purdue Model</a>
  <a class="ref-card" href="/wiki/ot-ics/ics-threat-model/"><span class="ref-label">OT/ICS</span>ICS Threat Modelling</a>
  <a class="ref-card" href="/wiki/ot-ics/attack-ics/"><span class="ref-label">OT/ICS</span>MITRE ATT&CK for ICS</a>
  <a class="ref-card" href="/wiki/ot-ics/ot-network-security/"><span class="ref-label">OT/ICS</span>OT Network Security</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
</div>

</div>
