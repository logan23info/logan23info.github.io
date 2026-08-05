---
title: "Kubernetes Security Hardening"
date: 2026-08-05
tags: ["Kubernetes", "K8s", "RBAC", "network-policy", "pod-security", "admission-controllers", "architecture"]
categories: ["architecture"]
description: "Complete Kubernetes security hardening guide — RBAC, network policies, pod security standards, admission controllers, secrets encryption, and cluster hardening."
showToc: true
layout: "single"
---

## Kubernetes threat model

Kubernetes has a large attack surface. Understanding the threat model is the starting point:

```
External attacker
    │
    ▼
[Ingress / API Server]  ← auth bypass, CVEs
    │
    ▼
[Pod / Container]       ← container escape, privilege escalation
    │
    ├──► [etcd]         ← unencrypted secrets, direct access
    ├──► [kubelet]      ← unauthenticated API, exec into pods
    ├──► [RBAC]         ← overprivileged service accounts
    ├──► [Network]      ← lateral movement between pods
    └──► [Supply chain] ← malicious images, helm charts
```

The four highest-risk areas: **RBAC misconfiguration, missing network policies, privileged pods, and unencrypted etcd secrets.**

---

## Pattern 1 — RBAC (Role-Based Access Control)

RBAC controls what Kubernetes API actions each identity can perform. The most common mistake is wildcard permissions.

```yaml
# WRONG — wildcard permissions (cluster-admin equivalent)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dangerous-role
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]              # DO NOT do this

# RIGHT — least privilege for a deployment controller
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: production
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  # No delete, no secrets, no cluster-level access
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-manager-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: ci-deployer
    namespace: production
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: rbac.authorization.k8s.io
```

### RBAC audit — find overprivileged accounts

```bash
# Find all cluster-admin bindings
kubectl get clusterrolebindings -o json | \
  jq '.items[] | select(.roleRef.name=="cluster-admin") | 
      {name:.metadata.name, subjects:.subjects}'

# Find service accounts that can exec into pods
kubectl auth can-i create pods/exec --as=system:serviceaccount:production:payment-service

# Enumerate all permissions for a service account
kubectl auth can-i --list \
  --as=system:serviceaccount:production:payment-service

# Use rakkess for visual permission matrix
kubectl-rakkess --sa production:payment-service

# Use rbac-police to find privilege escalation paths
rbac-police eval --cluster
```

### Service account hardening

```yaml
# Disable auto-mounting of service account tokens (default is true)
apiVersion: v1
kind: ServiceAccount
metadata:
  name: payment-service
  namespace: production
automountServiceAccountToken: false   # opt-out at SA level
---
# Only mount where explicitly needed
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      serviceAccountName: payment-service
      automountServiceAccountToken: false   # also disable at pod level
```

---

## Pattern 2 — Network Policies

By default, all pods can communicate with all other pods. Network Policies are Kubernetes's firewall — they define which pods can talk to which.

```yaml
# Default deny all ingress and egress — start with zero trust
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}        # applies to ALL pods in namespace
  policyTypes:
    - Ingress
    - Egress
---
# Allow payment-service to receive from order-service only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: payment-service-ingress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: payment-service
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: order-service
        - namespaceSelector:
            matchLabels:
              name: production
      ports:
        - protocol: TCP
          port: 8080
---
# Allow payment-service egress to database and external payment gateway only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: payment-service-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: payment-service
  policyTypes:
    - Egress
  egress:
    - to:                              # internal database
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    - to:                              # external payment gateway
        - ipBlock:
            cidr: 203.0.113.0/24
      ports:
        - protocol: TCP
          port: 443
    - to:                              # DNS resolution
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
```

```bash
# Verify network policy is working
kubectl exec -n production deploy/attacker-pod -- \
  curl -s --max-time 3 http://payment-service:8080/health
# Expected: connection timeout (blocked by NetworkPolicy)

# Visualise network policies
kubectl-np-viewer -n production
```

---

## Pattern 3 — Pod Security Standards

Pod Security Standards (PSS) replaced PodSecurityPolicy in K8s 1.25. Three levels:

| Level | Description | When to use |
|---|---|---|
| **Privileged** | No restrictions | Node-level system components only |
| **Baseline** | Minimal restrictions | General workloads |
| **Restricted** | Strongly restricted | Sensitive workloads, default target |

```yaml
# Enforce restricted standard on a namespace
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

What the **restricted** standard requires:

```yaml
# A pod that complies with restricted standard
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
        runAsNonRoot: true
