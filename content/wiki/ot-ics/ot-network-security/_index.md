---
title: "OT Network Security"
date: 2026-08-05
tags: ["OT-security", "ICS", "network-segmentation", "remote-access", "monitoring", "firewall"]
categories: ["ot-ics"]
description: "Securing OT networks — segmentation, secure remote access, passive monitoring, and protecting insecure-by-design industrial protocols."
showToc: true
layout: "single"
---

## The OT network security challenge

OT networks were built for reliability and safety, not security. They run protocols with no authentication, devices that cannot be patched, and equipment that must never go offline. Securing them means adding protection *around* systems you often cannot modify.

---

## Insecure-by-design protocols

Most industrial protocols have no built-in security:

| Protocol | Use | Security |
|---|---|---|
| Modbus | General industrial | No auth, no encryption — any device can send commands |
| DNP3 | Utilities, SCADA | Auth available (Secure DNP3) but rarely deployed |
| EtherNet/IP | Manufacturing | No native encryption |
| PROFINET | Manufacturing | No native encryption |
| IEC 61850 | Power substations | Targeted by Industroyer |
| S7comm | Siemens PLCs | Targeted by Stuxnet |

**The implication:** Since you cannot rely on the protocol for security, you must secure the *network* — segmentation, monitoring, and access control do the work the protocol cannot.

---

## Network segmentation

Segmentation is the single most effective OT security control. Follow the [Purdue Model](/wiki/ot-ics/purdue-model/) and enforce boundaries with firewalls.

```
Segmentation strategy:

1. IT / OT separation (the most important boundary)
   → IDMZ between enterprise IT and OT
   → No direct IT-to-OT traffic

2. Segment by Purdue level
   → Firewalls between Level 3 / 2 / 1
   → Default-deny; allow only required flows

3. Micro-segmentation within levels
   → Separate cells/zones for different processes
   → Contain an intrusion to one zone

4. Isolate safety systems
   → SIS on a physically separate network where possible
```

```
# Example OT firewall ruleset (conceptual — default deny)

# Allow HMI (L2) to poll PLC (L1) via Modbus — specific IPs only
ALLOW src=HMI-01 dst=PLC-CHEM proto=modbus/502 action=allow

# Allow historian (L3) to read from SCADA (L2)
ALLOW src=HISTORIAN dst=SCADA-01 proto=opc action=allow

# Deny everything else between levels
DENY  src=any dst=any action=deny log=true

# Explicitly deny any internet-bound traffic from OT
DENY  src=OT-subnet dst=internet action=deny log=true alert=true
```

---

## Secure remote access

Remote access is the #1 initial access vector for OT attacks. Vendors, remote operators, and integrators all need access — and each connection is a risk.

```
Secure OT remote access architecture:

Remote user
    │ VPN with MFA
    ▼
[IT network]
    │
    ▼
[IDMZ jump host]  ← MFA, session recording, time-limited access
    │ brokered connection (no direct tunnel to OT)
    ▼
[OT system]

Requirements:
□ No direct VPN into the OT network — always via IDMZ jump host
□ MFA on all remote access
□ Session recording for all OT access
□ Time-limited access — enabled only when needed, then disabled
□ Vendor access requires approval and is monitored live
□ Unique credentials per user — no shared vendor accounts
□ Disconnect by default — remote access is OFF until explicitly enabled
```

---

## Passive monitoring

You cannot run active vulnerability scans on OT — probing a fragile PLC can crash it and halt production. OT monitoring must be **passive**.

```
Passive monitoring approach:

1. Deploy a network tap or SPAN port (read-only copy of traffic)
2. Feed traffic to an OT monitoring platform (Dragos, Claroty, Nozomi)
3. The platform:
   - Passively discovers all devices (no active probing)
   - Baselines normal communication patterns
   - Alerts on anomalies without ever sending a packet to OT devices

What to alert on:
□ New/unknown device appears on the OT network
□ PLC programming/logic download (T0843)
□ Commands from unexpected sources
□ Communication with safety systems
□ Setpoint changes outside normal ranges
□ Any traffic attempting to cross segmentation boundaries
□ Cleartext credentials or unexpected protocols
```

---

## Protecting unpatchable systems

Many OT devices cannot be patched. Protect them with compensating controls:

```
Virtual patching / shielding:
  □ Network IPS in front of vulnerable devices (blocks known exploits)
  □ Application allowlisting on Windows-based HMIs/historians
  □ Restrict which systems can even communicate with the device

Isolation:
  □ Place unpatchable devices in their own segment
  □ Minimise what can reach them
  □ Monitor all traffic to/from them closely

Lifecycle:
  □ Track end-of-life systems in an asset register
  □ Plan replacement before vendor support ends
  □ Compensating controls documented as risk acceptances
```

---

## OT network security checklist

```
Segmentation
□ IDMZ between IT and OT — no direct traffic
□ Firewalls between Purdue levels (default-deny)
□ Micro-segmentation isolating process cells
□ Safety systems on isolated network
□ No OT system has direct internet access

Remote access
□ All remote access via IDMZ jump host (no direct OT tunnels)
□ MFA on all remote access
□ Session recording enabled
□ Remote access disabled by default, enabled on demand
□ Vendor access approved, time-limited, monitored
□ No shared accounts

Monitoring
□ Passive OT monitoring deployed (no active scanning)
□ All devices discovered and inventoried
□ Normal traffic baselined
□ Alerts for new devices, PLC changes, SIS comms, boundary crossings
□ OT logs fed to SIEM/SOC with OT context

Protecting legacy systems
□ Unpatchable devices identified and isolated
□ Network IPS / virtual patching for known vulnerabilities
□ Application allowlisting on OT servers/workstations
□ End-of-life systems tracked with replacement plans
□ Removable media controls (USB) — a primary infection vector
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ot-ics/purdue-model/"><span class="ref-label">OT/ICS</span>Purdue Model</a>
  <a class="ref-card" href="/wiki/ot-ics/ics-threat-model/"><span class="ref-label">OT/ICS</span>ICS Threat Modelling</a>
  <a class="ref-card" href="/wiki/ot-ics/attack-ics/"><span class="ref-label">OT/ICS</span>MITRE ATT&CK for ICS</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Cases</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Network Segmentation</a>
</div>

</div>
