---
title: "Attack Trees — Quick Reference"
date: 2026-08-02
tags: ["attack-trees", "threat-modelling", "reference"]
description: "How to build and use attack trees to map all paths an attacker could take."
showToc: true
---

## What is an attack tree?

An attack tree maps all the ways an attacker could achieve a specific goal. Root = attacker goal. Branches = sub-goals. Leaves = individual attack steps.

## AND vs OR nodes

- **OR-node** — any single child path is enough for the attacker to succeed
- **AND-node** — all child steps must succeed (multi-step attack chain)

## Example: Gain admin access

```
GOAL: Gain admin access
├── [OR] Compromise admin credentials
│   ├── Phishing attack on admin user
│   ├── Credential stuffing with leaked lists
│   └── Brute force weak admin password
├── [OR] Exploit application vulnerability
│   ├── SQL injection → extract + crack password hashes
│   └── IDOR on admin endpoint (missing auth check)
└── [OR] Compromise infrastructure
    ├── [AND] Exploit vulnerable dependency
    │   ├── Identify outdated package via public scan
    │   └── Use public exploit for that CVE
    └── Steal developer session token
```

## Scoring paths

| Path | Attacker cost | Probability | Priority to mitigate |
|---|---|---|---|
| Phishing admin | Low | High | Critical |
| IDOR missing auth | Low | High | Critical |
| Brute force | Low | Medium | High |
| CVE exploit | Medium | Medium | High |
| Steal dev session | High | Low | Medium |

## When to use attack trees

- You have a specific high-value asset to protect
- Preparing penetration test or red team scope
- Communicating risk to non-technical stakeholders
- Stage VI of PASTA methodology

## Free tools

| Tool | Notes |
|---|---|
| draw.io / diagrams.net | Visual, free, export to XML |
| OWASP Threat Dragon | Integrated with DFD threat modelling |
| Plain Markdown/ASCII | Version-controllable in Git |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Framework</span>PASTA — Stage VI uses attack trees</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
  <a class="ref-card" href="/wiki/templates/dfd/"><span class="ref-label">Template</span>Data Flow Diagram Guide</a>
  <a class="ref-card" href="/wiki/tools/threat-dragon/"><span class="ref-label">Tool</span>OWASP Threat Dragon</a>
  <a class="ref-card" href="/posts/01-intro-to-threat-modelling/"><span class="ref-label">Post</span>Intro to Threat Modelling</a>
</div>

</div>
