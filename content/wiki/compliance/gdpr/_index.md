---
title: "GDPR — General Data Protection Regulation"
date: 2026-08-05
tags: ["GDPR", "compliance", "privacy", "data-protection", "EU"]
categories: ["compliance"]
description: "GDPR compliance guide — key articles, security controls mapping, evidence requirements, and gap assessment checklist."
showToc: true
layout: "single"
---

## What is GDPR?

The General Data Protection Regulation (EU) 2016/679 governs how personal data of EU/EEA residents is collected, processed, and stored. It applies to **any organisation anywhere in the world** that processes personal data of EU residents.

**Penalties:** Up to €20M or 4% of global annual turnover (whichever is higher).

---

## Key articles — security engineering mapping

### Article 25 — Privacy by Design and Default

| Requirement | Engineering control | Evidence |
|---|---|---|
| Privacy by design | Threat model includes privacy threats | Threat model documents |
| Privacy by default | Most restrictive settings are the default | Code review, config audit |
| Data minimisation | APIs return minimum data | API schema, code review |

```python
# Privacy by default — return minimum data, opt-in for more
@app.get("/users/{user_id}")
def get_user(
    user_id: int,
    include_address: bool = False,   # opt-in only
    include_phone: bool = False,
    current_user = Depends(get_current_user)
):
    user = db.get_user(user_id)
    response = {"id": user.id, "name": user.name, "email": user.email}
    if include_address and has_permission(current_user, "view_address"):
        response["address"] = user.address
    return response
```

### Article 32 — Security of Processing

| Requirement | Engineering control | STRIDE | Evidence |
|---|---|---|---|
| Encryption at rest | AES-256 for all personal data | Info Disclosure | Encryption config |
| Encryption in transit | TLS 1.2+ for all API calls | Tampering | TLS scan results |
| Pseudonymisation | Replace direct identifiers with tokens | Info Disclosure | Design doc |
| Resilience | Multi-AZ, backups, tested DR | DoS | DR test results |
| Regular testing | Annual pen test, SAST/DAST in CI | All | Test reports |

```python
# Pseudonymisation
import hashlib, hmac

PSEUDONYMISATION_KEY = b"loaded-from-secrets-manager"

def pseudonymise(identifier: str) -> str:
    return hmac.new(PSEUDONYMISATION_KEY, identifier.encode(), hashlib.sha256).hexdigest()

# Analytics gets pseudonymised ID, never real email
def track_event(user_email: str, event: str):
    analytics.track(pseudonymise(user_email), event)
```

### Article 33 — Breach Notification (72 hours)

```yaml
# breach-notification-template.yml
breach_reference: "BR-2026-001"
awareness_datetime: "2026-08-05T14:30:00Z"
notification_deadline: "2026-08-08T14:30:00Z"   # 72 hours

nature_of_breach: "Unauthorised access to user database via SQL injection"
data_subjects:
  categories: ["registered users"]
  approximate_number: 45000
records_affected:
  categories: ["name", "email", "hashed password"]
  approximate_number: 45000
likely_consequences: "Low risk — passwords hashed with bcrypt. Phishing risk."
measures_taken:
  - "Vulnerability patched and deployed at 15:00"
  - "Forced password reset for all affected accounts"
  - "Forensic investigation commenced"
```

### Article 17 — Right to Erasure

```python
def handle_erasure_request(user_id: int, request_id: str):
    """Complete within 1 month — Article 12"""
    db.anonymise_user(user_id)
    email_marketing.delete_contact(user_id)
    analytics.delete_user(user_id)
    backup_queue.schedule_deletion(user_id)   # from backups within 30 days
    audit_log.record({"event": "erasure_completed", "request_id": request_id})
```

---

## GDPR gap assessment checklist

```
Governance
□ DPO appointed (required for large-scale processing)
□ Record of Processing Activities (RoPA) maintained — Article 30
□ DPIAs conducted for high-risk processing — Article 35
□ Data processing agreements with all processors — Article 28

Data management
□ Data minimisation — only collecting what is needed
□ Retention periods defined and automated deletion implemented
□ Data subject rights procedures tested:
  □ Subject Access Request (SAR) — within 1 month
  □ Right to erasure — within 1 month
  □ Right to rectification — within 1 month
  □ Right to portability — within 1 month

Security (Article 32)
□ Encryption at rest for all personal data
□ Encryption in transit (TLS 1.2+)
□ Pseudonymisation where feasible
□ Access controls with MFA on systems holding PII
□ Annual penetration test conducted
□ Vulnerability management programme active

Breach response
□ 72-hour notification procedure to DPA documented and rehearsed
□ Breach register maintained
□ Staff trained on breach identification and escalation

International transfers
□ SCCs in place for all non-EU personal data transfers
□ No transfers to countries without adequacy decision or appropriate safeguards
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS v4.0</a>
  <a class="ref-card" href="/wiki/compliance/iso-27001/"><span class="ref-label">Compliance</span>ISO 27001:2022</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/incident-response/data-breach-playbook/"><span class="ref-label">IR</span>Data Breach Playbook</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
</div>

</div>
