---
title: "Cloud Threat Model Template"
date: 2026-08-05
tags: ["threat-modelling", "cloud-security", "STRIDE", "AWS", "GCP", "Azure", "template"]
categories: ["cloud-security"]
description: "A STRIDE-based threat model template for cloud-native architectures — data flow diagrams, trust boundaries, pre-populated threats, and evidence requirements."
showToc: true
layout: "single"
---

## How to use this template

This template gives you a starting point for threat modelling any cloud-native system. Copy the YAML threat model, replace the placeholder values with your actual components, and work through the STRIDE checklist for each trust boundary crossing.

Run a threat modelling session with this template in **60–90 minutes** for a typical microservices application.

---

## Step 1 — Cloud-native DFD

A typical cloud-native architecture has these components and trust boundaries:

```
[End User / Browser]
        |
        | HTTPS (public internet)
        |
═══════════════════════════════════ TRUST BOUNDARY: Internet / Cloud Edge ═══
        |
[CDN / WAF]  (CloudFront / Cloud Armor / Azure Front Door)
        |
[Load Balancer / API Gateway]
        |
═══════════════════════════════════ TRUST BOUNDARY: Perimeter / VPC ═════════
        |
[Application Service]  (ECS / GKE / AKS / Lambda)
        |         |          |
        |         |          └─── [Cache]  (ElastiCache / Memorystore / Redis Cache)
        |         |
        |         └─────────────── [Message Queue]  (SQS / Pub/Sub / Service Bus)
        |                                    |
        |                           [Worker Service]
        |
═══════════════════════════════════ TRUST BOUNDARY: Data Tier ═══════════════
        |
[Database]  (RDS / Cloud SQL / Azure SQL)
        |
[Object Storage]  (S3 / GCS / Blob Storage)

════════════════════════════════════ TRUST BOUNDARY: Control Plane ══════════

[IAM / Identity]     [Secrets Manager]     [KMS]     [Audit Logs / SIEM]

Third parties: [Payment Gateway] [Email Provider] [OAuth Provider]
```

---

## Step 2 — STRIDE per trust boundary

### Boundary 1: Internet → CDN/WAF

| STRIDE | Threat | Pre-populated for cloud | Mitigation |
|---|---|---|---|
| S | Attacker spoofs client IP | IP spoofing, X-Forwarded-For manipulation | Validate at WAF, don't trust headers |
| T | Request body tampered in transit | MITM attack | TLS 1.2+ enforced, HSTS |
| R | Attacker denies sending malicious request | No client-side logging | WAF access logs, request fingerprinting |
| I | Sensitive data in URL parameters | URL logged by CDN, proxies, browser history | Move sensitive data to POST body or headers |
| D | Volumetric DDoS overwhelms CDN | Layer 3/4 DDoS | AWS Shield / Cloud Armor DDoS protection |
| E | WAF bypass via encoding tricks | WAF rule evasion | Test WAF with OWASP payloads |

### Boundary 2: CDN/WAF → Application (VPC)

| STRIDE | Threat | Pre-populated for cloud | Mitigation |
|---|---|---|---|
| S | Internal service claims to be another | No mTLS between services | Implement mTLS (Istio/Linkerd) |
| T | JWT payload manipulated | alg:none attack, weak secret | Whitelist RS256, validate aud/iss |
| R | Service action not logged | No structured audit trail | Structured logging, ship to SIEM |
| I | Service returns too much data | Over-fetching in API response | Return only required fields |
| D | One slow service cascades to outage | No circuit breaker | Circuit breaker, timeout, bulkhead pattern |
| E | App runs as root in container | Container escape → host | Non-root user, read-only filesystem |

### Boundary 3: Application → Data Tier

| STRIDE | Threat | Pre-populated for cloud | Mitigation |
|---|---|---|---|
| S | App uses shared DB credentials | Credential reuse, blast radius | Unique credentials per service, dynamic secrets |
| T | SQL injection from app to DB | App passes unsanitised input | Parameterised queries, ORM |
| R | DB changes not audited | No database audit log | Enable DB audit logging (RDS CloudWatch, Cloud SQL) |
| I | DB snapshot publicly accessible | Accidental public snapshot | Disable public snapshots, encrypt with CMEK |
| D | DB connection pool exhausted | No query timeout | Connection pool limits, query timeout |
| E | App account has DBA privileges | Blast radius if compromised | Least-privilege DB user per service |

