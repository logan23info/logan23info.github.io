---
title: "Risk Appetite"
date: 2026-08-05
tags: ["metrics", "risk-appetite", "risk-management", "governance", "risk-tolerance"]
categories: ["metrics"]
description: "Defining and operationalising security risk appetite — appetite vs tolerance, risk statements, and turning appetite into engineering decisions."
showToc: true
layout: "single"
---

## What is risk appetite?

Risk appetite is the amount and type of risk an organisation is willing to accept in pursuit of its objectives. It is the boundary that turns "how much security is enough?" from an endless debate into a defined threshold.

```
Risk Appetite  — how much risk we WANT to take (strategic, set by the board)
Risk Tolerance — how much we can DEVIATE from appetite before acting (operational)
Risk Capacity  — the maximum risk we could survive (absolute limit)

Appetite < Tolerance < Capacity
```

---

## Why it matters for engineers

Without a defined risk appetite, every security decision becomes subjective. With one, decisions become objective:

```
Without appetite:
  "Should we accept this vulnerability?" → endless debate

With appetite:
  "Our appetite says: no critical vulnerabilities on internet-facing
   systems for more than 24 hours. This one is critical and internet-facing.
   Therefore we must fix it within 24 hours or take the system offline."
   → clear, objective decision
```

---

## Risk appetite statements

Good risk appetite statements are specific and measurable:

```
DATA PROTECTION
"We have NO appetite for loss of customer personal data. We will invest
to keep the likelihood of a material data breach below [X]% per year."

AVAILABILITY
"We have LOW appetite for service downtime. Our target is 99.95% uptime;
we tolerate up to 99.9% before escalation."

VULNERABILITIES
"We have NO appetite for critical vulnerabilities on internet-facing
systems remaining unpatched beyond 24 hours."

THIRD PARTIES
"We have MODERATE appetite for third-party risk where the vendor holds
no customer data, and LOW appetite where they process personal data."

INNOVATION
"We have HIGHER appetite for risk in internal experimental tools and
LOWER appetite in customer-facing production systems."
```

---

## Appetite levels

```
NONE / AVERSE
  We will not accept this risk under any normal circumstances.
  Example: knowingly shipping known-exploited vulnerabilities.

LOW / MINIMAL
  We accept minimal risk, prioritising safety over speed/cost.
  Example: production systems handling payment data.

MODERATE / CAUTIOUS
  We accept measured risk with appropriate controls.
  Example: internal business systems.

HIGH / OPEN
  We accept higher risk to enable speed and innovation.
  Example: internal experimental/prototype tools.
```

---

## Operationalising risk appetite

Turn appetite into concrete engineering thresholds:

```yaml
# risk-appetite-operational.yml

internet_facing_systems:
  appetite: low
  thresholds:
    critical_vuln_max_age_hours: 24
    high_vuln_max_age_days: 7
    mfa_required: true
    encryption_required: true
    penetration_test_frequency: annual
  breach_action: "Escalate to CISO; may take system offline"

customer_data_systems:
  appetite: none  # for data loss
  thresholds:
    encryption_at_rest: mandatory
    access_reviews: quarterly
    dlp_required: true
    max_data_retention_days: per_policy
  breach_action: "Immediate escalation to CISO and DPO"

internal_tools:
  appetite: moderate
  thresholds:
    critical_vuln_max_age_days: 7
    mfa_required: true
  breach_action: "Track and remediate in normal sprint cycle"

experimental_prototypes:
  appetite: high
  thresholds:
    no_production_data: mandatory
    isolated_environment: mandatory
  breach_action: "Document; contain to prototype environment"
```

---

## Risk acceptance process

When a risk exceeds appetite but cannot be immediately fixed:

```yaml
# risk-acceptance-record.yml
risk_id: "RA-2026-042"
description: "Legacy API uses TLS 1.1 — cannot upgrade until Q3 client migration"
risk_score: 12   # high
appetite_breach: "Exceeds 'low appetite' for internet-facing systems"

business_justification: |
  Upgrading now would break 200 enterprise clients on legacy integrations.
  Migration plan in progress, completion Q3.

compensating_controls:
  - "WAF rule blocking known TLS 1.1 exploits"
  - "Enhanced monitoring on this endpoint"
  - "IP allowlist limiting access to known clients"

accepted_by: "CISO"          # must be senior enough for the risk level
accepted_date: "2026-08-05"
review_date: "2026-09-05"     # risk acceptance is time-boxed
expiry: "2026-10-01"          # hard deadline — must be resolved by Q3
```

**Key principle:** Risk acceptance is always time-boxed, documented, and signed off at a level appropriate to the risk. It is never permanent and never informal.

---

## Risk appetite checklist

```
Definition
□ Board-approved risk appetite statement exists
□ Appetite defined per domain (data, availability, vulnerabilities, third parties)
□ Appetite statements are specific and measurable
□ Difference between appetite, tolerance, and capacity understood

Operationalisation
□ Appetite translated into concrete engineering thresholds
□ Thresholds embedded in policy and automated where possible
□ Teams know the appetite for their systems
□ Breaching appetite triggers a defined action

Governance
□ Risk acceptance process documented
□ Risk acceptances are time-boxed and signed off appropriately
□ Compensating controls required for accepted risks
□ Risk register tracks all acceptances with review dates
□ Appetite reviewed annually and after major changes
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/metrics/security-kpis/"><span class="ref-label">Metrics</span>Security KPIs</a>
  <a class="ref-card" href="/wiki/metrics/board-reporting/"><span class="ref-label">Metrics</span>Board Reporting</a>
  <a class="ref-card" href="/wiki/dread/"><span class="ref-label">Framework</span>DREAD — risk scoring</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register</a>
  <a class="ref-card" href="/wiki/advisory-assurance/advisory-assurance/"><span class="ref-label">Assurance</span>Advisory & Assurance</a>
  <a class="ref-card" href="/wiki/compliance/dora/"><span class="ref-label">Compliance</span>DORA — risk management</a>
</div>

</div>
