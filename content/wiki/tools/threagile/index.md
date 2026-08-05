---
title: "Threagile — Threat Modelling as YAML"
date: 2026-08-02
tags: ["tools", "threagile", "threat-modelling", "automation"]
categories: ["tools"]
description: "Complete guide to Threagile — the open-source tool that generates a full threat model report from a YAML architecture description."
showToc: true
---

## What is Threagile?

Threagile is an open-source, agile threat modelling toolkit that lets you describe your architecture in YAML and automatically generates a complete threat model — including a DFD diagram, STRIDE analysis, risk-ranked findings, and a PDF report. It is built on the principle of **threat modelling as code**: your threat model lives in version control, evolves with your architecture, and can be validated in CI/CD.

**GitHub:** https://github.com/Threagile/threagile
**License:** MIT (free, open source)

---

## Why Threagile?

| Feature | Benefit |
|---|---|
| YAML-based model | Version-controlled, diff-able, PR-reviewable |
| Automated analysis | No manual STRIDE enumeration — engine does it |
| Risk ranking | Findings auto-ranked by severity |
| Multiple outputs | PDF report, DFD PNG, JSON findings, Excel |
| CI/CD integration | Runs in Docker, fits in any pipeline |
| 150+ built-in threats | Covers OWASP Top 10, CWEs, STRIDE categories |

---

## Installation

### Option 1 — Docker (recommended)

```bash
# Pull image
docker pull threagile/threagile

# Run against a model file
docker run --rm -it \
  -v "$(pwd)":/app/work \
  threagile/threagile \
  -model /app/work/threagile-model.yaml \
  -output /app/work/output \
  -verbose
```

Output folder will contain:
- `risks.json` — all identified risks as JSON
- `report.pdf` — full threat model report
- `data-flow-diagram.png` — DFD diagram
- `risks.xlsx` — risks in spreadsheet format

### Option 2 — Binary

```bash
# Download from GitHub releases
curl -L https://github.com/Threagile/threagile/releases/latest/download/threagile-linux-amd64 \
  -o threagile && chmod +x threagile

# Run
./threagile -model threagile-model.yaml -output ./output
```

---

## Writing a Threagile model

Threagile models are YAML files describing your architecture. Here is a minimal example for an API + database:

```yaml
threagile_version: "1.0.0"

title: "Payment API Threat Model"
date: "2026-08-02"
author:
  name: "Logan"

management_summary_comment: |
  This threat model covers the payment processing API and its
  dependencies including the PostgreSQL database and Redis cache.

business_criticality: critical     # archive | operational | important | critical | mission-critical

# ── Technical Assets (your components) ──────────────────────────
technical_assets:

  user-browser:
    id: user-browser
    title: User Browser
    type: external-entity
    usage: business
    out_of_scope: true
    technologies:
      - browser

  api-gateway:
    id: api-gateway
    title: API Gateway
    type: process
    usage: business
    technologies:
      - nginx
    machine: virtual
    internet: true
    multi_tenant: false
    redundant: true
    custom_developed_parts: true
    data_assets_processed:
      - customer-pii
      - payment-data
    data_assets_stored: []
    communication_links:
      to-auth-service:
        target: auth-service
        title: "gRPC to Auth"
        protocol: grpc
        authentication: token
        authorization: technical-user
        vpn: false
        ip_filtered: false
        readonly: false
        usage: business
        data_assets_sent:
          - customer-pii
        data_assets_received:
          - auth-token

  auth-service:
    id: auth-service
    title: Auth Service
    type: process
    usage: business
    technologies:
      - service-mesh
    machine: container
    custom_developed_parts: true
    data_assets_processed:
      - customer-pii
      - auth-token
    data_assets_stored: []
    communication_links:
      to-user-db:
        target: user-database
        title: "SQL to User DB"
        protocol: jdbc
        authentication: credentials
        authorization: technical-user
        data_assets_sent:
          - customer-pii
        data_assets_received:
          - customer-pii

  user-database:
    id: user-database
    title: "PostgreSQL: Users"
    type: datastore
    usage: business
    technologies:
      - database
    machine: virtual
    encryption: data-with-symmetric-shared-key
    custom_developed_parts: false
    data_assets_processed:
      - customer-pii
    data_assets_stored:
      - customer-pii

# ── Data Assets ──────────────────────────────────────────────────
data_assets:

  customer-pii:
    id: customer-pii
    title: Customer PII
    usage: business
    quantity: many
    confidentiality: strictly-confidential
    integrity: critical
    availability: critical
    justification_cia_rating: "Contains name, email, address — regulated under GDPR"

  payment-data:
    id: payment-data
    title: Payment Card Data
    usage: business
    quantity: many
    confidentiality: strictly-confidential
    integrity: critical
    availability: critical
    justification_cia_rating: "Cardholder data — PCI-DSS scope"

  auth-token:
    id: auth-token
    title: Auth Token (JWT)
    usage: business
    quantity: many
    confidentiality: confidential
    integrity: critical
    availability: operational

# ── Trust Boundaries ─────────────────────────────────────────────
trust_boundaries:

  internet-boundary:
    id: internet-boundary
    title: Internet Boundary
    type: network-on-prem
    technical_assets_inside:
      - api-gateway

  internal-network:
    id: internal-network
    title: Internal Network
    type: network-on-prem
    technical_assets_inside:
      - auth-service
      - user-database

# ── Shared Runtimes ──────────────────────────────────────────────
shared_runtimes:

  kubernetes-cluster:
    id: kubernetes-cluster
    title: Kubernetes Cluster
    technical_assets_running:
      - api-gateway
      - auth-service
```

