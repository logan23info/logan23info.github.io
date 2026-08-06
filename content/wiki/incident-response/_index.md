---
title: "Incident Response"
date: 2026-08-05
tags: ["incident-response", "IR", "playbooks", "ransomware", "data-breach", "DFIR"]
categories: ["incident-response"]
description: "Incident response reference — IR plan, ransomware playbook, data breach playbook, DDoS playbook, insider threat playbook, and post-incident review template."
showToc: true
layout: "single"
---

## Incident response phases

Every security incident follows the same lifecycle regardless of type:

```
Preparation → Detection → Analysis → Containment → Eradication → Recovery → Post-Incident Review
     ↑                                                                              |
     └──────────────────────────── lessons learned ──────────────────────────────┘
```

---

## Pages in this section

| Page | Description |
|---|---|
| [IR Plan](/wiki/incident-response/ir-plan/) | Incident response plan — governance, roles, classification, and communication |
| [Ransomware Playbook](/wiki/incident-response/ransomware-playbook/) | Step-by-step ransomware response — isolate, assess, decide, recover |
| [Data Breach Playbook](/wiki/incident-response/data-breach-playbook/) | Data breach response — triage, scope, notify, remediate |
| [DDoS Playbook](/wiki/incident-response/ddos-playbook/) | DDoS response — identify, classify, activate defences, recover |
| [Insider Threat Playbook](/wiki/incident-response/insider-threat-playbook/) | Insider threat response — detection, investigation, containment, legal |
| [Post-Incident Review Template](/wiki/incident-response/post-incident-review/) | PIR template — timeline, root cause, lessons learned, action items |

---

## Incident severity classification

| Severity | Criteria | Response SLA | Escalation |
|---|---|---|---|
| P1 — Critical | Production down, active breach, ransomware, >10,000 customers affected | Respond in 15 min, all hands | CISO, CEO, Board |
| P2 — High | Significant data exposure, single system compromised, >100 customers affected | Respond in 1 hour | CISO, CTO |
| P3 — Medium | Limited data exposure, non-critical system compromised | Respond in 4 hours | Security Manager |
| P4 — Low | Policy violation, minor misconfiguration, no data exposure | Respond in 24 hours | SOC Team |

---

## IR contact list template

```yaml
# ir-contacts.yml — keep updated and accessible offline
incident_commander:
  primary:
    name: ""
    role: "CISO"
    phone: ""
    email: ""
  backup:
    name: ""
    role: "Security Manager"
    phone: ""

technical_lead:
  primary:
    name: ""
    role: "Lead Security Engineer"
    phone: ""

legal_and_privacy:
  name: ""
  role: "General Counsel / DPO"
  phone: ""

communications:
  name: ""
  role: "Head of Communications"
  phone: ""

external:
  ir_retainer:
    company: ""
    contact: ""
    phone: ""
    contract_ref: ""

  law_enforcement:
    agency: "National Cyber Crime Unit / FBI"
    reporting_url: ""

  cyber_insurer:
    company: ""
    policy_number: ""
    claims_phone: ""
    claims_email: ""

  regulator:
    agency: ""   # ICO / CNIL / BaFin etc.
    reporting_url: ""
    notification_deadline: "72 hours (GDPR)"
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/ransomware-playbook/"><span class="ref-label">IR</span>Ransomware Playbook</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/detection-engineering/soc-playbooks/"><span class="ref-label">Detection</span>SOC Playbook Templates</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — 72-hour breach notification</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — MON domain</a>
</div>

</div>
