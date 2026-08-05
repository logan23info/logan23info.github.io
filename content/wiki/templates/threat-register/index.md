---
title: "Threat Register Template"
date: 2026-08-02
tags: ["template", "threat-register", "threat-modelling"]
categories: ["templates"]
description: "A ready-to-use threat register template for tracking threats, mitigations, and status across your system components."
showToc: true
---

## What is a Threat Register?

A threat register is a structured log of all threats identified during a threat modelling session, along with their severity scores, mitigations, owners, and current status. It is the primary output of a threat modelling exercise and the input to your security backlog.

---

## Markdown template

Copy this into your repo as `threat-register.md` or embed it in Confluence/Notion:

```markdown
# Threat Register — [System Name]

**Component:** [e.g. Auth Service]
**Last reviewed:** YYYY-MM-DD
**Reviewer:** [Name]
**Framework:** STRIDE + DREAD

| ID | Component | Threat description | STRIDE | DREAD | Severity | Mitigation | Owner | Status | Due |
|----|-----------|--------------------|--------|-------|----------|------------|-------|--------|-----|
| T-01 | | | | | | | | Open | |
| T-02 | | | | | | | | Open | |
```

---

## YAML template (threat-model-as-code)

Store this alongside your code in version control:

```yaml
version: "1.0"
component: "your-service-name"
last_reviewed: "2026-08-02"
reviewer: "your-name"
next_review: "2026-11-02"

threats:
  - id: T-01
    component: ""
    category: "spoofing"          # spoofing | tampering | repudiation | info_disclosure | dos | eop
    description: ""
    stride: "S"                   # S | T | R | I | D | E
    dread:
      damage:          0          # 1-10
      reproducibility: 0
      exploitability:  0
      affected_users:  0
      discoverability: 0
      score:           0.0        # average of above
    severity: "high"              # critical | high | medium | low
    status: "open"                # open | mitigated | accepted | transferred
    mitigation: ""
    owner: ""
    due: ""
    notes: ""
```

---

## Severity definitions

| Severity | DREAD score | Remediation SLA |
|---|---|---|
| <span class="badge badge-critical">Critical</span> | 9.0 – 10.0 | Fix within 24 hours |
| <span class="badge badge-high">High</span> | 7.0 – 8.9 | Fix within 1 week |
| <span class="badge badge-medium">Medium</span> | 4.0 – 6.9 | Fix within 1 sprint |
| <span class="badge badge-low">Low</span> | 1.0 – 3.9 | Backlog |

---

## Status definitions

| Status | Meaning |
|---|---|
| **Open** | Threat identified, mitigation not yet implemented |
| **Mitigated** | Mitigation implemented and verified |
| **Accepted** | Risk accepted by owner — documented rationale required |
| **Transferred** | Risk transferred (e.g. via insurance, third-party SLA) |

---

## Example completed register

| ID | Component | Threat | STRIDE | DREAD | Severity | Mitigation | Owner | Status |
|----|-----------|--------------------|--------|-------|----------|------------|-------|--------|
| T-01 | Auth Service | JWT replay via stolen token | S | 8.4 | <span class="badge badge-high">High</span> | 15-min TTL + rotation | team-auth | Mitigated |
| T-02 | Auth Service | alg:none JWT forgery | T | 9.0 | <span class="badge badge-critical">Critical</span> | Whitelist algorithms | team-auth | Mitigated |
| T-03 | Auth Service | Missing auth audit logs | R | 5.2 | <span class="badge badge-medium">Medium</span> | Structured event logging | team-auth | Open |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/">
    <span class="ref-label">Framework</span>STRIDE — Threat Categorisation
  </a>
  <a class="ref-card" href="/wiki/dread/">
    <span class="ref-label">Framework</span>DREAD — Risk Scoring
  </a>
  <a class="ref-card" href="/wiki/templates/pr-checklist/">
    <span class="ref-label">Template</span>PR Security Checklist
  </a>
  <a class="ref-card" href="/wiki/templates/dfd/">
    <span class="ref-label">Template</span>Data Flow Diagram Guide
  </a>
  <a class="ref-card" href="/posts/02-stride-methodology/">
    <span class="ref-label">Post</span>STRIDE Practitioner's Guide
  </a>
  <a class="ref-card" href="/posts/03-dread-scoring/">
    <span class="ref-label">Post</span>DREAD Scoring Deep-Dive
  </a>
</div>

</div>
