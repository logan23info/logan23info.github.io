---
title: "API Security Design"
date: 2026-08-05
tags: ["API", "REST", "GraphQL", "authentication", "authorisation", "rate-limiting", "architecture"]
categories: ["architecture"]
description: "Complete guide to secure API design — authentication, authorisation, input validation, rate limiting, API gateways, and the OWASP API Security Top 10."
showToc: true
---

## Why API security is different

APIs are the attack surface of modern applications. Unlike web pages (which humans browse), APIs are called by code — at machine speed, at scale, from anywhere. An attacker who finds a vulnerability can exploit it thousands of times per second with a script.

The OWASP API Security Top 10 (2023) lists the most common API vulnerabilities:

| Rank | Vulnerability | Description |
|---|---|---|
| API1 | Broken Object Level Authorisation (BOLA) | Accessing other users' objects by changing IDs |
| API2 | Broken Authentication | Weak tokens, no expiry, missing validation |
| API3 | Broken Object Property Level Auth | Reading/writing fields you shouldn't access |
| API4 | Unrestricted Resource Consumption | No rate limiting — DoS via resource exhaustion |
| API5 | Broken Function Level Authorisation | Calling admin functions as a regular user |
| API6 | Unrestricted Access to Sensitive Business Flows | Automating flows meant to be human-only |
| API7 | Server Side Request Forgery (SSRF) | API fetches attacker-controlled URLs |
| API8 | Security Misconfiguration | Debug endpoints, verbose errors, open CORS |
| API9 | Improper Inventory Management | Undocumented / shadow APIs |
| API10 | Unsafe Consumption of APIs | Trusting third-party API responses without validation |

---

## Pattern 1 — Authentication

Every API request must prove who is making it.

### JWT (JSON Web Tokens) — best practices

```python
import jwt
from datetime import datetime, timedelta, timezone

SECRET_KEY = "loaded-from-secrets-manager"  # never hardcoded
ALGORITHM  = "RS256"   # asymmetric — NEVER HS256 in production
                       # NEVER allow 'none' algorithm

def create_token(user_id: str, roles: list[str]) -> str:
    payload = {
        "sub": user_id,           # subject
        "roles": roles,
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + timedelta(minutes=15),  # short TTL
        "jti": generate_uuid(),   # unique token ID — enables revocation
        "iss": "https://auth.example.com",
        "aud": "https://api.example.com",
    }
    return jwt.encode(payload, PRIVATE_KEY, algorithm=ALGORITHM)

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token,
            PUBLIC_KEY,
            algorithms=["RS256"],  # whitelist — NEVER algorithms=["RS256", "none"]
            audience="https://api.example.com",
            issuer="https://auth.example.com",
        )
        if is_revoked(payload["jti"]):
            raise jwt.InvalidTokenError("Token revoked")
        return payload
    except jwt.ExpiredSignatureError:
        raise AuthError("Token expired")
    except jwt.InvalidTokenError as e:
        raise AuthError(f"Invalid token: {e}")
```

### API Keys — for machine-to-machine

```python
import secrets
import hashlib

def generate_api_key() -> tuple[str, str]:
    """Returns (raw_key_for_client, hashed_key_for_storage)"""
    raw_key = f"sk_{secrets.token_urlsafe(32)}"
    hashed  = hashlib.sha256(raw_key.encode()).hexdigest()
    return raw_key, hashed

# Store only the hash — never the raw key
# On each request: hash the incoming key, compare to stored hash
def verify_api_key(incoming_key: str, stored_hash: str) -> bool:
    incoming_hash = hashlib.sha256(incoming_key.encode()).hexdigest()
    return secrets.compare_digest(incoming_hash, stored_hash)  # constant-time
```

### OAuth 2.0 / OIDC — for delegated access

```
Client           Auth Server        Resource Server
  |                   |                    |
  |-- auth request -->|                    |
  |<-- auth code -----|                    |
  |-- code + secret ->|                    |
  |<-- access token --|                    |
  |                   |                    |
  |-- API call + Bearer token ------------>|
  |                   |<-- verify token ---|
  |                   |--- valid/invalid ->|
  |<-- API response ---------------------- |
```

Use **PKCE** (Proof Key for Code Exchange) for all public clients (SPAs, mobile apps):

```javascript
// Generate PKCE challenge
const codeVerifier  = generateRandomString(128);
const codeChallenge = base64url(sha256(codeVerifier));

// Include in auth request
const authUrl = `${AUTH_SERVER}/authorize?
  response_type=code
  &client_id=${CLIENT_ID}
  &redirect_uri=${REDIRECT_URI}
  &code_challenge=${codeChallenge}
  &code_challenge_method=S256
  &scope=openid profile`;
```

---

## Pattern 2 — Authorisation (BOLA / IDOR prevention)

BOLA (API1) is the most common API vulnerability. An attacker changes `user_id=123` to `user_id=124` and gets another user's data.

```python
# WRONG — trusting the ID in the request
@app.get("/orders/{order_id}")
def get_order(order_id: int):
    return db.query("SELECT * FROM orders WHERE id = ?", order_id)

# RIGHT — verify the requester owns the resource
@app.get("/orders/{order_id}")
def get_order(order_id: int, current_user: User = Depends(get_current_user)):
    order = db.query("SELECT * FROM orders WHERE id = ? AND user_id = ?",
                     order_id, current_user.id)
    if not order:
        raise HTTPException(status_code=404)  # 404, not 403 — don't confirm existence
    return order
```

