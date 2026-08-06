---
title: "AWS Security Baseline"
date: 2026-08-05
tags: ["AWS", "cloud-security", "IAM", "S3", "CloudTrail", "GuardDuty", "CIS-benchmark"]
categories: ["cloud-security"]
description: "AWS security baseline — IAM hardening, S3 security, VPC design, CloudTrail, GuardDuty, Security Hub, and CIS AWS Benchmark controls."
showToc: true
layout: "single"
---

## Overview

AWS is the world's largest cloud platform. Misconfigurations in AWS are responsible for some of the largest data breaches in history — Capital One (100M records), Twitch (125GB source code), and countless others. This baseline covers the CIS AWS Foundations Benchmark v3.0 controls with practical implementation guidance.

**Automated check:** Run Prowler against your account:
```bash
pip install prowler
prowler aws --compliance cis_aws_2.0
```

---

## 1. Identity & Access Management (IAM)

IAM is the most critical AWS security domain. Every breach starts with a credential or a misconfigured role.

### Root account protection

```bash
# Check root account MFA status
aws iam get-account-summary | jq '.AccountMFAEnabled'
# Expected: 1 (MFA enabled)

# Check for root access keys — should return empty
aws iam list-access-keys --user-name root 2>&1
# Expected: error — root has no programmatic access keys

# List active root access keys (should be none)
aws iam get-account-summary | jq '.AccountAccessKeysPresent'
# Expected: 0
```

**Root account rules:**
- Enable MFA on root — hardware MFA key preferred
- Delete all root access keys — use IAM roles instead
- Lock root credentials in a password manager accessible only to 2+ people
- Set billing alerts on root account — detect unexpected charges

### IAM password policy

```bash
# Set strong password policy
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --allow-users-to-change-password \
  --max-password-age 90 \
  --password-reuse-prevention 24 \
  --hard-expiry

# Verify policy
aws iam get-account-password-policy
```

### IAM users and roles — least privilege

```bash
# Find users with admin access
aws iam list-users | jq -r '.Users[].UserName' | while read user; do
  policies=$(aws iam list-attached-user-policies --user-name "$user" | \
    jq -r '.AttachedPolicies[].PolicyName')
  if echo "$policies" | grep -q "AdministratorAccess"; then
    echo "ADMIN USER: $user"
  fi
done

# Find unused access keys (not used in 90 days)
aws iam generate-credential-report
aws iam get-credential-report --output text --query Content | base64 -d | \
  awk -F, 'NR>1 {
    if ($9 != "N/A" && $9 != "no_information") {
      cmd = "date -d " $9 " +%s"
      cmd | getline last_used
      close(cmd)
      now = systime()
      days = (now - last_used) / 86400
      if (days > 90) print "UNUSED KEY (", days, "days):", $1
    }
  }'

# Enforce MFA for all console access
# Attach this policy to all IAM groups/users
cat > require-mfa-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowViewAccountInfo",
      "Effect": "Allow",
      "Action": ["iam:GetAccountPasswordPolicy", "iam:ListVirtualMFADevices"],
      "Resource": "*"
    },
    {
      "Sid": "AllowManageOwnMFA",
      "Effect": "Allow",
      "Action": ["iam:CreateVirtualMFADevice", "iam:EnableMFADevice",
                 "iam:GetUser", "iam:ListMFADevices", "iam:ResyncMFADevice"],
      "Resource": ["arn:aws:iam::*:mfa/${aws:username}",
                   "arn:aws:iam::*:user/${aws:username}"]
    },
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": ["iam:CreateVirtualMFADevice", "iam:EnableMFADevice",
                    "iam:GetUser", "iam:ListMFADevices", "iam:ListVirtualMFADevices",
                    "iam:ResyncMFADevice", "sts:GetSessionToken"],
      "Resource": "*",
      "Condition": {"BoolIfExists": {"aws:MultiFactorAuthPresent": "false"}}
    }
  ]
}
EOF
```

### OpenTofu — IAM least privilege

```hcl
# infra/iam.tf

# Service role for Lambda — only what it needs
resource "aws_iam_role" "payment_processor" {
  name = "payment-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "payment_processor" {
  name = "payment-processor-policy"
  role = aws_iam_role.payment_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/payment-processor:*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:prod/payment/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.payment_queue.arn
      }
      # NO s3:*, NO iam:*, NO ec2:* — only what's needed
    ]
  })
}
```

---

## 2. S3 Security

S3 misconfigurations are the most common cause of AWS data breaches.

```bash
# Find all public buckets in your account
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read bucket; do
    acl=$(aws s3api get-bucket-acl --bucket "$bucket" 2>/dev/null | \
      jq -r '.Grants[].Grantee.URI // empty' | grep -c "AllUsers" || echo 0)
    policy=$(aws s3api get-bucket-policy-status --bucket "$bucket" 2>/dev/null | \
      jq -r '.PolicyStatus.IsPublic' || echo false)
    if [ "$acl" -gt 0 ] || [ "$policy" = "true" ]; then
      echo "PUBLIC BUCKET: $bucket"
    fi
  done

# Block public access at account level — prevent all future public buckets
aws s3control put-public-access-block \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

```hcl
# infra/s3.tf — secure S3 bucket template

