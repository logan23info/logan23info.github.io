--- 
title: "Test of Design (ToD)"
layout: "single"
date: 2026-08-02
tags: ["ToD", "test-of-design", "assurance", "audit", "controls"]
categories: ["governance"]
description: "Test of Design — validating that security controls are appropriately designed to address identified risks before implementation."
showToc: true
---

## What is a Test of Design?

A Test of Design (ToD) is an assurance activity that validates whether a security control is **designed appropriately** to address the risk it is intended to mitigate. It does not test whether the control has been implemented or is working — it tests whether the design itself is sound.

A control can fail the ToD in two ways:
- **Design gap** — the control does not address the risk at all
- **Design weakness** — the control partially addresses the risk but has logical flaws

ToD is equivalent to **SOC 2 Type I** — an auditor's opinion that controls are suitably designed at a point in time.

---

## When to perform a ToD

| Trigger | Example |
|---|---|
| New system or service being designed | Auth service being architected |
| Significant change to existing control | MFA policy being updated |
| New regulatory requirement | DORA ICT risk controls required |
| Post-incident remediation design | New rate limiting design after DDoS |
| Pre-implementation review | Security review before sprint starts |
| Annual control refresh | Yearly review of all security controls |

---

## ToD activity types

### 1. Design document review
Review the architecture decision records (ADRs), design documents, or threat model to assess whether:
- The control is mapped to a specific identified risk
- The control design logically reduces the likelihood or impact of that risk
- The control design has no obvious bypass or logical gap
- The control design meets the relevant standard or requirement

**Evidence to request:** Architecture diagrams, threat model, ADRs, policy documents, control design specification

---

### 2. Threat model walkthrough
Walk through the threat model with the engineering team. For each threat, assess:
- Is there a corresponding control designed to mitigate it?
- Does the control design address the root cause, not just a symptom?
- Are there residual risks documented and accepted?

**Questions to ask:**
```
For each identified threat:
□ What control is designed to address this threat?
□ How does the control design prevent or detect the threat?
□ What assumptions does the control design rely on?
□ What would cause the control to fail?
□ Is the residual risk documented and accepted by a risk owner?
```

---

### 3. Policy and standard review
Assess whether the control design aligns with:
- Internal security policy
- Relevant regulatory requirements (PCI-DSS, GDPR, DORA)
- Industry standards (NIST, ISO 27001, CIS Controls)

**Common ToD failures in policy review:**
- Password policy requires 8 characters but NIST SP 800-63B recommends 12+
- Encryption policy states AES-128 but PCI-DSS requires AES-256 for stored card data
- MFA policy exempts service accounts — creating an unmitigated bypass path

---

### 4. Control mapping review
Map each control to the risk register and verify:
- Every high and critical risk has at least one designed control
- The control type is appropriate (preventive, detective, corrective, deterrent)
- Compensating controls are documented where primary controls are not feasible

**Control types:**

| Type | Description | Example |
|---|---|---|
| Preventive | Stops the threat occurring | Input validation, MFA |
| Detective | Identifies when threat occurs | SIEM alerting, audit logging |
| Corrective | Reduces impact after threat occurs | Incident response, backups |
| Deterrent | Discourages threat actors | Legal notices, bug bounty |
| Compensating | Alternative when primary not feasible | Manual review when automation not possible |

---

## ToD checklist by control domain

### Identity & Access Management
```
□ MFA design covers all user types (employees, contractors, service accounts)?
□ Password policy aligns with NIST SP 800-63B?
□ Privileged access design includes JIT/JEA (just-in-time, just-enough-access)?
□ Joiners/movers/leavers process designed for all identity types?
□ Session timeout design defined per sensitivity of application?
```

### Network Security
```
□ Segmentation design prevents lateral movement between zones?
□ Trust boundary design matches threat model?
□ Ingress/egress filtering design documented?
□ VPN/ZTNA design enforces device compliance?
□ WAF rule design covers OWASP Top 10?
```

### Data Protection
```
□ Encryption design specifies algorithm, key length, and key management?
□ Data classification scheme designed and documented?
□ Data retention and disposal design meets regulatory requirements?
□ DLP design covers all data egress channels?
□ Backup design includes encryption and offsite storage?
```

### Application Security
```
□ SDLC design includes security gates (SAST, DAST, SCA)?
□ Secret management design prevents hardcoded credentials?
□ API security design includes authentication and rate limiting?
□ Dependency management design includes vulnerability scanning?
□ Threat model produced as part of design process?
```

### Logging & Monitoring
```
□ Log retention design meets regulatory minimums (typically 12 months)?
□ SIEM design covers all critical log sources?
□ Alert design includes severity tiers and escalation paths?
□ Incident response design tested via tabletop exercise?
□ Audit trail design is tamper-evident?
```

---

## ToD evidence table

| Control | Evidence to request | Designed by | Review outcome |
|---|---|---|---|
| MFA on all applications | MFA policy, architecture diagram | Identity team | Pass / Fail / Gap |
| Encryption at rest | Encryption policy, key management design | Platform team | Pass / Fail / Gap |
| SIEM coverage design | Log source inventory, detection rule catalogue | SOC team | Pass / Fail / Gap |
| Threat modelling process | TM procedure, example TM output | AppSec team | Pass / Fail / Gap |
| Incident response design | IR plan, playbooks, escalation matrix | SecOps team | Pass / Fail / Gap |

---

## ToD finding classifications

| Finding | Definition | Action required |
|---|---|---|
| **Design Gap** | No control designed to address a material risk | Design a control before implementation |
| **Design Weakness** | Control designed but with logical flaws | Redesign before implementation |
| **Design Observation** | Control design could be improved | Recommendation for enhancement |
| **Design Pass** | Control appropriately designed | Proceed to ToI |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/"><span class="ref-label">Assurance</span>Advisory & Assurance Overview</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation (ToI)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — feeds ToD risk mapping</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
</div>

</div>
