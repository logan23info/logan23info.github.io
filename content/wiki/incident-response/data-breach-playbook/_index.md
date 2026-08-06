---
title: "Data Breach Response Playbook"
date: 2026-08-05
tags: ["data-breach", "incident-response", "GDPR", "notification", "PII", "playbook"]
categories: ["incident-response"]
description: "Data breach response playbook — triage, scope assessment, GDPR 72-hour notification, regulatory reporting, and customer communication."
showToc: true
layout: "single"
---

## Data breach response — the 72-hour clock

Under GDPR, you must notify your supervisory authority within **72 hours of becoming aware** of a personal data breach. The clock starts the moment you have reasonable grounds to believe a breach has occurred — not when the investigation is complete.

**The most important first step: establish awareness time precisely.** This determines your regulatory deadline.

---

## Immediate response (first 2 hours)

```
□ 1. Record the exact time of awareness (this starts the 72-hour clock)
□ 2. Assemble IR team — include DPO/Legal from the start
□ 3. Classify the incident:
    → Is personal data confirmed or suspected to be involved?
    → Is special category data involved (health, biometric, racial origin)?
    → What is the approximate scale?

□ 4. Initiate containment — stop the bleeding first:
    → Revoke compromised credentials / API keys
    → Patch exploited vulnerability (if known)
    → Isolate affected systems
    → Disable unauthorised access paths

□ 5. Preserve evidence:
    → Do NOT delete logs, even if they contain sensitive data
    → Snapshot database states and access logs
    → Capture network flow records
```

---

## Scope investigation (hours 2–24)

```
DATA SCOPE — answer these questions:
□ What categories of personal data were exposed?
  → Names, emails, addresses, phone numbers
  → Financial data (card numbers, bank accounts, salary)
  → Health or medical data (GDPR special category)
  → Government IDs (passport, national insurance, SSN)
  → Biometric data (GDPR special category)
  → Children's data (enhanced protections)

□ How many data subjects (individuals) are affected?
  → Approximate count is sufficient for initial notification
  → Be conservative — overstate if unsure

□ What was the exposure mechanism?
  → Unauthorised access (who, how, how long?)
  → Accidental disclosure (email, misconfigured S3)
  → Stolen device or paper records
  → Insider misuse

□ What is the confidentiality, integrity, availability impact?
  → Confidentiality: was data viewed/copied by unauthorised party?
  → Integrity: was data modified?
  → Availability: was data deleted or made inaccessible?

□ What is the risk to data subjects?
  → Low: encrypted data, no likely harm (still notify regulator)
  → Medium: names and emails — phishing risk
  → High: financial data, health data, credentials
  → Critical: data enabling identity theft, physical harm risk
```

---

## Regulatory notification decision tree

```
Is personal data of EU/UK residents involved?
  └─ YES → GDPR applies → notify DPA within 72 hours (Article 33)
  └─ NO  → Check other applicable regulations

Is the risk to individuals HIGH or CRITICAL?
  └─ YES → Also notify individuals without undue delay (Article 34)
  └─ NO  → Individual notification not required (document reasoning)

Is payment card data involved?
  └─ YES → Notify card brands (Visa/Mastercard) within 72 hours
           → Engage Qualified Incident Response Assessor (QIRA)

Is the entity a DORA-regulated financial entity (EU)?
  └─ YES → Assess against DORA major incident criteria
           → Notify competent authority within 4 hours if major

Is US personal data involved?
  └─ YES → Check applicable state laws (California CCPA, etc.)
           → Many states require 30–72 hour notification
```

---

## GDPR Article 33 notification template

```markdown
# Notification to [DPA Name]
# Article 33 GDPR — Personal Data Breach Notification

**Notification reference:** BR-2026-[XXX]
**Date/time of notification:** [timestamp]
**Date/time of awareness:** [timestamp — this determines if within 72h]
**Notifying organisation:** [Company name, address, registration number]
**DPO contact:** [Name, email, phone]

---

## 1. Nature of the breach (Article 33(3)(a))

**Category of breach:** [Confidentiality / Integrity / Availability breach]

**Description:**
[Plain language description of what happened, how it was discovered,
and the likely cause. Be factual — avoid speculation.]

---

## 2. Categories and approximate number of data subjects (Article 33(3)(b))

**Categories of data subjects:**
- [e.g. Registered customers]
- [e.g. Former employees]

**Approximate number of data subjects affected:** [number]

---

## 3. Categories and approximate number of records (Article 33(3)(b))

**Categories of personal data involved:**
- [e.g. Full name]
- [e.g. Email address]
- [e.g. Hashed password]
- [e.g. Date of birth]

**Approximate number of records:** [number]

**Special category data involved:** [Yes / No]
If yes: [specify category — health, biometric, etc.]

---

## 4. Likely consequences (Article 33(3)(c))

[Describe likely impact on affected individuals:
- Identity theft risk
- Financial harm risk
- Phishing/fraud risk
- Discrimination risk
- Physical safety risk]

---

## 5. Measures taken or proposed (Article 33(3)(d))

**Immediate measures taken:**
1. [e.g. Vulnerability patched at 15:30 on [date]]
2. [e.g. Compromised credentials revoked]
3. [e.g. Affected accounts flagged for password reset]
4. [e.g. Enhanced monitoring deployed]

**Planned measures:**
1. [e.g. Full forensic investigation in progress]
2. [e.g. Security audit of all similar endpoints scheduled]

---

## 6. Additional information

**Is the investigation ongoing?** Yes / No
If yes: we will provide supplementary information as available.

**Have individuals been notified?** Yes / No / Under assessment
```

---

## Customer notification (Article 34)

Notify individuals when the breach is **likely to result in high risk** to their rights and freedoms.

```
Subject: Important notice about your account security

Dear [Customer name / "Valued customer"],

We are writing to let you know about a security incident that may have
affected your account with [Company].

WHAT HAPPENED
On [date], we discovered that [brief, plain-language description].
We immediately [containment action].

WHAT INFORMATION WAS INVOLVED
The following information may have been accessed:
- [Data type 1]
- [Data type 2]

YOUR CREDIT CARD NUMBERS AND PASSWORDS WERE NOT INVOLVED.
[Delete/adjust as appropriate — be specific about what was NOT involved]

WHAT WE ARE DOING
We have [describe remediation]. We have also [describe additional measures].

WHAT YOU SHOULD DO
1. [Specific action — e.g. Change your password on [site] and any site
   where you use the same password]
2. [e.g. Be alert for phishing emails using your name and email address]
3. [e.g. Monitor your accounts for any unusual activity]

If you have any questions, please contact [dedicated breach support contact].

We sincerely apologise for this incident. [Do not over-apologise or admit
legal liability — Legal must approve this message before sending]

[Company name]
```

---

## Evidence preservation checklist

```
□ Incident timeline documented from first indicator to containment
□ All affected database query logs preserved
□ All authentication logs for affected systems preserved (6 months minimum)
□ Network flow logs for the breach window preserved
□ Copies of attacker tools, scripts, or code preserved
□ Screenshots of attacker activity in logs
□ Chain of custody document for forensic evidence
□ All communications with regulators logged and preserved
□ Legal hold placed on relevant email accounts and systems
□ Privilege log maintained for legal-privileged communications
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — Article 33 notification</a>
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review</a>
  <a class="ref-card" href="/wiki/owasp-top10/a01-broken-access-control/"><span class="ref-label">OWASP</span>A01 Broken Access Control</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS breach notification</a>
</div>

</div>