resource "aws_s3_bucket" "data" {
  bucket = "${var.project}-data-${random_id.suffix.hex}"
  tags   = { Environment = "production", Classification = "confidential" }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encryption — customer-managed KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true  # reduces KMS API costs
  }
}

# Versioning — enables recovery from accidental deletion
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}

# Enforce HTTPS — deny all HTTP requests
resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyHTTP"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = ["${aws_s3_bucket.data.arn}", "${aws_s3_bucket.data.arn}/*"]
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}

# Access logging
resource "aws_s3_bucket_logging" "data" {
  bucket        = aws_s3_bucket.data.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "s3-access-logs/${aws_s3_bucket.data.id}/"
}

# Lifecycle — expire old data
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
}
```

---

## 3. VPC Security

```hcl
# infra/vpc.tf — secure VPC baseline

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project}-vpc" }
}

# Public subnets — only for load balancers, NAT gateways
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false  # never auto-assign public IPs
  tags                    = { Name = "${var.project}-public-${count.index}", Tier = "public" }
}

# Private subnets — for all application workloads
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = { Name = "${var.project}-private-${count.index}", Tier = "private" }
}

# VPC Flow Logs — capture all network traffic metadata
resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
}

# Security group — deny all by default
resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "Application security group — deny all by default"
  vpc_id      = aws_vpc.main.id

  # No ingress rules by default — add explicitly
  egress {
    description = "HTTPS to internet (for AWS APIs)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NEVER add: cidr_blocks = ["0.0.0.0/0"] to ingress rules
  # NEVER allow port 22 (SSH) or 3389 (RDP) from 0.0.0.0/0
}
```

---

## 4. CloudTrail — Audit logging

```bash
# Verify CloudTrail is enabled in all regions
aws cloudtrail describe-trails --include-shadow-trails | \
  jq '.trailList[] | {name: .Name, multiRegion: .IsMultiRegionTrail, logValidation: .LogFileValidationEnabled}'

# Check trail is actually logging
aws cloudtrail get-trail-status --name your-trail-name | \
  jq '{logging: .IsLogging, lastDelivery: .LatestDeliveryTime}'
```

```hcl
# infra/cloudtrail.tf

resource "aws_cloudtrail" "main" {
  name                          = "${var.project}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true   # IAM, STS, CloudFront events
  is_multi_region_trail         = true   # ALL regions — not just us-east-1
  enable_log_file_validation    = true   # detect log tampering

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]   # log all S3 object-level events
    }
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  tags = { Name = "${var.project}-trail" }
}

# CloudWatch Alarms for critical events
resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "root-account-login"
  alarm_description   = "Alert on root account console login"
  metric_name         = "RootAccountUsage"
  namespace           = "CloudTrailMetrics"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

---

## 5. GuardDuty & Security Hub

```hcl
# infra/detective-controls.tf

# GuardDuty — threat detection
resource "aws_guardduty_detector" "main" {
  enable = true
  datasources {
    s3_logs { enable = true }
    kubernetes { audit_logs { enable = true } }
    malware_protection {
      scan_ec2_instance_with_findings { ebs_volumes { enable = true } }
    }
  }
}

# Security Hub — aggregate findings from all services
resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "cis" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
}
```

---

## AWS Security Baseline Checklist

```
IAM
□ Root account MFA enabled (hardware key)
□ No root access keys exist
□ MFA required for all console users
□ Password policy: 14+ chars, 90-day rotation
□ No wildcard (*) permissions in IAM policies
□ Access keys rotated every 90 days
□ Unused access keys (>90 days) removed
□ IAM Access Analyzer enabled

S3
□ Account-level S3 Block Public Access enabled
□ No public buckets (verified with Prowler)
□ All buckets encrypted (SSE-KMS preferred)
□ All buckets with versioning enabled
□ S3 access logging enabled
□ HTTPS enforced via bucket policy

Network
□ VPC Flow Logs enabled for all VPCs
□ No security group with 0.0.0.0/0 on port 22/3389
□ All workloads in private subnets
□ NACLs configured for defence in depth

Logging
□ CloudTrail enabled in ALL regions
□ CloudTrail log file validation enabled
□ CloudTrail logs ship to S3 with MFA delete
□ CloudWatch Alarms for root login, config changes

Detection
□ GuardDuty enabled in all regions
□ Security Hub enabled with CIS benchmark
□ AWS Config enabled with conformance packs
□ Macie enabled for S3 PII discovery
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/cloud-misconfig-top10/"><span class="ref-label">Cloud</span>Cloud Misconfiguration Top 10</a>
  <a class="ref-card" href="/wiki/cloud-security/gcp-baseline/"><span class="ref-label">Cloud</span>GCP Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/azure-baseline/"><span class="ref-label">Cloud</span>Azure Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-threat-model/"><span class="ref-label">Cloud</span>Cloud Threat Model Template</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
