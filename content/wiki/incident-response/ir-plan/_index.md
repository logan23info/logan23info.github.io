---
title: "Incident Response Plan"
date: 2026-08-05
tags: ["IR-plan", "incident-response", "governance", "DFIR", "NIST"]
categories: ["incident-response"]
description: "Incident response plan template — governance, roles, incident classification, communication, and the six NIST phases."
showToc: true
layout: "single"
---

## IR Plan structure

Based on NIST SP 800-61 Computer Security Incident Handling Guide.

---

## Phase 1 — Preparation

Preparation happens before any incident. Without it, every incident takes 10x longer.

### IR team structure

```yaml
ir_team:
  incident_commander:
    responsibilities:
      - Declare incident severity
      - Coordinate all response activities
      - Approve major decisions (isolate production, pay ransom, notify)
      - Brief executive and board
      - Authorise external communications

  technical_lead:
    responsibilities:
      - Lead technical investigation
      - Coordinate with engineering, platform, DevOps
      - Document technical timeline
      - Recommend containment and eradication actions

  communications_lead:
    responsibilities:
      - Draft customer and public communications
      - Coordinate with legal before any external statement
      - Manage media enquiries
      - Update internal stakeholders

  legal_and_compliance:
    responsibilities:
      - Advise on regulatory notification obligations
      - Review all external communications
      - Manage law enforcement interaction
      - Preserve legal privilege on investigation communications

  external_ir_retainer:
    when_to_engage:
      - Nation-state level attack suspected
      - Ransomware with >$100k potential impact
      - Data breach requiring forensic evidence for legal proceedings
      - Internal team lacks capacity
```

### IR preparation checklist

```
Documentation
□ IR plan approved by management, reviewed annually
□ Incident contact list current — tested quarterly (can you reach everyone at 3am?)
□ Escalation matrix documented and practised
□ External IR retainer contract signed and IR firm briefed

Tools
□ Out-of-band communication channel (Signal group, secondary email)
□ Forensic workstation with write blockers and imaging tools
□ Network capture capability (tcpdump, Wireshark on key segments)
□ Log aggregation — all critical logs in SIEM with adequate retention
□ EDR on all endpoints with isolation capability
□ Incident tracking system (dedicated — separate from normal ticketing)

Access
□ Break-glass accounts: documented, tested, accessible when primary systems are down
□ Cloud provider emergency access (AWS Support, Google Cloud Support)
□ IR team has read access to all logs without production access

Legal and insurance
□ Cyber insurance policy reviewed — understand what is covered
□ Cyber insurer's IR firm contact on file (insurer may require their firm)
□ Legal firm with cyber experience on retainer
□ Know which regulators to notify and within what timeframe
```

---

## Phase 2 — Detection and Analysis

### Incident intake form

```yaml
# Complete within first 30 minutes of incident declaration
incident_id: "INC-2026-001"
declared_by: ""
declared_at: "2026-08-05T14:30:00Z"
severity: ""        # P1 / P2 / P3 / P4
category: ""        # ransomware / data_breach / account_compromise / ddos / insider / other

initial_description: |
  Brief description of what was detected, by whom, and when.

affected_systems: []
affected_users_or_customers: []
data_potentially_involved: []

detection_source: ""   # SIEM alert / user report / external notification / threat intel

immediate_questions:
  - Is the attacker still active in our environment?
  - What data may have been accessed or exfiltrated?
  - Is customer-facing service impacted?
  - Is this a notifiable breach under GDPR/PCI/DORA?
```

### Timeline construction

Build a precise timeline from the moment you begin — it is essential for:
- Root cause analysis
- Regulatory reporting (GDPR 72-hour notification needs exact timestamps)
- Legal proceedings
- Post-incident review

```markdown
# Incident Timeline — INC-2026-001

| Timestamp (UTC) | Event | Source | Actioned by |
|---|---|---|---|
| 2026-08-05 14:22 | SIEM alert fires — LSASS access on HOST-001 | SIEM | Automated |
| 2026-08-05 14:25 | SOC analyst investigates alert | SIEM | analyst@example.com |
| 2026-08-05 14:35 | Lateral movement confirmed — 3 hosts affected | EDR | analyst@example.com |
| 2026-08-05 14:40 | Incident declared P1 | Phone | CISO |
| 2026-08-05 14:45 | IR team assembled on bridge call | Zoom | IC |
| 2026-08-05 15:00 | Affected hosts isolated | EDR | tech-lead@example.com |
```

---

## Phase 3 — Containment

### Containment decision framework

```
For each affected system, decide:

SHORT-TERM CONTAINMENT (do immediately)
→ Isolate: EDR network isolation, VLAN change, firewall block
→ Preserve: memory dump, log snapshot before isolation

LONG-TERM CONTAINMENT (within hours)
→ Can the system be rebuilt from known-good?
→ Is evidence preservation required for legal action?
→ Can the service be temporarily moved to a clean environment?

DO NOT DO IMMEDIATELY (preserve evidence):
→ Do not reimage without taking forensic image first
→ Do not delete attacker artefacts (you need them for root cause)
→ Do not patch before understanding the attack vector
```

---

## Phase 4 — Eradication

```
□ Identify all attacker persistence mechanisms
  → Scheduled tasks, startup items, registry keys
  → New user accounts or SSH keys
  → Web shells on web servers
  → Malware files and dropper scripts
  → Compromised credentials (rotate ALL credentials)

□ Remove all attacker artefacts from ALL affected systems
□ Patch the vulnerability that enabled the attack
□ Rotate all potentially compromised credentials
□ Revoke all potentially compromised tokens and certificates
□ Rebuild systems from known-good images where possible
```

---

## Phase 5 — Recovery

```
□ Restore from known-good backups (verify backup integrity first)
□ Rebuild compromised systems from clean base images
□ Verify systems are clean before returning to production
  → Fresh vulnerability scan
  → EDR confirmation no malicious processes
  → Log review for 24 hours post-recovery

□ Restore services in prioritised order (critical first)
□ Monitor intensively for 72 hours post-recovery
□ Communication: notify customers/stakeholders of recovery

Recovery validation:
□ Have we removed ALL attacker access?
□ Have we patched the root cause vulnerability?
□ Have we rotated all compromised credentials?
□ Are our monitoring and alerting working?
□ Do we have enhanced monitoring in place for the next 30 days?
```

---

## Phase 6 — Post-Incident Review

Conduct within 2 weeks of recovery. See [Post-Incident Review Template](/wiki/incident-response/post-incident-review/) for the full template.

```
Minimum outputs:
□ Complete incident timeline
□ Root cause identified
□ What worked well
□ What could be improved
□ Action items with owners and due dates — tracked to completion
□ Updated IR plan if gaps identified
□ Brief to executive team
□ Lessons shared with engineering team
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ransomware-playbook/"><span class="ref-label">IR</span>Ransomware Playbook</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review Template</a>
  <a class="ref-card" href="/wiki/detection-engineering/soc-playbooks/"><span class="ref-label">Detection</span>SOC Playbook Templates</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — breach notification</a>
  <a class="ref-card" href="/wiki/compliance/dora/"><span class="ref-label">Compliance</span>DORA — incident reporting</a>
</div>

</div>
