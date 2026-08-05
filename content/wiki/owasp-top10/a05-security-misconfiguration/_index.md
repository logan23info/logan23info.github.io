---
title: "A05 — Security Misconfiguration"
date: 2026-08-05
tags: ["OWASP", "misconfiguration", "hardening", "default-credentials", "cloud-security"]
categories: ["owasp"]
description: "OWASP A05 Security Misconfiguration — default credentials, verbose errors, unnecessary features, cloud misconfigurations. Detection and hardening checklists."
showToc: true
layout: "single"
---

## Overview

Security misconfiguration is the most commonly seen issue. It results from insecure default configurations, incomplete setups, open cloud storage, misconfigured HTTP headers, or verbose error messages. Every layer of the stack can be misconfigured: network, OS, application server, database, framework, and cloud.

| Attribute | Detail |
|---|---|
| OWASP rank | #5 (2021) — up from #6 |
| STRIDE mapping | **Information Disclosure, Elevation of Privilege** |
| CWEs mapped | 20 (incl. CWE-16, CWE-611) |
| Common examples | Default admin:admin, S3 bucket public, debug mode in production, directory listing |

---

## Attack patterns

- **Default credentials** — admin/admin, root/root left unchanged
- **Unnecessary features** — unused ports, services, pages, accounts, or privileges enabled
- **Verbose error messages** — stack traces, SQL errors, file paths returned to users
- **Missing security headers** — no CSP, HSTS, X-Frame-Options
- **Cloud misconfigurations** — public S3 buckets, open security groups, no MFA on root
- **Directory listing** — web server shows directory contents
- **Debug mode in production** — `/debug`, `/actuator`, `DEBUG=True` in Flask

---

## STRIDE mapping

| Threat | Misconfiguration | Example |
|---|---|---|
| **Info Disclosure** | Verbose errors | Stack trace reveals database schema |
| **Info Disclosure** | Public cloud storage | S3 bucket with customer data world-readable |
| **Info Disclosure** | Directory listing | `/uploads/` shows all uploaded files |
| **EoP** | Default credentials | `admin:admin` on admin panel |
| **EoP** | Overprivileged cloud role | Lambda with `*` IAM permissions |

---

## Vulnerable vs safe configurations

### Flask debug mode

```python
# VULNERABLE — debug mode exposes interactive shell in browser
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")    # never in production

# SAFE — environment-controlled, debug off by default
import os
debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
# In production: FLASK_DEBUG is never set (defaults to false)
if __name__ == "__main__":
    app.run(debug=debug, host="127.0.0.1")  # also don't bind to 0.0.0.0
```

### Error handling — hide internal details

```python
# VULNERABLE — returns full stack trace to client
@app.get("/users/{user_id}")
def get_user(user_id: int):
    user = db.query(User).filter_by(id=user_id).first()
    # If DB is down: returns full SQLAlchemy traceback with connection string
    return user

# SAFE — generic error to client, full details to logs
import logging
import traceback

logger = logging.getLogger(__name__)

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    # Log full details server-side
    logger.error(f"Unhandled exception: {traceback.format_exc()}")
    # Return generic message to client
    return JSONResponse(
        status_code=500,
        content={"error": "An internal error occurred", "request_id": get_request_id()}
    )
```

### AWS S3 — prevent public access

```python
import boto3

s3 = boto3.client("s3")

# VULNERABLE — creating bucket without blocking public access
s3.create_bucket(Bucket="my-customer-data")
# Default: bucket is private but easy to accidentally make public

# SAFE — explicitly block all public access at creation
s3.create_bucket(Bucket="my-customer-data")
s3.put_public_access_block(
    Bucket="my-customer-data",
    PublicAccessBlockConfiguration={
        "BlockPublicAcls": True,
        "IgnorePublicAcls": True,
        "BlockPublicPolicy": True,
        "RestrictPublicBuckets": True,
    }
)
# Also enforce at account level via AWS Organizations SCP
```

### Security headers

```python
# Add all security headers to every response
@app.middleware("http")
async def security_headers(request, call_next):
    response = await call_next(request)
    headers = {
        "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Permissions-Policy": "geolocation=(), microphone=(), camera=()",
        "Content-Security-Policy": (
            "default-src 'self'; "
            "script-src 'self'; "
            "style-src 'self'; "
            "object-src 'none'; "
            "frame-ancestors 'none'"
        ),
        "Cache-Control": "no-store",        # for API responses
    }
    # Remove headers that reveal technology stack
    response.headers.pop("X-Powered-By", None)
    response.headers.pop("Server", None)
    for key, value in headers.items():
        response.headers[key] = value
    return response
```

---

## Cloud misconfiguration detection

```bash
# AWS — Prowler (comprehensive AWS security checks)
prowler aws --compliance cis_aws_2.0

# AWS — ScoutSuite
scout aws --report-dir ./scout-results

# GCP — ScoutSuite
scout gcp --report-dir ./scout-results

# Terraform/OpenTofu — Checkov
checkov -d infra/ --framework terraform

# Kubernetes — kube-bench (CIS benchmark)
kube-bench run --targets master,node,etcd

# Docker — Docker Bench Security
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /etc:/etc:ro -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro -v /run/containerd:/run/containerd:ro \
  -v /var/lib:/var/lib:ro -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --label docker_bench_security \
  docker/docker-bench-security
```

---

## Prevention checklist

```
Application
□ Turn off all debug features in production (DEBUG=False, no stack traces to clients)
□ Remove or disable all unused features, endpoints, and sample applications
□ Change all default credentials immediately after install
□ Generic error messages to clients — full details only in server-side logs
□ Security headers on every response (HSTS, CSP, X-Frame-Options)
□ Directory listing disabled on web servers

Cloud
□ Public access blocked on all storage buckets (S3, GCS, Azure Blob)
□ No security group with 0.0.0.0/0 inbound on sensitive ports
□ MFA enforced on root/admin cloud accounts
□ All unused IAM users, roles, and access keys removed
□ CloudTrail/Cloud Audit Logs enabled across all regions

Infrastructure
□ Unnecessary ports closed (firewall default-deny)
□ Services running as non-root, non-privileged users
□ OS and software patched and up to date
□ CIS benchmark run quarterly (kube-bench, Prowler, Docker Bench)

Process
□ Security configuration checklist in deployment runbook
□ IaC scanned with Checkov/tfsec before every apply
□ Configuration drift detected via AWS Config or equivalent
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/kubernetes-security/"><span class="ref-label">Architecture</span>Kubernetes Security</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
