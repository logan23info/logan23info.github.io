---
title: "AI Threat Modelling"
date: 2026-08-05
tags: ["AI-security", "threat-modelling", "STRIDE", "MAESTRO", "LLM", "machine-learning"]
categories: ["ai-security"]
description: "Threat modelling for AI and LLM systems — STRIDE applied to AI, the MAESTRO framework, AI-specific data flow diagrams, and a reusable threat model template."
showToc: true
layout: "single"
---

## Why AI needs its own threat modelling approach

Standard STRIDE threat modelling still applies to AI systems, but AI introduces threat categories that traditional frameworks miss: training data poisoning, model extraction, adversarial examples, and the collapse of the instruction/data boundary. This page shows how to extend STRIDE for AI and introduces AI-specific frameworks.

---

## STRIDE applied to AI systems

| STRIDE | Traditional meaning | AI-specific manifestation |
|---|---|---|
| **Spoofing** | Impersonating a user/system | Impersonating the model (fake responses), synthetic identity via deepfakes |
| **Tampering** | Modifying data/code | Training data poisoning, adversarial examples, prompt injection |
| **Repudiation** | Denying an action | No audit trail of model decisions, non-reproducible outputs |
| **Information Disclosure** | Leaking data | Training data extraction, membership inference, system prompt leakage |
| **Denial of Service** | Overwhelming the system | Resource-exhaustion prompts, sponge examples, cost amplification |
| **Elevation of Privilege** | Gaining unauthorised access | Excessive agency, tool abuse via injection, jailbreaking guardrails |

---

## AI-specific threat categories

### Training-time threats

```
Data poisoning:
  Attacker injects malicious samples into training data
  → Model learns attacker-desired behaviour
  → Example: poison spam filter training data so attacker's spam passes

Backdoor / trojan:
  Model behaves normally except when it sees a specific trigger
  → Example: face recognition that fails when a specific pattern is worn

Supply chain:
  Compromised pre-trained model weights, poisoned datasets from public sources
  → Example: downloading a backdoored model from a public model hub
```

### Inference-time threats

```
Adversarial examples:
  Carefully crafted input that causes misclassification
  → Example: a stop sign with stickers that a self-driving car reads as "speed limit 45"

Prompt injection:
  Malicious instructions in input or retrieved content
  → See the Prompt Injection page for full detail

Model extraction / theft:
  Attacker queries the model repeatedly to steal its behaviour
  → Reconstructs a copy of a proprietary model

Membership inference:
  Determine whether a specific record was in the training data
  → Privacy violation — reveals someone's data was used
```

### Output threats

```
Sensitive information disclosure:
  Model reveals training data, other users' data, or secrets
  → Example: model trained on customer emails reveals one customer's data to another

Insecure output handling:
  Model output executed as code, rendered as HTML, used in SQL
  → Example: model output containing XSS payload rendered in a web page

Excessive agency:
  Model takes harmful actions via connected tools
  → Example: injected instruction causes agent to delete files or send money
```

---

## The MAESTRO framework

MAESTRO (Multi-Agent Environment, Security, Threat, Risk, and Outcome) is a threat modelling framework designed specifically for agentic AI systems. It examines threats across seven layers:

| Layer | Focus | Example threats |
|---|---|---|
| 1. Foundation Model | The base LLM | Backdoors, alignment failures, jailbreaks |
| 2. Data Operations | Training and RAG data | Data poisoning, indirect injection via RAG |
| 3. Agent Frameworks | The orchestration layer | Tool abuse, insecure agent-to-agent communication |
| 4. Deployment | Infrastructure | Model endpoint exposure, credential theft |
| 5. Evaluation | Testing and monitoring | Evaluation gaming, missing guardrails |
| 6. Security & Compliance | Controls | Insufficient access control, audit gaps |
| 7. Agent Ecosystem | Multi-agent interactions | Cascading failures, collusion, trust exploitation |

---

## AI system data flow diagram

A typical LLM application DFD with trust boundaries:

```
[User] ──────────────────────────────────────────────┐
   │ untrusted input                                  │
   │                                                  │
═══▼══════════════════════ TRUST BOUNDARY: User Input ═══
   │
   ▼
[Input Guardrail]  ← injection detection, content filter
   │
   ▼
[Prompt Builder]  ← combines system prompt + user input + context
   │                 ⚠ instruction/data boundary collapses here
   │
   ├──────────────◀── [RAG Retrieval] ◀── [Vector DB] ◀── [Documents]
   │  retrieved content                                    ⚠ indirect injection vector
   │  (UNTRUSTED)
   ▼
═══════════════════════ TRUST BOUNDARY: Model Inference ═══
   │
   ▼
[LLM] ─────────────────────────────┐
   │ model output (UNTRUSTED)       │
   │                                │
   ▼                                ▼
[Output Guardrail]           [Tool Router]  ← ⚠ excessive agency
   │ filter sensitive data          │
   │                                ├──▶ [Database Tool]  ← needs own authz
   ▼                                ├──▶ [Email Tool]     ← needs user confirm
[User]                             └──▶ [Web Request]    ← SSRF risk
```