### Attribute-Based Access Control (ABAC)

```python
def authorize(user: User, action: str, resource: Resource) -> bool:
    """
    Decision based on:
    - User attributes (role, department, clearance level)
    - Resource attributes (classification, owner, sensitivity)
    - Environment (time of day, IP, device compliance)
    - Action (read, write, delete, admin)
    """
    if user.role == "admin":
        return True
    if action == "read" and resource.owner_id == user.id:
        return True
    if action == "read" and resource.classification == "public":
        return True
    if user.department == resource.department and action in ["read", "comment"]:
        return True
    return False
```

---

## Pattern 3 — Input validation

Never trust input. Validate everything — type, format, length, range, and allowed values.

```python
from pydantic import BaseModel, validator, constr, conint
from typing import Literal

class CreateOrderRequest(BaseModel):
    product_id: int
    quantity:   conint(ge=1, le=100)        # 1–100 only
    note:       constr(max_length=500) = "" # max 500 chars
    priority:   Literal["standard", "express"]  # enum — no free text

    @validator("product_id")
    def product_must_exist(cls, v):
        if not db.product_exists(v):
            raise ValueError("Product not found")
        return v

# SQL — always parameterised, never f-strings
def get_user(user_id: int) -> User:
    # WRONG:
    # db.execute(f"SELECT * FROM users WHERE id = {user_id}")

    # RIGHT:
    return db.execute("SELECT * FROM users WHERE id = ?", (user_id,))
```

### Content-Type enforcement

```python
@app.post("/upload")
def upload_file(file: UploadFile):
    ALLOWED_TYPES = {"image/jpeg", "image/png", "application/pdf"}
    ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".pdf"}

    # Check Content-Type header
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(400, "Invalid file type")

    # Check actual file extension
    ext = Path(file.filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(400, "Invalid file extension")

    # Check magic bytes (actual file content) — not just the header
    header = await file.read(16)
    if not is_valid_magic_bytes(header, file.content_type):
        raise HTTPException(400, "File content does not match declared type")
```

---

## Pattern 4 — Rate limiting

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

# Different limits per endpoint sensitivity
@app.post("/auth/login")
@limiter.limit("10/minute")           # strict — auth endpoint
def login(request: Request): ...

@app.post("/auth/password-reset")
@limiter.limit("3/hour")              # very strict — abuse target
def password_reset(request: Request): ...

@app.get("/products")
@limiter.limit("100/minute")          # relaxed — public read
def list_products(request: Request): ...

@app.post("/orders")
@limiter.limit("20/minute")           # business logic limit
def create_order(request: Request): ...
```

**Rate limiting strategy — layer it:**

| Layer | Tool | Protects against |
|---|---|---|
| CDN / WAF | Cloudflare, AWS WAF | Volumetric DDoS, bot scraping |
| API Gateway | Kong, AWS API Gateway | Per-client rate limits |
| Application | slowapi, express-rate-limit | Business logic limits |
| Database | Connection pooling, query timeout | Resource exhaustion |

---

## Pattern 5 — API gateway security

```yaml
# Kong Gateway — declarative config
_format_version: "3.0"

services:
  - name: order-service
    url: http://order-service:8080

routes:
  - name: order-routes
    service: order-service
    paths: ["/v1/orders"]

plugins:
  - name: jwt                          # validate JWT on every request
    config:
      secret_is_base64: false
      claims_to_verify: [exp, nbf]

  - name: rate-limiting
    config:
      minute: 100
      hour: 2000
      policy: redis                    # shared state across gateway instances

  - name: request-size-limiting
    config:
      allowed_payload_size: 1          # 1 MB max — prevent DoS via large body

  - name: cors
    config:
      origins: ["https://app.example.com"]   # explicit allowlist — never "*"
      methods: [GET, POST, PUT, DELETE]
      headers: [Authorization, Content-Type]
      credentials: true

  - name: response-transformer
    config:
      remove:
        headers:                       # strip sensitive response headers
          - X-Powered-By
          - Server
          - X-AspNet-Version
```

---

## Pattern 6 — Security headers

Every API response must include these headers:

```python
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
    response.headers["X-Content-Type-Options"]    = "nosniff"
    response.headers["X-Frame-Options"]           = "DENY"
    response.headers["Cache-Control"]             = "no-store"
    response.headers["Content-Security-Policy"]   = "default-src 'none'"
    # Remove these:
    del response.headers["X-Powered-By"]          # do not reveal stack
    del response.headers["Server"]                # do not reveal server version
    return response
```

---

## API security checklist

```
Design
□ Every endpoint has defined authentication requirement
□ Every endpoint has defined authorisation requirement
□ BOLA checked for every resource-fetch endpoint
□ Input validation schema defined for every request body
□ Rate limits defined per endpoint per sensitivity

Implementation
□ JWT: RS256 algorithm, short TTL (15 min), aud/iss validated
□ API keys: hashed in storage, constant-time comparison
□ All SQL queries parameterised — no string concatenation
□ File uploads: type, extension, magic bytes validated
□ CORS: explicit origin allowlist, never wildcard
□ Security headers on all responses
□ No sensitive data in URL parameters (use body or headers)
□ Error messages: generic to client, detailed to logs only

Operations
□ API inventory maintained — no shadow/undocumented APIs
□ Rate limit breaches alerted
□ Unusual access patterns detected (UEBA)
□ API versions deprecated and removed on schedule
□ Pen test of API surface annually
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — API threat categories</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
