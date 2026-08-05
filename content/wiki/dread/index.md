---
title: "DREAD — Quick Reference"
date: 2026-08-02
tags: ["DREAD", "risk-scoring", "reference"]
description: "Quick reference card for the DREAD risk scoring model."
showToc: true
---

## Scoring dimensions (each 1–10)

| Dimension | Low (1–3) | Medium (4–6) | High (7–9) | Critical (10) |
|---|---|---|---|---|
| Damage | Non-sensitive leak | Partial exposure | Major breach | Full compromise |
| Reproducibility | Race condition | Works most times | Reliable | One-click |
| Exploitability | Expert + tools | Public tools | Script kiddie | No skills needed |
| Affected users | Single user | Subset | Most users | All users + admins |
| Discoverability | Source code only | Monitor traffic | Published CVE | Visible to anyone |

## Risk bands

| Score | Risk | SLA |
|---|---|---|
| 9.0–10 | Critical | Fix within 24 hours |
| 7.0–8.9 | High | Fix within 1 week |
| 4.0–6.9 | Medium | Fix within 1 sprint |
| 1.0–3.9 | Low | Backlog |

## Formula

```
DREAD = (Damage + Reproducibility + Exploitability + Affected Users + Discoverability) / 5
```

See the [DREAD scoring post](/posts/03-dread-scoring/) for a full worked example.

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Threat Categorisation</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Framework</span>PASTA — Full Methodology</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register</a>
  <a class="ref-card" href="/posts/03-dread-scoring/"><span class="ref-label">Post</span>DREAD Scoring Deep-Dive</a>
  <a class="ref-card" href="/posts/02-stride-methodology/"><span class="ref-label">Post</span>STRIDE Practitioner's Guide</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder</a>
</div>

</div>
