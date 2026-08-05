---
title: "A04 — Insecure Design"
date: 2026-08-05
tags: ["OWASP", "secure-design", "threat-modelling", "architecture", "security-requirements"]
categories: ["owasp"]
description: "OWASP A04 Insecure Design — security flaws baked in at the design stage. Threat modelling, security requirements, and design patterns that prevent entire vulnerability classes."
showToc: true
layout: "single"
---

## Overview

A04 is the only OWASP Top 10 category that is **not a bug — it is a missing control**. Insecure design means security was never considered during the design phase. You cannot patch your way out of insecure design — it requires architectural changes.

| Attribute | Detail |
|---|---|
| OWASP rank | #4 (new in 2021) |
| STRIDE mapping | **All STRIDE categories** — depends on the design flaw |
| CWEs mapped | 40 (incl. CWE-209, CWE-256, CWE-501, CWE-522) |
| Key difference | Insecure design ≠ insecure implementation. A secure design can have implementation flaws. An insecure design cannot be fixed by perfect implementation. |

---

## Real-world design failures

### Business logic flaws
- Password reset links never expire → attacker uses old reset link months later
- No limit on coupon codes → attacker applies same coupon 10,000 times
- Shopping cart trusts client-side price → attacker changes price to $0.01
- OTP sent via SMS but no rate limiting → attacker brute-forces 6-digit code

### Missing security controls by design
- No rate limiting designed for authentication → credential stuffing at scale
- No account lockout in authentication flow → brute force attack succeeds
- Admin functions designed without MFA → single credential compromise = full admin access
- API designed to return full objects → over-exposure of sensitive fields

---

## STRIDE mapping

| Design flaw | STRIDE | Example |
|---|---|---|
| No rate limiting | DoS | Brute force login |
| Full object return | Info Disclosure | User API returns password hash |
| Client-side trust | Tampering | Client sets price/role |
| No account lockout | Spoofing | Brute force authentication |
| Predictable tokens | Spoofing | Sequential password reset tokens |
| No audit logging | Repudiation | No record of admin actions |

---

## Design patterns that prevent vulnerabilities

### Rate limiting by design

```python
from slowapi import Limiter
from slowapi.util import get_remote_address
import time

# Design rate limits into the API from day one
limiter = Limiter(key_func=get_remote_address)

@app.post("/auth/login")
@limiter.limit("5/minute")          # designed in — not bolted on later
def login(credentials: LoginRequest):
    ...

@app.post("/auth/otp/verify")
@limiter.limit("3/minute")          # OTP brute force prevention
def verify_otp(otp: OTPRequest):
    ...

@app.post("/auth/password-reset/request")
@limiter.limit("3/hour")            # prevent reset link flooding
def request_password_reset(email: EmailRequest):
    # Always return same response — do not confirm email existence
    send_reset_if_exists(email.address)
    return {"message": "If that email exists, a reset link has been sent"}
```

### Token design

```python
import secrets
import time
from datetime import datetime, timedelta, timezone

# WRONG design — sequential, predictable
def generate_reset_token_wrong(user_id: int) -> str:
    return f"reset_{user_id}_{int(time.time())}"   # guessable

# RIGHT design — cryptographically random, time-limited
def generate_reset_token(user_id: int) -> str:
    token = secrets.token_urlsafe(32)          # 256 bits of entropy
    expiry = datetime.now(timezone.utc) + timedelta(hours=1)
    db.store_reset_token(
        user_id=user_id,
        token_hash=hash_token(token),          # store hash, not token
        expiry=expiry,
        used=False
    )
    return token

def verify_reset_token(token: str) -> int | None:
    record = db.get_reset_token(hash_token(token))
    if not record:
        return None
    if record.expiry < datetime.now(timezone.utc):
        return None    # expired
    if record.used:
        return None    # already used
    db.mark_token_used(record.id)
    return record.user_id
```

### Separation of duties in design

