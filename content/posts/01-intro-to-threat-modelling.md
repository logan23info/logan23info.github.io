---
title: "Introduction to Threat Modelling"
date: 2026-08-02
tags: ["threat-modelling", "security", "fundamentals"]
categories: ["fundamentals"]
series: ["Security Engineering Maturity"]
description: "What threat modelling is, why every engineering team needs it, and the four core questions that drive every session."
showToc: true
weight: 1
---

## What is Threat Modelling?

Threat modelling is a structured process for **identifying security risks before attackers do**. Instead of waiting for a penetration test or a production incident, you reason about your system's weaknesses during design — when changes are cheap.

Every threat modelling session answers four questions:

1. **What are we building?** — understand the system
2. **What can go wrong?** — enumerate threats
3. **What are we going to do about it?** — decide on mitigations
4. **Did we do a good enough job?** — validate

---

## Why most teams skip it (and why they shouldn't)

Done well, a threat modelling session is a **60-minute whiteboard conversation** that produces a prioritised list of risks — a handful of actionable tickets, not a 40-page report.

| Finding stage | Average cost to fix |
|---|---|
| Design | $80 |
| Development | $240 |
| Testing | $960 |
| Production | $7,600+ |

The earlier you find a flaw, the cheaper it is to fix.

---

## What you need to start

- **A data flow diagram (DFD)** — how data moves through your system
- **A threat enumeration method** — STRIDE, PASTA, or attack trees
- **A risk scoring approach** — DREAD or CVSS
- **30–90 minutes** with the people who built the system

---

## Data Flow Diagram example

```
[Browser] --HTTPS--> [API Gateway] --gRPC--> [Auth Service]
                          |                        |
                          v                        v
                     [App DB]              [User DB]
```

Every arrow crossing a trust boundary is a candidate threat.

---

## Where threat modelling fits in the maturity ladder

Threat modelling is **Level 1** of the [Security Engineering Maturity Ladder](/wiki/maturity-ladder/). It is the foundation that every other security discipline builds on:

- **Level 2 ASM** validates your threat model with real exposure data
- **Level 3 Red Teaming** proves whether your threat model's mitigations work
- **Level 4 Purple Teaming** validates whether you can detect the attacks you modelled
- **Level 5 Threat Intelligence** makes your threat model attacker-realistic

Start here. Get good at this. Then climb the ladder.

---

## Frameworks covered in this wiki

| Framework | Best for | Complexity |
|---|---|---|
| [STRIDE](/wiki/stride/) | General-purpose | Low |
| [DREAD](/wiki/dread/) | Risk scoring | Low |
| [PASTA](/wiki/pasta/) | Business-risk-driven | High |
| [Attack Trees](/wiki/attack-trees/) | Attack path analysis | Medium |
