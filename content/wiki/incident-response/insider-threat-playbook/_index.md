---
title: "Insider Threat Response Playbook"
date: 2026-08-05
tags: ["insider-threat", "incident-response", "playbook", "DLP", "investigation"]
categories: ["incident-response"]
description: "Insider threat response — detection, covert investigation, legal coordination, containment, and evidence preservation."
showToc: true
layout: "single"
---

## Insider threat — critical distinctions

Insider threat response is fundamentally different from external attack response:

| Dimension | External attack | Insider threat |
|---|---|---|
| Speed of containment | Immediate isolation | Covert — do NOT tip off the subject |
| Primary concern | Stop the attack | Preserve evidence, legal process |
| Who to involve immediately | IR team | HR, Legal, Compliance — before IT action |
| Evidence risk | Attacker destroying evidence | Subject destroying evidence if alerted |
| Notification | Broad IR team | Need-to-know only — strict confidentiality |

**The golden rule:** Never alert the insider before legal and HR authorise action. A tipped-off insider will destroy evidence and complicate legal proceedings.

---

## Immediate response (first 2 hours) — covert phase

```
□ 1. STRICT NEED-TO-KNOW: Brief only CISO, Legal, HR Director, CEO
     Do NOT brief the subject's manager yet (they may tip off the subject)
     Do NOT brief the broader IR team until legal authorises

□ 2. Preserve all evidence silently:
     → Enable enhanced audit logging on subject's accounts
     → Export current logs before they rotate
     → Snapshot email mailbox
     → Export DLP alerts and incidents involving the subject
     → Capture network logs showing subject's traffic

□ 3. Determine if ongoing harm is occurring:
     → Is exfiltration happening right now?
     → Is the subject currently logged in?
     → Are they accessing systems outside normal hours?

□ 4. Legal assessment (within 2 hours):
     → What is the legal basis for investigation?
     → What monitoring is permitted under employment law and GDPR?
     → Is law enforcement involvement needed?
     → What is the plan for employment action (suspension, termination)?
```

---

## Investigation (covert — days 1–7)

```
TECHNICAL EVIDENCE TO COLLECT
□ Email records — sent, received, deleted (including personal webmail if accessed on corporate device)
□ DLP alerts — all policy violations in past 90 days
□ File access logs — what files did the subject access?
□ File transfer logs — what was copied to USB, cloud, or email?
□ Printer logs — what was printed?
□ Browser history — corporate device
□ Application audit logs — what actions did they take in business systems?
□ Badge access records — physical access to restricted areas
□ VPN logs — off-hours remote access

BEHAVIOURAL INDICATORS TO DOCUMENT
□ Access to data outside their job role
□ Bulk downloads or large file copies
□ Accessing systems immediately before or after resignation notice
□ Emailing files to personal email addresses
□ Copying files to personal devices (USB, personal cloud)
□ Searching for competitors' information
□ Escalating frustration or grievance discussions (HR records)

CHAIN OF CUSTODY
□ All evidence must be collected with documented chain of custody
□ Forensic copies, not originals where possible
□ Hash verification of all evidence files
□ Evidence log: who collected, when, from where, how stored
```

---

## Legal decision point — before any overt action

```
BEFORE suspending, terminating, or confronting the subject, ensure:
□ Legal has reviewed all evidence
□ HR has reviewed against employment policies and local law
□ Decision: criminal referral vs civil vs employment action vs all three
□ Law enforcement briefed if criminal referral intended
□ Communication plan approved by Legal (what to say to colleagues)
□ IT access revocation plan ready to execute simultaneously with HR action
```

---

## Containment — coordinated and simultaneous

```
Execute all of these simultaneously at the agreed time:
□ HR: Conduct suspension/termination meeting
□ IT: Revoke all access (simultaneously with HR action)
  → Active Directory / Entra ID account disabled
  → All SaaS application access revoked
  → VPN access revoked
  → Physical badge access revoked
  → All active sessions terminated
□ IT: Change all shared credentials the subject had access to
□ Legal: Serve legal hold / preservation notice if required
□ Communications: Brief only those who need to know (subject's manager)
```

---

## Post-incident (systemic improvements)

```
□ Review how the behaviour went undetected for so long
□ Assess data access controls — did the subject have more access than needed?
□ Review DLP rules — should additional rules have caught this earlier?
□ Consider User and Entity Behaviour Analytics (UEBA) implementation
□ Review offboarding process — was this triggered by a resignation?
□ Update leavers process: revoke access within 1 hour of departure, not EOD
□ Consider data access reviews for users in high-risk roles (departing, disciplinary)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM — Insider Threat Use Cases</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — data breach notification</a>
</div>

</div>
