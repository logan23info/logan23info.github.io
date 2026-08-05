---
title: "PASTA: Process for Attack Simulation and Threat Analysis"
date: 2026-08-02
tags: ["PASTA", "threat-modelling", "risk", "frameworks", "attacker-centric"]
categories: ["frameworks"]
series: ["Security Engineering Maturity"]
description: "A deep dive into PASTA — the seven-stage, business-risk-aligned framework that thinks like an attacker."
showToc: true
weight: 4
---

## What is PASTA?

PASTA is a seven-stage, risk-centric threat modelling framework. Unlike STRIDE (developer-friendly, component-focused), PASTA is attacker-centric — it simulates realistic attack scenarios and ties every finding back to business impact.

Use PASTA when findings need to reach business stakeholders, not just engineers.

---

## The seven stages

| Stage | Name | Output |
|---|---|---|
| I | Define business objectives | Business impact statement, crown jewels |
| II | Define technical scope | Architecture diagram, component inventory |
| III | Application decomposition | DFD, use case map, data classification |
| IV | Threat analysis | Threat library, attacker profiles |
| V | Vulnerability analysis | Vulnerabilities mapped to threats |
| VI | Attack modelling | Attack trees for high-priority threats |
| VII | Risk and impact analysis | Risk register with business-impact scores |

---

## Stage I — Business objectives example

```
Application: Payment processing API
Crown jewels: cardholder data, payment tokens
Regulatory scope: PCI-DSS Level 1
Business impact of breach: up to $500k fines + customer churn
Critical processes: checkout, refund, fraud detection
```

---

## Stage IV — Attacker profiling

| Threat actor | Motivation | Capability | Likelihood |
|---|---|---|---|
| External cybercriminal | Financial | High | High |
| Insider threat | Sabotage | Medium | Low |
| Nation-state | IP theft | Very high | Low |
| Script kiddie | Opportunistic | Low | High |

---

## Stage VI — Attack tree example

```
Goal: obtain cardholder PAN in plaintext
├── Attack the application layer
│   ├── SQL injection → dump card_tokens table
│   ├── IDOR → access other users stored cards
│   └── XSS → steal card details from DOM
├── Attack the infrastructure
│   └── Intercept traffic (no TLS enforced)
└── Attack the supply chain
    └── Compromise payment SDK dependency
```

---

## PASTA vs STRIDE

| Dimension | STRIDE | PASTA |
|---|---|---|
| Time | 1–2 hours | 1–2 days |
| Audience | Engineering | Engineering + business + leadership |
| Output | Threat list | Risk register with financial impact |
| Best for | Agile sprint review | Compliance, enterprise risk management |

Next: see how to embed all of this into your CI/CD pipeline in [Threat Modelling in DevSecOps](/posts/05-threat-modelling-in-devsecops/).
