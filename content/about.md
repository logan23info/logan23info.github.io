---
title: "About"
date: 2026-08-05
layout: "single"
showToc: true
---

## About this wiki

A practitioner's reference covering the full security engineering lifecycle — built for engineers, by an engineer. Every page focuses on what you actually do, not just what you should know.

---

## Content structure

The wiki is organised into six areas that cover the complete security lifecycle:

```
Design → Build → Test → Validate → Operate → Respond
  ↓         ↓        ↓        ↓           ↓          ↓
Threat    Secure   OWASP   Advisory    Maturity   Incident
Model    Arch     Top 10   & Assurance  Ladder    Response
```

### 🪜 Security Engineering Maturity Ladder
The progression from threat modelling through to Zero Trust — how security programmes mature.

### 🔐 OWASP Top 10
One page per vulnerability with code examples, STRIDE mapping, and detection methods.

### 🏗️ Secure Architecture
Patterns for securing microservices, APIs, secrets, containers, and Kubernetes.

### 🔍 Advisory & Assurance
ToD, ToI, ToOE — independent validation that controls work. Evidence templates for audits.

### 🛠 Tools & Templates
Threat Dragon, Threagile, threat register templates, PR checklists, DFD guides.

---

## The stack behind this site

This wiki is itself a DevSecOps example — the infrastructure is managed as code, the deployment is automated, and the site has its own threat model.

| Layer | Tool | Purpose |
|---|---|---|
| Hugo | Static site generator | No runtime, no attack surface |
| PaperMod | Theme | Clean, fast, dark mode |
| GitHub Actions | CI/CD | Auto-deploy on every push |
| OpenTofu | IaC | AWS resources as code |
| Terraform Cloud | State backend | Free remote state |
| GitHub Pages | Hosting | Free, no servers to patch |

Source: [github.com/logan23info/logan23info.github.io](https://github.com/logan23info/logan23info.github.io)

---

## Contributing

Found an error or want to suggest content? Open an issue or PR on GitHub.

Planned content: Compliance Mappings, Incident Response, Detection Engineering, AI/LLM Security, Privacy, Cryptography, Security Metrics, OT/ICS Security.
