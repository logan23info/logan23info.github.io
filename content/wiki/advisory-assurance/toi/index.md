--- 
title: "Test of Implementation (ToI)"
layout: "single"
date: 2026-08-02
tags: ["ToI", "test-of-implementation", "assurance", "audit", "controls"]
categories: ["governance"]
description: "Test of Implementation — validating that security controls have been correctly and completely implemented as designed."
showToc: true
---

## What is a Test of Implementation?

A Test of Implementation (ToI) is an assurance activity that validates whether a security control has been **correctly and completely implemented** in accordance with its design. It bridges the gap between design intent and technical reality.

A control can pass the ToD (design is sound) but fail the ToI because:
- The implementation is incomplete — only partially deployed
- The implementation has a technical error — a misconfiguration
- The implementation deviates from the design — shortcuts were taken
- The implementation was correct but has drifted — configuration changed since deployment

---

## ToI vs Penetration Testing

| Dimension | ToI | Penetration Test |
|---|---|---|
| Goal | Verify control is correctly implemented | Find exploitable vulnerabilities |
| Approach | Evidence-based + targeted technical testing | Adversarial, creative |
| Scope | Specific controls being assured | Broad attack surface |
| Output | Pass/Fail per control | Vulnerability list |
| Who performs | Assurance team, internal audit | Red team, pen testers |
| Frequency | Per control lifecycle change | Annually or per compliance |

ToI is structured and control-focused. Pen testing is adversarial and open-ended.

---

## ToI testing techniques

### 1. Configuration inspection
Review the actual technical configuration against the design specification.

**Examples:**
```bash
# Verify TLS configuration on API endpoint
nmap --script ssl-enum-ciphers -p 443 api.example.com
# Expected: TLS 1.2+ only, no weak ciphers (RC4, DES, 3DES)

# Verify S3 bucket encryption
aws s3api get-bucket-encryption --bucket my-bucket
# Expected: SSEAlgorithm: aws:kms

# Verify MFA enforcement in AWS
aws iam get-account-password-policy
# Check: require MFA for console access

# Check Security Group — no 0.0.0.0/0 inbound on port 22
aws ec2 describe-security-groups --query \
  "SecurityGroups[?IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0'] && ToPort==\`22\`]]"
```

### 2. Evidence sampling
Request a sample of evidence demonstrating the control is in place across a population.

**Examples:**
- MFA enforcement: request screenshot of MFA settings for 25 randomly selected user accounts
- Patch management: request patch scan report showing all systems patched within SLA
- Access reviews: request completed access review sign-off for 3 most recent quarters
- Vulnerability scanning: request scan results for last 3 months across all in-scope systems

### 3. Walkthrough testing
Walk through the control operation step-by-step with the control owner and verify each step works as designed.

**Example — MFA walkthrough:**
```
Step 1: Navigate to application login page
Step 2: Enter valid username and password
Step 3: Verify MFA prompt appears
Step 4: Attempt to bypass MFA (e.g. directly access authenticated URL)
Step 5: Verify bypass is blocked
Step 6: Complete MFA — verify access granted
Step 7: Test with service account — verify MFA not required (if by design)
         OR verify MFA is enforced (if policy requires it)
```

### 4. Technical control testing
Use automated tools to test specific control implementations.

```bash
# Test HTTP security headers implementation
curl -I https://api.example.com | grep -E "(Strict-Transport|Content-Security|X-Frame|X-Content)"
# Expected headers:
# Strict-Transport-Security: max-age=31536000; includeSubDomains
# Content-Security-Policy: default-src 'self'
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff

# Test rate limiting implementation
for i in {1..20}; do
  curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/login \
    -d '{"username":"test","password":"test"}'
done
# Expected: HTTP 429 after configured threshold (e.g. 10 attempts)

# Test JWT algorithm restriction
# Craft a JWT with alg:none
TOKEN=$(python3 -c "
import base64, json
header = base64.b64encode(json.dumps({'alg':'none','typ':'JWT'}).encode()).decode().rstrip('=')
payload = base64.b64encode(json.dumps({'sub':'admin','role':'admin'}).encode()).decode().rstrip('=')
print(f'{header}.{payload}.')
")
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/admin
# Expected: HTTP 401 Unauthorized
```

