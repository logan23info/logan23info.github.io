---
title: "Secrets Management"
date: 2026-08-05
tags: ["secrets", "vault", "AWS-Secrets-Manager", "credentials", "rotation", "architecture"]
categories: ["architecture"]
description: "Complete guide to secrets management — avoiding hardcoded secrets, Vault, AWS Secrets Manager, secret injection patterns, rotation, and detection."
showToc: true
layout: "single"
---

## The secrets problem

A secret is any value that grants access to a system — passwords, API keys, database credentials, TLS private keys, tokens, certificates. Secrets are everywhere in modern applications and they are consistently one of the most exploited attack surfaces.

**Why secrets leak:**
- Hardcoded in source code — committed to Git
- In environment variables — visible in process listings, CI logs
- In configuration files — checked into version control
- In container images — baked into layers
- In CI/CD logs — printed by debug statements
- In application logs — accidentally logged

**The cost:** The 2020 SolarWinds breach started with a hardcoded credential. The 2022 Samsung breach exposed 190GB of source code including secret keys. Credential exposure is consistently in the top 3 initial access vectors in breach reports.

---

## Pattern 1 — Never hardcode secrets

```python
# WRONG — all of these
DATABASE_URL = "postgresql://admin:P@ssw0rd@prod-db.example.com/app"
API_KEY = "sk_live_abc123def456"
AWS_SECRET = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# WRONG — environment variables are better but not sufficient for production
import os
DATABASE_URL = os.environ["DATABASE_URL"]  # still appears in process env, CI logs

# RIGHT — fetch from secrets manager at runtime
import boto3

def get_secret(secret_name: str) -> str:
    client = boto3.client("secretsmanager", region_name="us-east-1")
    response = client.get_secret_value(SecretId=secret_name)
    return response["SecretString"]

DATABASE_URL = get_secret("prod/app/database-url")
```

---

## Pattern 2 — HashiCorp Vault

Vault is the most widely used open-source secrets manager. It provides dynamic secrets, automatic rotation, fine-grained access control, and a full audit log.

### Core concepts

| Concept | Description |
|---|---|
| **Secret engine** | Plugin that manages a type of secret (KV, database, AWS, PKI) |
| **Auth method** | How a client proves its identity (Kubernetes, AWS IAM, OIDC) |
| **Policy** | What secrets a client can access after authentication |
| **Lease** | Time-limited access to a dynamic secret |
| **Audit log** | Immutable record of every secret access |

### Setting up Vault with Kubernetes auth

```bash
# Install Vault via Helm
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault \
  --set "server.ha.enabled=true" \
  --set "server.ha.replicas=3"

# Enable Kubernetes auth
vault auth enable kubernetes

vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Create a policy for the payment service
vault policy write payment-service - <<EOF
path "secret/data/production/payment/*" {
  capabilities = ["read"]
}
path "database/creds/payment-db-role" {
  capabilities = ["read"]
}
EOF

# Bind the policy to the Kubernetes service account
vault write auth/kubernetes/role/payment-service \
  bound_service_account_names=payment-service \
  bound_service_account_namespaces=production \
  policies=payment-service \
  ttl=1h
```

### Dynamic database credentials

Instead of a static password, Vault generates a short-lived, unique credential per request:

```bash
# Enable database secrets engine
vault secrets enable database

# Configure for PostgreSQL
vault write database/config/payment-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles="payment-db-role" \
  connection_url="postgresql://{{username}}:{{password}}@db.example.com/payments" \
  username="vault-admin" \
  password="from-bootstrap-only"

# Create role with 1-hour TTL
vault write database/roles/payment-db-role \
  db_name=payment-db \
  creation_statements="CREATE ROLE '{{name}}' WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, INSERT ON payments TO '{{name}}';" \
  default_ttl="1h" \
  max_ttl="4h"
```

Now each service gets a unique DB user/password that expires automatically. If credentials leak, they are already expired within an hour.

### Reading secrets in application code

```python
import hvac

def get_vault_client() -> hvac.Client:
    client = hvac.Client(url="https://vault.example.com")
    # Authenticate using Kubernetes service account token
    with open("/var/run/secrets/kubernetes.io/serviceaccount/token") as f:
        jwt_token = f.read()
    client.auth.kubernetes.login(
        role="payment-service",
        jwt=jwt_token,
    )
    return client

def get_db_credentials() -> tuple[str, str]:
    client = get_vault_client()
    creds = client.secrets.database.generate_credentials(name="payment-db-role")
    return creds["data"]["username"], creds["data"]["password"]
```

---

## Pattern 3 — AWS Secrets Manager

For AWS-native workloads, Secrets Manager integrates with IAM and provides automatic rotation.

