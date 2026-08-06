---
title: "MITRE ATT&CK for ICS"
date: 2026-08-05
tags: ["OT-security", "ICS", "MITRE-ATTACK", "TTPs", "threat-intelligence", "TRITON", "Stuxnet"]
categories: ["ot-ics"]
description: "MITRE ATT&CK for ICS — the tactics and techniques attackers use against industrial control systems, notable incidents, and detection guidance."
showToc: true
layout: "single"
---

## What is ATT&CK for ICS?

MITRE ATT&CK for ICS is a knowledge base of adversary tactics and techniques specific to industrial control systems. Unlike Enterprise ATT&CK (focused on IT), it covers the techniques attackers use to manipulate physical processes — the final stage of an OT attack.

It maps how attackers move from initial access all the way to causing physical impact.

---

## ATT&CK for ICS tactics

| Tactic | Attacker goal |
|---|---|
| Initial Access | Get into the OT environment |
| Execution | Run malicious code on OT systems |
| Persistence | Maintain access across reboots/updates |
| Privilege Escalation | Gain higher access on OT systems |
| Evasion | Avoid detection |
| Discovery | Map the OT environment and processes |
| Lateral Movement | Move between OT systems |
| Collection | Gather process data |
| Command and Control | Communicate with compromised systems |
| Inhibit Response Function | Disable safety/protection systems |
| Impair Process Control | Manipulate the physical process |
| Impact | Cause physical damage, loss, or disruption |

The last three tactics — **Inhibit Response Function, Impair Process Control, and Impact** — are unique to ICS and represent the physical endgame.

---

## Key ICS-specific techniques

### Initial Access
```
T0817 — Drive-by Compromise
T0819 — Exploit Public-Facing Application
T0866 — Exploitation of Remote Services
T0822 — External Remote Services (VPN, remote access)
T0865 — Spearphishing Attachment (most common entry — via IT then pivot)
T0847 — Replication Through Removable Media (USB — how Stuxnet spread)
```

### Impair Process Control
```
T0836 — Modify Parameter (change setpoints to unsafe values)
T0831 — Manipulation of Control (directly control the process)
T0855 — Unauthorized Command Message (send rogue commands to PLCs)
T0806 — Brute Force I/O (rapidly manipulate inputs/outputs)
```

### Inhibit Response Function
```
T0880 — Loss of Safety (disable safety instrumented systems — TRITON)
T0878 — Alarm Suppression (hide the attack from operators)
T0838 — Modify Alarm Settings
T0881 — Service Stop (stop critical OT services)
```

### Impact
```
T0879 — Damage to Property (physical destruction)
T0826 — Loss of Availability (process shutdown)
T0828 — Loss of Productivity and Revenue
T0837 — Loss of Protection (remove safety margins)
T0882 — Theft of Operational Information
```

---

## Notable ICS attacks

### Stuxnet (2010) — the first cyber-physical weapon
```
Target: Iranian uranium enrichment centrifuges
Technique: Modified PLC logic to subtly alter centrifuge speeds while
           showing normal readings to operators
Delivery: USB (T0847) — crossed the air gap
Impact: Physically destroyed ~1,000 centrifuges (T0879)
Significance: Proved cyber attacks can cause physical destruction
```

### Ukraine Power Grid (2015 & 2016)
```
Target: Ukrainian electricity distribution
Technique: BlackEnergy (2015) then Industroyer/CrashOverride (2016)
           Industroyer spoke native ICS protocols (IEC 101/104, IEC 61850)
Impact: ~230,000 people lost power (T0826 Loss of Availability)
Significance: First confirmed cyber attack to cause a power blackout;
              Industroyer was purpose-built, protocol-aware ICS malware
```

### TRITON / TRISIS (2017)
```
Target: Petrochemical plant safety systems (Triconex SIS) in Saudi Arabia
Technique: Malware specifically designed to reprogram Safety Instrumented
           Systems (T0880 Loss of Safety)
Impact: Plant shut down safely when the attack triggered a fault; the
        intended impact was potentially catastrophic physical harm
Significance: First malware to target safety systems — crossing a line
              toward attacks intended to endanger human life
```

---

## Detecting ICS attacks

Detection in OT differs from IT — you cannot install agents on PLCs, and active scanning can crash fragile devices.

```
Passive network monitoring (the primary method):
  - Deploy a passive tap/SPAN port — never active scanning
  - Baseline normal OT protocol traffic (Modbus, DNP3, etc.)
  - Alert on anomalies:
    → New devices appearing on the OT network
    → Unexpected engineering/programming commands
    → Commands from unexpected sources
    → PLC logic downloads (T0843 Program Download)
    → Communication with the Safety Instrumented System
    → Setpoint changes outside normal operating ranges

Tools:
  - Nozomi Networks, Claroty, Dragos — OT-specific monitoring platforms
  - Zeek/Suricata with ICS protocol parsers
  - Historian anomaly detection (process values behaving abnormally)

Key detections mapped to ATT&CK for ICS:
  T0843 Program Download    → alert on ANY PLC reprogramming
  T0855 Unauthorized Command → alert on commands from non-HMI sources
  T0880 Loss of Safety       → alert on ANY SIS communication
  T0878 Alarm Suppression    → alert on alarm configuration changes
```

---

## ICS detection checklist

```
Visibility
□ Passive OT network monitoring deployed (no active scanning)
□ Baseline of normal OT traffic established
□ Asset inventory of all OT devices maintained

Detection coverage (mapped to ATT&CK for ICS)
□ PLC program downloads detected (T0843)
□ Unauthorised commands to controllers detected (T0855)
□ Any SIS communication alerted (T0880)
□ Alarm/setpoint changes monitored (T0836, T0838, T0878)
□ New devices on OT network detected
□ IT-to-OT boundary crossings monitored

Threat intelligence
□ ICS-specific threat intelligence consumed (Dragos, CISA ICS advisories)
□ Known ICS malware signatures deployed where possible
□ Sector-specific threats tracked (energy, water, manufacturing)

Response
□ OT-specific incident response plan (cannot just "unplug" safely)
□ Coordination between security, operations, and safety teams
□ Manual/safe operation procedures if control systems compromised
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ot-ics/purdue-model/"><span class="ref-label">OT/ICS</span>Purdue Model</a>
  <a class="ref-card" href="/wiki/ot-ics/ics-threat-model/"><span class="ref-label">OT/ICS</span>ICS Threat Modelling</a>
  <a class="ref-card" href="/wiki/ot-ics/ot-network-security/"><span class="ref-label">OT/ICS</span>OT Network Security</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Cases</a>
</div>

</div>
