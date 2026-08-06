---
title: "Data Subject Rights"
date: 2026-08-05
tags: ["privacy", "GDPR", "data-subject-rights", "SAR", "erasure", "portability"]
categories: ["privacy"]
description: "Implementing GDPR data subject rights in code — access, erasure, rectification, portability, and objection, with request-handling workflows."
showToc: true
layout: "single"
---

## The GDPR data subject rights

GDPR gives individuals eight rights over their personal data. Most must be actioned within **one month** of receiving a request.

| Right | Article | Deadline | What it means |
|---|---|---|---|
| Access (SAR) | 15 | 1 month | Get a copy of all their data |
| Rectification | 16 | 1 month | Correct inaccurate data |
| Erasure | 17 | 1 month | Delete their data ("right to be forgotten") |
| Restriction | 18 | 1 month | Limit how data is processed |
| Portability | 20 | 1 month | Receive data in machine-readable format |
| Objection | 21 | 1 month | Object to processing (e.g. marketing) |
| Automated decisions | 22 | — | Not be subject to solely automated decisions |
| Information | 13/14 | At collection | Be told how data is used |

---

## Subject Access Request (Article 15)

```python
def handle_subject_access_request(user_id: int, request_id: str) -> dict:
    """
    Compile ALL personal data held about the individual.
    Must be provided within 1 month, in a commonly used format.
    """
    # Gather from ALL systems — this is the hard part
    data = {
        "request_id": request_id,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "identity": db.get_user_profile(user_id),
        "orders": db.get_user_orders(user_id),
        "support_tickets": support_system.get_tickets(user_id),
        "consent_history": consent_manager.get_history(user_id),
        "marketing_preferences": marketing.get_preferences(user_id),
        "login_history": auth_logs.get_history(user_id, days=365),
        "analytics_profile": analytics.get_profile(pseudonymise(user_id)),
        "third_party_shares": data_sharing_log.get_shares(user_id),
    }

    # Redact data about OTHER people that may appear
    # (e.g. a support ticket mentioning another customer)
    data = redact_third_party_data(data)

    # Include metadata GDPR requires
    data["processing_info"] = {
        "purposes": get_processing_purposes(user_id),
        "categories": get_data_categories(user_id),
        "recipients": get_data_recipients(user_id),
        "retention_periods": RETENTION_POLICIES,
        "source": get_data_source(user_id),
    }

    audit_log.record("sar_completed", request_id, user_id)
    return data
```

## Right to Erasure (Article 17)

```python
def handle_erasure_request(user_id: int, request_id: str) -> dict:
    """
    Delete personal data across ALL systems.
    Some data may be retained if there is a legal obligation.
    """
    results = {}

    # Check for lawful reasons to retain (Article 17(3) exceptions)
    if has_legal_retention_obligation(user_id):
        # e.g. tax records must be kept 7 years — anonymise instead
        results["transactions"] = "anonymised (legal retention)"
        anonymise_transactions(user_id)
    else:
        results["transactions"] = "deleted"
        db.delete_transactions(user_id)

    # Delete from all other systems
    db.anonymise_user(user_id);            results["profile"] = "anonymised"
    email_marketing.delete(user_id);       results["marketing"] = "deleted"
    analytics.delete(pseudonymise(user_id)); results["analytics"] = "deleted"
    support_system.anonymise(user_id);     results["support"] = "anonymised"
    search_index.remove(user_id);          results["search"] = "removed"

    # Backups — cannot delete immediately, schedule for next rotation
    backup_deletion_queue.add(user_id, complete_by=datetime.now() + timedelta(days=35))
    results["backups"] = "scheduled for deletion within 35 days"

    # Notify downstream processors to delete too
    for processor in get_processors(user_id):
        processor.request_deletion(user_id)

    audit_log.record("erasure_completed", request_id, user_id, results)
    notify_user_of_completion(user_id, request_id)
    return results
```

## Right to Portability (Article 20)

```python
def handle_portability_request(user_id: int) -> bytes:
    """
    Provide data the user gave us, in a structured, machine-readable,
    commonly-used format (JSON, CSV). Only data provided by the user
    under consent or contract — not derived/inferred data.
    """
    portable_data = {
        "profile": db.get_user_provided_profile(user_id),   # data THEY gave
        "content": db.get_user_generated_content(user_id),  # their posts, uploads
        "preferences": db.get_user_preferences(user_id),
        # NOT included: derived data, analytics inferences, internal scores
    }
    # Machine-readable format enables transfer to another provider
    return json.dumps(portable_data, indent=2).encode()
```

## Request handling workflow

```python
from enum import Enum

class RequestType(Enum):
    ACCESS = "access"
    ERASURE = "erasure"
    RECTIFICATION = "rectification"
    PORTABILITY = "portability"
    OBJECTION = "objection"
    RESTRICTION = "restriction"

class DataSubjectRequest:
    def __init__(self, request_type: RequestType, user_email: str):
        self.id = generate_request_id()
        self.type = request_type
        self.received_at = datetime.now(timezone.utc)
        self.deadline = self.received_at + timedelta(days=30)   # 1 month
        self.status = "received"

    def process(self):
        # Step 1 — Verify identity (prevent unauthorised requests)
        if not self.verify_identity():
            self.status = "identity_verification_required"
            return

        # Step 2 — Log the request (accountability)
        audit_log.record("dsr_received", self.id, self.type)

        # Step 3 — Route to the correct handler
        handler = {
            RequestType.ACCESS: handle_subject_access_request,
            RequestType.ERASURE: handle_erasure_request,
            RequestType.PORTABILITY: handle_portability_request,
        }[self.type]

        result = handler(self.user_id, self.id)
        self.status = "completed"

        # Step 4 — Respond within deadline
        self.respond_to_subject(result)
```

## Data subject rights checklist

```
Process
□ Single intake point for all data subject requests
□ Identity verification before actioning any request
□ Every request logged with timestamp and deadline
□ 1-month deadline tracked with escalation before breach
□ Extension process for complex requests (max +2 months, must notify)

Access (SAR)
□ Can compile ALL data across ALL systems for one individual
□ Third-party data redacted from responses
□ Processing metadata included (purposes, recipients, retention)

Erasure
□ Deletes from primary AND all secondary systems
□ Legal retention exceptions handled (anonymise vs delete)
□ Backup deletion scheduled and tracked
□ Downstream processors notified

Portability
□ Export in machine-readable format (JSON/CSV)
□ Only user-provided data (not derived/inferred)

Rectification & objection
□ Correction propagates to all systems
□ Marketing objection stops processing immediately
□ Automated-decision objection routes to human review
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/privacy/gdpr-engineering/"><span class="ref-label">Privacy</span>GDPR Engineering</a>
  <a class="ref-card" href="/wiki/privacy/privacy-by-design/"><span class="ref-label">Privacy</span>Privacy by Design</a>
  <a class="ref-card" href="/wiki/privacy/dpia/"><span class="ref-label">Privacy</span>DPIA</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
</div>

</div>
