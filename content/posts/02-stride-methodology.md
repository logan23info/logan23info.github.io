---
title: "STRIDE: The Practitioner's Guide"
date: 2026-08-02
tags: ["STRIDE", "threat-modelling", "security", "frameworks"]
categories: ["frameworks"]
series: ["Security Engineering Maturity"]
description: "A complete walkthrough of STRIDE with worked examples on a real Auth Service."
showToc: true
weight: 2
---

## What is STRIDE?

STRIDE is a threat categorisation framework developed at Microsoft in 1999. It gives you a checklist of threat types to apply systematically to each component and data flow in your system.

| Letter | Threat | Violated property | Key question |
|--------|--------|-------------------|--------------|
| **S** | Spoofing | Authentication | Can an attacker pretend to be someone else? |
| **T** | Tampering | Integrity | Can an attacker modify data or code? |
| **R** | Repudiation | Non-repudiation | Can an attacker deny having done something? |
| **I** | Information Disclosure | Confidentiality | Can an attacker read data they should not? |
| **D** | Denial of Service | Availability | Can an attacker make the system unavailable? |
| **E** | Elevation of Privilege | Authorisation | Can an attacker gain permissions they should not have? |

---

## STRIDE by element type

| Element | S | T | R | I | D | E |
|---------|---|---|---|---|---|---|
| External entity | ✓ | | ✓ | | | |
| Process | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Data store | | ✓ | ✓ | ✓ | ✓ | |
| Data flow | | ✓ | | ✓ | ✓ | |

---

## Worked example: Auth Service

### Spoofing
- JWT replay via stolen token
- **Mitigation:** Short-lived JWTs (15 min), validate exp claim, rotate signing keys

### Tampering
- alg:none JWT forgery — remove signature, set algorithm to none
- **Mitigation:** Whitelist allowed algorithms explicitly in jwt.verify()

### Repudiation
- No audit log for password resets or login events
- **Mitigation:** Structured auth event logging to tamper-evident store

### Information Disclosure
- User enumeration via different error messages for valid vs invalid usernames
- **Mitigation:** Return generic error messages to clients always

### Denial of Service
- Credential stuffing exhausts database connection pool
- **Mitigation:** Rate limiting per IP and account, connection pool limits

### Elevation of Privilege
- JWT role claim trusted without server-side validation
- **Mitigation:** Always validate roles server-side from the database on every request

---

## Threat register output

| ID | Threat | Category | Severity | Mitigation |
|----|--------|----------|----------|------------|
| T-01 | JWT replay | Spoofing | High | Short TTL + rotation |
| T-02 | alg:none forgery | Tampering | Critical | Whitelist algorithms |
| T-03 | Missing audit logs | Repudiation | Medium | Auth event logging |
| T-04 | User enumeration | Info Disclosure | Medium | Generic errors |
| T-05 | Credential stuffing | DoS | High | Rate limiting |
| T-06 | JWT role manipulation | EoP | Critical | Server-side validation |

---

## Next: scoring your findings

Use [DREAD](/posts/03-dread-scoring/) to score and prioritise which threats to fix first.
