---
title: "Ransomware Response Playbook"
date: 2026-08-05
tags: ["ransomware", "incident-response", "playbook", "recovery", "backup"]
categories: ["incident-response"]
description: "Step-by-step ransomware incident response — immediate isolation, scope assessment, the pay/don't-pay decision framework, and recovery."
showToc: true
layout: "single"
---

## Ransomware response — critical first 4 hours

Ransomware response is time-critical. The attacker may still be active and encrypting. Every minute matters.

---

## Immediate actions (first 30 minutes)

```
MINUTE 1–5: STOP THE SPREAD
□ Alert the IR team — declare P1 immediately
□ Do NOT shut down affected systems (you will lose volatile memory)
□ Do NOT reconnect isolated systems to the network
□ Immediately identify which systems are actively encrypting

□ Network isolation — cut affected network segments:
  → AWS: modify security groups to block all traffic
  → On-prem: VLAN change or disable switch ports
  → EDR: enable network isolation on all affected endpoints

MINUTE 5–15: PRESERVE EVIDENCE
□ Capture memory from affected systems (Magnet RAM Capture, WinPmem)
□ Preserve network logs from past 48 hours BEFORE they rotate
□ Screenshot ransom note — photograph the screen if needed
□ Note all affected hostnames and IPs

MINUTE 15–30: SCOPE ASSESSMENT
□ How many systems are encrypted?
□ Is the attacker still active? (Check EDR for running processes)
□ Are backups affected? (Check backup system — is it encrypted too?)
□ Is data exfiltration suspected? (Check network egress logs)
□ Are domain controllers compromised? (This determines recovery complexity)
```

---

## Scope and impact assessment (hours 1–4)

```
SYSTEM SCOPE
□ List all encrypted systems (by hostname, IP, function)
□ Identify which systems are critical (production vs non-production)
□ Are domain controllers affected? (Critical — means all credentials compromised)
□ Is Active Directory/Entra ID affected?
□ Are backup systems affected?

DATA SCOPE
□ What data was on affected systems?
□ Is any of it personal data (GDPR notification trigger)?
□ Is any of it payment card data (PCI-DSS notification trigger)?
□ Evidence of exfiltration before encryption? (Check:)
  → Large outbound transfers in 48 hours before encryption
  → Connections to Mega.nz, file-sharing sites, unusual IPs
  → Rclone, WinRAR with unusual command-line arguments

BACKUP INTEGRITY
□ Are backups encrypted? (Test restore of a recent backup NOW)
□ When was the last clean backup?
□ How long to restore from backup?
□ Is the restore tested and reliable?

ATTACKER PRESENCE
□ Is the attacker still active in the environment?
□ Are there any systems NOT yet encrypted that the attacker has access to?
□ Have admin credentials been compromised? (Assume yes until proven otherwise)
```

---

## The pay / don't pay decision

This is a business decision, not a technical one. Involve: CISO, CEO, CFO, Legal, Cyber Insurance.

| Factor | Pay | Don't Pay |
|---|---|---|
| Backups available and tested | ✗ No | ✓ Yes |
| Recovery time from backup | >4 weeks | <1 week |
| Data exfiltrated and threatened | ✓ Yes | ✗ No |
| Regulatory obligation if data published | Critical | Low |
| Threat actor reputation for decryption | ✓ Reliable | ✗ Scammer |
| Payment amount vs recovery cost | Payment < recovery | Payment > recovery |
| Law enforcement guidance | Allows payment | Discourages payment |

**Before deciding to pay:**
- Contact your cyber insurer — they may have negotiating experience
- Contact law enforcement — they may have the decryption key
- Check https://www.nomoreransom.org — free decryptors for many strains
- Verify the attacker can actually decrypt (request test decryption of 2–3 non-sensitive files)
- Engage specialist ransomware negotiation firm (check insurer's panel)

**Note:** Payment does not guarantee decryption. Payment does not prevent data publication. Some jurisdictions restrict payments to sanctioned entities — legal must verify before any payment.

---

## Recovery phases

### Phase A — Infrastructure recovery (domain compromised)

If domain controllers are compromised, assume ALL domain credentials are stolen:

```
□ 1. Rebuild domain controllers from scratch (do not restore from backup)
□ 2. Create new krbtgt account (invalidates all Kerberos tickets)
□ 3. Reset ALL domain user passwords — every single one
□ 4. Reset ALL service account passwords
□ 5. Revoke all cloud federation tokens
□ 6. Reset all local administrator passwords
□ 7. Deploy new GPO baseline
□ 8. Only then begin restoring other systems
```

### Phase B — System restoration

```
Priority order:
1. Core infrastructure (DNS, DHCP, authentication)
2. Business-critical systems (ERP, payment processing)
3. Communication systems (email, collaboration)
4. Business systems (CRM, finance)
5. Development systems (lowest priority)

For each system:
□ Restore from last known clean backup
□ Verify backup integrity before restore
□ Patch all vulnerabilities before connecting to network
□ Deploy EDR before connecting to network
□ Monitor intensively for 72 hours after restore
□ Verify business functionality before declaring recovered
```

### Phase C — Root cause remediation

Do not restore to production until you have:
```
□ Identified the initial access vector
□ Patched or remediated the initial access vulnerability
□ Confirmed the vulnerability no longer exists
□ Enhanced monitoring for that attack vector
□ Confirmed no backdoors or persistence remain
```

---

## Communication templates

### Internal executive update (every 2 hours)

```
RANSOMWARE INCIDENT UPDATE — [Time]

Incident Commander: [Name]
Severity: P1

SITUATION:
- [X] systems encrypted as of [time]
- Attacker [is/is not] believed to still be active
- Backup integrity: [clean/affected — last clean backup: date]
- Estimated recovery time: [X hours/days]

CURRENT ACTIONS:
- [Action 1]
- [Action 2]

DECISIONS NEEDED FROM EXECUTIVE:
- [Decision 1 — e.g. approve payment negotiation]

NEXT UPDATE: [Time]
```

### Customer notification (coordinate with Legal before sending)

```
Subject: Important security notice — service disruption

We are writing to inform you that [Company] has experienced a cybersecurity
incident that has caused disruption to our services.

What happened: [Brief, non-technical description]
What we are doing: [Recovery actions]
What this means for you: [Impact on customer]
What you should do: [Any actions required from customer]

We take the security of your data extremely seriously and are working around
the clock to restore services. We will provide further updates as available.

[Do not speculate about data exposure until investigation is complete]
[Legal must review before sending]
```

---

## Post-ransomware hardening

Before declaring fully recovered, implement:

```
□ Offline, air-gapped backups — implement the 3-2-1-1-0 backup rule:
  3 copies, 2 different media, 1 offsite, 1 offline, 0 errors verified
□ Network segmentation — prevent lateral movement
□ Privileged Access Workstations (PAWs) for admin tasks
□ MFA everywhere — especially VPN and RDP
□ Disable RDP on internet-facing systems
□ EDR on 100% of endpoints
□ Email filtering — block Office macros from external sources
□ Canary files — files that alert when accessed (honeypots)
□ Immutable backup storage (S3 Object Lock, Azure Immutable Blob)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review Template</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — breach notification</a>
</div>

</div>
