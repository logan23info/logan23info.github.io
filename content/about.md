---
title: "About"
date: 2026-08-02
layout: "single"
showToc: false
---

## About this wiki

A practitioner's reference covering the full **Security Engineering Maturity Ladder** — from Threat Modelling foundations through to Zero Trust Architecture and Supply Chain Security.

### What you will find here

- Deep-dives into all 6 levels of the Security Engineering Maturity Ladder
- Threat Modelling frameworks: STRIDE, DREAD, PASTA, Attack Trees
- Attack Surface Management: discovery, tooling, CI/CD integration
- Red Teaming: adversary simulation, MITRE ATT&CK, C2 frameworks
- Purple Teaming: detection engineering, VECTR, Atomic Red Team
- Threat Intelligence: CTI tiers, MISP, OpenCTI, threat actor profiles
- Zero Trust Architecture: NIST SP 800-207, five pillars, BeyondCorp
- Supply Chain Security: SLSA, SBOM, Sigstore, build pipeline hardening

### The stack behind this site

This wiki is itself a DevSecOps example:

- **Hugo** — static site generator (no runtime attack surface)
- **GitHub Actions** — CI/CD pipeline, auto-deploys on every push
- **OpenTofu** — IaC managing AWS resources as code
- **Terraform Cloud** — free remote state backend
- **GitHub Pages** — free hosting, no servers to patch

Source: [github.com/logan23info/logan23info.github.io](https://github.com/logan23info/logan23info.github.io)