### 5. Automated compliance scanning
Use IaC scanning tools to verify infrastructure implementation:

```bash
# Checkov — scan Terraform for control implementation
checkov -d infra/ --framework terraform --check \
  CKV_AWS_19,CKV_AWS_20,CKV_AWS_57  # S3 encryption, public access, logging

# tfsec
tfsec infra/ --format json | jq '.results[] | select(.severity == "HIGH")'

# AWS Config rules — verify controls across account
aws configservice describe-compliance-by-config-rule \
  --compliance-types NON_COMPLIANT \
  --query 'ComplianceByConfigRules[*].ConfigRuleName'

# Prowler — AWS security best practices
prowler aws --compliance pci_3.2.1
```

---

## ToI by control domain

### Identity & Access Management

| Control | ToI test | Evidence to request | Pass criteria |
|---|---|---|---|
| MFA on all users | Sample 25 accounts — verify MFA enrolled | IAM MFA report, screenshot | 100% of in-scope users have MFA |
| Privileged access | List all admin accounts — verify approved | Access review sign-off, IAM report | No unapproved admin accounts |
| Terminated user access | Sample 5 recent leavers — verify access removed | HR termination list vs IAM report | Access removed within SLA (e.g. 4 hours) |
| Password complexity | Attempt to set weak password | Screenshot of rejection | Policy enforced technically, not just documented |
| Service account MFA | List service accounts — verify controls | IAM report, API key audit | No human-usable credentials without MFA |

### Network Security

| Control | ToI test | Evidence to request | Pass criteria |
|---|---|---|---|
| TLS enforcement | SSL scan of all endpoints | Nmap/sslyze output | TLS 1.2+ only, no weak ciphers |
| Security group rules | Review all SGs for 0.0.0.0/0 | AWS Config report, SG export | No unrestricted inbound except 80/443 |
| WAF implementation | Test OWASP payloads against WAF | WAF log showing blocks | OWASP Top 10 payloads blocked |
| Network segmentation | Attempt cross-segment connection | Network diagram, firewall ruleset | Cross-segment access blocked per design |

### Application Security

| Control | ToI test | Evidence to request | Pass criteria |
|---|---|---|---|
| SAST in pipeline | Review pipeline config | GitHub Actions workflow, SAST report | SAST runs on every PR, blocks on High |
| Secret scanning | Check repo for secrets | Trufflehog/gitleaks output | No secrets found in codebase or history |
| Dependency scanning | Review Dependabot config | Dependabot alerts report | Critical CVEs alerted within 24h |
| SBOM generation | Verify SBOM in build output | SBOM file from recent build | SBOM present, complete, in SPDX/CycloneDX |

### Logging & Monitoring

| Control | ToI test | Evidence to request | Pass criteria |
|---|---|---|---|
| Centralised logging | Verify all sources sending logs | SIEM source inventory, log volume | 100% of defined sources active |
| Log retention | Check retention policy applied | Storage policy config, oldest log date | Logs retained per policy (e.g. 12 months) |
| Alert implementation | Trigger test alert — verify fires | SIEM alert config, test result | Alert fires within defined SLA |
| Audit logging | Perform sensitive action — verify logged | Audit log sample | All sensitive actions captured |

---

## ToI finding classifications

| Finding | Definition | Action |
|---|---|---|
| **Implementation Gap** | Control not implemented at all | Implement before next ToOE |
| **Implementation Deficiency** | Control implemented but incorrectly | Remediate and re-test |
| **Scope Gap** | Control implemented but not across full population | Extend to full scope |
| **Implementation Observation** | Minor improvement opportunity | Recommendation |
| **Implementation Pass** | Control correctly implemented | Proceed to ToOE |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/advisory-assurance/"><span class="ref-label">Assurance</span>Advisory & Assurance Overview</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design (ToD)</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