```

---

## Pattern 4 — Admission Controllers

Admission controllers validate and mutate requests to the Kubernetes API before they are persisted. Use them to enforce security policies:

```yaml
# OPA Gatekeeper — policy as code
# Constraint Template: require all containers to have resource limits
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredresources
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredResources
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredresources
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits.memory
          msg := sprintf("Container %v has no memory limit", [container.name])
        }
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits.cpu
          msg := sprintf("Container %v has no CPU limit", [container.name])
        }
---
# Apply the constraint to all namespaces
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredResources
metadata:
  name: require-resource-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

```yaml
# Kyverno — simpler policy syntax
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-privileged
      match:
        any:
          - resources:
              kinds: [Pod]
      validate:
        message: "Privileged containers are not allowed"
        pattern:
          spec:
            containers:
              - =(securityContext):
                  =(privileged): "false"

    - name: require-non-root
      match:
        any:
          - resources:
              kinds: [Pod]
      validate:
        message: "Containers must not run as root"
        pattern:
          spec:
            securityContext:
              runAsNonRoot: true
```

---

## Pattern 5 — etcd encryption at rest

etcd stores all Kubernetes secrets in plaintext by default. Enable encryption:

```yaml
# /etc/kubernetes/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
      - configmaps
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <base64-encoded-32-byte-key>
      - identity: {}         # fallback for unencrypted reads during migration
```

```bash
# Apply to kube-apiserver
# In /etc/kubernetes/manifests/kube-apiserver.yaml add:
# --encryption-provider-config=/etc/kubernetes/encryption-config.yaml

# Verify all existing secrets are encrypted
kubectl get secrets --all-namespaces -o json | \
  kubectl replace -f -    # re-encrypt all existing secrets

# Verify encryption is active — should return encrypted value
ETCDCTL_API=3 etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get /registry/secrets/production/my-secret | hexdump -C | head
# Should show: k8s:enc:aescbc: prefix — not plaintext
```

---

## Pattern 6 — Cluster hardening

```bash
# CIS Kubernetes Benchmark — automated check
kube-bench run --targets master,node,etcd,policies

# Key hardening steps:

# 1. Disable anonymous auth on API server
# --anonymous-auth=false

# 2. Enable audit logging
# --audit-log-path=/var/log/kubernetes/audit.log
# --audit-log-maxage=30
# --audit-log-maxsize=100
# --audit-policy-file=/etc/kubernetes/audit-policy.yaml

# 3. Restrict API server access to known CIDRs
# --authorization-mode=Node,RBAC  (not AlwaysAllow)

# 4. Disable insecure port
# --insecure-port=0

# 5. Kubelet security
# --anonymous-auth=false
# --authorization-mode=Webhook
# --read-only-port=0
```

```yaml
# Audit policy — log sensitive operations
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["secrets", "configmaps"]
  - level: Metadata
    resources:
      - group: ""
        resources: ["pods", "services"]
  - level: Request
    verbs: ["create", "update", "patch", "delete"]
  - level: None
    resources:
      - group: ""
        resources: ["events"]
```

---

## Kubernetes security checklist

```
RBAC
□ No wildcard (*) permissions in any Role or ClusterRole
□ cluster-admin binding count reviewed — minimised
□ Service accounts have automountServiceAccountToken: false by default
□ Each workload has a dedicated service account with minimal permissions
□ RBAC reviewed quarterly

Network
□ Default deny NetworkPolicy applied to all namespaces
□ Explicit allow policies for each service-to-service communication
□ No pod-to-pod communication allowed outside defined policies
□ mTLS enforced between all services (Istio/Linkerd)

Pod Security
□ Pod Security Standard: restricted enforced on all production namespaces
□ No privileged containers
□ No hostPID, hostNetwork, hostIPC
□ readOnlyRootFilesystem: true
□ ALL capabilities dropped
□ runAsNonRoot enforced
□ Resource limits set on all containers

Admission Control
□ OPA Gatekeeper or Kyverno enforcing policies
□ Image registry allowlist enforced
□ Image signature verification enforced (Cosign)
□ Resource limits required

Secrets & etcd
□ etcd encryption at rest enabled
□ etcd access restricted to API server only
□ Secrets managed via external secrets manager (Vault / AWS SM)

Cluster hardening
□ Anonymous auth disabled
□ Audit logging enabled and shipped to SIEM
□ CIS Benchmark score > 90%
□ kube-bench run quarterly
□ Kubernetes version within 2 minor versions of latest
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/secure-architecture/container-security/"><span class="ref-label">Architecture</span>Container Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/microservices/"><span class="ref-label">Architecture</span>Microservices Security</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
</div>

</div>
