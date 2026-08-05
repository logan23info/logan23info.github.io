---
title: "PR Security Checklist Template"
date: 2026-08-02
tags: ["template", "PR", "checklist", "DevSecOps"]
categories: ["templates"]
description: "A pull request security checklist template — add this to your repo so every engineer considers STRIDE on every code change."
showToc: true
---

## Why a PR security checklist?

A PR checklist is the simplest way to embed threat modelling into daily engineering. It takes 2 minutes per PR and prevents the most common categories of vulnerability from being introduced in the first place.

---

## GitHub PR template

Create this file at `.github/pull_request_template.md` in your repo:

```markdown
## What does this PR do?

<!-- Brief description of the change -->

## Type of change
- [ ] New feature
- [ ] Bug fix
- [ ] Infrastructure / IaC change
- [ ] Pipeline / CI change
- [ ] Configuration change
- [ ] Content / docs only

---

## 🔒 Security checklist

> **Skip if:** this is a content-only or docs-only change.
> **Complete if:** this PR touches authentication, authorisation, data handling,
> infrastructure, secrets, dependencies, or API endpoints.

### Input & authentication (STRIDE: Spoofing, Tampering)
- [ ] All new inputs are validated and sanitised
- [ ] New API endpoints require authentication
- [ ] No new trust relationships without explicit justification
- [ ] JWT / session tokens handled securely (short TTL, signed, validated)

### Data handling (STRIDE: Information Disclosure)
- [ ] No secrets, credentials, or PII committed to the repo
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Error messages do not leak internal details to clients
- [ ] New log statements do not log sensitive data

### Authorisation (STRIDE: Elevation of Privilege)
- [ ] Authorisation checked server-side (not just client-side)
- [ ] New endpoints follow least-privilege — users can only access their own data
- [ ] No mass assignment vulnerabilities in new model/schema changes
- [ ] IAM roles / policies follow least privilege

### Audit & availability (STRIDE: Repudiation, Denial of Service)
- [ ] Sensitive actions (login, delete, admin) are audit-logged
- [ ] Rate limiting applied to new public-facing endpoints
- [ ] No unbounded loops or queries that could exhaust resources
- [ ] Timeout set on new external API calls

### Dependencies & supply chain
- [ ] New dependencies reviewed for known CVEs (`npm audit` / `pip-audit` / Dependabot)
- [ ] No new dependency added without justification in PR description
- [ ] Dependency versions pinned in lockfile

### Threat model
- [ ] `threat-model.yml` updated if new threats were identified
- [ ] No open Critical threats remain after this change

---

## Checkov / tfsec output (for IaC changes)
<!-- Paste output or write "clean" -->

## Reviewer notes
<!-- Anything specific you want the reviewer to check -->
```

---

## Jira / Linear ticket checklist

For teams using Jira or Linear, add these acceptance criteria to your security-relevant ticket template:

```
Security acceptance criteria:
□ STRIDE analysis completed for this change
□ All inputs validated
□ Authentication and authorisation verified
□ No secrets in code or logs
□ Audit logging added for sensitive actions
□ Rate limiting applied if public-facing
□ Dependencies scanned for CVEs
□ Threat register updated
```

---

## Lightweight version (for fast-moving teams)

If the full checklist feels too heavy, use this 5-question version:

```markdown
## Quick security check (2 mins)

1. **New inputs?** Are they validated? (Tampering / SQLi / XSS)
2. **New data access?** Is it authorised per-user? (EoP / IDOR)
3. **New secrets?** Are they in GitHub Secrets, not in code? (Info Disclosure)
4. **New endpoint?** Does it require auth and have rate limiting? (DoS / Spoofing)
5. **New dependency?** Has it been audited? (Supply chain)
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/stride/">
    <span class="ref-label">Framework</span>STRIDE — Threat Categorisation
  </a>
  <a class="ref-card" href="/wiki/templates/threat-register/">
    <span class="ref-label">Template</span>Threat Register Template
  </a>
  <a class="ref-card" href="/wiki/templates/dfd/">
    <span class="ref-label">Template</span>Data Flow Diagram Guide
  </a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/">
    <span class="ref-label">Post</span>Threat Modelling in DevSecOps
  </a>
  <a class="ref-card" href="/wiki/supply-chain/">
    <span class="ref-label">Wiki</span>Supply Chain Security
  </a>
  <a class="ref-card" href="/wiki/maturity-ladder/">
    <span class="ref-label">Wiki</span>Security Engineering Maturity Ladder
  </a>
</div>

</div>
