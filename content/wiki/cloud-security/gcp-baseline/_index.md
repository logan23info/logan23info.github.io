---
title: "GCP Security Baseline"
date: 2026-08-05
tags: ["GCP", "Google-Cloud", "cloud-security", "IAM", "Cloud-Audit-Logs", "Security-Command-Center"]
categories: ["cloud-security"]
description: "GCP security baseline — IAM, Cloud Storage, VPC, Cloud Audit Logs, Security Command Center, and CIS GCP Benchmark controls."
showToc: true
layout: "single"
---

## Overview

Google Cloud Platform (GCP) has a strong security foundation but requires careful configuration. GCP's identity model centres on **Google accounts and service accounts** — misconfigurations here account for the majority of GCP security incidents. This baseline covers CIS GCP Foundations Benchmark v2.0 controls.

**Automated check:**
```bash
pip install prowler
prowler gcp --compliance cis_gcp_2.0
```

---

## 1. IAM — Identity and Access Management

GCP IAM is built around **principals** (who), **roles** (what), and **resources** (where).

### Organisation-level policies

```bash
# List all organisation IAM bindings — find over-privileged accounts
gcloud organizations get-iam-policy ORG_ID \
  --format="table(bindings.role,bindings.members)"

# Find users with owner role at organisation level (should be near zero)
gcloud organizations get-iam-policy ORG_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  --filter="bindings.role=roles/owner"

# Find all service accounts with organisation-level access
gcloud organizations get-iam-policy ORG_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount"
```

### Service account security

```bash
# List all service accounts with keys
gcloud iam service-accounts list --format="value(email)" | while read sa; do
  keys=$(gcloud iam service-accounts keys list --iam-account="$sa" \
    --managed-by=user --format="value(name)" | wc -l)
  if [ "$keys" -gt 0 ]; then
    echo "SA WITH USER-MANAGED KEYS: $sa ($keys keys)"
  fi
done

# Find service accounts with roles/owner or roles/editor
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount AND (bindings.role=roles/owner OR bindings.role=roles/editor)" \
  --format="table(bindings.role,bindings.members)"
```

```hcl
# infra/iam.tf — GCP IAM best practices

# Dedicated service account per workload — least privilege
resource "google_service_account" "app" {
  account_id   = "payment-processor"
  display_name = "Payment Processor Service Account"
  project      = var.project_id
}

# Bind specific roles — never roles/editor or roles/owner
resource "google_project_iam_member" "app_secretmanager" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.app.email}"

  condition {
    title       = "payment-secrets-only"
    description = "Only access payment-related secrets"
    expression  = "resource.name.startsWith(\"projects/${var.project_id}/secrets/payment-\")"
  }
}

# Workload Identity — no service account keys needed for GKE workloads
resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
  ]
}

# Organisation policy — disable service account key creation
resource "google_org_policy_policy" "disable_sa_key_creation" {
  name   = "organizations/${var.org_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "organizations/${var.org_id}"

  spec {
    rules {
      enforce = true
    }
  }
}
```

---

## 2. Cloud Storage Security

```bash
# Find publicly accessible buckets
gsutil ls -p PROJECT_ID | while read bucket; do
  iam=$(gsutil iam get "$bucket" 2>/dev/null | \
    python3 -c "import json,sys; d=json.load(sys.stdin);
    print(any('allUsers' in b.get('members',[]) or 'allAuthenticatedUsers' in b.get('members',[])
    for b in d.get('bindings',[])))")
  if [ "$iam" = "True" ]; then
    echo "PUBLIC BUCKET: $bucket"
  fi
done

# Check bucket uniform access (prevents ACL bypass)
gsutil uniformbucketlevelaccess get gs://BUCKET_NAME
```

```hcl
# infra/storage.tf — secure GCS bucket

resource "google_storage_bucket" "data" {
  name          = "${var.project_id}-data-${random_id.suffix.hex}"
  location      = "US"
  storage_class = "STANDARD"
  project       = var.project_id

  # Prevent public access
  public_access_prevention = "enforced"

  # Uniform bucket-level access — disable legacy ACLs
  uniform_bucket_level_access = true

  # Encryption with CMEK
  encryption {
    default_kms_key_name = google_kms_crypto_key.storage.id
  }

  versioning {
    enabled = true
  }

  # Retention policy — prevent deletion of objects
  retention_policy {
    is_locked        = false
    retention_period = 2592000  # 30 days
  }

  lifecycle_rule {
    action { type = "Delete" }
    condition {
      age                = 365
      with_state         = "ARCHIVED"
    }
  }

  logging {
    log_bucket        = google_storage_bucket.access_logs.name
    log_object_prefix = "gcs-access-logs/"
  }
}

# Organisation policy — enforce public access prevention on all buckets
resource "google_org_policy_policy" "storage_public_access" {
  name   = "organizations/${var.org_id}/policies/storage.publicAccessPrevention"
  parent = "organizations/${var.org_id}"
  spec {
    rules { enforce = true }
  }
}
```

