---
title: "Post-Incident Review Template"
date: 2026-08-05
tags: ["post-incident-review", "PIR", "lessons-learned", "incident-response", "blameless"]
categories: ["incident-response"]
description: "Post-incident review template — blameless retrospective, timeline, root cause analysis, impact quantification, and action items."
showToc: true
layout: "single"
---

## Purpose of the Post-Incident Review

A Post-Incident Review (PIR) — also called a post-mortem — is a structured retrospective conducted after every significant security incident. Its purpose is to:

- Understand exactly what happened and why
- Identify systemic improvements that prevent recurrence
- Learn from the incident without blaming individuals
- Document decisions made and their rationale

**Blameless culture:** The PIR is not about finding who made a mistake. It is about understanding why a reasonable person, with the information available at the time, made the decisions they did — and what systemic changes would have led to a better outcome.

**Timing:** Conduct within 2 weeks of incident resolution, while memories are fresh.

---

## PIR template

```markdown
# Post-Incident Review
## [Incident ID] — [Incident title]

**Date of PIR:** [date]
**Incident Commander:** [name]
**Facilitator:** [name — should not be IC]
**Attendees:** [list everyone present]
**Document status:** Draft / Final
**Classification:** Internal / Confidential

---

## 1. Incident summary

| Field | Value |
|---|---|
| Incident ID | INC-2026-XXX |
| Severity | P1 / P2 / P3 / P4 |
| Category | Ransomware / Data breach / DDoS / Account compromise / Other |
| Start time | [timestamp — when attack/issue began] |
| Detection time | [timestamp — when we became aware] |
| Containment time | [timestamp — when attacker access stopped] |
| Recovery time | [timestamp — when services fully restored] |
| Total duration | [hours/days from start to recovery] |
| MTTD (Mean Time to Detect) | [start time → detection time] |
| MTTC (Mean Time to Contain) | [detection time → containment time] |
| MTTR (Mean Time to Recover) | [detection time → recovery time] |

---

## 2. Impact

### Customer impact
- Number of customers affected: [number or "unknown"]
- Nature of impact: [service unavailable / data exposed / degraded service]
- Duration of customer impact: [hours]
- SLA breach: [Yes / No — specify SLA and breach duration]

### Data impact
- Personal data involved: [Yes / No]
- Categories of data: [if yes — specify]
- Number of data subjects: [if yes — approximate]
- Regulatory notification required: [Yes / No / Under investigation]

### Financial impact
- Direct costs: [IR firm fees, forensic tools, overtime]
- Indirect costs: [SLA credits, business disruption estimate]
- Regulatory fines risk: [if notification required]
- Reputational impact: [news coverage, customer churn estimate]

### Operational impact
- Systems affected: [list]
- Peak outage: [% of service unavailable at worst]
- Data loss: [any data permanently lost?]

---

## 3. Timeline

*Be precise — use UTC timestamps. Every significant event in chronological order.*

| Time (UTC) | Event | Who | Source |
|---|---|---|---|
| [timestamp] | [Earliest indicator of attack/issue] | | |
| [timestamp] | [Alert fired in SIEM] | | SIEM |
| [timestamp] | [SOC analyst investigates] | [name] | |
| [timestamp] | [Incident declared — severity set] | [name] | |
| [timestamp] | [IR team assembled] | [name] | |
| [timestamp] | [First containment action] | [name] | |
| [timestamp] | [Executive notified] | [name] | |
| [timestamp] | [Regulator notified (if applicable)] | [name] | |
| [timestamp] | [Customers notified (if applicable)] | [name] | |
| [timestamp] | [Root cause identified] | [name] | |
| [timestamp] | [Systems restored] | [name] | |
| [timestamp] | [Incident closed] | [name] | |

---

## 4. Root cause analysis

### 5-Whys analysis

*Keep asking "Why?" until you reach a systemic cause.*

```
PROBLEM: [Describe the incident]

WHY 1: Why did this happen?
  → [Answer]

WHY 2: Why did [answer to Why 1] happen?
  → [Answer]

WHY 3: Why did [answer to Why 2] happen?
  → [Answer]

