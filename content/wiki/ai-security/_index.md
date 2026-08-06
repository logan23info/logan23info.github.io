---
title: "AI & LLM Security"
date: 2026-08-05
tags: ["AI-security", "LLM", "prompt-injection", "OWASP-LLM", "machine-learning"]
categories: ["ai-security"]
description: "AI and LLM security reference — OWASP LLM Top 10, prompt injection, AI threat modelling, and AI red teaming."
showToc: true
layout: "single"
---

## Why AI security is different

Large Language Models introduce security properties that traditional application security does not address:

| Traditional software | LLM-based systems |
|---|---|
| Deterministic — same input, same output | Probabilistic — same input, different output |
| Code and data clearly separated | Instructions and data in the same channel |
| Input validation is well-understood | Natural language input is unbounded |
| Vulnerabilities are in code | Vulnerabilities emerge from model behaviour |
| Patchable | Retraining is expensive and slow |

**The core problem:** LLMs cannot reliably distinguish between instructions from the developer (system prompt) and instructions embedded in user data. This is the root cause of prompt injection — the most significant LLM vulnerability class.

---

## Pages in this section

| Page | Description |
|---|---|
| [OWASP LLM Top 10](/wiki/ai-security/llm-top10/) | The 10 most critical LLM application vulnerabilities |
| [Prompt Injection](/wiki/ai-security/prompt-injection/) | Direct and indirect prompt injection — attacks and defences |
| [AI Threat Modelling](/wiki/ai-security/ai-threat-modelling/) | STRIDE applied to LLM architectures, RAG, and agents |
| [AI Red Teaming](/wiki/ai-security/ai-red-teaming/) | Adversarial testing of AI systems — methodology and tools |

---

## The AI attack surface

```
User input
    ↓
[Input filtering]  ← jailbreaks, prompt injection
    ↓
[System prompt + user prompt]  ← prompt leaking, instruction override
    ↓
[LLM]  ← model extraction, training data extraction
    ↓
[Tool/function calling]  ← excessive agency, unauthorised actions
    ↓
[RAG retrieval]  ← indirect injection via poisoned documents
    ↓
[Output]  ← insecure output handling, XSS via LLM output
    ↓
[Downstream system]  ← SQL injection, RCE via LLM-generated code
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/ai-security/llm-top10/"><span class="ref-label">AI</span>OWASP LLM Top 10</a>
  <a class="ref-card" href="/wiki/ai-security/prompt-injection/"><span class="ref-label">AI</span>Prompt Injection</a>
  <a class="ref-card" href="/wiki/ai-security/ai-threat-modelling/"><span class="ref-label">AI</span>AI Threat Modelling</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 (web)</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
