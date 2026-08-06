---
title: "Cryptography Fundamentals"
date: 2026-08-05
tags: ["cryptography", "symmetric", "asymmetric", "hashing", "AEAD"]
categories: ["cryptography"]
description: "Cryptography fundamentals for engineers — symmetric vs asymmetric encryption, hashing, digital signatures, and authenticated encryption with working code."
showToc: true
layout: "single"
---

## The three building blocks

```
1. SYMMETRIC encryption — one shared key for encrypt and decrypt
   Fast. Used for bulk data. Problem: how to share the key?

2. ASYMMETRIC encryption — public/private key pair
   Slow. Solves key distribution. Used to exchange symmetric keys.

3. HASHING — one-way function, no key
   Used for integrity, passwords, fingerprints. Cannot be reversed.
```

Real systems combine all three: asymmetric to exchange a symmetric key, symmetric for the bulk data, and hashing for integrity.

---

## Symmetric encryption

The same key encrypts and decrypts. Always use authenticated encryption (AEAD).

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

# AES-256-GCM — authenticated encryption (confidentiality + integrity)
def encrypt(plaintext: bytes, key: bytes) -> bytes:
    aesgcm = AESGCM(key)                  # key must be 32 bytes for AES-256
    nonce = os.urandom(12)                # 96-bit nonce — NEVER reuse with same key
    ciphertext = aesgcm.encrypt(nonce, plaintext, associated_data=None)
    return nonce + ciphertext             # prepend nonce for decryption

def decrypt(data: bytes, key: bytes) -> bytes:
    aesgcm = AESGCM(key)
    nonce, ciphertext = data[:12], data[12:]
    return aesgcm.decrypt(nonce, ciphertext, associated_data=None)
    # Raises InvalidTag if the ciphertext was tampered with

# Generate a proper key
key = AESGCM.generate_key(bit_length=256)
```

**Why GCM, not ECB or CBC?**
- ECB: identical plaintext blocks produce identical ciphertext — patterns leak
- CBC: no built-in authentication — ciphertext can be tampered (padding oracle attacks)
- GCM: authenticated — detects tampering, no padding oracle

---

## Asymmetric encryption

A public key encrypts; only the private key decrypts. Used mainly to exchange symmetric keys or for signatures.

```python
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization

# Generate key pair
private_key = rsa.generate_private_key(public_exponent=65537, key_size=3072)
public_key = private_key.public_key()

# Encrypt with public key (only private key can decrypt)
def encrypt_asymmetric(plaintext: bytes, public_key) -> bytes:
    return public_key.encrypt(
        plaintext,
        padding.OAEP(                          # OAEP padding — never PKCS1v15
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

def decrypt_asymmetric(ciphertext: bytes, private_key) -> bytes:
    return private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

# Note: asymmetric encryption is slow and size-limited.
# In practice: use it to encrypt a symmetric key, then use AES for the data.
# This is "hybrid encryption" — what TLS does.
```

---

## Digital signatures

Signatures prove authenticity and integrity — that a message came from the holder of the private key and was not modified.

```python
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

# Ed25519 — modern, fast, secure signature scheme
private_key = Ed25519PrivateKey.generate()
public_key = private_key.public_key()

# Sign with private key
def sign(message: bytes, private_key) -> bytes:
    return private_key.sign(message)

# Verify with public key
def verify(message: bytes, signature: bytes, public_key) -> bool:
    try:
        public_key.verify(signature, message)
        return True
    except Exception:
        return False   # signature invalid or message tampered
```

**Encryption vs signing:**
- Encryption: public key encrypts, private key decrypts → confidentiality
- Signing: private key signs, public key verifies → authenticity + integrity

---

## Hashing

One-way functions. Cannot be reversed. Used for integrity, fingerprints, and (with special algorithms) passwords.

```python
import hashlib
from argon2 import PasswordHasher

# General-purpose hashing (integrity, fingerprints)
def hash_data(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()      # SHA-256 for integrity

# Password hashing — NEVER use SHA-256 for passwords
ph = PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4)

def hash_password(password: str) -> str:
    return ph.hash(password)                      # Argon2id — slow by design

def verify_password(password: str, stored_hash: str) -> bool:
    try:
        return ph.verify(stored_hash, password)
    except Exception:
        return False
```

**Why not SHA-256 for passwords?** SHA-256 is fast — an attacker can try billions of guesses per second. Argon2id is deliberately slow and memory-hard, making brute force infeasible.

---

## Message Authentication Codes (MAC)

A MAC proves a message came from someone who knows the shared secret and was not modified.

```python
import hmac
import hashlib

def create_mac(message: bytes, key: bytes) -> str:
    return hmac.new(key, message, hashlib.sha256).hexdigest()

def verify_mac(message: bytes, key: bytes, provided_mac: str) -> bool:
    expected = hmac.new(key, message, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, provided_mac)   # constant-time comparison
    # Constant-time comparison prevents timing attacks
```

---

## Fundamentals checklist

```
□ Symmetric: AES-256-GCM or ChaCha20-Poly1305 (never ECB)
□ Nonces: fresh random nonce per encryption, never reused
□ Asymmetric: RSA-3072+ with OAEP, or elliptic curve (Ed25519, X25519)
□ Signatures: Ed25519 or ECDSA — verified before trusting data
□ Hashing (integrity): SHA-256, SHA-3, or BLAKE2
□ Hashing (passwords): Argon2id, bcrypt, or scrypt — never fast hashes
□ MAC: HMAC-SHA256 with constant-time comparison
□ Random: CSPRNG (secrets module, os.urandom) — never rand()
□ Libraries: vetted crypto libraries only — never home-made
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/pki-certificates/"><span class="ref-label">Crypto</span>PKI & Certificates</a>
  <a class="ref-card" href="/wiki/crypto/tls-best-practices/"><span class="ref-label">Crypto</span>TLS Best Practices</a>
  <a class="ref-card" href="/wiki/crypto/key-management/"><span class="ref-label">Crypto</span>Key Management</a>
  <a class="ref-card" href="/wiki/crypto/post-quantum/"><span class="ref-label">Crypto</span>Post-Quantum Cryptography</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/owasp-top10/a07-auth-failures/"><span class="ref-label">OWASP</span>A07 Authentication Failures</a>
</div>

</div>
