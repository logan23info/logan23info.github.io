---
title: "A02 — Cryptographic Failures"
date: 2026-08-05
tags: ["OWASP", "cryptography", "encryption", "TLS", "data-protection"]
categories: ["owasp"]
description: "OWASP A02 Cryptographic Failures — weak encryption, missing TLS, hardcoded keys, and insecure data storage. STRIDE mapping, code examples, and detection."
showToc: true
layout: "single"
---

## Overview

Previously called "Sensitive Data Exposure", A02 focuses on failures in cryptography that expose sensitive data. The root cause is not a cryptographic attack — it is the failure to use cryptography at all, or using it incorrectly.

| Attribute | Detail |
|---|---|
| OWASP rank | #2 (2021) |
| STRIDE mapping | **Information Disclosure** |
| CWEs mapped | 29 (incl. CWE-261, CWE-296, CWE-310) |
| Common examples | Plain-text passwords, HTTP instead of HTTPS, weak algorithms (MD5, SHA1, DES) |

---

## Attack patterns

- **Cleartext transmission** — sensitive data sent over HTTP, unencrypted FTP, or SMTP
- **Weak algorithms** — MD5/SHA1 for passwords, DES/3DES for data encryption
- **Hardcoded keys** — encryption keys committed to source code
- **Insufficient key management** — keys never rotated, stored in plaintext config files
- **Missing encryption at rest** — databases, backups, and log files unencrypted
- **Predictable IVs** — ECB mode or reused IVs make ciphertext patterns visible

---

## STRIDE mapping

| Threat | Mechanism |
|---|---|
| **Information Disclosure** | Attacker reads plaintext passwords, credit card numbers, health data from database dump or network capture |
| **Tampering** | Weak MAC allows attacker to modify encrypted messages without detection |

---

## Vulnerable vs safe code

### Password hashing

```python
import hashlib
import bcrypt
from argon2 import PasswordHasher

# VULNERABLE — MD5 (broken), SHA256 (not a password hash)
def hash_password_wrong(password: str) -> str:
    return hashlib.md5(password.encode()).hexdigest()         # cracked in seconds
    return hashlib.sha256(password.encode()).hexdigest()      # no salt, rainbow tables

# VULNERABLE — fast hash, no salt
def hash_password_still_wrong(password: str) -> str:
    salt = "fixed_salt"                                       # hardcoded salt
    return hashlib.sha256(f"{salt}{password}".encode()).hexdigest()

# SAFE — bcrypt (work factor = slow by design)
def hash_password_bcrypt(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12)).decode()

def verify_password_bcrypt(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())

# BEST — Argon2id (winner of Password Hashing Competition)
ph = PasswordHasher(time_cost=2, memory_cost=65536, parallelism=2)

def hash_password(password: str) -> str:
    return ph.hash(password)

def verify_password(password: str, hashed: str) -> bool:
    try:
        return ph.verify(hashed, password)
    except Exception:
        return False
```

### Symmetric encryption

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

# VULNERABLE — ECB mode, patterns visible in ciphertext
from Crypto.Cipher import AES
def encrypt_wrong(data: bytes, key: bytes) -> bytes:
    cipher = AES.new(key, AES.MODE_ECB)    # ECB reveals patterns
    return cipher.encrypt(data)

# SAFE — AES-256-GCM (authenticated encryption)
def encrypt(plaintext: bytes, key: bytes) -> bytes:
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)          # 96-bit random nonce — never reuse
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce + ciphertext       # prepend nonce for decryption

def decrypt(data: bytes, key: bytes) -> bytes:
    aesgcm = AESGCM(key)
    nonce, ciphertext = data[:12], data[12:]
    return aesgcm.decrypt(nonce, ciphertext, None)   # raises on tamper

# Key generation — never hardcode
KEY = os.urandom(32)    # 256-bit key
# Store in secrets manager, not in code
```

### TLS configuration

```python
import ssl

# VULNERABLE — accepts all certs, old protocols
context = ssl.SSLContext(ssl.PROTOCOL_TLS)
context.verify_mode = ssl.CERT_NONE          # disables cert validation
context.check_hostname = False
context.set_ciphers("ALL")                   # includes broken ciphers

# SAFE — strict TLS configuration
context = ssl.create_default_context()        # verifies certs by default
context.minimum_version = ssl.TLSVersion.TLSv1_2
context.set_ciphers(
    "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20"
    ":!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK"
)
```

### Sensitive data in logs

```python
import logging

# VULNERABLE — logs sensitive data
def process_payment(card_number: str, cvv: str, amount: float):
    logging.info(f"Processing payment: card={card_number} cvv={cvv} amount={amount}")

# SAFE — mask sensitive data
def process_payment(card_number: str, cvv: str, amount: float):
    masked = f"****-****-****-{card_number[-4:]}"
    logging.info(f"Processing payment: card={masked} amount={amount}")
    # cvv never logged
```

---

## Detection & testing methods

```bash
# 1. Check TLS configuration
testssl.sh --severity HIGH https://target.example.com
sslyze --regular target.example.com:443

# 2. Check for HTTP (no TLS)
curl -v http://target.example.com   # should redirect to HTTPS

# 3. Check security headers
curl -I https://target.example.com | grep -i "strict-transport"
# Expected: Strict-Transport-Security: max-age=31536000; includeSubDomains

# 4. Scan for secrets in code
trufflehog git https://github.com/myorg/myrepo
gitleaks detect --source . --verbose

# 5. Check password hashing algorithm in database
# Look for $2b$ (bcrypt) or $argon2 prefix in stored hashes
# MD5 hashes are 32 hex chars, SHA1 are 40 — red flags

# 6. OWASP ZAP — passive scan for cleartext transmission
zap-cli passive-scan https://target.example.com
```

---

## Prevention checklist

```
□ Classify data: identify all sensitive data (PII, financial, health, credentials)
□ Do not store sensitive data unnecessarily — discard as soon as possible
□ Encrypt all sensitive data at rest (AES-256-GCM)
□ Enforce TLS 1.2+ for all data in transit — disable TLS 1.0 and 1.1
□ Use Argon2id, bcrypt, or scrypt for password hashing — never MD5/SHA1
□ Use HSTS to prevent protocol downgrade attacks
□ Never hardcode keys or secrets — use a secrets manager
□ Rotate encryption keys on a schedule and after any suspected exposure
□ Disable caching for responses containing sensitive data
□ Verify certificate validity — do not disable certificate checking
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — DAT domain</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Info Disclosure</a>
  <a class="ref-card" href="/wiki/owasp-top10/a01-broken-access-control/"><span class="ref-label">OWASP</span>A01 Broken Access Control</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust — Data pillar</a>
</div>

</div>
