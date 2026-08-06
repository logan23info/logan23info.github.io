---
title: "PCI-DSS v4.0"
date: 2026-08-05
tags: ["PCI-DSS", "compliance", "payment-card", "cardholder-data", "QSA"]
categories: ["compliance"]
description: "PCI-DSS v4.0 compliance guide — 12 requirements mapped to security controls, evidence requirements, and gap assessment checklist."
showToc: true
layout: "single"
---

## What is PCI-DSS?

The Payment Card Industry Data Security Standard (PCI-DSS) is a contractual security standard required by Visa, Mastercard, Amex, and Discover for any organisation that stores, processes, or transmits payment card data. Version 4.0 became the only active version in March 2024.

**Penalties for non-compliance:** Card brand fines ($5,000–$100,000/month), increased transaction fees, loss of ability to process card payments.
**Validation:** QSA (Qualified Security Assessor) audit or Self-Assessment Questionnaire (SAQ) depending on transaction volume.

---

## The 12 PCI-DSS requirements

| Req | Domain | Core control |
|---|---|---|
| 1 | Network security | Install and maintain network security controls |
| 2 | Secure configuration | Apply secure configurations to all system components |
| 3 | Protect stored account data | Protect stored account data (no full PAN unencrypted) |
| 4 | Protect cardholder data in transit | Encrypt transmission over open/public networks |
| 5 | Protect against malicious software | Protect all systems against malware |
| 6 | Develop and maintain secure systems | Develop and maintain secure systems and software |
| 7 | Restrict access to cardholder data | Restrict access to system components and cardholder data |
| 8 | Identify users and authenticate access | Identify users and authenticate access to system components |
| 9 | Restrict physical access | Restrict physical access to cardholder data |
| 10 | Log and monitor all access | Log and monitor all access to system components and cardholder data |
| 11 | Test security of systems and networks | Test security of systems and networks regularly |
| 12 | Support information security | Support information security with organisational policies |

---

## Key requirements — engineering mapping

### Requirement 3 — Protect stored account data

**Never store:**
- Full magnetic stripe data
- CVV/CVC codes (not even hashed)
- PIN data

**If storing Primary Account Number (PAN):**

```python
# PAN must be rendered unreadable — truncation or tokenisation
def store_card_reference(pan: str) -> str:
    """Never store full PAN — tokenise or truncate"""
    # Option 1: Tokenise — store token, send real PAN to token vault
    token = payment_vault.tokenise(pan)
    return token   # store this, never the PAN

def display_card(pan: str) -> str:
    """Display only last 4 digits — required by PCI-DSS"""
    return f"**** **** **** {pan[-4:]}"

# Verify PAN is not in logs
import re

def sanitise_log(log_entry: str) -> str:
    """Remove PAN patterns from log output"""
    pan_pattern = r'\b(?:\d{4}[-\s]?){3}\d{4}\b'
    return re.sub(pan_pattern, '[PAN REDACTED]', log_entry)
```

### Requirement 4 — Encrypt cardholder data in transit

```bash
# Verify TLS on payment endpoints
testssl.sh --severity HIGH https://payments.example.com

# Must have:
# TLS 1.2 or higher (TLS 1.0 and 1.1 are prohibited)
# No weak cipher suites (RC4, DES, 3DES prohibited)
# Valid certificate from trusted CA

# Check security headers
curl -I https://payments.example.com | grep -i "strict-transport"
# Expected: Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### Requirement 6 — Secure development (6.3.2 — SBOM)

```yaml
# New in PCI-DSS v4.0: Software Bill of Materials required
# Generate SBOM for every release

- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    format: cyclonedx-json
    artifact-name: payment-app-sbom.json

- name: Scan for vulnerable components
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: sbom
    input: payment-app-sbom.json
    severity: CRITICAL,HIGH
    exit-code: 1
```

### Requirement 8 — Multi-factor authentication

```
PCI-DSS v4.0 requires MFA for:
□ All non-console administrative access into the cardholder data environment (CDE)
□ All access into the CDE from outside the CDE
□ New in v4.0: ALL personnel with access to the CDE (not just admins)

MFA requirements:
- At least two of: something you know, something you have, something you are
- Time-based OTP, hardware token, FIDO2/WebAuthn all acceptable
- SMS OTP is discouraged but not prohibited
```

### Requirement 10 — Logging and monitoring

```
Audit log requirements (Req 10.2):
□ User access to cardholder data
□ All actions by root or administrator accounts
□ Access to all audit trails
□ Invalid logical access attempts
□ Use of and changes to identification/authentication mechanisms
□ Initialisation, stopping, or pausing of audit logs
□ Creation/deletion of system-level objects

Log retention:
□ 12 months total
□ 3 months immediately available for analysis
```

### Requirement 11 — Security testing

```
11.3.1 — Internal vulnerability scans:
□ At least quarterly
□ All failures remediated and rescanned
□ Performed by qualified internal resource or QSA

11.3.2 — External vulnerability scans:
□ At least quarterly via Approved Scanning Vendor (ASV)
□ All high vulnerabilities remediated before passing

11.4 — Penetration testing:
□ At least annually
□ After any significant infrastructure or application changes
□ Covers entire CDE perimeter and critical systems
□ Performed by qualified internal resource or QSA

11.6.1 — NEW in v4.0: Payment page integrity monitoring:
□ Monitor HTTP headers and content on payment pages
□ Alert on unauthorised changes (web skimming / Magecart attacks)
```

---

## PCI-DSS scope reduction

The most effective PCI-DSS strategy is reducing scope — getting card data out of your systems:

```
Full PCI scope (hard):
Browser → Your application → Your database (stores PAN)
All of your infrastructure is in scope

Minimal PCI scope (recommended):
Browser → Payment iframe (hosted by PSP) → PSP (stores PAN)
Your application only receives a token
Your infrastructure is largely out of scope
```

---

## PCI-DSS gap assessment checklist

```
Network (Req 1-2)
□ Network diagram shows all cardholder data flows
□ CDE segmented from all other networks
□ Firewall rules reviewed every 6 months
□ All system defaults changed (passwords, SNMP, etc.)

Data protection (Req 3-4)
□ No full PAN stored unencrypted anywhere
□ CVV/CVC never stored (even post-authorisation)
□ PAN tokenised or truncated in all non-payment systems
□ TLS 1.2+ on all cardholder data transmission
□ No legacy SSL/TLS/early TLS in CDE

Access control (Req 7-8)
□ Least privilege — access only to job-required cardholder data
□ Unique user IDs — no shared accounts in CDE
□ MFA for all access to CDE
□ Password policy: 12+ chars, complexity, 90-day change

Logging (Req 10)
□ Audit logs for all cardholder data access
□ Logs protected from modification (read-only to application)
□ Logs retained 12 months (3 months immediately available)
□ Daily log review conducted

Testing (Req 11)
□ Quarterly internal and external vulnerability scans
□ Annual penetration test of CDE
□ Quarterly wireless scans (if wireless in CDE)
□ Payment page integrity monitoring active (new v4.0)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/gdpr/"><span class="ref-label">Compliance</span>GDPR</a>
  <a class="ref-card" href="/wiki/compliance/soc2/"><span class="ref-label">Compliance</span>SOC 2 Type II</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/owasp-top10/a02-cryptographic-failures/"><span class="ref-label">OWASP</span>A02 Cryptographic Failures</a>
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
</div>

</div>
