---
title: "Post-Quantum Cryptography"
date: 2026-08-05
tags: ["cryptography", "post-quantum", "PQC", "ML-KEM", "ML-DSA", "quantum"]
categories: ["cryptography"]
description: "The quantum threat to cryptography — which algorithms break, NIST's post-quantum standards (ML-KEM, ML-DSA), and how to prepare for migration."
showToc: true
layout: "single"
---

## The quantum threat

A sufficiently large quantum computer running Shor's algorithm could break the public-key cryptography that secures the internet today — RSA, ECDSA, and Diffie-Hellman. While such a computer does not yet exist publicly, the threat is real and imminent for two reasons:

1. **"Harvest now, decrypt later"** — adversaries are collecting encrypted data today to decrypt once quantum computers arrive. Data that must stay secret for 10+ years is already at risk.
2. **Migration takes years** — replacing cryptography across all systems is a multi-year effort. Starting now is necessary.

---

## What breaks and what survives

| Algorithm | Type | Quantum impact |
|---|---|---|
| RSA | Asymmetric | **Broken** by Shor's algorithm |
| ECDSA / ECDH | Asymmetric | **Broken** by Shor's algorithm |
| Diffie-Hellman | Key exchange | **Broken** by Shor's algorithm |
| AES-128 | Symmetric | Weakened (use AES-256) |
| AES-256 | Symmetric | **Safe** (Grover's algorithm only halves effective strength) |
| SHA-256 | Hashing | **Safe** (use SHA-384+ for margin) |

**Key insight:** Symmetric crypto (AES) and hashing (SHA) are largely fine — just use larger sizes. It is public-key crypto (RSA, ECC) that must be replaced entirely.

---

## NIST post-quantum standards

In August 2024, NIST finalised the first post-quantum cryptography standards:

| Standard | Name | Purpose | Replaces |
|---|---|---|---|
| FIPS 203 | ML-KEM (Kyber) | Key encapsulation | RSA/ECDH key exchange |
| FIPS 204 | ML-DSA (Dilithium) | Digital signatures | RSA/ECDSA signatures |
| FIPS 205 | SLH-DSA (SPHINCS+) | Digital signatures (hash-based) | Backup signature scheme |

```
ML-KEM (Module-Lattice Key Encapsulation Mechanism):
  - Based on the hardness of lattice problems
  - Used to establish shared secrets (like ECDH)
  - Parameter sets: ML-KEM-512, ML-KEM-768, ML-KEM-1024

ML-DSA (Module-Lattice Digital Signature Algorithm):
  - Lattice-based signatures
  - Parameter sets: ML-DSA-44, ML-DSA-65, ML-DSA-87

SLH-DSA (Stateless Hash-based Digital Signature Algorithm):
  - Based only on hash function security (very conservative)
  - Larger signatures, slower, but minimal assumptions
```

---

## Hybrid approach — the safe migration path

During the transition, use **hybrid** cryptography — combine a classical and a post-quantum algorithm so you are protected even if one is broken.

```
Hybrid key exchange:
  Shared secret = KDF( ECDH_secret || ML-KEM_secret )

If ECDH is broken by quantum → ML-KEM still protects you
If ML-KEM has an undiscovered flaw → ECDH still protects you

This is what TLS 1.3 hybrid modes (X25519MLKEM768) do today.
```

```python
# Conceptual hybrid key exchange
def hybrid_key_exchange():
    # Classical: X25519 ECDH
    classical_secret = x25519_exchange(my_ec_key, peer_ec_public)

    # Post-quantum: ML-KEM
    pq_secret = ml_kem_decapsulate(my_pq_key, peer_pq_ciphertext)

    # Combine both — secure if EITHER is secure
    combined = hkdf(classical_secret + pq_secret, info="hybrid-handshake")
    return combined
```

---

## Preparing for post-quantum migration

```
Phase 1 — Inventory (do this now)
□ Catalogue all uses of public-key crypto (TLS, signing, key exchange)
□ Identify data that must remain secret for 10+ years (highest priority)
□ Identify systems using RSA/ECC and their upgrade paths
□ Assess third-party and library dependencies

Phase 2 — Crypto-agility (do this now)
□ Abstract cryptographic operations behind an interface
□ Ensure algorithms can be swapped without rewriting applications
□ Avoid hardcoding algorithm choices throughout the codebase

Phase 3 — Hybrid deployment (starting now)
□ Enable hybrid TLS key exchange (X25519MLKEM768) where supported
□ Test post-quantum algorithms in non-production
□ Monitor library support (OpenSSL 3.5+, BoringSSL)

Phase 4 — Full migration (as standards mature)
□ Migrate signatures to ML-DSA
□ Migrate key exchange to ML-KEM
□ Increase symmetric keys to AES-256 and hashes to SHA-384+
□ Retire classical-only public-key crypto
```

---

## What to do today

```
Immediate actions:
□ Use AES-256 (not AES-128) for new symmetric encryption
□ Use SHA-384 or SHA-512 for long-term integrity needs
□ Build crypto-agility into new systems (swappable algorithms)
□ Inventory long-lived secrets (harvest-now-decrypt-later risk)
□ Enable hybrid TLS where your stack supports it
□ Track NIST PQC guidance and library support

Do NOT:
□ Panic — symmetric crypto and hashing are largely fine
□ Deploy experimental PQC as your ONLY protection (use hybrid)
□ Ignore it — migration takes years, start the inventory now
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/fundamentals/"><span class="ref-label">Crypto</span>Cryptography Fundamentals</a>
  <a class="ref-card" href="/wiki/crypto/key-management/"><span class="ref-label">Crypto</span>Key Management</a>
  <a class="ref-card" href="/wiki/crypto/tls-best-practices/"><span class="ref-label">Crypto</span>TLS Best Practices</a>
  <a class="ref-card" href="/wiki/crypto/pki-certificates/"><span class="ref-label">Crypto</span>PKI & Certificates</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
</div>

</div>
