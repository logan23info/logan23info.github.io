---
title: "Cloud Security"
date: 2026-08-05
tags: ["cloud-security", "AWS", "GCP", "Azure", "misconfiguration", "baseline"]
categories: ["cloud-security"]
description: "Cloud security reference — AWS, GCP, and Azure security baselines, cloud misconfiguration top 10, and a cloud threat model template."
showToc: true
layout: "single"
---

## Overview

Cloud security differs from traditional infrastructure security in three fundamental ways:

- **Everything is API-driven** — misconfigurations are code, and code can be scanned
- **Identity is the perimeter** — IAM replaces the network as the primary access control
- **Scale and speed** — resources spin up in seconds, creating exposure before controls catch up

This section covers the three major cloud providers and cross-cloud concepts.

---

## Pages in this section

| Page | Description |
|---|---|
| [AWS Security Baseline](/wiki/cloud-security/aws-baseline/) | IAM, S3, EC2, VPC, CloudTrail, GuardDuty — CIS AWS Benchmark |
| [GCP Security Baseline](/wiki/cloud-security/gcp-baseline/) | IAM, Cloud Storage, VPC, Cloud Audit Logs, Security Command Center |
| [Azure Security Baseline](/wiki/cloud-security/azure-baseline/) | Entra ID, RBAC, Storage, NSGs, Defender for Cloud, Sentinel |
| [Cloud Misconfiguration Top 10](/wiki/cloud-security/cloud-misconfig-top10/) | The 10 most dangerous cloud misconfigurations with detection and fix |
| [Cloud Threat Model Template](/wiki/cloud-security/cloud-threat-model/) | STRIDE-based threat model template for cloud-native architectures |

---

## The shared responsibility model

Understanding what the cloud provider secures vs what you are responsible for:

| Layer | AWS | GCP | Azure | Your responsibility |
|---|---|---|---|---|
| Physical datacentre | ✅ Provider | ✅ Provider | ✅ Provider | None |
| Hypervisor / host OS | ✅ Provider | ✅ Provider | ✅ Provider | None |
| Network infrastructure | ✅ Provider | ✅ Provider | ✅ Provider | None |
| Managed services (RDS, GCS, Azure SQL) | ✅ Provider patches | ✅ Provider patches | ✅ Provider patches | Configuration, access |
| EC2/Compute Engine/Azure VMs | Provider: hypervisor | Provider: hypervisor | Provider: hypervisor | OS, patching, apps |
| IAM / Identity | Provider: service | Provider: service | Provider: service | **Policies, keys, MFA** |
| Data | Provider: durability | Provider: durability | Provider: durability | **Classification, encryption, access** |
| Applications | — | — | — | **Everything** |

**The most exploited gap:** organisations assume the cloud provider secures everything. In reality, every IAM misconfiguration, public S3 bucket, and overprivileged role is entirely the customer's responsibility.

---

## Cross-cloud security principles

These apply regardless of provider:

```
1. Identity first — IAM is your perimeter, not the network
2. Least privilege — every identity gets only what it needs
3. Assume breach — segment everything, alert on anomalies
4. Encrypt everything — at rest and in transit, customer-managed keys for sensitive data
5. Log everything — ship to immutable SIEM, retain 12 months
6. Infrastructure as code — all resources defined in Terraform/OpenTofu, scanned before apply
7. Continuous compliance — automated checks, not annual audits
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/gcp-baseline/"><span class="ref-label">Cloud</span>GCP Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/azure-baseline/"><span class="ref-label">Cloud</span>Azure Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-misconfig-top10/"><span class="ref-label">Cloud</span>Cloud Misconfiguration Top 10</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