```python
import boto3
import json
from functools import lru_cache

@lru_cache(maxsize=None)
def get_secret(secret_name: str) -> dict:
    """Cache in memory — do not call Secrets Manager on every request"""
    client = boto3.client("secretsmanager", region_name="us-east-1")
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response["SecretString"])

# Use the secret
db_config = get_secret("prod/payment-service/database")
conn = psycopg2.connect(
    host=db_config["host"],
    user=db_config["username"],
    password=db_config["password"],
    dbname=db_config["dbname"],
)
```

### Automatic rotation

```python
# Lambda function for secret rotation
def lambda_handler(event, context):
    arn    = event["SecretId"]
    token  = event["ClientRequestToken"]
    step   = event["Step"]

    client = boto3.client("secretsmanager")

    if step == "createSecret":
        # Generate new credentials
        new_password = generate_password()
        client.put_secret_value(
            SecretId=arn,
            ClientRequestToken=token,
            SecretString=json.dumps({"password": new_password}),
            VersionStages=["AWSPENDING"],
        )

    elif step == "setSecret":
        # Apply new credentials to the target system
        pending = client.get_secret_value(
            SecretId=arn, VersionStage="AWSPENDING"
        )
        update_database_password(json.loads(pending["SecretString"])["password"])

    elif step == "testSecret":
        # Verify the new credentials work
        pending = client.get_secret_value(
            SecretId=arn, VersionStage="AWSPENDING"
        )
        test_database_connection(json.loads(pending["SecretString"])["password"])

    elif step == "finishSecret":
        # Promote AWSPENDING to AWSCURRENT
        client.update_secret_version_stage(
            SecretId=arn,
            VersionStage="AWSCURRENT",
            MoveToVersionId=token,
        )
```

---

## Pattern 4 — Secret injection patterns

### Vault Agent Sidecar (Kubernetes)

Vault Agent runs as a sidecar, fetches secrets, and writes them to a shared volume — no Vault SDK in application code:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "payment-service"
        vault.hashicorp.com/agent-inject-secret-config: "secret/data/production/payment/config"
        vault.hashicorp.com/agent-inject-template-config: |
          {{- with secret "secret/data/production/payment/config" -}}
          DATABASE_URL={{ .Data.data.database_url }}
          API_KEY={{ .Data.data.api_key }}
          {{- end }}
    spec:
      serviceAccountName: payment-service
      containers:
        - name: payment-service
          image: mycompany/payment-service:latest
          env:
            - name: CONFIG_FILE
              value: /vault/secrets/config   # read from file, not env var
```

### External Secrets Operator (Kubernetes)

Sync secrets from AWS Secrets Manager / GCP Secret Manager / Vault into Kubernetes Secrets automatically:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: payment-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: payment-secrets          # creates a K8s Secret with this name
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: prod/payment/database
        property: url
    - secretKey: api-key
      remoteRef:
        key: prod/payment/api-key
```

---

## Pattern 5 — Secret scanning (detect before they ship)

```yaml
# .github/workflows/secret-scan.yml
name: Secret scanning

on: [push, pull_request]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0       # full history — scan all commits

      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```toml
# .gitleaks.toml — custom rules
[[rules]]
id          = "internal-api-key"
description = "Internal API key pattern"
regex       = '''mycompany_[a-zA-Z0-9]{32}'''
severity    = "critical"

[[rules]]
id          = "database-url"
description = "Database connection string"
regex       = '''(postgresql|mysql|mongodb)://[^:]+:[^@]+@'''
severity    = "critical"
```

---

## Secret rotation schedule

| Secret type | Rotation frequency | Method |
|---|---|---|
| Database passwords | Every 24 hours | Dynamic secrets (Vault) or Lambda rotation |
| API keys (third-party) | Every 90 days | Manual or provider API |
| TLS certificates | 90 days (Let's Encrypt) or 1 year | cert-manager, ACM |
| SSH keys | Every 90 days | CA-signed short-lived certs |
| JWT signing keys | Every 30 days | JWKS endpoint rotation |
| IAM access keys | Every 90 days | AWS IAM rotation policy |
| Service account tokens | 1 hour (Kubernetes) | Automatic via bound SA tokens |

---

## Secrets management checklist

```
Prevention
□ Secret scanning in CI/CD pipeline (Gitleaks, truffleHog)
□ GitHub secret scanning enabled on all repos
□ Pre-commit hooks block secret commits locally
□ .gitignore covers all credential file patterns

Storage
□ No secrets in source code, config files, or Docker images
□ No secrets in environment variables for production workloads
□ All secrets stored in a secrets manager (Vault / AWS SM / GCP SM)
□ Secrets encrypted at rest with customer-managed keys

Access
□ Least privilege — services access only their own secrets
□ Human access to production secrets requires MFA + approval
□ All secret access logged to audit trail
□ Emergency access ("break glass") procedure defined

Rotation
□ All secrets have a defined rotation schedule
□ Rotation is automated — not manual
□ Applications handle rotation gracefully (no restart required)
□ Rotation tested quarterly
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/kubernetes-security/"><span class="ref-label">Architecture</span>Kubernetes Security</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — Info Disclosure</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