### Boundary 4: Application → Cloud Control Plane (IAM/Secrets)

| STRIDE | Threat | Pre-populated for cloud | Mitigation |
|---|---|---|---|
| S | Attacker assumes IAM role | SSRF to metadata → role credentials | IMDSv2 (AWS), Workload Identity (GCP) |
| T | CloudTrail logs deleted | Attacker covers tracks | CloudTrail log validation, MFA delete on log bucket |
| R | Admin action not attributed | Shared admin credentials | Individual accounts, no shared IAM users |
| I | Secrets in environment variables | Visible in task definitions, CI logs | Use Secrets Manager, inject at runtime |
| D | Secret rotation breaks application | No graceful rotation handling | Test rotation, build retry logic |
| E | Overprivileged IAM role | One compromise = full account | Least-privilege IAM, SCPs, Permission Boundaries |

---

## Step 3 — Cloud threat model YAML

Copy this into your repo as `threat-model-cloud.yml`:

```yaml
version: "1.0"
system: "your-system-name"
cloud_provider: "aws"          # aws | gcp | azure | multi-cloud
last_reviewed: "2026-08-05"
reviewer: "your-name"
next_review: "2026-11-05"

components:
  - id: CDN
    name: "CloudFront / CDN"
    type: "cdn"
    internet_facing: true

  - id: API_GW
    name: "API Gateway"
    type: "api-gateway"
    internet_facing: true

  - id: APP
    name: "Application Service"
    type: "compute"
    runtime: "ecs-fargate"    # ecs-fargate | gke | aks | lambda
    internet_facing: false

  - id: DB
    name: "PostgreSQL RDS"
    type: "database"
    engine: "postgresql"
    internet_facing: false

  - id: STORE
    name: "S3 Data Bucket"
    type: "object-storage"
    classification: "confidential"
    internet_facing: false

  - id: QUEUE
    name: "SQS Payment Queue"
    type: "message-queue"
    internet_facing: false

  - id: IAM
    name: "AWS IAM"
    type: "identity"
    internet_facing: false

  - id: SECRETS
    name: "AWS Secrets Manager"
    type: "secrets"
    internet_facing: false

trust_boundaries:
  - id: TB-01
    name: "Internet to CDN/WAF"
    components: [CDN]

  - id: TB-02
    name: "Perimeter — VPC boundary"
    components: [API_GW, APP, QUEUE]

  - id: TB-03
    name: "Data tier"
    components: [DB, STORE]

  - id: TB-04
    name: "Control plane"
    components: [IAM, SECRETS]

threats:
  # ── Internet → Application threats ──────────────────────────────
  - id: CT-01
    boundary: TB-01
    component: CDN
    category: dos
    description: "Volumetric DDoS attack overwhelms CDN capacity"
    stride: "D"
    dread_score: 7.2
    status: mitigated
    mitigation: "AWS Shield Standard enabled — upgrade to Advanced for SLA"

  - id: CT-02
    boundary: TB-01
    component: CDN
    category: tampering
    description: "MITM attack intercepts traffic — no TLS enforcement"
    stride: "T"
    dread_score: 8.0
    status: mitigated
    mitigation: "CloudFront viewer policy: HTTPS only. HSTS header set."

  - id: CT-03
    boundary: TB-02
    component: API_GW
    category: spoofing
    description: "JWT alg:none attack — attacker forges token"
    stride: "S"
    dread_score: 9.0
    status: mitigated
    mitigation: "JWT library configured to whitelist RS256 only"

  - id: CT-04
    boundary: TB-02
    component: APP
    category: elevation_of_privilege
    description: "Container running as root — escape to host OS"
    stride: "E"
    dread_score: 7.8
    status: open
    mitigation: "Set runAsNonRoot: true in ECS task definition"
    owner: "platform-team"
    due: "2026-09-01"

  # ── Data tier threats ────────────────────────────────────────────
  - id: CT-05
    boundary: TB-03
    component: DB
    category: tampering
    description: "SQL injection via unsanitised application input"
    stride: "T"
    dread_score: 8.6
    status: mitigated
    mitigation: "SQLAlchemy ORM with parameterised queries throughout"

  - id: CT-06
    boundary: TB-03
    component: STORE
    category: information_disclosure
    description: "S3 bucket accidentally made public via ACL"
    stride: "I"
    dread_score: 9.2
    status: mitigated
    mitigation: "Account-level S3 Block Public Access enforced via SCP"

  # ── Control plane threats ────────────────────────────────────────
  - id: CT-07
    boundary: TB-04
    component: IAM
    category: elevation_of_privilege
    description: "SSRF attack reaches EC2 metadata — steals IAM credentials"
    stride: "E"
    dread_score: 9.4
    status: mitigated
    mitigation: "IMDSv2 enforced on all instances. SSRF input validation."

  - id: CT-08
    boundary: TB-04
    component: SECRETS
    category: information_disclosure
    description: "Secrets in environment variables visible in ECS task definitions"
    stride: "I"
    dread_score: 8.2
    status: open
    mitigation: "Migrate to Secrets Manager injection — remove env vars"
    owner: "app-team"
    due: "2026-08-15"

  - id: CT-09
    boundary: TB-04
    component: IAM
    category: repudiation
    description: "CloudTrail logs deleted to cover attacker tracks"
    stride: "R"
    dread_score: 7.6
    status: mitigated
    mitigation: "MFA delete on CloudTrail bucket. Log file validation enabled."

  - id: CT-10
    boundary: TB-04
    component: IAM
    category: elevation_of_privilege
    description: "Overprivileged IAM role — wildcard actions in policy"
    stride: "E"
    dread_score: 8.8
    status: open
    mitigation: "Replace * actions with explicit service:action permissions"
    owner: "platform-team"
    due: "2026-08-20"

residual_risks:
  - id: RR-01
    threat_id: CT-04
    description: "Until CT-04 is remediated, container escape risk remains"
    accepted_by: "CISO"
    accepted_date: "2026-08-05"
    review_date: "2026-09-01"
    compensating_control: "Falco runtime monitoring active — alerts on suspicious container behaviour"
```

