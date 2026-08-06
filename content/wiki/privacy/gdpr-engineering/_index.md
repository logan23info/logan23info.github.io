---
title: "GDPR Engineering"
date: 2026-08-05
tags: ["privacy", "GDPR", "data-protection", "engineering", "pseudonymisation"]
categories: ["privacy"]
description: "Implementing GDPR requirements in code — data minimisation, pseudonymisation, consent management, retention, and lawful basis enforcement."
showToc: true
layout: "single"
---

## Overview

This page translates GDPR's legal requirements into concrete engineering patterns. For the legal framework itself, see the [GDPR compliance page](/wiki/compliance/gdpr/).

---

## Data minimisation in practice

```python
# Principle: collect only what you need for the stated purpose

# WRONG — collecting everything "just in case"
class UserProfile(BaseModel):
    email: str
    password: str
    full_name: str
    date_of_birth: str       # why? not needed for the service
    phone: str               # why? not needed at signup
    home_address: str        # why? not needed for a digital service
    gender: str              # why? not needed
    income_bracket: str      # why? definitely not needed

# RIGHT — collect the minimum, expand only with justification
class UserProfile(BaseModel):
    email: str               # needed for account + communication
    password_hash: str       # needed for authentication
    display_name: str        # needed for personalisation
    # Everything else collected later, only when a feature requires it,
    # with clear purpose communicated to the user
```

## Purpose limitation — tagging data with its purpose

```python
from enum import Enum
from dataclasses import dataclass

class ProcessingPurpose(Enum):
    ACCOUNT_MANAGEMENT = "account_management"
    MARKETING = "marketing"
    ANALYTICS = "analytics"
    LEGAL_OBLIGATION = "legal_obligation"

@dataclass
class PersonalDataField:
    value: str
    purposes: set[ProcessingPurpose]   # what this data may be used for
    lawful_basis: str
    collected_at: datetime
    retention_days: int

# Enforce purpose limitation at access time
def access_data(field: PersonalDataField, purpose: ProcessingPurpose):
    if purpose not in field.purposes:
        raise PurposeViolationError(
            f"Data collected for {field.purposes} cannot be used for {purpose}"
        )
    audit_log.record_access(field, purpose)
    return field.value
```

## Pseudonymisation

```python
import hmac, hashlib

# Reversible pseudonymisation (with key) — GDPR pseudonymisation
class Pseudonymiser:
    def __init__(self, key: bytes):
        self._key = key
        self._vault = {}   # token → real value (encrypted store)

    def pseudonymise(self, value: str) -> str:
        token = hmac.new(self._key, value.encode(), hashlib.sha256).hexdigest()[:16]
        self._vault[token] = encrypt(value, self._key)   # store mapping securely
        return token

    def reverse(self, token: str) -> str:
        # Only accessible to authorised roles — this is the re-identification key
        return decrypt(self._vault[token], self._key)

# Analytics uses pseudonyms — cannot re-identify without vault access
def track_purchase(user_email: str, amount: float):
    pseudo = pseudonymiser.pseudonymise(user_email)
    analytics.record({"user": pseudo, "amount": amount})
```

## Anonymisation (irreversible)

```python
# True anonymisation — cannot be reversed, removes GDPR scope
# Must protect against re-identification via combination of fields

def anonymise_dataset(records: list[dict]) -> list[dict]:
    anonymised = []
    for r in records:
        anonymised.append({
            # Remove direct identifiers entirely
            # Generalise quasi-identifiers to prevent re-identification
            "age_band": generalise_age(r["age"]),        # 34 → "30-39"
            "region": generalise_location(r["postcode"]), # "SW1A 1AA" → "London"
            "signup_year": r["signup_date"].year,          # drop day/month
            # Keep only the non-identifying data you actually need
            "purchase_count": r["purchase_count"],
        })
    # Apply k-anonymity check — every combination appears >= k times
    assert satisfies_k_anonymity(anonymised, k=5)
    return anonymised
```

## Consent management

```python
from datetime import datetime, timezone

@dataclass
class ConsentRecord:
    user_id: int
    purpose: ProcessingPurpose
    granted: bool
    timestamp: datetime
    version: str          # which privacy policy version
    withdrawal_method: str | None = None

class ConsentManager:
    def grant_consent(self, user_id: int, purpose: ProcessingPurpose, policy_version: str):
        record = ConsentRecord(
            user_id=user_id,
            purpose=purpose,
            granted=True,
            timestamp=datetime.now(timezone.utc),
            version=policy_version,
        )
        db.store_consent(record)   # immutable audit trail

    def has_consent(self, user_id: int, purpose: ProcessingPurpose) -> bool:
        latest = db.get_latest_consent(user_id, purpose)
        return latest is not None and latest.granted

    def withdraw_consent(self, user_id: int, purpose: ProcessingPurpose):
        # Withdrawal must be as easy as granting (GDPR Article 7)
        record = ConsentRecord(
            user_id=user_id, purpose=purpose, granted=False,
            timestamp=datetime.now(timezone.utc), version="withdrawal",
            withdrawal_method="user_settings",
        )
        db.store_consent(record)
        # Stop all processing for this purpose immediately
        processing_engine.halt(user_id, purpose)

# Check consent before every processing operation
def send_marketing_email(user_id: int):
    if not consent_manager.has_consent(user_id, ProcessingPurpose.MARKETING):
        return   # no consent — do not process
    email_service.send_marketing(user_id)
```

## Automated retention and deletion

```python
# GDPR storage limitation — delete when no longer needed

RETENTION_POLICIES = {
    "marketing_data": 730,        # 2 years after last interaction
    "transaction_records": 2555,  # 7 years (legal/tax obligation)
    "support_tickets": 1095,      # 3 years
    "inactive_accounts": 1095,    # 3 years of inactivity
    "server_logs": 90,            # 90 days
}

def enforce_retention():
    """Run daily — delete or anonymise data past retention period"""
    for data_type, retention_days in RETENTION_POLICIES.items():
        cutoff = datetime.now(timezone.utc) - timedelta(days=retention_days)
        expired = db.find_expired(data_type, cutoff)
        for record in expired:
            if record.has_legal_hold:
                continue   # do not delete data under legal hold
            if data_type == "transaction_records":
                anonymise(record)   # anonymise rather than delete (keep for accounting)
            else:
                secure_delete(record)
            audit_log.record_deletion(data_type, record.id, reason="retention_expired")
```

## GDPR engineering checklist

```
Data minimisation
□ Every collected field has a documented purpose
□ No "collect just in case" fields
□ Optional fields are genuinely optional

Purpose limitation
□ Data tagged with allowed processing purposes
□ Purpose checked at access time
□ Secondary use requires new lawful basis

Pseudonymisation / anonymisation
□ Analytics use pseudonymised identifiers
□ Shared/exported data is anonymised (k-anonymity verified)
□ Re-identification keys stored separately with strict access control

Consent
□ Consent recorded with timestamp and policy version
□ Withdrawal as easy as granting
□ Processing checks consent before every operation
□ Consent audit trail is immutable

Retention
□ Retention period defined for every data category
□ Automated deletion/anonymisation at end of retention
□ Legal hold mechanism prevents deletion when required
□ Deletion is logged
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/privacy/privacy-by-design/"><span class="ref-label">Privacy</span>Privacy by Design</a>
  <a class="ref-card" href="/wiki/privacy/data-subject-rights/"><span class="ref-label">Privacy</span>Data Subject Rights</a>
  <a class="ref-card" href="/wiki/privacy/dpia/"><span class="ref-label">Privacy</span>DPIA</a>
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
</div>

</div>
