---
title: "Data Protection Impact Assessment (DPIA)"
date: 2026-08-05
tags: ["privacy", "DPIA", "GDPR", "risk-assessment", "data-protection"]
categories: ["privacy"]
description: "When and how to conduct a Data Protection Impact Assessment — triggers, the full process, risk scoring, and a reusable DPIA template."
showToc: true
layout: "single"
---

## What is a DPIA?

A Data Protection Impact Assessment (DPIA) is a process to identify and minimise the data protection risks of a project. GDPR Article 35 makes DPIAs mandatory for processing that is "likely to result in a high risk to the rights and freedoms of natural persons."

A DPIA is not a box-ticking exercise — done well, it is a structured privacy threat model that surfaces risks before they become breaches or regulatory findings.

---

## When is a DPIA mandatory?

A DPIA is required when processing involves any of these (per Article 35 and guidance):

```
□ Systematic and extensive profiling with significant effects
  (e.g. credit scoring, automated hiring decisions)

□ Large-scale processing of special category data
  (health, biometric, racial/ethnic, political, religious data)

□ Systematic monitoring of a publicly accessible area on a large scale
  (e.g. CCTV, location tracking)

Additional triggers from regulator guidance (any TWO = DPIA needed):
□ Evaluation or scoring
□ Automated decision-making with legal/significant effect
□ Systematic monitoring
□ Sensitive data or highly personal data
□ Data processed on a large scale
□ Matching or combining datasets
□ Data concerning vulnerable subjects (children, employees, patients)
□ Innovative use of new technology (AI, IoT, biometrics)
□ Processing that prevents data subjects exercising a right or using a service
```

---

## The DPIA process

```
Step 1 — Describe the processing
    What data, why, how, who, how long, where

Step 2 — Assess necessity and proportionality
    Is this processing necessary? Is there a less intrusive way?

Step 3 — Identify and assess risks
    What could go wrong for the individuals? (privacy threat modelling)

Step 4 — Identify measures to mitigate risks
    What controls reduce each risk to an acceptable level?

Step 5 — Sign off and integrate
    DPO reviews; residual high risks may require regulator consultation

Step 6 — Review
    Revisit when the processing changes
```

---

## DPIA template

```markdown
# Data Protection Impact Assessment

**Project:** [name]
**DPIA reference:** DPIA-2026-XXX
**Author:** [name]
**Date:** [date]
**DPO review:** [name, date]
**Status:** Draft / Approved / Requires regulator consultation

---

## 1. Description of processing

**What is the project?**
[Describe the system/feature and its purpose]

**What personal data is processed?**
| Data category | Special category? | Source | Volume |
|---|---|---|---|
| [e.g. Name, email] | No | User signup | ~50,000 |
| [e.g. Health data] | Yes | User input | ~5,000 |

**Purpose of processing:** [Why is this data processed?]
**Lawful basis:** [Consent / Contract / Legitimate interest / etc.]
**Data subjects:** [Who? Customers, employees, children?]
**Recipients:** [Who receives the data? Internal teams, processors, third parties]
**Retention period:** [How long is data kept?]
**International transfers:** [Any transfers outside EU/UK? Safeguards?]

---

## 2. Necessity and proportionality

**Is the processing necessary to achieve the purpose?**
[Justify why this data is needed]

**Could the purpose be achieved with less data or less intrusive means?**
[Consider alternatives — can you use anonymised/aggregated data instead?]

**How is data minimisation applied?**
[What have you excluded? Why is what remains the minimum?]

---

## 3. Risk assessment

*For each risk: score Likelihood (1-5) × Severity (1-5) = Risk score*

| ID | Risk to individuals | Likelihood | Severity | Score | 
|---|---|---|---|---|
| R1 | [e.g. Unauthorised access to health data] | 3 | 5 | 15 |
| R2 | [e.g. Data used beyond stated purpose] | 2 | 4 | 8 |
| R3 | [e.g. Re-identification of anonymised data] | 2 | 4 | 8 |
| R4 | [e.g. Excessive retention] | 3 | 3 | 9 |
| R5 | [e.g. Data breach exposing PII] | 3 | 4 | 12 |

*Risk to individuals means harm to THEM — identity theft, discrimination,
financial loss, distress, reputational damage — not risk to the company.*

---

## 4. Mitigation measures

| Risk ID | Mitigation | Residual score | Owner |
|---|---|---|---|
| R1 | Encryption at rest + field-level access control + MFA | 4 | Eng lead |
| R2 | Purpose tagging enforced at access time | 2 | Eng lead |
| R3 | k-anonymity (k=5) verified before any data sharing | 2 | Data team |
| R4 | Automated deletion after retention period | 3 | Platform |
| R5 | Pen test + encryption + breach response plan | 4 | Security |

---

## 5. Outcome

**Highest residual risk:** [score]

□ All risks reduced to acceptable level → proceed
□ High residual risk remains → consult supervisory authority before proceeding (Article 36)

**DPO recommendation:** [Approve / Approve with conditions / Do not proceed]

---

## 6. Sign-off

| Role | Name | Date | Decision |
|---|---|---|---|
| Project owner | | | |
| DPO | | | |
| CISO | | | |
```

---

## Privacy risk scoring guide

```
SEVERITY (impact on the individual):
5 — Critical: identity theft, physical safety risk, severe discrimination
4 — Major: financial loss, significant distress, reputational harm
3 — Moderate: inconvenience, minor distress, spam/unwanted contact
2 — Minor: limited impact, easily remedied
1 — Negligible: no meaningful impact

LIKELIHOOD:
5 — Almost certain: will happen without controls
4 — Likely: probable in normal operation
3 — Possible: could happen
2 — Unlikely: would require unusual circumstances
1 — Rare: highly improbable

RISK = Severity × Likelihood
15-25: High — mitigate before proceeding, consider regulator consultation
8-14:  Medium — mitigate to reduce
1-7:   Low — monitor
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/privacy/privacy-by-design/"><span class="ref-label">Privacy</span>Privacy by Design</a>
  <a class="ref-card" href="/wiki/privacy/gdpr-engineering/"><span class="ref-label">Privacy</span>GDPR Engineering</a>
  <a class="ref-card" href="/wiki/privacy/data-subject-rights/"><span class="ref-label">Privacy</span>Data Subject Rights</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
</div>

</div>