```python
# WRONG — same person can create and approve payments
class PaymentService:
    def create_payment(self, amount, created_by):
        return db.create({"amount": amount, "created_by": created_by})

    def approve_payment(self, payment_id, approved_by):
        db.update(payment_id, {"approved": True})   # no check that approver != creator

# RIGHT — enforce four-eyes principle in the data model
class PaymentService:
    def approve_payment(self, payment_id: int, approved_by: int):
        payment = db.get_payment(payment_id)
        if payment.created_by == approved_by:
            raise BusinessRuleError("Creator cannot approve their own payment")
        if payment.amount > APPROVAL_THRESHOLD:
            # Require additional approver for large amounts
            if not self._has_senior_approval(payment_id):
                raise BusinessRuleError("Large payments require senior approval")
        db.approve(payment_id, approved_by)
```

### Never trust the client

```python
# WRONG — client sends price
@app.post("/orders")
def create_order(item_id: int, quantity: int, unit_price: float):
    total = quantity * unit_price   # client-supplied price — attacker sends 0.001
    charge_customer(total)

# RIGHT — server always looks up authoritative price
@app.post("/orders")
def create_order(item_id: int, quantity: int):
    item = db.get_item(item_id)               # authoritative price from database
    if not item or not item.available:
        raise HTTPException(404)
    total = quantity * item.current_price     # server-controlled price
    charge_customer(total)
```

---

## Security requirements by design

Use threat modelling to define security requirements before writing a line of code:

```yaml
# security-requirements.yml — created during design phase
feature: "Password Reset"
threat_model_date: "2026-08-05"

security_requirements:
  - id: SR-01
    requirement: "Reset tokens must be cryptographically random (min 128 bits)"
    threat: "Predictable token allows account takeover"
    stride: "Spoofing"
    test: "Verify token entropy using statistical analysis"

  - id: SR-02
    requirement: "Reset tokens expire after 1 hour"
    threat: "Stale token used for unauthorised account access"
    stride: "Spoofing"
    test: "Verify expired token returns 400 after 60 minutes"

  - id: SR-03
    requirement: "Reset tokens are single-use"
    threat: "Replay attack using intercepted token"
    stride: "Spoofing"
    test: "Verify second use of same token returns 400"

  - id: SR-04
    requirement: "Rate limit: max 3 reset requests per email per hour"
    threat: "Email flooding, user enumeration"
    stride: "DoS"
    test: "Verify 4th request within 1 hour returns 429"

  - id: SR-05
    requirement: "Response does not reveal whether email exists"
    threat: "User enumeration"
    stride: "Info Disclosure"
    test: "Verify response identical for existing and non-existing email"
```

---

## Detection & testing

```bash
# Business logic testing (manual)
# 1. Test coupon/discount codes — apply same code twice
# 2. Test quantity/price fields — submit negative values
# 3. Test workflow steps — skip step 2, jump to step 3
# 4. Test rate limits — send 100 requests rapidly
# 5. Test token reuse — use reset link twice

# Design review questions for threat model sessions
# - What happens if a user sends a request out of order?
# - What happens if a user tampers with hidden form fields?
# - What is the maximum number of X a user should be able to create?
# - What rate limits are needed to prevent abuse of this feature?
# - What does the response reveal about internal state?
```

---

## Prevention checklist

```
□ Threat model every significant feature before implementation
□ Define security requirements as acceptance criteria alongside functional requirements
□ Use secure design patterns: never trust client input, deny by default
□ Separate duties for sensitive operations (create vs approve)
□ Design rate limits and account lockout from the start
□ Use cryptographically secure random tokens — never sequential or predictable
□ Design for minimal data exposure — return only what the caller needs
□ Review design with security team before sprint starts, not after
□ Build negative test cases into acceptance testing
□ Document residual risks and decisions in threat-model.yml
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — threat categories</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Framework</span>PASTA — business risk design</a>
  <a class="ref-card" href="/posts/01-intro-to-threat-modelling/"><span class="ref-label">Post</span>Introduction to Threat Modelling</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register Template</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
</div>

</div>
