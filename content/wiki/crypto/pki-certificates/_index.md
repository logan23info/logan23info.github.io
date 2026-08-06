---
title: "PKI & Certificates"
date: 2026-08-05
tags: ["cryptography", "PKI", "certificates", "X.509", "certificate-authority", "TLS"]
categories: ["cryptography"]
description: "Public Key Infrastructure explained — certificate authorities, chains of trust, X.509 certificates, and certificate lifecycle management."
showToc: true
layout: "single"
---

## What is PKI?

Public Key Infrastructure (PKI) is the system of certificate authorities, certificates, and policies that lets you trust a public key belongs to who it claims to. When you visit an HTTPS site, PKI is what tells your browser the server's public key is legitimate.

---

## The chain of trust

```
[Root CA]                    ← trusted by your OS/browser (root store)
   │ signs
   ▼
[Intermediate CA]            ← signed by root, signs end certificates
   │ signs
   ▼
[End-entity certificate]     ← your server's certificate (example.com)

Your browser trusts the root CA. The root vouches for the intermediate.
The intermediate vouches for example.com. Therefore your browser trusts
example.com — this is the chain of trust.
```

**Why intermediates?** The root CA's private key is kept offline in a vault. Intermediates do the day-to-day signing, so if an intermediate is compromised it can be revoked without destroying the entire trust hierarchy.

---

## X.509 certificate structure

```bash
# Inspect a certificate
openssl x509 -in certificate.pem -text -noout

# Key fields in an X.509 certificate:
# - Subject: who the certificate is for (CN=example.com)
# - Issuer: which CA signed it
# - Validity: not-before and not-after dates
# - Public Key: the subject's public key
# - Subject Alternative Names (SAN): all domains this cert covers
# - Signature: the CA's signature over all the above
# - Extensions: key usage, extended key usage, etc.
```

```bash
# Check what domains a certificate covers
openssl x509 -in cert.pem -noout -ext subjectAltName

# Check certificate expiry
openssl x509 -in cert.pem -noout -dates

# Verify a certificate chain
openssl verify -CAfile chain.pem certificate.pem

# Check a live server's certificate
openssl s_client -connect example.com:443 -servername example.com < /dev/null | \
  openssl x509 -noout -text
```

---

## Issuing certificates

### Let's Encrypt (free, automated, 90-day certs)

```bash
# Using certbot
certbot certonly --standalone -d example.com -d www.example.com

# Using cert-manager in Kubernetes (auto-renewal)
```

```yaml
# cert-manager ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
---
# Certificate resource — cert-manager auto-issues and renews
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com-tls
spec:
  secretName: example-com-tls
  duration: 2160h      # 90 days
  renewBefore: 360h    # renew 15 days before expiry
  dnsNames:
    - example.com
    - www.example.com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
```

### Private CA for internal services

```bash
# Create a private root CA (for internal mTLS)
openssl genrsa -out root-ca.key 4096
openssl req -x509 -new -nodes -key root-ca.key -sha256 -days 3650 \
  -out root-ca.crt -subj "/CN=Internal Root CA/O=MyCompany"

# Create an intermediate CA
openssl genrsa -out intermediate.key 4096
openssl req -new -key intermediate.key \
  -out intermediate.csr -subj "/CN=Internal Intermediate CA/O=MyCompany"
openssl x509 -req -in intermediate.csr -CA root-ca.crt -CAkey root-ca.key \
  -CAcreateserial -out intermediate.crt -days 1825 -sha256

# Issue a service certificate
openssl genrsa -out service.key 2048
openssl req -new -key service.key \
  -out service.csr -subj "/CN=payment-service.internal"
openssl x509 -req -in service.csr -CA intermediate.crt -CAkey intermediate.key \
  -CAcreateserial -out service.crt -days 90 -sha256
```

---

## Certificate revocation

When a certificate must be invalidated before expiry (key compromise, etc.):

```
CRL (Certificate Revocation List):
  CA publishes a list of revoked certificate serial numbers
  Client downloads and checks the list
  Problem: lists get large, caching means delays

OCSP (Online Certificate Status Protocol):
  Client asks the CA "is this certificate still valid?" in real time
  Problem: privacy (CA sees what you visit), latency, availability

OCSP Stapling (best):
  Server periodically gets a signed OCSP response from the CA
  Server "staples" it to the TLS handshake
  Client gets revocation status without contacting the CA
```

```nginx
# Enable OCSP stapling in nginx
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /path/to/chain.pem;
resolver 1.1.1.1 8.8.8.8 valid=300s;
```

---

## Certificate management best practices

```
Inventory & monitoring
□ Maintain an inventory of ALL certificates and their expiry dates
□ Automated alerting 30/14/7 days before expiry
□ Monitor Certificate Transparency logs for unexpected certs for your domains

Automation
□ Automate issuance and renewal (cert-manager, certbot, ACM)
□ Never rely on manual renewal — expired certs cause outages
□ Short-lived certificates (90 days or less) with auto-renewal

Key protection
□ Private keys never leave the server or HSM where generated
□ Private keys never committed to source control
□ Root CA private key stored offline in an HSM

Configuration
□ Use SANs — modern browsers ignore CN
□ 2048-bit RSA minimum, or ECDSA P-256
□ OCSP stapling enabled
□ Certificate Transparency compliance

Revocation
□ Documented process to revoke and reissue on compromise
□ OCSP stapling configured for fast revocation checking
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/tls-best-practices/"><span class="ref-label">Crypto</span>TLS Best Practices</a>
  <a class="ref-card" href="/wiki/crypto/fundamentals/"><span class="ref-label">Crypto</span>Cryptography Fundamentals</a>
  <a class="ref-card" href="/wiki/crypto/key-management/"><span class="ref-label">Crypto</span>Key Management</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices — mTLS</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