WHY 4: Why did [answer to Why 3] happen?
  → [Answer]

WHY 5: Why did [answer to Why 4] happen?
  → ROOT CAUSE: [The systemic reason — this is what the action items must address]
```

### Contributing factors

*Beyond the root cause, what other factors made this worse?*

| Factor | Description |
|---|---|
| Detection gap | [e.g. Alert threshold too high — should have fired earlier] |
| Response gap | [e.g. On-call runbook not accessible during incident] |
| Control gap | [e.g. MFA not enforced on affected account] |
| Process gap | [e.g. Vendor patch notification not acted on] |
| Training gap | [e.g. Analyst not familiar with this attack type] |

---

## 5. What went well

*Be specific — recognise effective actions and decisions.*

| What | Why it helped |
|---|---|
| [e.g. EDR isolation capability] | [Reduced spread to 3 systems instead of entire network] |
| [e.g. IR retainer contract] | [IR firm on-site within 2 hours] |
| [e.g. Immutable backups] | [Ransomware could not encrypt backups — recovery possible] |
| [e.g. Out-of-band comms] | [Attacker could not intercept IR team communications] |

---

## 6. What could be improved

*Be specific and blameless — focus on systems and processes, not people.*

| What | Why it was a problem | Proposed improvement |
|---|---|---|
| [e.g. Detection delay] | [SIEM alert threshold too high — fired 4 hours late] | [Lower threshold, add correlated rule] |
| [e.g. Playbook gap] | [No ransomware playbook — team improvised] | [Create and test ransomware playbook] |
| [e.g. Access control] | [Compromised account had excessive permissions] | [Quarterly access review, least privilege enforcement] |

---

## 7. Action items

*Every finding must have an owner and a due date. Track to completion.*

| ID | Action | Owner | Priority | Due date | Status |
|---|---|---|---|---|---|
| PIR-001-01 | [Action description] | [Name/team] | Critical | [date] | Open |
| PIR-001-02 | [Action description] | [Name/team] | High | [date] | Open |
| PIR-001-03 | [Action description] | [Name/team] | Medium | [date] | Open |

**Review cadence:** Action items reviewed at weekly security meeting until all closed.
**Owner accountability:** [CISO name] is accountable for ensuring all PIR actions are completed.

---

## 8. Decisions log

*Document major decisions made during the incident and the rationale.*

| Time | Decision | Made by | Rationale |
|---|---|---|---|
| [timestamp] | [e.g. Decided not to pay ransom] | [IC + CEO] | [Backups available, clean restore feasible] |
| [timestamp] | [e.g. Delayed customer notification by 6 hours] | [Legal + CISO] | [Needed to confirm scope before notification] |
| [timestamp] | [e.g. Engaged external IR firm] | [CISO] | [Internal team at capacity] |

---

## 9. Communications log

| Time | Audience | Channel | Message summary | Sent by |
|---|---|---|---|---|
| [timestamp] | Executive team | Phone bridge | Incident declared P1 | IC |
| [timestamp] | Board | Email | Status update | CEO |
| [timestamp] | Regulator (ICO) | Secure portal | Article 33 notification | DPO |
| [timestamp] | Customers | Email | Breach notification | Comms lead |

---

## 10. Metrics update

*Update the team's detection and response metrics based on this incident.*

| Metric | This incident | Previous average | Trend |
|---|---|---|---|
| MTTD | [X hours] | [X hours] | ↑ worse / ↓ better |
| MTTC | [X hours] | [X hours] | |
| MTTR | [X hours] | [X hours] | |
| Detection source | [SIEM / User report / External] | | |

---

## 11. Approval

| Role | Name | Date |
|---|---|---|
| Incident Commander | | |
| CISO | | |
| Legal | | |
| DPO (if applicable) | | |
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/ransomware-playbook/"><span class="ref-label">IR</span>Ransomware Playbook</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Metrics — MTTD/MTTR</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — notification requirements</a>
  <a class="ref-card" href="/wiki/compliance/dora/"><span class="ref-label">Compliance</span>DORA — incident reporting</a>
</div>

</div>
