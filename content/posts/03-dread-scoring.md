---
title: "DREAD: Risk Scoring for Threat Modelling"
date: 2026-08-02
tags: ["DREAD", "risk-scoring", "threat-modelling", "frameworks"]
categories: ["frameworks"]
series: ["Security Engineering Maturity"]
description: "How to use DREAD to score and prioritise threats so your team knows what to fix first."
showToc: true
weight: 3
---

## What is DREAD?

DREAD is a risk scoring model. Where STRIDE tells you what kind of threat something is, DREAD tells you how bad it is — so you can prioritise your mitigation backlog.

| Letter | Dimension | Question |
|--------|-----------|----------|
| **D** | Damage | How much damage if exploited? |
| **R** | Reproducibility | How easy is it to reproduce? |
| **E** | Exploitability | How much skill does exploitation require? |
| **A** | Affected users | How many users are impacted? |
| **D** | Discoverability | How easy is it to find the vulnerability? |

Each dimension scored 1–10. Final score = average of all five.

---

## Scoring guide

| Dimension | Low (1–3) | Medium (4–6) | High (7–9) | Critical (10) |
|---|---|---|---|---|
| Damage | Non-sensitive leak | Partial exposure | Major breach | Full compromise |
| Reproducibility | Race condition | Works most times | Reliable | One-click |
| Exploitability | Expert + custom tools | Public tools | Script kiddie | No skills needed |
| Affected users | Single user | Subset | Most users | All users + admins |
| Discoverability | Source code only | Monitor traffic | Published CVE | Visible to anyone |

---

## Risk bands

| Score | Risk | Fix SLA |
|---|---|---|
| 9–10 | Critical | Within 24 hours |
| 7–8.9 | High | Within 1 week |
| 4–6.9 | Medium | Within 1 sprint |
| 1–3.9 | Low | Backlog |

---

## Prioritised backlog from Auth Service threats

| Priority | ID | Threat | DREAD | Action |
|----------|----|--------|-------|--------|
| 1 | T-02 | alg:none JWT forgery | 9.0 | Fix immediately |
| 2 | T-06 | JWT role manipulation | 8.8 | Fix this week |
| 3 | T-01 | JWT replay | 8.4 | Fix this week |
| 4 | T-04 | User enumeration | 8.2 | Fix this sprint |
| 5 | T-05 | Credential stuffing DoS | 6.6 | Next sprint |
| 6 | T-03 | Missing audit logs | 5.2 | Next sprint |

Now your backlog is prioritised — no guessing what matters most.

---

## DREAD vs alternatives

| Model | Strengths | When to use |
|---|---|---|
| DREAD | Fast, intuitive | Quick triage, smaller teams |
| CVSS v3.1 | Standardised, auditable | Enterprise, compliance |
| OWASP Risk Rating | Includes business impact | Stakeholder reporting |

Next: see [PASTA](/posts/04-pasta-framework/) for business-risk-aligned threat modelling.
