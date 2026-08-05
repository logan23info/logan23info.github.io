---
title: "Container Security"
date: 2026-08-05
tags: ["containers", "Docker", "image-scanning", "runtime-security", "supply-chain", "architecture"]
categories: ["architecture"]
description: "Complete guide to container security — secure Dockerfile practices, image scanning, runtime security, least privilege, and supply chain integrity."
showToc: true
---

## Container attack surface

Containers share the host kernel. A misconfigured container can compromise the host. The attack surface includes:

| Layer | Attack surface | Example threat |
|---|---|---|
| Base image | Vulnerable OS packages | CVE in base Ubuntu layer |
| Application dependencies | Known CVEs in libraries | Log4Shell in a JAR |
| Dockerfile instructions | Hardcoded secrets, root execution | `ENV PASSWORD=secret` |
| Container runtime | Escape vulnerabilities | runc CVE-2019-5736 |
| Registry | Supply chain tampering | Malicious image push |
| Orchestration | Misconfigured permissions | Privileged pod |

---

## Pattern 1 — Secure Dockerfile

```dockerfile
# WRONG — common insecure patterns
FROM ubuntu:latest           # mutable tag — gets different images over time
RUN apt-get install -y curl  # installs unnecessary tools
ENV DB_PASSWORD=secret123    # hardcoded secret in image layer
USER root                    # runs as root
COPY . .                     # copies everything including .git, secrets
RUN chmod 777 /app           # overly permissive

# RIGHT — secure Dockerfile
# Pin to specific digest — immutable reference
FROM python:3.12-slim@sha256:a1b2c3d4...

# Set working directory explicitly
WORKDIR /app

# Install dependencies first (layer caching + minimal attack surface)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir safety \
    && safety check \                           # scan deps during build
    && pip uninstall -y safety                  # remove scan tool from final image

# Copy only what's needed — use .dockerignore
COPY src/ ./src/
COPY config/ ./config/

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser \
    && chown -R appuser:appuser /app

# Drop to non-root
USER appuser

# Declare listening port
EXPOSE 8080

# Use exec form — not shell form
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

```
# .dockerignore — prevent sensitive files entering image
.git
.gitignore
*.md
.env
.env.*
**/*.pem
**/*.key
**/secrets/
node_modules/
__pycache__/
.pytest_cache/
coverage/
*.log
Dockerfile*
docker-compose*
```

---

## Pattern 2 — Minimal base images

| Base image | Size | Attack surface | Use for |
|---|---|---|---|
| `scratch` | 0 MB | Zero | Static Go/Rust binaries only |
| `distroless/static` | ~2 MB | Minimal | Static binaries |
| `distroless/base` | ~20 MB | Very low | Dynamic binaries, no shell |
| `alpine:3.19` | ~7 MB | Low | General purpose, musl libc |
| `python:3.12-slim` | ~130 MB | Medium | Python apps |
| `ubuntu:22.04` | ~78 MB | High | Avoid in production |
| `ubuntu:latest` | Unpinned | Variable | Never use |

### Multi-stage builds — keep build tools out of production

```dockerfile
# Stage 1: Build
FROM golang:1.22 AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server ./cmd/server

# Stage 2: Production — distroless, no shell, no package manager
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/server /server
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]
# Final image: ~5MB, zero attack surface, no shell for attacker to use
```

---

## Pattern 3 — Image scanning

Scan at every stage — build, push, and deploy:

```yaml
# GitHub Actions — scan on every push
name: Container security scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: 1          # fail build on Critical or High CVE

      - name: Upload scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif
```

```bash
# Trivy — scan locally
trivy image --severity CRITICAL,HIGH myapp:latest

# Grype — alternative scanner
grype myapp:latest --fail-on high

# Dockerfile best practice linting
hadolint Dockerfile

