---
title: "Supply Chain Security"
date: 2026-08-02
tags: ["supply-chain", "SLSA", "SBOM", "security-engineering", "DevSecOps"]
categories: ["security-engineering"]
description: "Complete guide to Software Supply Chain Security — SLSA framework, SBOM, dependency management, and securing the build pipeline."
showToc: true
weight: 7
---

## What is Supply Chain Security?

Software supply chain security is the practice of securing every component, tool, and process that contributes to building and delivering your software. Modern applications are typically 80–90% third-party code — open source libraries, frameworks, and dependencies written by others.

A supply chain attack targets this dependency on third-party code. Instead of attacking your application directly, attackers compromise something your application trusts — a popular open source library, a build tool, or a software update mechanism.

---

## Why supply chain security matters

### The scale of the problem

- The average enterprise application has **528 open source dependencies**
- In 2023, there were **245,000+ malicious packages** published to npm, PyPI, and other registries
- Supply chain attacks increased **742%** between 2019 and 2022

### High-profile supply chain attacks

**SolarWinds (2020)**
- Attackers compromised SolarWinds' build pipeline
- Malicious code inserted into Orion software update
- 18,000 organisations installed the backdoored update
- Victims included US Treasury, State Department, Microsoft, FireEye

**Log4Shell (2021 — CVE-2021-44228)**
- Critical zero-day in Log4j — a logging library used in millions of Java applications
- CVSS score 10.0 (maximum)
- Affected organisations had no idea they were using Log4j — it was a transitive dependency
- Demonstrated: you must know every dependency, not just your direct ones

**XZ Utils (2024)**
- Attacker spent two years building trust in the XZ Utils open source project
- Gained maintainer access and inserted a backdoor targeting SSH authentication
- Would have affected millions of Linux servers
- Caught by accident before widespread deployment

---

## The SLSA framework

SLSA (Supply chain Levels for Software Artifacts, pronounced "salsa") is a security framework developed by Google that provides a checklist of standards to prevent tampering and improve software integrity.

### SLSA levels

| Level | Requirements | What it prevents |
|---|---|---|
| SLSA 0 | No guarantees | Nothing |
| SLSA 1 | Build process documented, provenance generated | Accidental errors |
| SLSA 2 | Build service used, provenance signed | Tampering by rogue developer |
| SLSA 3 | Hardened build service, source verified | Compromised build service |
| SLSA 4 | Two-party review, hermetic builds | Sophisticated insider attacks |

### SLSA provenance

Provenance is a verifiable record of how an artifact was built — who built it, from what source, using what process.

```json
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "subject": [{
    "name": "myapp-v1.0.tar.gz",
    "digest": {"sha256": "abc123..."}
  }],
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "predicate": {
    "builder": {"id": "https://github.com/actions/runner"},
    "buildType": "https://github.com/slsa-framework/slsa-github-generator",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/myorg/myapp@refs/heads/main",
        "digest": {"sha1": "def456..."},
        "entryPoint": ".github/workflows/release.yml"
      }
    },
    "metadata": {
      "buildStartedOn": "2026-08-02T09:00:00Z",
      "completeness": {"parameters": true, "environment": true}
    }
  }
}
```

### Implementing SLSA in GitHub Actions

```yaml
# .github/workflows/release.yml
name: Release with SLSA provenance

on:
  push:
    tags: ['v*']

permissions:
  contents: write
  id-token: write
  actions: read

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      hashes: ${{ steps.hash.outputs.hashes }}
    steps:
      - uses: actions/checkout@v4

      - name: Build artifact
        run: |
          make build
          echo "artifact=myapp-${{ github.ref_name }}.tar.gz" >> $GITHUB_OUTPUT

      - name: Generate SHA256 hashes
        id: hash
        run: |
          sha256sum myapp-*.tar.gz > checksums.txt
          echo "hashes=$(cat checksums.txt | base64 -w0)" >> $GITHUB_OUTPUT

      - uses: actions/upload-artifact@v4
        with:
          name: artifacts
          path: "*.tar.gz"

  provenance:
    needs: [build]
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v1.10.0
    with:
      base64-subjects: "${{ needs.build.outputs.hashes }}"
      upload-assets: true
```

---

## Software Bill of Materials (SBOM)

An SBOM is a complete list of every component in your software — like a nutritional label for code. It enables you to quickly determine whether you are affected by a newly discovered vulnerability.

### SBOM formats

**SPDX** (Software Package Data Exchange) — Linux Foundation standard:
```json
{
  "SPDXID": "SPDXRef-DOCUMENT",
  "spdxVersion": "SPDX-2.3",
  "name": "myapp-1.0",
  "packages": [
    {
      "SPDXID": "SPDXRef-log4j",
      "name": "log4j-core",
      "version": "2.14.1",
      "supplier": "Organization: Apache Software Foundation",
      "downloadLocation": "https://search.maven.org/...",
      "filesAnalyzed": true,
      "packageVerificationCode": {"packageVerificationCodeValue": "abc123"},
      "licenseConcluded": "Apache-2.0",
      "licenseDeclared": "Apache-2.0"
    }
  ]
}
```

