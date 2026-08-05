---
title: "Advisory & Assurance — The Governance Layer Over Security Engineering"
date: 2026-08-02
tags: ["assurance", "advisory", "audit", "ToD", "ToI", "ToOE", "governance", "SOC2", "ISO27001", "PCI-DSS"]
categories: ["governance"]
series: ["Security Engineering Maturity"]
description: "How Advisory and Assurance activities — Test of Design, Test of Implementation, and Test of Operating Effectiveness — validate the controls your security engineering team builds."
showToc: true
weight: 7
---

## The missing layer

You have threat models, a red team, purple team exercises, and a Zero Trust roadmap. But how does anyone — the board, your customers, regulators — know the controls are actually working?

That is the role of **Advisory & Assurance**: an independent governance layer that validates what security engineering builds.

```
Security Engineering   → designs and builds controls
Advisory               → advises on control design and gaps
Assurance              → independently validates controls work
```

These are not competing functions. They are the complete control lifecycle.

---

## The three testing disciplines

### Test of Design (ToD)

**Question: Is the control designed correctly to address the risk?**

ToD happens before or during implementation. An assurance reviewer examines the control design — the architecture document, threat model, or policy — and assesses whether it logically mitigates the risk it is intended to address.

A control can fail ToD because:
- It does not address the root cause of the risk
- It has a logical bypass built into the design
- It does not meet the relevant regulatory requirement

**Real example:**
A company designs an MFA policy that requires MFA for all users — but exempts service accounts. An attacker who compromises a service account has full access with no MFA challenge. The design has a gap. ToD catches this before implementation.

---

### Test of Implementation (ToI)

**Question: Has the control been correctly implemented as designed?**

ToI happens after implementation. The assurance reviewer tests whether the control is actually in place — not just documented.

Common ToI techniques:
- Configuration inspection (check the actual settings)
- Walkthrough testing (step through the control operation)
- Technical testing (attempt to bypass the control)
- Evidence sampling (verify the control for a sample of cases)

**Real example:**
MFA policy says all users must have MFA. ToI finds that 14 service accounts, created before the policy, have never had MFA enrolled. The design was correct but implementation is incomplete. ToI catches this.

---

### Test of Operating Effectiveness (ToOE)

**Question: Has the control operated consistently and effectively over the review period?**

ToOE covers a period of time — typically 3, 6, or 12 months. It is not enough that a control worked once. It must work every time, for every applicable case, throughout the period.

This is the equivalent of **SOC 2 Type II** — the gold standard for customer-facing security assurance.

**Real example:**
MFA is enforced for all users. But in March, a bulk user import script created 200 accounts without triggering MFA enrollment. For 11 days, those accounts had no MFA. The control failed to operate effectively for 11 days. ToOE catches this through population sampling or continuous monitoring.

---

## How this maps to compliance frameworks

| Framework | ToD equivalent | ToI equivalent | ToOE equivalent |
|---|---|---|---|
| SOC 2 | Trust service criteria design | Type I opinion | Type II opinion |
| ISO 27001 | Control objective review | Implementation audit | Surveillance audit |
| PCI-DSS | Requirement design review | SAQ / onsite assessment | Continuous compliance |
| DORA (EU) | ICT risk control design | TLPT (threat-led pen test) | Annual ICT assurance |
| NIST CSF | Identify + Protect | Detect | Recover + continuous |

---

## Advisory activities

Beyond testing, the advisory function provides forward-looking guidance:

| Activity | Description | Output |
|---|---|---|
| Control gap analysis | Compare current controls to framework requirements | Gap register with priorities |
| Risk advisory | Advise on emerging risks and appropriate controls | Risk advisory report |
| Architecture review | Review new system designs for security control adequacy | Design findings |
| Regulatory advisory | Interpret new regulations and advise on compliance | Compliance roadmap |
| Security programme review | Assess overall security programme maturity | Maturity assessment |
| Red team debrief | Facilitate discussion of red team findings with stakeholders | Remediation priorities |

---

## Putting it all together

The full control assurance lifecycle:

```
1. Risk identified (via threat model, incident, regulatory change)
        ↓
2. Control designed (ToD — is the design adequate?)
        ↓
3. Control implemented (ToI — is it correctly in place?)
        ↓
4. Control operated (ToOE — is it working consistently?)
        ↓
5. Evidence collected (Controls & Evidence Catalogue)
        ↓
6. Findings reported (to management, audit committee, regulators)
        ↓
7. Gaps remediated → back to step 2
```

---

## Quick reference: what to test and when

| When | Activity | Test type |
|---|---|---|
| New system being designed | Architecture review, threat model review | ToD |
| Pre-go-live | Configuration review, walkthrough testing | ToI |
| Post-go-live (30 days) | Verify control operating | ToI |
| Quarterly | Access review validation, exception review | ToOE |
| Annually | Full control effectiveness review | ToOE |
| Before SOC 2 audit | Readiness assessment | ToD + ToI + ToOE |
| After security incident | Post-incident control review | ToI + ToOE |
| New regulation | Regulatory gap analysis | ToD |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation (ToI)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