---

## Reading the output

### risks.json

```json
[
  {
    "category": "sql-nosql-injection",
    "risk_status": "unchecked",
    "severity": "critical",
    "exploitation_likelihood": "likely",
    "exploitation_impact": "critical",
    "title": "SQL/NoSQL-Injection risk at 'Auth Service' against database 'PostgreSQL: Users'",
    "synthetic_id": "sql-nosql-injection@auth-service",
    "most_relevant_technical_asset": "auth-service",
    "most_relevant_communication_link": "to-user-db"
  }
]
```

### CI/CD integration

```yaml
# .github/workflows/threat-model.yml
name: Threagile Threat Model

on:
  push:
    paths:
      - 'threat-models/threagile-model.yaml'
  pull_request:
    paths:
      - 'threat-models/threagile-model.yaml'

jobs:
  analyse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Threagile
        run: |
          docker run --rm \
            -v "${{ github.workspace }}/threat-models":/app/work \
            threagile/threagile \
            -model /app/work/threagile-model.yaml \
            -output /app/work/output

      - name: Check for critical risks
        run: |
          CRITICAL=$(cat threat-models/output/risks.json | \
            python3 -c "
import json,sys
risks = json.load(sys.stdin)
crit = [r['title'] for r in risks if r['severity']=='critical' and r['risk_status']=='unchecked']
if crit:
    print('CRITICAL RISKS FOUND:')
    [print(f'  - {r}') for r in crit]
    sys.exit(1)
print('No unchecked critical risks.')
")

      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: threat-model-report
          path: threat-models/output/
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/tools/threat-dragon/">
    <span class="ref-label">Tool</span>OWASP Threat Dragon
  </a>
  <a class="ref-card" href="/wiki/tools/ms-tmt/">
    <span class="ref-label">Tool</span>Microsoft Threat Modelling Tool
  </a>
  <a class="ref-card" href="/wiki/templates/dfd/">
    <span class="ref-label">Template</span>Data Flow Diagram Guide
  </a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/">
    <span class="ref-label">Post</span>Threat Modelling in DevSecOps
  </a>
  <a class="ref-card" href="/wiki/stride/">
    <span class="ref-label">Framework</span>STRIDE Reference
  </a>
  <a class="ref-card" href="/wiki/supply-chain/">
    <span class="ref-label">Wiki</span>Supply Chain Security
  </a>
</div>

</div>
