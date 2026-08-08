---
title: "Threat Modelling"
date: 2026-08-05
description: "An introduction to threat modelling — what it is, the main methodologies (STRIDE, DREAD, PASTA, Attack Trees), and how to run a threat modelling session."
showToc: true
layout: "single"
---

## What is threat modelling?

Threat modelling is the structured process of identifying, communicating, and understanding threats to a system — and the mitigations that address them — **before** the system is built or changed. Done well, it turns "we hope this is secure" into a documented, defensible set of decisions.

It answers four questions, popularised by Adam Shostack:

```
1. What are we building?          → Data Flow Diagram (DFD)
2. What can go wrong?             → Apply a threat framework (STRIDE, etc.)
3. What are we going to do about it?  → Mitigations, accepted risks
4. Did we do a good job?          → Review, validate, iterate
```

Threat modelling is not a one-time audit — it is a practice repeated every time a system changes meaningfully: new feature, new integration, new trust boundary.

---

## The four main methodologies

Each methodology answers "what can go wrong?" differently. Most mature programmes use STRIDE for technical threat categorisation and DREAD or PASTA to prioritise findings by business risk.

| Methodology | Best for | Output |
|---|---|---|
| [STRIDE](/wiki/stride/) | Categorising technical threats per component | Threat list mapped to 6 categories |
| [DREAD](/wiki/dread/) | Scoring and prioritising found threats | Numeric risk score per threat |
| [PASTA](/wiki/pasta/) | Aligning threats to business risk and impact | Business-risk-weighted threat model |
| [Attack Trees](/wiki/attack-trees/) | Mapping out attacker paths to a specific goal | Visual tree of attack paths |

### STRIDE — the starting point for most teams
Categorises every threat into one of six types: **S**poofing, **T**ampering, **R**epudiation, **I**nformation Disclosure, **D**enial of Service, **E**levation of Privilege. Applied per component and per trust boundary in a data flow diagram.
**[Read the full STRIDE guide →](/wiki/stride/)**

### DREAD — turning threats into numbers
Scores each threat across five factors (Damage, Reproducibility, Exploitability, Affected users, Discoverability) to produce a comparable risk score — useful for prioritising a long list of findings.
**[Read the full DREAD guide →](/wiki/dread/)**

### PASTA — business-risk-driven modelling
A seven-stage process (Process for Attack Simulation and Threat Analysis) that ties technical threats directly to business impact and attacker motivation — favoured where security has to justify itself in business terms.
**[Read the full PASTA guide →](/wiki/pasta/)**

### Attack Trees — mapping attacker paths
A hierarchical diagram starting from an attacker's goal (root node) and branching into the different ways that goal could be achieved — useful for red team scoping and understanding compound attack paths.
**[Read the full Attack Trees guide →](/wiki/attack-trees/)**

---

## Where threat modelling fits in your workflow

Threat modelling is the entry point to the wider maturity ladder — it produces the findings that drive everything downstream: architecture decisions, detection rules, and red team scope.

```
Threat Modelling ──▶ Secure Architecture ──▶ Detection Engineering ──▶ Incident Response
  (this page)          (implement controls)    (monitor for the threats)  (respond when they occur)
```

**[See the full Security Engineering Maturity Ladder →](/wiki/maturity-ladder/)**

---

## Running a threat modelling session

```
1. Gather the right people (30-60 min)
   Engineer(s) who built/will build it, a security engineer, product owner

2. Draw the Data Flow Diagram (15 min)
   Processes, data stores, external entities, trust boundaries

3. Apply STRIDE per element (30-45 min)
   For every process and every trust boundary crossing, ask:
   can this be spoofed / tampered / repudiated / disclosed / DoS'd / escalated?

4. Score and prioritise (15 min)
   Apply DREAD or a simple High/Medium/Low to each finding

5. Assign mitigations and owners
   Every finding gets a mitigation, an owner, and a due date —
   or an explicit, signed-off risk acceptance

6. Document and revisit
   Store the model in the repo (see the Threat Register Template)
   Revisit when the system changes materially
```

**[Get the Threat Register Template →](/wiki/templates/threat-register/)**
**[See a worked example: Introduction to Threat Modelling →](/posts/01-intro-to-threat-modelling/)**

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE</a>
  <a class="ref-card" href="/wiki/dread/"><span class="ref-label">Framework</span>DREAD</a>
  <a class="ref-card" href="/wiki/pasta/"><span class="ref-label">Framework</span>PASTA</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Framework</span>Attack Trees</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register Template</a>
</div>

</div>
