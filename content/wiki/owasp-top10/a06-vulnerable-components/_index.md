---
title: "A06 — Vulnerable and Outdated Components"
date: 2026-08-05
tags: ["OWASP", "dependencies", "CVE", "SCA", "supply-chain", "SBOM"]
categories: ["owasp"]
description: "OWASP A06 Vulnerable and Outdated Components — known CVEs in libraries, frameworks, and dependencies. SCA scanning, SBOM, and dependency management."
showToc: true
layout: "single"
---

## Overview

Modern applications are 80–90% open source code written by others. A06 covers the risk of using components with known vulnerabilities. The Log4Shell vulnerability (CVE-2021-44228, CVSS 10.0) affected millions of applications and was devastating precisely because most organisations did not know they were running Log4j.

| Attribute | Detail |
|---|---|
| OWASP rank | #6 (2021) — previously #9 |
| STRIDE mapping | **All categories** — depends on the CVE |
| CWEs mapped | 3 (CWE-1104, CWE-1035, CWE-937) |
| Famous examples | Log4Shell (CVSS 10.0), Heartbleed (OpenSSL), Struts2 (Equifax breach) |

---

## The supply chain attack surface

```
Your application
    ↓
Direct dependencies (you chose these)
    ↓
Transitive dependencies (dependencies of dependencies)
    ↓
Build tools (Maven, npm, pip)
    ↓
Base container images
    ↓
OS packages in base image
    ↓
Infrastructure packages (Kubernetes, cloud CLIs)
```

Log4j was a **transitive dependency** — most affected organisations had no idea they were running it. It was a dependency of a dependency of a dependency.

---

## Detection & scanning

### Software Composition Analysis (SCA)

```bash
# npm / Node.js
npm audit
npm audit --audit-level=high   # fail on high+
npm audit fix                   # auto-fix where possible

# Python
pip-audit                       # pip-audit scans installed packages
pip-audit -r requirements.txt

# Java / Maven
mvn dependency:tree             # see full dependency tree
mvn org.owasp:dependency-check-maven:check

# Container image scanning
trivy image python:3.11-slim
trivy image --severity CRITICAL,HIGH myapp:latest
grype myapp:latest

# SBOM generation + scanning
syft myapp:latest -o cyclonedx-json > sbom.json
grype sbom:sbom.json
```

### GitHub Dependabot (automated)

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"

  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### CI/CD security gate

```yaml
# .github/workflows/security.yml
name: Dependency security scan

on: [push, pull_request]

jobs:
  sca:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Python dependency audit
        run: |
          pip install pip-audit
          pip-audit -r requirements.txt --fail-on-vuln

      - name: npm audit
        run: npm audit --audit-level=high
        working-directory: frontend/

      - name: Container image scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:latest
          exit-code: 1
          severity: CRITICAL,HIGH

      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          artifact-name: sbom.cyclonedx.json
          format: cyclonedx-json
```

---

## Dependency management best practices

### Pin exact versions with lockfiles

```bash
# Python — pin to exact versions
pip freeze > requirements.txt
# requirements.txt:
# requests==2.31.0        ← exact, not requests>=2.0

# Node.js — commit package-lock.json
npm ci   # installs exactly from lockfile — not npm install

# Go — go.sum pins exact hashes
go mod verify   # verify against go.sum

# Never do this:
# requests>=2.0       ← any 2.x could be installed — attacker publishes 2.99.0
# requests~=2.0       ← same risk
```

### Verify package integrity

```bash
# npm — verify package integrity hashes
npm audit signatures

# Python — verify with pip hash checking
pip install --require-hashes -r requirements.txt
# requirements.txt must include hashes:
# requests==2.31.0 \
#     --hash=sha256:58cd2187423d78... \
#     --hash=sha256:942c5a758f98d7...

# Docker — pin base images to digest
FROM python:3.12-slim@sha256:a1b2c3...   # immutable reference
# NOT: FROM python:3.12-slim              # tag can change
```

---

## Response to a new critical CVE

When a critical CVE is published for a component you use:

```
Hour 0:  CVE published
Hour 1:  SCA tools flag in CI/CD — alert fires
Hour 2:  Assess: are we affected? (check SBOM)
Hour 4:  Patch available? Apply and test
Hour 24: Deploy to production (critical SLA)

If no patch available:
  - Apply vendor mitigation (e.g. Log4Shell: set log4j2.formatMsgNoLookups=true)
  - Implement WAF rule to block exploit pattern
  - Risk-accept with documented rationale and review date
  - Monitor vendor for patch release
```

---

## Prevention checklist

```
□ SBOM generated for every production build (SPDX or CycloneDX)
□ SCA scan runs on every PR — blocks merge on Critical CVEs
□ Dependabot or Renovate enabled on all repos
□ Dependencies pinned to exact versions in lockfiles
□ Base container images pinned to digest (not mutable tag)
□ Dependency review on every PR that changes package files
□ Critical CVE patched within 24 hours, High within 7 days
□ Quarterly review of all dependencies — remove unused ones
□ Internal package registry scanned for malicious packages
□ OpenSSF Scorecard run on critical dependencies before adoption
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/owasp-top10/a08-software-integrity/"><span class="ref-label">OWASP</span>A08 Software Integrity Failures</a>
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — VM domain</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
</div>

</div>
