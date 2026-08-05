---
title: "Secure Architecture Patterns"
date: 2026-08-05
tags: ["architecture", "security", "microservices", "cloud", "DevSecOps"]
categories: ["architecture"]
description: "Secure architecture patterns for modern cloud-native systems — microservices, API security, secrets management, containers, and Kubernetes."
showToc: true
---

## Overview

Secure architecture is not a layer you add at the end — it is a set of patterns and decisions made at design time that determine whether your system is defensible. This section covers the five most critical domains for modern cloud-native and microservices-based architectures.

---

## Sections

| Page | Description |
|---|---|
| [Microservices Security](/wiki/secure-architecture/microservices/) | Service-to-service auth, zero trust between services, mTLS, service mesh |
| [API Security Design](/wiki/secure-architecture/api-security/) | Authentication, authorisation, rate limiting, input validation, API gateways |
| [Secrets Management](/wiki/secure-architecture/secrets-management/) | Vault, AWS Secrets Manager, rotation, injection patterns, avoiding hardcoded secrets |
| [Container Security](/wiki/secure-architecture/container-security/) | Image hardening, runtime security, scanning, least privilege, supply chain |
| [Kubernetes Security Hardening](/wiki/secure-architecture/kubernetes-security/) | RBAC, network policies, pod security, admission controllers, cluster hardening |

---

## How these relate to the maturity ladder

| Architecture pattern | Threat category mitigated | Maturity level |
|---|---|---|
| mTLS between services | Spoofing, Tampering (STRIDE) | Level 1 → Level 6 |
| API gateway with auth | Spoofing, EoP (STRIDE) | Level 1 |
| Secrets manager + rotation | Info Disclosure (STRIDE) | Level 1 |
| Container image scanning | Supply chain attack | +1 Supply Chain |
| K8s network policies | Lateral movement | Level 6 Zero Trust |
| Admission controllers | Tampering, EoP (STRIDE) | Level 2 ASM |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — threat categories</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/"><span class="ref-label">Post</span>Threat Modelling in DevSecOps</a>
</div>

</div>
