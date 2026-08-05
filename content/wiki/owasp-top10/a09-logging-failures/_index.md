---
title: "A09 — Security Logging and Monitoring Failures"
date: 2026-08-05
tags: ["OWASP", "logging", "monitoring", "SIEM", "incident-response", "audit-trail"]
categories: ["owasp"]
description: "OWASP A09 Security Logging and Monitoring Failures — missing audit logs, no alerting, insufficient monitoring. What to log, how to protect logs, and detection engineering."
showToc: true
layout: "single"
---

## Overview

Without logging and monitoring, breaches cannot be detected. The average time to detect a breach is 207 days (IBM Cost of a Data Breach 2023). Attackers rely on the lack of monitoring to maintain persistence undetected. A09 covers insufficient logging, missing alerting, and logs that are not monitored.

| Attribute | Detail |
|---|---|
| OWASP rank | #9 (2021) — previously #10 |
| STRIDE mapping | **Repudiation** |
| CWEs mapped | 4 (CWE-117, CWE-223, CWE-532, CWE-778) |
| Key metric | Average breach detection time without good monitoring: 207 days |

---

## What must be logged

```python
import logging
import json
from datetime import datetime, timezone
from uuid import uuid4

# Structured logging — machine-parseable, SIEM-ready
class SecurityLogger:
    def __init__(self):
        self.logger = logging.getLogger("security")
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter("%(message)s"))
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)

    def log(self, event_type: str, **kwargs):
        record = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "event_id": str(uuid4()),
            "event_type": event_type,
            **kwargs
        }
        # Never log: passwords, tokens, card numbers, SSNs
        self.logger.info(json.dumps(record))

security_log = SecurityLogger()

# Authentication events
security_log.log("auth.login.success", user_id=123, ip="1.2.3.4", mfa_used=True)
security_log.log("auth.login.failure", username="admin", ip="1.2.3.4", reason="bad_password")
security_log.log("auth.login.locked", username="admin", ip="1.2.3.4", attempt_count=5)
security_log.log("auth.logout", user_id=123, session_id="abc123")
security_log.log("auth.password_reset.requested", email_hash="sha256:...", ip="1.2.3.4")
security_log.log("auth.mfa.failure", user_id=123, ip="1.2.3.4")

# Authorisation events
security_log.log("authz.denied", user_id=123, resource="/admin/users", action="GET", ip="1.2.3.4")
security_log.log("authz.idor_attempt", user_id=123, requested_resource_id=456, ip="1.2.3.4")

# Data access events
security_log.log("data.export", user_id=123, resource_type="customer_records", count=10000)
security_log.log("data.sensitive_access", user_id=123, data_type="payment_info", record_id=789)

# Admin actions
security_log.log("admin.user_created", admin_id=1, new_user_id=456, role="admin")
security_log.log("admin.permission_changed", admin_id=1, user_id=456, old_role="user", new_role="admin")
security_log.log("admin.config_changed", admin_id=1, setting="mfa_required", old=False, new=True)
```

### What NOT to log

```python
# NEVER log these — they become a data breach if logs are exposed
BAD_EXAMPLES = {
    "password": "P@ssw0rd123",          # NEVER
    "credit_card": "4111111111111111",  # NEVER
    "cvv": "123",                       # NEVER
    "ssn": "123-45-6789",              # NEVER
    "token": "Bearer eyJhbGci...",      # NEVER — log token_hash instead
    "api_key": "sk_live_abc123",        # NEVER
}

# Safe alternatives
GOOD_EXAMPLES = {
    "password_length": 12,              # length only
    "card_last4": "1111",               # last 4 only
    "token_hash": "sha256:d14a...",     # hash, never the token
    "user_id": 123,                     # ID, not PII
}
```

---

## Log protection — tamper-evident storage

```python
import hashlib
import hmac

SECRET = b"log-signing-key-from-secrets-manager"

def create_tamper_evident_log(entry: dict) -> dict:
    """Chain log entries — detect deletion or modification"""
    entry_json = json.dumps(entry, sort_keys=True).encode()
    entry["hash"] = hashlib.sha256(entry_json).hexdigest()
    entry["signature"] = hmac.new(SECRET, entry_json, hashlib.sha256).hexdigest()
    return entry

# Ship logs to immutable storage immediately
# Never allow logs to be deleted or modified by application accounts
# Log to separate system (SIEM) that application cannot write to or delete from
```

---

## Detection rules — SIEM alerts

```yaml
# Sigma rules for security events

- title: Brute Force Attack Detected
  description: Multiple failed logins from single IP
  detection:
    selection:
      event_type: "auth.login.failure"
    timeframe: 5m
    condition: selection | count(ip) by ip > 10
  level: high

- title: Privilege Escalation Detected
  description: User role changed to admin
  detection:
    selection:
      event_type: "admin.permission_changed"
      new_role: "admin"
  level: critical

- title: Bulk Data Export
  description: Large number of records exported
  detection:
    selection:
      event_type: "data.export"
      count|gte: 1000
  level: high

- title: IDOR Attempt
  description: User attempted to access another user's resource
  detection:
    selection:
      event_type: "authz.idor_attempt"
  timeframe: 1h
  condition: selection | count(user_id) by user_id > 3
  level: medium

- title: After-Hours Admin Action
  description: Admin action outside business hours
  detection:
    selection:
      event_type|startswith: "admin."
    filter:
      timestamp|timeframe: "08:00-18:00"
  level: medium
```

---

## Detection & testing

```bash
# Test what gets logged
# Attempt login with wrong password — does it log?
curl -X POST https://target.example.com/login \
  -d "username=admin&password=wrongpassword"

# Check auth failure appears in logs within 5 seconds
# Check SIEM alert fires within 10 minutes for 5 failures

# Check access denied is logged
curl -H "Authorization: Bearer REGULAR_USER_TOKEN" \
  https://target.example.com/admin/users
# Expect: 403 response + log entry within 5 seconds

# Verify logs cannot be tampered with
# Attempt to delete a log entry — should fail
# Verify log integrity check detects any gap or modification
```

---

## Prevention checklist

```
Authentication
□ All login success and failure events logged
□ Account lockouts logged with user + IP
□ Password reset requests logged
□ MFA failures logged and alerted after 3 failures

Authorisation
□ All access denied events logged
□ Admin actions logged with before/after values
□ Bulk data access logged and alerted

Log quality
□ Logs are structured (JSON) — not free-text
□ Every log entry has: timestamp, event type, user ID, IP, result
□ Sensitive data (passwords, tokens, PII) never logged
□ Log entries include correlation ID to link related events

Log protection
□ Logs shipped to immutable SIEM — application cannot delete
□ Log retention: minimum 12 months online, 7 years archived
□ Log access restricted — developers cannot access production logs without approval

Alerting
□ Failed authentication > 5/minute: alert
□ Privilege escalation: alert immediately
□ Bulk data export: alert
□ Admin action outside business hours: alert
□ SIEM alert response SLA: critical < 15 min, high < 1 hour
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming — detection validation</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Repudiation</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — MON domain</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
</div>

</div>
