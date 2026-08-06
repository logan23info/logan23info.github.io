---
title: "Privacy by Design"
date: 2026-08-05
tags: ["privacy", "privacy-by-design", "LINDDUN", "data-protection", "architecture"]
categories: ["privacy"]
description: "Privacy by Design — the 7 foundational principles, LINDDUN privacy threat modelling, and concrete privacy engineering patterns."
showToc: true
layout: "single"
---

## The 7 principles of Privacy by Design

Privacy by Design (PbD), developed by Ann Cavoukian and now embedded in GDPR Article 25, rests on seven principles:

| # | Principle | What it means in engineering |
|---|---|---|
| 1 | Proactive not reactive | Build privacy in at design time, not after a breach |
| 2 | Privacy as the default | Most private settings are the default — no action needed by user |
| 3 | Privacy embedded into design | Privacy is a core requirement, not a bolt-on |
| 4 | Full functionality (positive-sum) | Privacy AND functionality — not a trade-off |
| 5 | End-to-end security | Data protected across its entire lifecycle |
| 6 | Visibility and transparency | Users can see what happens to their data |
| 7 | Respect for user privacy | Keep it user-centric — user interests come first |

---

## LINDDUN — privacy threat modelling

LINDDUN is to privacy what STRIDE is to security. It provides seven privacy threat categories:

| Category | Threat | Example |
|---|---|---|
| **L**inking | Associating data items or actions to the same person | Correlating pseudonymous sessions to identify a user |
| **I**dentifying | Learning the identity of a person | De-anonymising a dataset |
| **N**on-repudiation | Being unable to deny an action | System proves a user visited a sensitive site — could harm them |
| **D**etecting | Deducing involvement through observation | Inferring someone uses a service from response times |
| **D**ata disclosure | Excessive or unauthorised data exposure | Over-collecting, leaking data |
| **U**nawareness | User is uninformed about processing | Hidden data collection, unclear policies |
| **N**on-compliance | System violates privacy regulations | Keeping data beyond retention, no lawful basis |

---

## Applying LINDDUN to a data flow

```
For each data flow and data store in your DFD, ask:

LINKING
  Can separate pieces of data be linked to build a profile?
  → Mitigation: unlinkability — separate identifiers per context

IDENTIFYING
  Can an individual be identified from this data?
  → Mitigation: anonymisation, pseudonymisation

NON-REPUDIATION
  Does the system create evidence that could harm the user?
  → Mitigation: plausible deniability where appropriate

DETECTING
  Can an observer detect that a user is involved?
  → Mitigation: hide patterns, constant-time responses

DATA DISCLOSURE
  Is more data exposed than necessary?
  → Mitigation: data minimisation, access control

UNAWARENESS
  Does the user understand what is happening to their data?
  → Mitigation: transparency, clear consent

NON-COMPLIANCE
  Does this violate any privacy regulation?
  → Mitigation: build to GDPR/regulatory requirements
```

---

## Privacy patterns

### Pattern 1 — Privacy by default

```python
# All privacy settings default to the MOST protective option

class PrivacySettings(BaseModel):
    profile_visibility: str = "private"          # not "public"
    share_data_for_analytics: bool = False       # opt-in, not opt-out
    marketing_emails: bool = False               # opt-in
    show_online_status: bool = False             # private by default
    allow_data_export_to_partners: bool = False  # opt-in

# The user must actively CHOOSE to share more — never the reverse
```

### Pattern 2 — Data separation / unlinkability

```python
# Store identifying data separately from behavioural data
# so a breach of one does not reveal the other

# Identity store (heavily protected, rarely accessed)
class IdentityRecord:
    internal_id: str        # random UUID — the linking key
    email: str
    name: str
    # encrypted, strict access control

# Behaviour store (used for analytics — no direct identifiers)
class BehaviourRecord:
    internal_id: str        # links to identity ONLY via the protected store
    events: list
    preferences: dict
    # An analyst can work with behaviour data without seeing identity
```

### Pattern 3 — Selective disclosure

```python
# Return only the data the specific context requires

def get_user_for_context(user_id: int, context: str) -> dict:
    user = db.get_user(user_id)
    if context == "public_profile":
        return {"display_name": user.display_name}   # minimal
    elif context == "order_shipping":
        return {"name": user.name, "address": user.address}  # only shipping
    elif context == "support_agent":
        return {"name": user.name, "email": user.email,
                "account_status": user.status}       # support-relevant only
    # Never return everything — each context gets its minimum
```

### Pattern 4 — Differential privacy for analytics

```python
import random

def private_count(true_count: int, epsilon: float = 1.0) -> float:
    """
    Add Laplace noise to protect individuals in aggregate statistics.
    Lower epsilon = more privacy, more noise.
    """
    scale = 1.0 / epsilon
    noise = random.gauss(0, scale)   # simplified; use proper Laplace in production
    return true_count + noise

# Publishing "how many users have condition X" — add noise so you
# cannot determine whether any specific individual is included
reported = private_count(actual_count, epsilon=0.5)
```

---

## Privacy by Design checklist

```
Design time
□ Privacy requirements defined alongside functional requirements
□ LINDDUN privacy threat model conducted for the feature
□ DPIA conducted if processing is high-risk
□ Data minimisation applied — only necessary data collected

Defaults
□ Most privacy-protective settings are the default
□ Data sharing is opt-in, never opt-out
□ New features do not silently expand data collection

Architecture
□ Identifying data separated from behavioural data
□ Selective disclosure — each context gets minimum data
□ Encryption at rest and in transit
□ Access control enforced per data category

Transparency
□ Privacy policy is accurate and plain-language
□ Users can see what data is held about them
□ Users can export and delete their data easily
□ Data processing is logged and auditable

Lifecycle
□ Retention limits enforced automatically
□ Data deleted/anonymised when no longer needed
□ Third-party processors bound by data processing agreements
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/privacy/gdpr-engineering/"><span class="ref-label">Privacy</span>GDPR Engineering</a>
  <a class="ref-card" href="/wiki/privacy/dpia/"><span class="ref-label">Privacy</span>DPIA</a>
  <a class="ref-card" href="/wiki/privacy/data-subject-rights/"><span class="ref-label">Privacy</span>Data Subject Rights</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/owasp-top10/a04-insecure-design/"><span class="ref-label">OWASP</span>A04 Insecure Design</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR — Article 25</a>
</div>

</div>
