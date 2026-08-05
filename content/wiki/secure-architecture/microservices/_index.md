---
title: "Microservices Security"
date: 2026-08-05
tags: ["microservices", "mTLS", "service-mesh", "zero-trust", "architecture"]
categories: ["architecture"]
description: "Security patterns for microservices architectures — service identity, mTLS, zero trust between services, service mesh, and lateral movement prevention."
showToc: true
layout: "single"
---

## The microservices security problem

In a monolith, a function call stays inside a process — it cannot be intercepted, spoofed, or tampered with by an external attacker. In a microservices architecture, every function call becomes a network request. Each service-to-service call is a potential attack surface.

The core threats in microservices:

| Threat | STRIDE category | Example |
|---|---|---|
| Service A impersonating Service B | Spoofing | Attacker spins up rogue service claiming to be payment service |
| MITM between services | Tampering, Info Disclosure | Attacker intercepts internal API calls |
| Compromised service pivoting | Lateral movement | Attacker in one pod reaches all other services |
| Missing auth on internal APIs | Elevation of Privilege | Internal endpoint assumed safe, no auth check |
| Overprivileged service | Elevation of Privilege | Order service can access user credentials |

---

## Pattern 1 — Service identity with mTLS

Every service must have a cryptographic identity. Mutual TLS (mTLS) means both the client and server present certificates — so each service proves who it is before communication is allowed.

```
Service A                              Service B
    |                                      |
    |--- presents client cert ------------>|
    |<-- presents server cert -------------|
    |--- TLS handshake complete ---------->|
    |=== encrypted, authenticated channel =|
```

**Without mTLS:** Any process on the internal network can call any service. One compromised container can reach everything.

**With mTLS:** A compromised container can only call services its certificate is authorised to reach.

### Implementing mTLS with cert-manager (Kubernetes)

```yaml
# cert-manager CertificateRequest for a service
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: payment-service-cert
  namespace: production
spec:
  secretName: payment-service-tls
  duration: 24h        # short-lived — rotate frequently
  renewBefore: 8h
  subject:
    organizations:
      - "mycompany"
  commonName: "payment-service.production.svc.cluster.local"
  dnsNames:
    - "payment-service"
    - "payment-service.production"
    - "payment-service.production.svc.cluster.local"
  issuerRef:
    name: internal-ca
    kind: ClusterIssuer
```

### Implementing mTLS with Istio service mesh

```yaml
# Enforce strict mTLS across the entire mesh
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system    # applies mesh-wide
spec:
  mtls:
    mode: STRICT             # reject all non-mTLS traffic
```

```yaml
# Allow specific service-to-service calls only
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: payment-service-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: payment-service
  action: ALLOW
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/production/sa/order-service"
              - "cluster.local/ns/production/sa/billing-service"
      to:
        - operation:
            methods: ["POST"]
            paths: ["/v1/payments/*"]
```

---

## Pattern 2 — Zero trust between services

Every service-to-service call must be:
- **Authenticated** — who is calling?
- **Authorised** — are they allowed to call this endpoint?
- **Encrypted** — is the call protected in transit?

Never assume a call is safe because it comes from inside the cluster.

```
# WRONG — trusting internal network
if (request.source_ip in INTERNAL_NETWORK):
    # skip auth check — it's internal
    process_request()

# RIGHT — verify every request regardless of source
token = request.headers.get("Authorization")
service_identity = verify_jwt(token, expected_issuer="spiffe://cluster.local")
if not authorize(service_identity, request.method, request.path):
    return 403
process_request()
```

### SPIFFE / SPIRE — workload identity standard

SPIFFE (Secure Production Identity Framework for Everyone) provides a standard for workload identity in distributed systems. Each workload gets a SPIFFE ID:

```
spiffe://trust-domain/ns/production/sa/payment-service
```

SPIRE (SPIFFE Runtime Environment) issues short-lived X.509 SVIDs (SPIFFE Verifiable Identity Documents) that services use to authenticate each other — no long-lived secrets.

```bash
# Install SPIRE server and agent
kubectl apply -f https://spiffe.github.io/spire/releases/latest/spire.yaml

# Verify a workload's SVID
spire-server entry show -spiffeID spiffe://example.org/ns/production/sa/payment-service
```

---

## Pattern 3 — Service mesh for security

A service mesh (Istio, Linkerd, Consul Connect) handles mTLS, authorisation policy, and observability transparently — without changing application code. The sidecar proxy intercepts all traffic.

```
Pod: Payment Service
┌─────────────────────────────────┐
│  ┌────────────────────┐         │
│  │  payment-service   │         │
│  │  (your app code)   │         │
│  └────────┬───────────┘         │
│           │ localhost:8080       │
│  ┌────────▼───────────┐         │
│  │   Envoy sidecar    │◄────────┼── all inbound/outbound
│  │   (mTLS, authz,    │         │   traffic intercepted
│  │    observability)  │─────────┼── here
│  └────────────────────┘         │
└─────────────────────────────────┘
```

**Linkerd (simpler, lower overhead):**

```bash
# Install Linkerd
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -

# Inject sidecar into a namespace
kubectl annotate namespace production \
  linkerd.io/inject=enabled

# Verify mTLS is active
linkerd viz stat deploy -n production
```

---

## Pattern 4 — API gateway for north-south traffic

All external traffic enters through a single API gateway. Services never expose ports directly to the internet.

```
Internet
    |
    ▼
[API Gateway / Ingress]
    |  - TLS termination
    |  - Authentication (JWT validation)
    |  - Rate limiting
    |  - WAF rules
    |  - Request routing
    ▼
[Internal service mesh — mTLS]
    ├── Auth Service
    ├── Order Service
    └── Payment Service
```

---

## Pattern 5 — Least privilege service accounts

Each service runs with a dedicated service account that has only the permissions it needs.

```yaml
# Kubernetes ServiceAccount per service
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payment-service
  namespace: production
  annotations:
    # AWS IRSA — bind to IAM role with least privilege
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/payment-service-role
---
# The IAM role only allows payment-service to access its own secrets
# and its own S3 bucket — nothing else
```

---

## Threat model for microservices

Apply STRIDE to each service boundary:

```
For every service-to-service API call, ask:

S — Can an attacker spoof the calling service?
    Mitigation: mTLS with SPIFFE identity

T — Can the request be tampered with in transit?
    Mitigation: TLS encryption, request signing

R — Can the calling service deny making the call?
    Mitigation: structured access logs with service identity

I — Can the data in the response be intercepted?
    Mitigation: TLS, minimal data returned per response

D — Can the called service be overwhelmed?
    Mitigation: circuit breakers, rate limiting, timeouts

E — Can the calling service access endpoints it should not?
    Mitigation: authorisation policy per endpoint per service identity
```

---

## Security checklist for microservices

```
Design
□ Every service has a defined threat model
□ Service-to-service communication diagram drawn
□ Trust boundaries documented
□ Data classification per service defined

Implementation
□ mTLS enforced between all services (STRICT mode)
□ Each service has a dedicated service account
□ AuthZ policy defined per endpoint per caller
□ No hardcoded credentials in service code
□ Health check endpoints do not expose sensitive data
□ Error responses do not leak internal details

Operations
□ Certificate rotation automated (< 24h TTL)
□ Service mesh telemetry monitored for anomalies
□ Unauthorised call attempts alerted on
□ Quarterly service permission review conducted
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/secure-architecture/api-security/"><span class="ref-label">Architecture</span>API Security Design</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/secure-architecture/kubernetes-security/"><span class="ref-label">Architecture</span>Kubernetes Security</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE Reference</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
</div>

</div>