# Check image for secrets
docker save myapp:latest | trivy fs --input /dev/stdin --scanners secret
```

---

## Pattern 4 — Runtime security

Scanning only catches known CVEs. Runtime security detects malicious behaviour:

```yaml
# Falco rules — detect suspicious container activity
- rule: Shell in container
  desc: Alert when a shell is spawned in a container
  condition: >
    spawned_process
    and container
    and (proc.name in (bash, sh, zsh, ksh, ash))
    and not user_known_shell_container_processes
  output: >
    Shell spawned in container
    (user=%user.name container=%container.name
     image=%container.image.repository:%container.image.tag
     shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline)
  priority: WARNING

- rule: Write to sensitive directory
  desc: Alert on writes to /etc, /bin, /sbin, /usr/bin, /usr/sbin
  condition: >
    open_write
    and container
    and (fd.name startswith /etc or fd.name startswith /bin
         or fd.name startswith /sbin or fd.name startswith /usr/bin)
  output: >
    Write to sensitive directory in container
    (file=%fd.name container=%container.name
     image=%container.image.repository)
  priority: ERROR

- rule: Outbound connection to unexpected destination
  desc: Container making unexpected outbound connection
  condition: >
    outbound
    and container
    and not (fd.sip in (trusted_ip_ranges))
  output: >
    Unexpected outbound connection from container
    (image=%container.image.repository
     connection=%fd.name)
  priority: WARNING
```

---

## Pattern 5 — Container least privilege

```yaml
# Kubernetes pod spec — hardened
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true           # enforce non-root at pod level
    runAsUser: 10001
    runAsGroup: 10001
    fsGroup: 10001
    seccompProfile:
      type: RuntimeDefault       # restrict syscalls

  containers:
    - name: app
      image: myapp:latest@sha256:abc123   # pin to digest
      securityContext:
        allowPrivilegeEscalation: false   # prevent sudo, setuid
        readOnlyRootFilesystem: true      # immutable filesystem
        capabilities:
          drop: ["ALL"]                   # drop ALL Linux capabilities
          add: []                         # add back only what's needed
        runAsNonRoot: true
        runAsUser: 10001

      resources:
        limits:
          memory: "256Mi"        # prevent memory exhaustion
          cpu: "500m"
        requests:
          memory: "128Mi"
          cpu: "100m"

      volumeMounts:
        - name: tmp             # writable temp space (readOnlyRootFilesystem workaround)
          mountPath: /tmp

  volumes:
    - name: tmp
      emptyDir: {}

  automountServiceAccountToken: false   # only mount if needed
```

---

## Pattern 6 — Image signing and verification

```bash
# Sign image with Cosign (Sigstore)
cosign sign --yes \
  --key cosign.key \
  myregistry.io/myapp:latest

# Verify before deployment
cosign verify \
  --key cosign.pub \
  myregistry.io/myapp:latest

# Keyless signing with GitHub Actions OIDC (no keys to manage)
- name: Sign image
  uses: sigstore/cosign-installer@v3
  
- name: Sign
  run: |
    cosign sign --yes \
      myregistry.io/myapp:${{ github.sha }}
  env:
    COSIGN_EXPERIMENTAL: "true"
```

---

## Container security checklist

```
Build
□ Base image pinned to SHA digest (not mutable tag)
□ Minimal base image (distroless or slim)
□ Multi-stage build — no build tools in production image
□ Non-root user created and used
□ No secrets in ENV, ARG, or image layers
□ .dockerignore prevents sensitive files entering image
□ Image scanned for CVEs before push (Trivy/Grype)
□ Dockerfile linted (Hadolint)

Registry
□ Image signed with Cosign/Notary
□ Registry access requires authentication
□ Push access restricted to CI/CD pipeline only
□ Image retention policy set (clean up old images)

Runtime
□ readOnlyRootFilesystem: true
□ allowPrivilegeEscalation: false
□ ALL capabilities dropped
□ runAsNonRoot enforced
□ Resource limits set (CPU + memory)
□ seccompProfile: RuntimeDefault
□ Runtime security monitoring active (Falco)
□ Signature verified before deployment
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/secure-architecture/kubernetes-security/"><span class="ref-label">Architecture</span>Kubernetes Security Hardening</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/advisory-assurance/toi/"><span class="ref-label">Assurance</span>Test of Implementation</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
</div>

</div>
