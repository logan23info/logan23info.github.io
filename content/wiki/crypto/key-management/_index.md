---
title: "Key Management"
date: 2026-08-05
tags: ["cryptography", "key-management", "KMS", "HSM", "key-rotation", "envelope-encryption"]
categories: ["cryptography"]
description: "Cryptographic key management — key lifecycle, KMS, HSMs, envelope encryption, key rotation, and derivation."
showToc: true
layout: "single"
---

## The key management problem

Encryption is only as strong as your key management. A perfect AES-256 implementation is worthless if the key is hardcoded in source, stored next to the data, or never rotated. Key management is where most cryptographic systems actually fail.

---

## Key lifecycle

```
1. GENERATION — create keys with a strong CSPRNG or HSM
2. DISTRIBUTION — get keys to where they're needed without exposure
3. STORAGE — protect keys at rest (KMS, HSM, never plaintext)
4. USE — use keys without exposing them (envelope encryption)
5. ROTATION — replace keys periodically and after suspected compromise
6. REVOCATION — invalidate compromised keys
7. DESTRUCTION — securely destroy keys at end of life
```

---

## Envelope encryption

The industry-standard pattern: encrypt data with a data key, encrypt the data key with a master key held in a KMS.

```
Master Key (in KMS/HSM — never leaves)
    │ encrypts
    ▼
Data Encryption Key (DEK)
    │ encrypts
    ▼
Your actual data

Why? The master key never leaves the KMS. You can encrypt terabytes
with fast local DEKs, only calling the KMS to wrap/unwrap the small DEK.
```

```python
import boto3
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

kms = boto3.client("kms")
MASTER_KEY_ID = "arn:aws:kms:us-east-1:123456789:key/abc-123"

def encrypt_with_envelope(plaintext: bytes) -> dict:
    # 1. Ask KMS to generate a data key (returns plaintext + encrypted versions)
    response = kms.generate_data_key(KeyId=MASTER_KEY_ID, KeySpec="AES_256")
    plaintext_dek = response["Plaintext"]       # use this locally
    encrypted_dek = response["CiphertextBlob"]  # store this alongside data

    # 2. Encrypt data locally with the plaintext DEK (fast)
    aesgcm = AESGCM(plaintext_dek)
    nonce = os.urandom(12)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)

    # 3. Discard the plaintext DEK from memory
    del plaintext_dek

    # 4. Store encrypted data + encrypted DEK + nonce
    return {
        "ciphertext": nonce + ciphertext,
        "encrypted_dek": encrypted_dek,   # only KMS can decrypt this
    }

def decrypt_with_envelope(envelope: dict) -> bytes:
    # 1. Ask KMS to decrypt the DEK
    response = kms.decrypt(CiphertextBlob=envelope["encrypted_dek"])
    plaintext_dek = response["Plaintext"]

    # 2. Decrypt data locally
    data = envelope["ciphertext"]
    nonce, ciphertext = data[:12], data[12:]
    aesgcm = AESGCM(plaintext_dek)
    plaintext = aesgcm.decrypt(nonce, ciphertext, None)

    del plaintext_dek
    return plaintext
```

---

## KMS vs HSM

| | KMS (cloud) | HSM (hardware) |
|---|---|---|
| What | Managed key service (AWS KMS, GCP KMS, Azure Key Vault) | Physical tamper-resistant device |
| Key exposure | Keys never leave the service | Keys never leave the hardware |
| Compliance | FIPS 140-2 Level 2/3 | FIPS 140-2 Level 3/4 |
| Cost | Low (pay per operation) | High (dedicated hardware) |
| Use case | Most applications | Root CA keys, highest-value keys, regulatory requirement |

```python
# AWS KMS — key with automatic rotation
import boto3
kms = boto3.client("kms")

# Create a key with annual rotation
key = kms.create_key(Description="Payment data encryption key")
kms.enable_key_rotation(KeyId=key["KeyMetadata"]["KeyId"])   # rotates yearly
```

---

## Key derivation

Derive multiple keys from one master secret using a KDF — never reuse one key for multiple purposes.

```python
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes

def derive_key(master_secret: bytes, purpose: str, length: int = 32) -> bytes:
    """Derive a purpose-specific key from a master secret"""
    hkdf = HKDF(
        algorithm=hashes.SHA256(),
        length=length,
        salt=None,
        info=purpose.encode(),   # different purpose = different key
    )
    return hkdf.derive(master_secret)

# One master secret, many purpose-specific keys
encryption_key = derive_key(master, "data-encryption")
mac_key        = derive_key(master, "message-authentication")
token_key      = derive_key(master, "session-tokens")
# Compromise of one derived key does not reveal the others or the master
```

---

## Key rotation

```python
# Support multiple key versions for zero-downtime rotation
class KeyManager:
    def __init__(self):
        self.keys = {}          # version → key
        self.current_version = None

    def encrypt(self, plaintext: bytes) -> dict:
        # Always encrypt with the CURRENT key
        key = self.keys[self.current_version]
        ciphertext = aes_encrypt(plaintext, key)
        return {"version": self.current_version, "ciphertext": ciphertext}

    def decrypt(self, envelope: dict) -> bytes:
        # Decrypt with whatever version encrypted it
        key = self.keys[envelope["version"]]     # old keys still work
        return aes_decrypt(envelope["ciphertext"], key)

    def rotate(self, new_key: bytes, new_version: str):
        # Add new key, make it current — old keys retained for decryption
        self.keys[new_version] = new_key
        self.current_version = new_version
        # Background job re-encrypts old data with the new key over time
```

---

## Key management checklist

```
Generation
□ Keys generated with CSPRNG or HSM — never predictable
□ Sufficient key length (AES-256, RSA-3072+, ECC P-256+)

Storage
□ Keys stored in KMS or HSM — never in code, config, or env vars
□ Master keys never leave the KMS/HSM
□ Envelope encryption for bulk data

Use
□ Different keys for different purposes (via KDF)
□ Keys held in memory only as long as needed, then cleared
□ No key material in logs, error messages, or backups

Rotation
□ Automatic rotation enabled (annual minimum for master keys)
□ Multiple key versions supported (zero-downtime rotation)
□ Immediate rotation capability on suspected compromise
□ Data re-encrypted with new keys over time

Access & audit
□ Least-privilege access to keys (separate encrypt/decrypt permissions)
□ All key operations logged (KMS audit trail)
□ Key access alerting for anomalies
□ Documented key destruction process
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/fundamentals/"><span class="ref-label">Crypto</span>Cryptography Fundamentals</a>
  <a class="ref-card" href="/wiki/crypto/post-quantum/"><span class="ref-label">Crypto</span>Post-Quantum Cryptography</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS — KMS configuration</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS — key management</a>
</div>

</div>
