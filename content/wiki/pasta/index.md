---
title: "PASTA — Quick Reference"
date: 2026-08-02
tags: ["PASTA", "risk", "reference"]
description: "Quick reference for the PASTA seven-stage threat modelling methodology."
showToc: true
---

## The seven stages

| Stage | Name | Output |
|---|---|---|
| I | Define business objectives | Business impact statement, crown jewel list |
| II | Define technical scope | Architecture diagram, component inventory |
| III | Application decomposition | DFD, use case map, data classification |
| IV | Threat analysis | Threat library, attacker profiles |
| V | Vulnerability analysis | Vulnerability list mapped to threats |
| VI | Attack modelling | Attack trees for high-priority threats |
| VII | Risk and impact analysis | Risk register with business-impact scores |

## When to use PASTA vs STRIDE

| Situation | Use |
|---|---|
| New feature threat review, 60-min timebox | STRIDE |
| Quarterly security review of tier-1 service | PASTA |
| Compliance audit (PCI-DSS, SOC 2) | PASTA |
| PR-level security checklist | STRIDE |
| Risk presentation to leadership | PASTA |

See the [PASTA framework post](/posts/04-pasta-framework/) for a full walkthrough.

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Threat Categorisation</a>
  <a class="ref-card" href="/wiki/dread/"><span class="ref-label">Framework</span>DREAD — Risk Scoring</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Framework</span>Attack Trees</a>
  <a class="ref-card" href="/posts/04-pasta-framework/"><span class="ref-label">Post</span>PASTA Deep-Dive Post</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
</div>

</div>