---

## Step 4 — Cloud-specific STRIDE checklist

Use this in every threat modelling session for cloud workloads:

```
Identity & IAM
□ S: Can the workload's IAM role be assumed by an unintended principal?
□ S: Are service account keys / access keys exposed anywhere?
□ E: Does the IAM role have more permissions than the workload needs?
□ E: Can the IAM role be used to escalate privileges (iam:PassRole, iam:CreateRole)?
□ I: Are credentials stored in environment variables or task definitions?

Compute (EC2 / GKE / AKS / Lambda)
□ E: Does the compute run as root / privileged?
□ E: Is IMDSv2 enforced (AWS) / Workload Identity used (GCP)?
□ T: Is the container image pinned to a digest?
□ I: Are secrets injected from secrets manager at runtime?
□ D: Are resource limits set (CPU, memory, concurrency)?

Storage (S3 / GCS / Blob)
□ I: Is public access blocked at the account/org level?
□ I: Is encryption at rest enabled with CMEK?
□ T: Is versioning and MFA delete enabled?
□ I: Are access logs enabled and shipped to SIEM?
□ D: Is there a lifecycle policy preventing unbounded storage growth?

Network
□ T: Is all traffic encrypted in transit (TLS 1.2+)?
□ E: Is the workload in a private subnet with no direct internet access?
□ E: Are security groups / firewall rules default-deny with explicit allows?
□ S: Is mTLS enforced between services?
□ I: Are VPC Flow Logs / network logs enabled?

Logging & Detection
□ R: Is CloudTrail / Cloud Audit Logs / Activity Log enabled in ALL regions?
□ R: Are logs shipped to an immutable SIEM the application cannot delete?
□ R: Are admin actions logged with individual attribution?
□ D: Is GuardDuty / SCC / Defender for Cloud enabled?
□ D: Are alerts configured for critical events (root login, IAM changes)?
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-misconfig-top10/"><span class="ref-label">Cloud</span>Cloud Misconfiguration Top 10</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register Template</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
</div>

</div>
