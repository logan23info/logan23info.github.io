---
title: "Zero Trust Architecture (ZTA)"
date: 2026-08-02
tags: ["zero-trust", "ZTA", "architecture", "security-engineering", "level-6"]
categories: ["security-engineering"]
description: "Complete guide to Zero Trust Architecture — from NIST SP 800-207 foundations through to practical implementation roadmaps."
showToc: true
weight: 6
---

## What is Zero Trust?

Zero Trust is a security architecture philosophy based on a single principle:

> **"Never trust, always verify."**

In a traditional perimeter-based security model, anything inside the corporate network is trusted. Zero Trust eliminates the concept of a trusted network. Every request — regardless of where it comes from (corporate office, home, cloud, internal network) — must be authenticated, authorised, and continuously validated before access is granted.

**The traditional model:** Trust the network. Verify at the perimeter. Everything inside is safe.

**Zero Trust:** Trust nothing. Verify everything. Assume breach.

---

## Why Zero Trust now?

The traditional perimeter has dissolved:

- **Cloud:** Corporate data lives in AWS/GCP/Azure, not in an on-premises datacenter
- **Remote work:** Users work from home, coffee shops, and hotels — outside the perimeter
- **SaaS:** Applications like Salesforce, Slack, and GitHub are accessed over the internet
- **Mobile:** Company data is accessed from phones and tablets outside corporate control
- **Insider threats:** The perimeter model fails completely against internal attackers

The result: a VPN that "puts you inside the network" now gives attackers who steal one credential access to everything.

**Zero Trust solves this by making the identity and device the perimeter, not the network.**

---

## NIST SP 800-207 — The definitive standard

NIST Special Publication 800-207 is the authoritative definition of Zero Trust Architecture. It defines seven core tenets:

### Tenet 1 — All data sources and computing services are resources
Everything is a resource — a database, an API, a printer, a cloud function. No resource is inherently trusted because of where it is located.

### Tenet 2 — All communication is secured regardless of network location
A request from inside the corporate network is treated the same as a request from the internet. All communication is encrypted and authenticated.

### Tenet 3 — Access to individual resources is granted on a per-session basis
Access is not granted to a network segment — it is granted to a specific resource for a specific session. Logging into VPN does not grant access to everything; accessing the payroll database requires separate authorisation for that resource.

### Tenet 4 — Access to resources is determined by dynamic policy
The policy engine considers identity, device health, location, time of day, data sensitivity, and behavioural patterns when making access decisions — not just "is this user in the right group?"

### Tenet 5 — The enterprise monitors and measures the integrity of all assets
All devices are continuously assessed for security posture — are they patched? Is AV running? Is disk encrypted? An unpatched device gets reduced access, not full trust.

### Tenet 6 — All resource authentication and authorisation is dynamic and strictly enforced
Authentication is not a one-time event. Sessions are continuously re-evaluated. An anomalous action (unusual download volume, access from a new location) triggers step-up authentication.

### Tenet 7 — Enterprise collects information about the current state of assets, network, and communications
Comprehensive logging of all access requests, policy decisions, and resource access enables audit, threat hunting, and incident response.

---

## The Zero Trust logical architecture

```
                    ┌─────────────────────────────────┐
                    │         CONTROL PLANE            │
                    │                                  │
  Identity ─────→  │  Policy Engine ←── Threat Intel  │
  Device   ─────→  │       ↕                          │
  Context  ─────→  │  Policy Administrator            │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────▼──────────────────┐
                    │          DATA PLANE              │
                    │                                  │
  Subject ─────→   │  Policy Enforcement Point (PEP)  │ ────→ Resource
  (User/Device)    │                                  │
                    └─────────────────────────────────┘
```

- **Policy Engine (PE):** Makes the access decision (allow/deny/step-up auth)
- **Policy Administrator (PA):** Executes the decision (issues session token, configures PEP)
- **Policy Enforcement Point (PEP):** Enforces the decision (API gateway, proxy, firewall)

---

## The five pillars of Zero Trust

### Pillar 1 — Identity

Identity is the foundation of Zero Trust — it is the new perimeter.

**Requirements:**
- Multi-factor authentication (MFA) on every application
- Passwordless authentication (FIDO2/WebAuthn) where possible
- Just-in-time (JIT) and just-enough-access (JEA) provisioning
- Privileged Access Management (PAM) for admin accounts
- Continuous identity risk scoring

**Technologies:** Microsoft Entra ID, Okta, Ping Identity, CyberArk PAM

**Maturity levels:**
```
Level 1: MFA enabled for all users
Level 2: Conditional access policies (block risky sign-ins)
Level 3: Passwordless for privileged accounts
Level 4: Continuous access evaluation, real-time risk scoring
```

### Pillar 2 — Devices

Every device accessing company resources must be known, managed, and healthy.

**Requirements:**
- Device inventory (every device registered in MDM)
- Device compliance checks before access is granted
- Certificate-based device authentication
- Continuous device health monitoring
- Remote wipe capability for lost/stolen devices

**Technologies:** Microsoft Intune, Jamf, CrowdStrike Falcon, Carbon Black