---

## 3. VPC Security

```hcl
# infra/vpc.tf — secure GCP VPC

resource "google_compute_network" "main" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false   # manual subnet control
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.project_id}-private"
  ip_cidr_range            = "10.0.0.0/24"
  network                  = google_compute_network.main.id
  region                   = var.region
  project                  = var.project_id
  private_ip_google_access = true   # reach Google APIs without internet

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Deny all ingress by default — explicit allow rules only
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "deny-all-ingress"
  network   = google_compute_network.main.id
  priority  = 65534
  direction = "INGRESS"

  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}

# Allow SSH only via IAP (Identity-Aware Proxy) — never from 0.0.0.0/0
resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "allow-iap-ssh"
  network   = google_compute_network.main.id
  priority  = 1000
  direction = "INGRESS"

  allow { protocol = "tcp"; ports = ["22"] }
  # IAP's IP range only — not the internet
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh-allowed"]
}
```

---

## 4. Cloud Audit Logs

```hcl
# infra/audit-logs.tf

# Enable all audit log types for all services
resource "google_project_iam_audit_config" "all_services" {
  project = var.project_id
  service = "allServices"

  audit_log_config { log_type = "ADMIN_READ" }
  audit_log_config { log_type = "DATA_READ" }
  audit_log_config { log_type = "DATA_WRITE" }
}

# Export audit logs to Cloud Storage for long-term retention
resource "google_logging_project_sink" "audit_logs" {
  name        = "audit-logs-to-storage"
  project     = var.project_id
  destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"

  filter = <<-EOT
    logName:"cloudaudit.googleapis.com" OR
    logName:"externalaudit.googleapis.com"
  EOT

  unique_writer_identity = true
}

# Alert on critical IAM changes
resource "google_logging_metric" "iam_changes" {
  name    = "iam-policy-changes"
  project = var.project_id
  filter  = <<-EOT
    resource.type="project" AND
    protoPayload.methodName:"SetIamPolicy"
  EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "iam_changes" {
  display_name = "IAM Policy Changes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "IAM policy change detected"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.iam_changes.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}
```

---

## 5. Security Command Center

```bash
# Enable Security Command Center
gcloud services enable securitycenter.googleapis.com

# List all active findings
gcloud scc findings list ORGANIZATION_ID \
  --filter="state=ACTIVE AND severity=CRITICAL" \
  --format="table(name,category,severity,eventTime)"

# Enable built-in threat detection services
gcloud scc settings update-org-settings ORGANIZATION_ID \
  --enable-asset-discovery

# Common SCC finding categories to prioritise:
# PUBLIC_BUCKET_ACL — public S3/GCS bucket
# OPEN_FIREWALL — firewall rule allowing 0.0.0.0/0
# DEFAULT_SERVICE_ACCOUNT_USED — workload using default SA
# SERVICE_ACCOUNT_KEY_EXPOSED — SA key in public code
# WEAK_SSL_POLICY — old TLS on load balancer
```

---

## GCP Security Baseline Checklist

```
IAM
□ Organisation-level IAM: no users with roles/owner
□ Service accounts: no user-managed keys (use Workload Identity)
□ Org policy: iam.disableServiceAccountKeyCreation = true
□ Org policy: iam.disableServiceAccountCreation restricted
□ MFA enforced for all Google Workspace / Cloud Identity users
□ Principle of least privilege — custom roles over primitive roles
□ Quarterly IAM review — remove unused bindings

Storage
□ public_access_prevention = "enforced" on all buckets
□ uniform_bucket_level_access = true on all buckets
□ CMEK encryption on sensitive buckets
□ Versioning enabled on data buckets
□ Access logging enabled

Network
□ VPC Flow Logs enabled on all subnets
□ No firewall rule allowing 0.0.0.0/0 on SSH/RDP
□ SSH access only via IAP (35.235.240.0/20)
□ private_ip_google_access = true on private subnets
□ Default VPC deleted or unused

Logging & Detection
□ Cloud Audit Logs: ADMIN_READ, DATA_READ, DATA_WRITE for allServices
□ Audit logs exported to GCS with 12-month retention
□ Log-based alerts for IAM changes, firewall changes
□ Security Command Center enabled
□ Chronicle or SIEM ingesting GCP logs
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/azure-baseline/"><span class="ref-label">Cloud</span>Azure Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-misconfig-top10/"><span class="ref-label">Cloud</span>Cloud Misconfiguration Top 10</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-threat-model/"><span class="ref-label">Cloud</span>Cloud Threat Model Template</a>
  <a class="ref-card" href="/wiki/secure-architecture/kubernetes-security/"><span class="ref-label">Architecture</span>Kubernetes Security</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
