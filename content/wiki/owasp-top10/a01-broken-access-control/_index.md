---
title: "A01 — Broken Access Control"
date: 2026-08-05
tags: ["OWASP", "access-control", "IDOR", "BOLA", "authorisation", "EoP"]
categories: ["owasp"]
description: "OWASP A01 Broken Access Control — the #1 web application vulnerability. IDOR, privilege escalation, path traversal — with STRIDE mapping, code examples, and detection methods."
showToc: true
layout: "single"
---

## Overview

Broken Access Control moved from #5 to **#1** in the 2021 OWASP Top 10 — found in 94% of tested applications. It occurs when users can act outside their intended permissions: accessing other users' data, performing admin actions, or bypassing access restrictions entirely.

| Attribute | Detail |
|---|---|
| OWASP rank | #1 (2021) |
| STRIDE mapping | **Elevation of Privilege, Information Disclosure** |
| CWEs mapped | 34 (incl. CWE-200, CWE-201, CWE-352) |
| Prevalence | 94% of applications tested |
| Avg incidence rate | 3.81% |

---

## Attack patterns

### IDOR / BOLA (Broken Object Level Authorisation)
Attacker changes a resource ID in the URL to access another user's data.

### Privilege escalation
Regular user accesses admin functionality by modifying role parameters or JWT claims.

### Path traversal
Attacker reads files outside the intended directory using `../` sequences.

### CORS misconfiguration
Overly permissive CORS allows attacker-controlled sites to make authenticated requests.

### Force browsing
Attacker directly accesses URLs for authenticated pages without logging in.

---

## STRIDE mapping

| Threat | Mechanism | Example |
|---|---|---|
| **Elevation of Privilege** | Missing function-level auth check | `/admin/delete-user` accessible by regular user |
| **Information Disclosure** | IDOR exposes other users' data | `GET /api/orders/1234` returns any user's order |
| **Tampering** | Unauthorised write access | `PUT /api/users/456/role` sets attacker as admin |

---

## Vulnerable vs safe code

### IDOR — direct object reference

```python
# VULNERABLE — trusts the ID in the request
@app.get("/api/orders/{order_id}")
def get_order(order_id: int):
    order = db.query("SELECT * FROM orders WHERE id = ?", order_id)
    return order   # returns ANY user's order

# SAFE — verifies ownership
@app.get("/api/orders/{order_id}")
def get_order(order_id: int, current_user = Depends(get_current_user)):
    order = db.query(
        "SELECT * FROM orders WHERE id = ? AND user_id = ?",
        order_id, current_user.id
    )
    if not order:
        raise HTTPException(status_code=404)   # 404 not 403 — don't leak existence
    return order
```

### Missing function-level access control

```python
# VULNERABLE — no admin check
@app.delete("/admin/users/{user_id}")
def delete_user(user_id: int):
    db.execute("DELETE FROM users WHERE id = ?", user_id)
    return {"deleted": user_id}

# SAFE — explicit role check
@app.delete("/admin/users/{user_id}")
def delete_user(user_id: int, current_user = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    db.execute("DELETE FROM users WHERE id = ?", user_id)
    return {"deleted": user_id}
```

### Path traversal

```python
# VULNERABLE
@app.get("/files/{filename}")
def get_file(filename: str):
    path = f"/var/uploads/{filename}"      # ../../../etc/passwd works
    return open(path).read()

# SAFE
import os
from pathlib import Path

UPLOAD_DIR = Path("/var/uploads").resolve()

@app.get("/files/{filename}")
def get_file(filename: str):
    # Resolve and verify the path stays within UPLOAD_DIR
    requested = (UPLOAD_DIR / filename).resolve()
    if not str(requested).startswith(str(UPLOAD_DIR)):
        raise HTTPException(status_code=400, detail="Invalid path")
    if not requested.exists():
        raise HTTPException(status_code=404)
    return requested.read_text()
```

### JWT role manipulation

```python
# VULNERABLE — trusting role claim from token
@app.get("/admin/dashboard")
def admin_dashboard(token: str = Header()):
    payload = jwt.decode(token, SECRET, algorithms=["RS256"])
    if payload["role"] == "admin":     # attacker crafts token with role=admin
        return admin_data()

# SAFE — validate role from database, not token
@app.get("/admin/dashboard")
def admin_dashboard(current_user = Depends(get_current_user)):
    # get_current_user fetches role from DB, not from token payload
    db_user = db.get_user(current_user.id)
    if db_user.role != "admin":
        raise HTTPException(status_code=403)
    return admin_data()
```

---

## Detection & testing methods

### Manual testing
```bash
# 1. IDOR testing — change IDs
curl -H "Authorization: Bearer USER_A_TOKEN" \
  https://api.example.com/orders/USER_B_ORDER_ID

# 2. Privilege escalation — access admin endpoints as regular user
curl -H "Authorization: Bearer REGULAR_USER_TOKEN" \
  https://api.example.com/admin/users

# 3. HTTP method tampering
curl -X DELETE https://api.example.com/posts/123   # when only GET should work

# 4. Path traversal
curl "https://api.example.com/files/../../../../etc/passwd"
curl "https://api.example.com/files/%2e%2e%2f%2e%2e%2fetc%2fpasswd"

# 5. Force browsing
curl https://api.example.com/admin/dashboard   # without auth token
```

### Automated scanning
```bash
# OWASP ZAP — access control scan
zap-cli quick-scan --self-contained \
  --start-options "-config api.disablekey=true" \
  https://target.example.com

# Burp Suite — Autorize extension
# Intercept requests as admin, replay as regular user
# Flag responses where regular user gets admin data

# Nuclei — access control templates
nuclei -u https://target.example.com \
  -t vulnerabilities/generic/cors-misconfig.yaml \
  -t vulnerabilities/generic/path-traversal.yaml
```

### SAST rules (Semgrep)
```yaml
rules:
  - id: missing-auth-check
    patterns:
      - pattern: |
          @app.route(...)
          def $FUNC(...):
              ...
    pattern-not: |
          @app.route(...)
          @login_required
          def $FUNC(...):
              ...
    message: "Route $FUNC missing authentication decorator"
    severity: ERROR
```

---

## Prevention checklist

```
□ Deny access by default — whitelist what is allowed, not blacklist what is denied
□ Implement access control checks server-side for every request
□ Never trust client-supplied role or permission claims — validate from database
□ Use indirect object references (UUIDs or opaque tokens) instead of sequential IDs
□ Log all access control failures and alert on repeated failures
□ Rate-limit API access to minimise automated attack impact
□ Disable directory listing on web servers
□ CORS: explicitly allowlist trusted origins — never use wildcard (*)
□ Test access control as part of every feature — include negative test cases
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/owasp-top10/a07-auth-failures/"><span class="ref-label">OWASP</span>A07 Authentication Failures</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — EoP category</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
</div>

</div>
