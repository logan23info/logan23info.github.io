---
title: "TLS Best Practices"
date: 2026-08-05
tags: ["cryptography", "TLS", "SSL", "HTTPS", "HSTS", "mTLS"]
categories: ["cryptography"]
description: "Configuring TLS correctly — protocol versions, cipher suites, HSTS, certificate pinning, mTLS, and testing tools."
showToc: true
layout: "single"
---

## TLS version support

```
TLS 1.3 — USE THIS. Faster handshake, forward secrecy by default, removed weak crypto
TLS 1.2 — Acceptable. Still widely required for compatibility
TLS 1.1 — DISABLE. Deprecated, no modern browser needs it
TLS 1.0 — DISABLE. Deprecated, PCI-DSS prohibits it
SSL 3.0 — DISABLE. Broken (POODLE)
SSL 2.0 — DISABLE. Completely broken
```

---

## Recommended nginx TLS configuration

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # Certificate
    ssl_certificate     /etc/ssl/certs/example.com.pem;
    ssl_certificate_key /etc/ssl/private/example.com.key;

    # Protocols — TLS 1.2 and 1.3 only
    ssl_protocols TLSv1.2 TLSv1.3;

    # Cipher suites — strong ciphers only (TLS 1.2)
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;   # let client choose (better for TLS 1.3)

    # Forward secrecy — ECDHE key exchange
    ssl_ecdh_curve X25519:secp384r1;

    # Session resumption
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/chain.pem;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;

    # HSTS — force HTTPS for 2 years, include subdomains, allow preload
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Other security headers
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options DENY always;
}

# Redirect all HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```

---

## HSTS (HTTP Strict Transport Security)

HSTS tells browsers to only ever connect via HTTPS, preventing downgrade attacks.

```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload

max-age=63072000    → remember for 2 years
includeSubDomains   → apply to all subdomains
preload             → eligible for browser preload lists
```

**Preloading:** Submit your domain to https://hstspreload.org to have HSTS hardcoded into browsers — protects even the very first connection.

---

## Mutual TLS (mTLS)

In mTLS, both client and server present certificates. Used for service-to-service authentication.

```nginx
# nginx server requiring client certificates
server {
    listen 443 ssl;

    ssl_certificate     /etc/ssl/server.pem;
    ssl_certificate_key /etc/ssl/server.key;

    # Require and verify client certificates
    ssl_client_certificate /etc/ssl/client-ca.pem;
    ssl_verify_client on;
    ssl_verify_depth 2;

    location / {
        # Pass client cert info to backend
        proxy_set_header X-Client-Cert-DN $ssl_client_s_dn;
        proxy_set_header X-Client-Verify $ssl_client_verify;
        proxy_pass http://backend;
    }
}
```

See [Microservices Security](/wiki/secure-architecture/microservices/) for service mesh mTLS.

---

## Testing TLS configuration

```bash
# testssl.sh — comprehensive TLS testing
testssl.sh https://example.com
testssl.sh --severity HIGH https://example.com

# sslyze — fast scanner
sslyze example.com:443

# Check with OpenSSL
openssl s_client -connect example.com:443 -tls1_3    # test TLS 1.3
openssl s_client -connect example.com:443 -tls1      # should FAIL (1.0 disabled)

# Online: SSL Labs (aim for A+ grade)
# https://www.ssllabs.com/ssltest/

# Check HSTS preload eligibility
# https://hstspreload.org
```

---

## TLS best practices checklist

```
Protocol
□ TLS 1.2 and 1.3 only — 1.0/1.1 and all SSL disabled
□ Strong cipher suites only (AEAD: GCM, ChaCha20-Poly1305)
□ Forward secrecy (ECDHE key exchange)
□ Weak ciphers disabled (RC4, DES, 3DES, export ciphers)

Certificates
□ Valid certificate from trusted CA (or internal CA for mTLS)
□ SANs configured (not relying on CN)
□ Automated renewal (no expiry outages)
□ OCSP stapling enabled

Headers
□ HSTS enabled (max-age >= 1 year, includeSubDomains)
□ Consider HSTS preloading
□ HTTP redirects to HTTPS

Testing
□ SSL Labs grade A or A+
□ testssl.sh run with no HIGH severity findings
□ Certificate expiry monitoring in place
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/crypto/pki-certificates/"><span class="ref-label">Crypto</span>PKI & Certificates</a>
  <a class="ref-card" href="/wiki/crypto/fundamentals/"><span class="ref-label">Crypto</span>Cryptography Fundamentals</a>
  <a class="ref-card" href="/wiki/crypto/key-management/"><span class="ref-label">Crypto</span>Key Management</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices — mTLS</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/compliance/pci-dss/"><span class="ref-label">Compliance</span>PCI-DSS — TLS requirements</a>
</div>

</div>