**Compliance checks:**
```python
# Example device compliance policy
def check_device_compliance(device):
    checks = {
        "disk_encrypted": device.bitlocker_enabled or device.filevault_enabled,
        "os_patched": device.days_since_patch < 30,
        "av_running": device.av_status == "active",
        "screen_lock": device.screen_lock_timeout <= 15,
        "jailbroken": not device.is_jailbroken,
    }
    compliance_score = sum(checks.values()) / len(checks)
    return compliance_score >= 0.8  # 80% compliance required
```

### Pillar 3 — Network

Microsegment the network so that compromise of one segment cannot spread to others.

**Requirements:**
- Eliminate implicit trust based on network location
- Microsegmentation — every workload isolated by default
- Encrypt all east-west (internal) traffic
- Software-defined perimeter (SDP) instead of VPN
- Network traffic analytics to detect anomalies

**Technologies:** Zscaler ZPA, Cloudflare Access, Palo Alto Prisma, Cisco Duo

**Before microsegmentation:**
```
Corporate Network (all trusted)
├── Finance systems
├── HR systems
├── Developer systems   ← compromised
│     └── Lateral movement to Finance ← unrestricted
└── Customer database   ← exfiltrated
```

**After microsegmentation:**
```
Corporate Network (no implicit trust)
├── Finance segment (Finance team only, MFA required per session)
├── HR segment (HR team only)
├── Developer segment   ← compromised
│     └── Cannot reach Finance ← blocked by policy
└── Customer DB segment (App service only, no direct user access)
```

### Pillar 4 — Applications

Move away from network-based access (VPN) to identity-based access per application.

**Requirements:**
- All applications require authentication (no network-based trust)
- Application-level authorisation (RBAC/ABAC)
- API gateway enforces per-request authorisation
- Single Sign-On (SSO) with MFA for all apps
- Continuous session validation

**Technologies:** Okta, Auth0, Azure AD App Proxy, BeyondCorp

### Pillar 5 — Data

Protect data at rest and in transit, and enforce data-level access controls.

**Requirements:**
- Data classification (public, internal, confidential, restricted)
- Encryption at rest for all sensitive data
- Encryption in transit (TLS 1.3 minimum)
- Data Loss Prevention (DLP) on endpoints and network
- Rights management for sensitive documents

**Technologies:** Microsoft Purview, Varonis, Forcepoint DLP

---

## Zero Trust implementation roadmap

Zero Trust is a multi-year journey, not a product you buy.

### Year 1 — Foundation
- [ ] MFA for all users on all applications
- [ ] Device inventory — know every device accessing your data
- [ ] Identity governance — review and remove excessive permissions
- [ ] Conditional access — block sign-ins from unmanaged devices
- [ ] Data classification — know where your sensitive data is

### Year 2 — Enforcement
- [ ] Device compliance policies — block non-compliant devices
- [ ] Application proxy — remove VPN for internal apps
- [ ] Microsegmentation — segment at least critical systems
- [ ] PAM solution — control privileged access
- [ ] DLP — prevent sensitive data leaving controlled channels

### Year 3 — Optimisation
- [ ] Continuous access evaluation — real-time session risk assessment
- [ ] UEBA — behavioural analytics to detect anomalies
- [ ] Passwordless authentication for all users
- [ ] Full microsegmentation across all workloads
- [ ] Automated response — risky sessions terminated automatically

---

## Google BeyondCorp — The real-world blueprint

Google built the first enterprise Zero Trust implementation after the Operation Aurora attack in 2010 (a nation-state attack via an IE zero-day). Their BeyondCorp architecture:

- **Eliminated the corporate VPN** — all access goes through an identity-aware proxy
- **Made the internet the network** — employees work from anywhere with the same access
- **Every request validated** — user identity + device certificate + device health
- **No special trust for the internal network** — a request from Google HQ is treated the same as from a coffee shop

Google published their architecture in a series of papers (BeyondCorp 1–6) available free online. This became the template for the entire Zero Trust industry.

---

## Zero Trust vs traditional security

| Scenario | Traditional (Perimeter) | Zero Trust |
|---|---|---|
| Stolen VPN credentials | Attacker has full network access | Access still requires MFA + compliant device |
| Compromised laptop on corporate network | Full lateral movement possible | Microsegmentation blocks cross-segment access |
| Insider threat | Can access anything on the network | Access limited to job-required resources only |
| Shadow IT | Unknown apps on the network | All access requires policy enforcement point |
| Remote worker | Reduced access via VPN | Same access as office — identity is the perimeter |

---

## Key metrics

| Metric | Target |
|---|---|
| MFA coverage | 100% of users and applications |
| Managed device ratio | > 95% of devices accessing company data |
| Privileged account review | Quarterly, all unused accounts removed |
| Mean time to revoke access | < 1 hour for terminated employees |
| Microsegmentation coverage | 100% of critical workloads isolated |
| Lateral movement blast radius | < 5% of assets reachable from single compromise |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder Overview</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Zero Trust eliminates these threats</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
