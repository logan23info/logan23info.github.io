---
title: "Cryptography"
date: 2026-08-05
tags: ["cryptography", "encryption", "PKI", "TLS", "key-management", "post-quantum"]
categories: ["cryptography"]
description: "Applied cryptography reference — fundamentals, PKI and certificates, TLS best practices, key management, and post-quantum cryptography."
showToc: true
layout: "single"
---

## Applied cryptography for engineers

This section focuses on using cryptography correctly, not on the mathematics. The most common cryptographic failures are not broken algorithms — they are correct algorithms used incorrectly: hardcoded keys, weak modes, missing authentication, and poor key management.

**The golden rule:** Don't roll your own crypto. Use well-tested libraries (libsodium, the Python `cryptography` library, Go's `crypto` package) and use them correctly.

---

## Pages in this section

| Page | Description |
|---|---|
| [Cryptography Fundamentals](/wiki/crypto/fundamentals/) | Symmetric, asymmetric, hashing, and when to use each |
| [PKI & Certificates](/wiki/crypto/pki-certificates/) | Certificate authorities, chains, X.509, and certificate management |
| [TLS Best Practices](/wiki/crypto/tls-best-practices/) | Configuring TLS correctly — versions, ciphers, HSTS, mTLS |
| [Key Management](/wiki/crypto/key-management/) | Key lifecycle, KMS, HSMs, rotation, and derivation |
| [Post-Quantum Cryptography](/wiki/crypto/post-quantum/) | The quantum threat and NIST's post-quantum standards |

---

## Cryptographic decision guide

| Goal | Use | Do NOT use |
|---|---|---|
| Hash a password | Argon2id, bcrypt, scrypt | MD5, SHA-1, plain SHA-256 |
| Encrypt data (symmetric) | AES-256-GCM, ChaCha20-Poly1305 | AES-ECB, DES, 3DES, RC4 |
| Encrypt data (asymmetric) | RSA-OAEP (2048+), ECIES | RSA-PKCS1v1.5, RSA <2048 |
| Sign data | Ed25519, ECDSA (P-256), RSA-PSS | RSA-PKCS1v1.5 (legacy) |
| Key exchange | X25519, ECDH (P-256) | Static DH, small parameters |
| Hash data (integrity) | SHA-256, SHA-3, BLAKE2 | MD5, SHA-1 |
| Message authentication | HMAC-SHA256, Poly1305 | Home-made MAC |
| Random values | OS CSPRNG (secrets, /dev/urandom) | rand(), Math.random() |

---

## The most common crypto mistakes

```
1. Hardcoded keys in source code
   → Use a KMS or secrets manager

2. Using ECB mode (patterns visible in ciphertext)
   → Use AES-GCM (authenticated encryption)

3. Encryption without authentication (malleable ciphertext)
   → Use AEAD modes (GCM, ChaCha20-Poly1305)

4. Reusing nonces/IVs
   → Generate a fresh random nonce for every encryption

5. Fast hashes for passwords (rainbow table / brute force)
   → Use Argon2id, bcrypt, or scrypt

6. Weak random number generation
   → Use cryptographically secure RNG (secrets, not random)

7. Not verifying certificates (MITM)
   → Always verify TLS certificates

8. Rolling your own crypto
   → Use vetted libraries
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/fundamentals/"><span class="ref-label">Crypto</span>Cryptography Fundamentals</a>
  <a class="ref-card" href="/wiki/crypto/pki-certificates/"><span class="ref-label">Crypto</span>PKI & Certificates</a>
  <a class="ref-card" href="/wiki/crypto/tls-best-practices/"><span class="ref-label">Crypto</span>TLS Best Practices</a>
  <a class="ref-card" href="/wiki/crypto/key-management/"><span class="ref-label">Crypto</span>Key Management</a>
  <a class="ref-card" href="/wiki/crypto/post-quantum/"><span class="ref-label">Crypto</span>Post-Quantum Cryptography</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
</div>

</div>