**CycloneDX** — OWASP standard, security-focused:
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "version": 1,
  "components": [
    {
      "type": "library",
      "name": "log4j-core",
      "version": "2.14.1",
      "purl": "pkg:maven/org.apache.logging.log4j/log4j-core@2.14.1",
      "licenses": [{"license": {"id": "Apache-2.0"}}],
      "vulnerabilities": [
        {
          "id": "CVE-2021-44228",
          "ratings": [{"severity": "critical", "score": 10.0}]
        }
      ]
    }
  ]
}
```

### Generating SBOMs in CI/CD

```yaml
# Add to your GitHub Actions workflow
- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    artifact-name: sbom.spdx.json
    format: spdx-json

- name: Scan SBOM for vulnerabilities
  uses: anchore/scan-action@v3
  with:
    sbom: sbom.spdx.json
    fail-build: true
    severity-cutoff: high
```

---

## Dependency security

### Dependency scanning tools

| Tool | Language | CI Integration | Cost |
|---|---|---|---|
| Dependabot | All | GitHub native | Free |
| Snyk | All | GitHub/GitLab/Jenkins | Free tier |
| OWASP Dependency-Check | Java/.NET | All CI | Free |
| npm audit | JavaScript | npm native | Free |
| pip-audit | Python | Any | Free |
| Trivy | Containers + packages | GitHub Actions | Free |
| Grype | Containers + SBOMs | Any | Free |

### Dependency confusion attacks

Dependency confusion (Alex Birsan, 2021) exploits how package managers resolve package names. If your private package registry has a package called `mycompany-utils`, an attacker can publish a **public** package with the same name but a higher version number — and package managers may install the malicious public version instead.

**Mitigations:**
```
1. Scope private packages: @mycompany/utils (npm scoped packages)
2. Use private registry that explicitly blocks public fallback for private names
3. Pin exact versions with lockfiles (package-lock.json, yarn.lock, poetry.lock)
4. Verify package integrity with checksums
```

### Typosquatting

Attackers publish malicious packages with names similar to popular ones:
- `lodash` (legitimate) vs `lodashs` (malicious)
- `requests` (legitimate) vs `request` (check carefully)
- `numpy` (legitimate) vs `numpay` (malicious)

**Mitigation:** Only install packages from verified sources. Review package metadata before installing. Use Typosquatting detection tools.

---

## Securing the build pipeline

Your build pipeline is a high-value target — compromise it and you can tamper with every artifact it produces.

### Build pipeline hardening checklist

```
Source code
□ Branch protection on main branch (require PR review)
□ Signed commits (GPG or SSH signing)
□ CODEOWNERS for sensitive files
□ Secret scanning enabled (GitHub Advanced Security / gitleaks)

Build environment
□ Ephemeral build environments (no persistent build agents)
□ Minimal permissions for build service accounts
□ No hardcoded credentials in build scripts
□ Build artifacts checksummed and signed
□ Hermetic builds (dependencies pinned, no internet access during build)

Artifact storage
□ Artifacts stored in access-controlled registry
□ Vulnerability scanning on container images before push
□ Image signing with Cosign/Notary
□ Immutable artifact storage (no overwrite of published versions)

Deployment
□ Verify artifact signatures before deployment
□ Verify SLSA provenance before deployment
□ Deploy from registry, never from local build
□ GitOps — deployment state in version control
```

### Signing artifacts with Sigstore/Cosign

```bash
# Install cosign
brew install cosign  # or download from sigstore.dev

# Sign a container image (keyless using GitHub Actions OIDC)
cosign sign --yes ghcr.io/myorg/myapp:v1.0

# Verify a signed image
cosign verify \
  --certificate-identity "https://github.com/myorg/myapp/.github/workflows/release.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myapp:v1.0
```

---

## Third-party risk management

### Evaluating open source dependencies

Before adding a new dependency, evaluate:

| Factor | What to check |
|---|---|
| Maintainership | How many active maintainers? When was the last commit? |
| Community | Stars, forks, contributors, issue response time |
| Security track record | Past CVEs, how quickly patched? |
| License | Compatible with your use case? |
| Popularity | Widely used = more scrutiny, but also bigger target |
| Provenance | Who published it? Is it the legitimate maintainer? |

### Scorecard — automated dependency evaluation

OpenSSF Scorecard evaluates open source packages across 18 security criteria:

```bash
# Install and run Scorecard
go install sigs.k8s.io/release-utils/cmd/scorecard@latest

scorecard --repo=github.com/someorg/somepackage

# Output:
# Maintained: 8/10
# Code-Review: 7/10
# Branch-Protection: 5/10
# Vulnerabilities: 10/10
# Pinned-Dependencies: 3/10   ← gap
# SAST: 6/10
# Aggregate: 7.2/10
```

---

## Key metrics

| Metric | Target |
|---|---|
| SBOM coverage | 100% of production software |
| Time to patch critical CVE | < 24 hours |
| Dependency freshness | No dependency > 2 major versions behind |
| Signed artifact coverage | 100% of released artifacts |
| Secret scan coverage | 100% of repositories |
| Dependency review on PRs | 100% of dependency-adding PRs reviewed |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder Overview</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/tools/threagile/"><span class="ref-label">Tool</span>Threagile — threat model as code</a>
  <a class="ref-card" href="/wiki/templates/pr-checklist/"><span class="ref-label">Template</span>PR Security Checklist</a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/"><span class="ref-label">Post</span>Threat Modelling in DevSecOps</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