Key trust boundaries:
- **User input** — always untrusted, may contain direct injection
- **Retrieved content** — untrusted, may contain indirect injection
- **Model output** — untrusted, must be validated before use or rendering
- **Tool calls** — each requires independent authorisation

---

## AI threat model template

```yaml
# ai-threat-model.yml
system: "customer-support-ai-agent"
model: "gpt-4-class LLM via API"
last_reviewed: "2026-08-05"

components:
  - id: USER_INPUT
    trust: untrusted
  - id: RAG_STORE
    trust: untrusted   # content could be poisoned
    description: "Vector DB of support articles + past tickets"
  - id: LLM
    trust: semi-trusted
    description: "Third-party API — subject to injection"
  - id: TOOLS
    trust: privileged
    tools: ["search_kb", "create_ticket", "issue_refund"]

threats:
  - id: AI-01
    category: prompt_injection
    stride: "T, E"
    description: "User directly injects instructions to bypass guardrails and issue unauthorised refunds"
    likelihood: high
    impact: high
    mitigation: "issue_refund tool requires human approval above $50; injection detection on input"
    status: mitigated

  - id: AI-02
    category: indirect_injection
    stride: "T, E"
    description: "Attacker plants injection in a support ticket; when agent retrieves it via RAG, agent follows injected instructions"
    likelihood: medium
    impact: high
    mitigation: "RAG content processed by quarantined model with no tool access; retrieved content clearly delimited as data"
    status: mitigated

  - id: AI-03
    category: information_disclosure
    stride: "I"
    description: "Model reveals another customer's data present in the RAG store"
    likelihood: medium
    impact: high
    mitigation: "RAG retrieval filtered by customer_id at query time — model only ever sees the current user's data"
    status: mitigated

  - id: AI-04
    category: excessive_agency
    stride: "E"
    description: "Injected instruction causes agent to issue large refund or mass-create tickets"
    likelihood: medium
    impact: high
    mitigation: "Tools have rate limits; refunds >$50 need human approval; all tool calls logged"
    status: mitigated

  - id: AI-05
    category: sensitive_disclosure
    stride: "I"
    description: "System prompt (containing business logic) leaked via injection"
    likelihood: high
    impact: low
    mitigation: "System prompt contains no secrets; assume it will leak and design accordingly"
    status: accepted

  - id: AI-06
    category: denial_of_service
    stride: "D"
    description: "Attacker sends resource-exhaustion prompts to amplify API costs"
    likelihood: medium
    impact: medium
    mitigation: "Per-user rate limits; max token limits; cost alerting"
    status: mitigated

  - id: AI-07
    category: insecure_output
    stride: "T"
    description: "Model output containing XSS rendered in support agent's browser"
    likelihood: low
    impact: medium
    mitigation: "All model output HTML-escaped before rendering"
    status: mitigated
```

---

## AI threat modelling checklist

```
Data and training
□ Training data sources documented and trusted
□ Data poisoning risk assessed for any user-contributed training data
□ Pre-trained models sourced from verified providers with integrity checks
□ Model provenance and version tracked

Input
□ User input treated as untrusted — injection possible
□ Retrieved/RAG content treated as untrusted — indirect injection possible
□ Input and instructions clearly separated
□ Injection detection in place (as telemetry)

Model and inference
□ Model has minimal agency — least privilege for tools
□ Sensitive tools require human confirmation
□ RAG retrieval filtered by user authorisation at query time
□ Rate limiting and cost controls in place

Output
□ Model output treated as untrusted
□ Output validated/escaped before rendering or execution
□ Output filtered for sensitive data leakage
□ Tool calls validated against strict schema

Governance
□ AI system has a documented threat model
□ AI red teaming conducted before launch
□ Model decisions are logged for audit
□ Incident response plan covers AI-specific failures
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ai-security/prompt-injection/"><span class="ref-label">AI</span>Prompt Injection</a>
  <a class="ref-card" href="/wiki/ai-security/llm-top10/"><span class="ref-label">AI</span>OWASP LLM Top 10</a>
  <a class="ref-card" href="/wiki/ai-security/ai-red-teaming/"><span class="ref-label">AI</span>AI Red Teaming</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/templates/threat-register/"><span class="ref-label">Template</span>Threat Register Template</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
