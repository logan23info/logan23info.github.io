---
title: "ICS Threat Modelling"
date: 2026-08-05
tags: ["OT-security", "ICS", "threat-modelling", "STRIDE", "SCADA", "safety"]
categories: ["ot-ics"]
description: "Threat modelling for industrial control systems — safety-first STRIDE, consequence-driven analysis, and an ICS threat model template."
showToc: true
layout: "single"
---

## Why ICS threat modelling is different

In IT threat modelling, the worst outcome is usually data loss. In ICS, the worst outcome is physical: an explosion, a toxic release, a power blackout, or loss of life. ICS threat modelling therefore starts from **consequences** — what physical harm could occur — and works backwards to the cyber attack paths that could cause it.

This is called **Consequence-driven, Cyber-informed Engineering (CCE)**.

---

## Safety-first STRIDE for ICS

Standard STRIDE still applies, but the impact lens is safety and availability, not confidentiality:

| STRIDE | ICS manifestation | Potential physical consequence |
|---|---|---|
| **Spoofing** | Fake HMI commands, spoofed sensor readings | Operator acts on false data → wrong control action |
| **Tampering** | Modified PLC logic, altered setpoints | Process pushed outside safe limits → equipment damage |
| **Repudiation** | No logging of who changed control logic | Cannot attribute a dangerous change |
| **Information Disclosure** | Process data leaked | Reconnaissance for a targeted physical attack |
| **Denial of Service** | Flooding the control network | Loss of view/control → unsafe state, forced shutdown |
| **Elevation of Privilege** | Engineering access from HMI | Attacker reprograms controllers → full process control |

---

## Consequence-driven analysis

```
Step 1 — Identify the worst physical consequences (the "crown jewels")
  What is the most catastrophic thing that could physically happen?
  - Turbine overspeed and destruction
  - Chemical reactor overpressure
  - Release of toxic material
  - Widespread power outage
  - Contamination of water supply

Step 2 — Identify what must be manipulated to cause it
  Which controllers, setpoints, or safety systems would an attacker
  need to compromise to cause that consequence?

Step 3 — Map the cyber attack paths to those targets
  How could an attacker reach and manipulate those specific systems?
  Trace from internet → IT → IDMZ → OT → target controller

Step 4 — Identify where to break the attack path
  Where can you place controls that an attacker MUST bypass?
  Prioritise protecting the paths to catastrophic consequences.

Step 5 — Verify safety systems are independent
  Can the Safety Instrumented System (SIS) still trigger a safe
  shutdown even if the control system is fully compromised?
```

---

## The role of Safety Instrumented Systems (SIS)

```
The SIS is the last line of defence — an independent system that
brings the process to a safe state regardless of what the control
system does.

CRITICAL PRINCIPLE:
  The SIS must be independent of the control system (BPCS).
  If one attack can compromise BOTH the control system AND the SIS,
  there is no safety backstop.

The 2017 TRITON/TRISIS malware specifically targeted Triconex SIS
controllers — the first known malware designed to disable safety
systems, potentially enabling physical harm. This is why SIS
independence is now a primary threat modelling concern.
```

---

## ICS threat model template

```yaml
# ics-threat-model.yml
facility: "water-treatment-plant-01"
last_reviewed: "2026-08-05"
methodology: "Consequence-driven (CCE) + STRIDE"

catastrophic_consequences:
  - id: C1
    description: "Overdose of treatment chemical into water supply"
    safety_impact: "Public health emergency — potential mass poisoning"
    severity: catastrophic

  - id: C2
    description: "Loss of control causing untreated water release"
    safety_impact: "Public health — contaminated water"
    severity: critical

critical_assets:
  - id: PLC-CHEM
    name: "Chemical dosing PLC"
    purpose: "Controls chlorine/chemical injection rate"
    consequence_link: C1
    purdue_level: 1

  - id: SIS-CHEM
    name: "Chemical safety system"
    purpose: "Independent shutdown if dosing exceeds safe limits"
    consequence_link: C1
    purdue_level: 1
    independence_verified: true

  - id: HMI-01
    name: "Operator HMI"
    purpose: "Operator control and monitoring"
    purdue_level: 2

threats:
  - id: ICS-01
    target: PLC-CHEM
    consequence: C1
    stride: "T"
    description: "Attacker modifies dosing PLC logic to overdose chemical"
    attack_path: "Internet → IT phishing → IDMZ jump host → engineering workstation → PLC"
    likelihood: low
    impact: catastrophic
    mitigations:
      - "IDMZ prevents direct IT-to-OT access"
      - "Engineering workstation locked down + MFA"
      - "PLC logic change management + integrity monitoring"
      - "SIS-CHEM independently limits maximum dose (safety backstop)"
    residual_risk: low
    status: mitigated

  - id: ICS-02
    target: SIS-CHEM
    consequence: C1
    stride: "T, D"
    description: "Attacker disables safety system (TRITON-style) to enable overdose"
    attack_path: "OT network → SIS engineering interface"
    likelihood: low
    impact: catastrophic
    mitigations:
      - "SIS on physically separate network"
      - "SIS key switch in RUN mode (no remote programming)"
      - "Alerting on any SIS communication"
    residual_risk: low
    status: mitigated

  - id: ICS-03
    target: HMI-01
    stride: "S"
    description: "Spoofed sensor data causes operator to make unsafe manual adjustment"
    likelihood: medium
    impact: high
    mitigations:
      - "Sensor value range validation"
      - "Redundant sensors with cross-checking"
      - "Operator training on anomaly recognition"
    residual_risk: medium
    status: mitigated
```

---

## ICS threat modelling checklist

```
Consequence analysis
□ Catastrophic physical consequences identified
□ Critical assets linked to each consequence
□ Attack paths to critical assets mapped
□ Highest-consequence paths prioritised for controls

Safety systems
□ Safety Instrumented Systems identified
□ SIS independence from control system verified
□ SIS cannot be remotely reprogrammed (key switch in RUN)
□ TRITON-style SIS attacks specifically considered

Attack paths
□ IT-to-OT attack path traced and controls verified
□ Remote access paths (vendor, remote ops) assessed
□ Removable media and supply chain paths considered
□ Insider threat paths considered

Controls
□ Each catastrophic path has a control the attacker must bypass
□ Network segmentation (Purdue) enforced
□ PLC logic integrity monitoring in place
□ Change management for all control logic changes
□ Detection for anomalous OT commands
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ot-ics/purdue-model/"><span class="ref-label">OT/ICS</span>Purdue Model</a>
  <a class="ref-card" href="/wiki/ot-ics/attack-ics/"><span class="ref-label">OT/ICS</span>MITRE ATT&CK for ICS</a>
  <a class="ref-card" href="/wiki/ot-ics/ot-network-security/"><span class="ref-label">OT/ICS</span>OT Network Security</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Wiki</span>Attack Trees</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register</a>
</div>

</div>
