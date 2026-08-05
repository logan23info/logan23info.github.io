---
title: "A07 — Identification and Authentication Failures"
date: 2026-08-05
tags: ["OWASP", "authentication", "MFA", "session-management", "credential-stuffing", "brute-force"]
categories: ["owasp"]
description: "OWASP A07 Authentication Failures — weak passwords, missing MFA, broken session management, credential stuffing. Code examples and detection methods."
showToc: true
layout: "single"
---

## Overview

A07 covers failures in confirming who users are. When authentication is broken, attackers can assume other users' identities. This was previously #2 in the OWASP Top 10 and includes credential stuffing, brute force, session fixation, and weak password policies.

| Attribute | Detail |
|---|---|
| OWASP rank | #7 (2021) — previously #2 |
| STRIDE mapping | **Spoofing** |
| CWEs mapped | 22 (incl. CWE-287, CWE-384, CWE-521) |
| Common attacks | Credential stuffing, brute force, session hijacking, password spraying |

---

## Vulnerable vs safe code

### Brute force protection

```python
import time
from collections import defaultdict

# VULNERABLE — no rate limiting, no lockout
@app.post("/login")
def login(username: str, password: str):
    user = db.get_user(username)
    if user and check_password(password, user.password_hash):
        return create_session(user)
    return {"error": "Invalid credentials"}   # attacker tries millions of passwords

# SAFE — progressive delay + lockout + rate limiting
from datetime import datetime, timedelta, timezone

failed_attempts = defaultdict(list)  # use Redis in production

@app.post("/login")
@limiter.limit("10/minute")          # IP-level rate limit
def login(username: str, password: str):
    # Check account lockout
    attempts = failed_attempts[username]
    recent = [t for t in attempts if t > datetime.now(timezone.utc) - timedelta(minutes=15)]
    if len(recent) >= 5:
        return JSONResponse(status_code=429, content={
            "error": "Account temporarily locked. Try again in 15 minutes."
        })

    user = db.get_user(username)
    if user and check_password(password, user.password_hash):
        failed_attempts[username] = []   # reset on success
        return create_session(user)

    # Record failure — always same response time to prevent timing attacks
    failed_attempts[username].append(datetime.now(timezone.utc))
    time.sleep(0.1)   # prevent timing-based user enumeration
    return {"error": "Invalid username or password"}   # never reveal which
```

### Secure session management

```python
import secrets
from datetime import datetime, timedelta, timezone

# VULNERABLE — predictable session IDs, no expiry, HTTP
session_store = {}

def create_session_wrong(user_id: int) -> str:
    session_id = str(user_id) + "_" + str(int(time.time()))  # predictable
    session_store[session_id] = user_id
    # Set as cookie with no security flags
    response.set_cookie("session", session_id)  # no Secure, HttpOnly, SameSite
    return session_id

# SAFE — cryptographic session ID, expiry, secure cookie flags
def create_session(user_id: int) -> str:
    session_id = secrets.token_urlsafe(32)    # 256 bits of entropy
    expiry = datetime.now(timezone.utc) + timedelta(hours=8)
    redis.setex(
        f"session:{session_id}",
        timedelta(hours=8),
        json.dumps({"user_id": user_id, "created": datetime.now().isoformat()})
    )
    response.set_cookie(
        "session",
        session_id,
        httponly=True,      # no JavaScript access
        secure=True,        # HTTPS only
        samesite="Strict",  # CSRF protection
        max_age=28800,      # 8 hours
        path="/",
    )
    return session_id

# Invalidate session on logout
def logout(session_id: str):
    redis.delete(f"session:{session_id}")
    response.delete_cookie("session")
```

### Multi-Factor Authentication

```python
import pyotp
import qrcode

def setup_totp(user_id: int) -> dict:
    """Set up TOTP for a user"""
    secret = pyotp.random_base32()       # 160-bit random secret
    db.store_totp_secret(user_id, encrypt(secret))  # encrypt at rest

    totp = pyotp.TOTP(secret)
    provisioning_uri = totp.provisioning_uri(
        name=f"user_{user_id}@example.com",
        issuer_name="MyApp"
    )
    return {
        "secret": secret,
        "qr_code_uri": provisioning_uri   # user scans with authenticator app
    }

def verify_totp(user_id: int, otp_code: str) -> bool:
    secret = decrypt(db.get_totp_secret(user_id))
    totp = pyotp.TOTP(secret)
    # valid_window=1 allows 30s clock skew — do not increase
    return totp.verify(otp_code, valid_window=1)

@app.post("/login")
@limiter.limit("10/minute")
def login(username: str, password: str, otp: str | None = None):
    user = authenticate_password(username, password)
    if not user:
        return {"error": "Invalid credentials"}

    if user.mfa_enabled:
        if not otp:
            return {"status": "mfa_required"}     # prompt for OTP
        if not verify_totp(user.id, otp):
            record_failed_mfa(user.id)
            return {"error": "Invalid OTP"}

    return create_session(user.id)
```

---

## Credential stuffing detection

Credential stuffing uses breached username/password pairs from other sites:

```python
# Detect credential stuffing patterns in logs
def analyze_login_pattern(ip: str, time_window: int = 300) -> bool:
    """Returns True if IP shows credential stuffing pattern"""
    recent_attempts = redis.lrange(f"login_attempts:{ip}", 0, -1)
    if len(recent_attempts) < 10:
        return False

    # Credential stuffing: many different usernames from same IP
    usernames = [json.loads(a)["username"] for a in recent_attempts]
    unique_usernames = len(set(usernames))
    if unique_usernames > 5:   # many different usernames = stuffing
        alert_security_team(f"Credential stuffing from {ip}: {unique_usernames} usernames")
        return True
    return False
```

---

## Detection & testing

```bash
# Test for credential stuffing vulnerability
# Use a list of known breached credentials
hydra -L userlist.txt -P passwordlist.txt \
  target.example.com http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid credentials"

# Check if account lockout fires after N attempts
for i in {1..10}; do
  curl -s -X POST https://target.example.com/login \
    -d "username=admin&password=wrong$i" | jq .
done
# Expect 429 or lockout message after attempt 5

# Check session cookie security flags
curl -I https://target.example.com/login
# Look for Set-Cookie with: HttpOnly; Secure; SameSite=Strict

# Test password policy
curl -X POST https://target.example.com/register \
  -d "username=test&password=password"   # should reject common password

# Check for username enumeration in reset flow
# Timing attack: measure response time for valid vs invalid email
```

---

## Prevention checklist

```
□ MFA available (preferably mandatory) for all users
□ No default credentials — force change on first login
□ Password policy: min 12 chars, check against HaveIBeenPwned API
□ Account lockout after 5 failed attempts (15 min lockout)
□ Rate limiting on all authentication endpoints
□ Session IDs are cryptographically random (min 128 bits)
□ Session invalidated on logout (server-side deletion)
□ Session cookies: HttpOnly, Secure, SameSite=Strict
□ Session timeout: 15-30 min idle, 8 hour absolute max
□ Rotate session ID after privilege escalation (login, role change)
□ Generic error messages — never reveal whether username exists
□ Monitor for credential stuffing patterns (many usernames, one IP)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/a01-broken-access-control/"><span class="ref-label">OWASP</span>A01 Broken Access Control</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust — Identity pillar</a>
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Spoofing</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — IAM domain</a>
</div>

</div>
