---
title: "Cloud Misconfiguration Top 10"
date: 2026-08-05
tags: ["cloud-security", "misconfiguration", "AWS", "GCP", "Azure", "CSPM", "detection"]
categories: ["cloud-security"]
description: "The 10 most dangerous cloud misconfigurations — with STRIDE mapping, detection commands, and OpenTofu fixes for AWS, GCP, and Azure."
showToc: true
layout: "single"
---

## Overview

Cloud misconfigurations are responsible for the majority of cloud security incidents. Unlike traditional vulnerabilities, they are not software bugs — they are incorrect settings made by engineers. The good news: every one is detectable and fixable in code.

This list is derived from analysis of real-world cloud breaches, NSA/CISA cloud security advisories, and CIS Benchmark findings.

---

## M01 — Public Cloud Storage Buckets

**STRIDE:** Information Disclosure
**Severity:** Critical
**Frequency:** Extremely common — found in >30% of AWS assessments

**What it is:** S3 buckets, GCS buckets, or Azure Blob containers configured to allow public read or write access — exposing customer data, backups, credentials, and source code to the internet.

**Famous breaches:** Capital One (2019, 100M records), Twitch (2021, 125GB source code), 1.5B Facebook records (2019)

**Detection:**
```bash
# AWS — find public buckets
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read b; do
    status=$(aws s3api get-public-access-block --bucket "$b" 2>/dev/null | \
      jq -r '.PublicAccessBlockConfiguration | [.BlockPublicAcls,.IgnorePublicAcls,.BlockPublicPolicy,.RestrictPublicBuckets] | all')
    if [ "$status" != "true" ]; then echo "VULNERABLE: $b"; fi
  done

# Shodan — find your buckets exposed to the internet
# Search: http.title:"Index of" host:s3.amazonaws.com

# Prowler check
prowler aws --check s3_bucket_public_access_block_enabled
```

**Fix (OpenTofu):**
```hcl
resource "aws_s3_bucket_public_access_block" "fix" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

## M02 — Overprivileged IAM Roles and Policies

**STRIDE:** Elevation of Privilege
**Severity:** Critical
**Frequency:** Found in virtually every cloud environment

**What it is:** IAM roles, service accounts, or managed identities with more permissions than needed. The most dangerous patterns: `"Action": "*"`, `"Resource": "*"`, or roles/Owner assigned to application workloads.

**Detection:**
```bash
# AWS — find policies with wildcard actions
aws iam list-policies --scope Local | jq -r '.Policies[].Arn' | while read arn; do
  doc=$(aws iam get-policy-version \
    --policy-arn "$arn" \
    --version-id $(aws iam get-policy --policy-arn "$arn" | jq -r '.Policy.DefaultVersionId') | \
    jq -r '.PolicyVersion.Document')
  if echo "$doc" | jq -e '.Statement[].Action == "*"' > /dev/null 2>&1; then
    echo "WILDCARD ACTION POLICY: $arn"
  fi
done

# AWS IAM Access Analyzer
aws accessanalyzer list-findings \
  --analyzer-arn $(aws accessanalyzer list-analyzers | jq -r '.analyzers[0].arn') \
  --filter '{"status": {"eq": ["ACTIVE"]}}' | \
  jq '.findings[] | {id, resourceType, condition}'

# GCP — find bindings with primitive roles
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.role:(roles/owner OR roles/editor)" \
  --format="table(bindings.role,bindings.members)"
```

**Fix:** Apply least privilege — replace wildcard with specific actions and resources.

---

## M03 — Missing Multi-Factor Authentication

**STRIDE:** Spoofing
**Severity:** Critical
**Frequency:** Very common — single largest enabler of account takeover

**What it is:** Console users, privileged accounts, or root/admin accounts without MFA. A single stolen password gives an attacker full access.

**Detection:**
```bash
# AWS — find users without MFA
aws iam generate-credential-report
aws iam get-credential-report --output text --query Content | \
  base64 -d | awk -F, 'NR>1 && $8=="false" {print "NO MFA:", $1}'

# AWS — check if MFA is required by policy
aws iam list-account-aliases
aws iam get-account-summary | jq '.AccountMFAEnabled'

# GCP — users without 2FA (requires Admin SDK)
gcloud beta workspace-states list --customer-id=CUSTOMER_ID

# Azure — users without MFA (Microsoft Graph)
az rest --method GET \
  --url "https://graph.microsoft.com/beta/reports/authenticationMethods/userRegistrationDetails?\$filter=isMfaRegistered eq false" | \
  jq '.value[].userPrincipalName'
```

---

## M04 — Unrestricted Inbound Access (0.0.0.0/0)

**STRIDE:** Elevation of Privilege, Spoofing
**Severity:** High
**Frequency:** Common — especially on SSH (22) and RDP (3389)

**What it is:** Security groups (AWS), firewall rules (GCP), or NSGs (Azure) allowing any IP to connect on administrative ports. One exposed SSH server with a weak credential = full server compromise.

**Detection:**
```bash
# AWS — find security groups with 0.0.0.0/0 on sensitive ports
aws ec2 describe-security-groups \
  --query "SecurityGroups[?IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0'] && (ToPort==\`22\` || ToPort==\`3389\` || ToPort==\`5432\` || ToPort==\`3306\`)]].[GroupId,GroupName]" \
  --output table

# All ports open to internet
aws ec2 describe-security-groups \
  --query "SecurityGroups[?IpPermissions[?IpRanges[?CidrIp=='0.0.0.0/0'] && (FromPort==\`0\` || ToPort==\`65535\`)]].[GroupId,GroupName]" \
  --output table

# GCP — find permissive firewall rules
gcloud compute firewall-rules list \
  --filter="direction=INGRESS AND sourceRanges=0.0.0.0/0" \
  --format="table(name,network,allowed,sourceRanges)"

# Azure — NSG rules allowing Internet inbound
az network nsg list --query "[].{name:name, rules:securityRules[?access=='Allow' && direction=='Inbound' && sourceAddressPrefix=='*']}" -o json
```

**Fix (OpenTofu):**
```hcl
# NEVER do this
resource "aws_security_group_rule" "bad" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]   # WRONG
}

# Use VPN, bastion, or SSM Session Manager instead
resource "aws_security_group_rule" "good" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id  # only from bastion
}
```

---

## M05 — Disabled or Missing Audit Logging

**STRIDE:** Repudiation
**Severity:** High
**Frequency:** Common — especially missing in non-production accounts

**What it is:** CloudTrail (AWS), Cloud Audit Logs (GCP), or Activity Logs (Azure) disabled, limited to one region, or not shipping to a central SIEM. Without logs, breaches go undetected for months.

**Detection:**
```bash
# AWS — find regions without CloudTrail
for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  trails=$(AWS_DEFAULT_REGION=$region aws cloudtrail describe-trails \
    --include-shadow-trails false --query 'trailList[?IsMultiRegionTrail==`false`]' | \
    jq length)
  logging=$(AWS_DEFAULT_REGION=$region aws cloudtrail get-trail-status \
    --name default --query 'IsLogging' 2>/dev/null || echo false)
  echo "$region: trails=$trails logging=$logging"
done

# GCP — verify audit logs enabled for all services
gcloud projects get-iam-policy PROJECT_ID \
  --format=json | jq '.auditConfigs'
# Should show allServices with DATA_READ, DATA_WRITE, ADMIN_READ

# Azure — verify Activity Log diagnostic setting
az monitor diagnostic-settings list \
  --resource /subscriptions/SUBSCRIPTION_ID \
  --query "[].{name:name,workspace:workspaceId}"
```

---

## M06 — Unencrypted Data at Rest

**STRIDE:** Information Disclosure
**Severity:** High
**Frequency:** Common for databases and storage created via console

**What it is:** RDS instances, S3 buckets, EBS volumes, GCS buckets, or Azure Storage using provider-managed encryption without customer-managed keys — or worse, no encryption at all.

**Detection:**
```bash
# AWS — unencrypted EBS volumes
aws ec2 describe-volumes \
  --query "Volumes[?Encrypted==\`false\`].[VolumeId,State]" \
  --output table

# AWS — unencrypted RDS instances
aws rds describe-db-instances \
  --query "DBInstances[?StorageEncrypted==\`false\`].[DBInstanceIdentifier,Engine]" \
  --output table

# AWS — S3 buckets without default encryption
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read b; do
    enc=$(aws s3api get-bucket-encryption --bucket "$b" 2>&1)
    if echo "$enc" | grep -q "ServerSideEncryptionConfigurationNotFoundError"; then
      echo "NO ENCRYPTION: $b"
    fi
  done

# Enable encryption on all new EBS volumes by default
aws ec2 enable-ebs-encryption-by-default --region us-east-1
```

---

## M07 — Exposed Credentials in Code or Environment Variables

**STRIDE:** Information Disclosure, Spoofing
**Severity:** Critical
**Frequency:** Very common in developer environments and CI/CD

**What it is:** AWS access keys, GCP service account JSON, Azure client secrets, or database passwords committed to Git repositories, stored in environment variables visible in CI logs, or baked into container images.

**Detection:**
```bash
# Scan Git history for secrets
trufflehog git https://github.com/myorg/myrepo --only-verified
gitleaks detect --source . --verbose

# Scan container images for secrets
trivy image --scanners secret myapp:latest

# AWS — check for exposed access keys in public code
# AWS itself will notify you via email if your keys appear in public GitHub repos
# Also check: https://console.aws.amazon.com/iam/home#/security_credentials

# Check environment variables of running containers (ECS)
aws ecs describe-task-definition --task-definition myapp | \
  jq '.taskDefinition.containerDefinitions[].environment'
# Any secrets here are visible to anyone with ecs:DescribeTaskDefinition
```

**Fix:** Use AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault. Never put secrets in environment variables for production workloads.

---

## M08 — Permissive Cross-Account Trust

**STRIDE:** Elevation of Privilege, Spoofing
**Severity:** High
**Frequency:** Common in multi-account environments

**What it is:** IAM roles or resource policies that allow any AWS account (`"AWS": "*"`) or any principal to assume them or access resources, without conditions. A confused deputy attack vector.

**Detection:**
```bash
# AWS — find roles that trust all AWS accounts
aws iam list-roles | jq -r '.Roles[].Arn' | while read role; do
  trust=$(aws iam get-role --role-name "$(basename $role)" | \
    jq -r '.Role.AssumeRolePolicyDocument.Statement[].Principal.AWS // empty')
  if echo "$trust" | grep -q '"\*"'; then
    echo "TRUSTS ALL ACCOUNTS: $role"
  fi
done

# Find S3 bucket policies allowing cross-account access without conditions
aws s3api list-buckets --query 'Buckets[].Name' --output text | \
  tr '\t' '\n' | while read b; do
    policy=$(aws s3api get-bucket-policy --bucket "$b" 2>/dev/null | \
      jq -r '.Policy' | jq 'if .Statement[].Principal == "*" then . else empty end')
    if [ -n "$policy" ]; then echo "CROSS-ACCOUNT POLICY: $b"; fi
  done
```

---

## M09 — No Resource Tagging / Untracked Resources

**STRIDE:** Denial of Service (cost attack), Information Disclosure
**Severity:** Medium
**Frequency:** Very common — creates shadow IT in the cloud

**What it is:** Cloud resources created without mandatory tags for owner, environment, and cost centre — making it impossible to track who created them, whether they are still needed, or which team is responsible for securing them. Orphaned resources become unpatched attack surface.

**Detection:**
```bash
# AWS — find EC2 instances without required tags
aws ec2 describe-instances \
  --query "Reservations[].Instances[?!not_null(Tags[?Key=='Environment'])].[InstanceId,LaunchTime]" \
  --output table

# AWS Config rule — detect untagged resources
aws configservice put-config-rule --config-rule '{
  "ConfigRuleName": "required-tags",
  "Source": {"Owner": "AWS", "SourceIdentifier": "REQUIRED_TAGS"},
  "InputParameters": "{\"tag1Key\":\"Environment\",\"tag2Key\":\"Owner\",\"tag3Key\":\"Project\"}"
}'

# Azure — resources without required tags
az resource list --query "[?tags.Environment==null].{name:name,type:type,rg:resourceGroup}" -o table
```

---

## M10 — Disabled Threat Detection Services

**STRIDE:** Repudiation
**Severity:** High
**Frequency:** Common — especially in development accounts

**What it is:** GuardDuty (AWS), Security Command Center (GCP), or Defender for Cloud (Azure) disabled or not configured. Without these services, active attacks — credential theft, cryptomining, data exfiltration — go undetected.

**Detection:**
```bash
# AWS — check GuardDuty status in all regions
for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  status=$(AWS_DEFAULT_REGION=$region aws guardduty list-detectors 2>/dev/null | \
    jq -r '.DetectorIds[0] // "NOT_ENABLED"')
  echo "$region: GuardDuty=$status"
done

# GCP — check Security Command Center status
gcloud scc organizations ORGANIZATION_ID sources list

# Azure — check Defender for Cloud pricing tier
az security pricing list \
  --query "[?pricingTier=='Free'].{name:name,tier:pricingTier}" \
  --output table
# Any "Free" tier = threat detection disabled for that resource type
```

---

## Cloud misconfiguration detection — all-in-one tools

```bash
# AWS — Prowler (most comprehensive)
prowler aws --compliance cis_aws_2.0 --output-modes json html

# GCP — Prowler
prowler gcp --compliance cis_gcp_2.0

# Azure — Prowler
prowler azure --compliance cis_azure_2.0

# Multi-cloud — ScoutSuite
scout aws && scout gcp && scout azure

# IaC scanning — Checkov (before deploy)
checkov -d infra/ --framework terraform --output sarif

# CI/CD integration
# Run Checkov on every PR — block merge on CRITICAL findings
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/gcp-baseline/"><span class="ref-label">Cloud</span>GCP Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/azure-baseline/"><span class="ref-label">Cloud</span>Azure Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-threat-model/"><span class="ref-label">Cloud</span>Cloud Threat Model Template</a>
  <a class="ref-card" href="/wiki/owasp-top10/a05-security-misconfiguration/"><span class="ref-label">OWASP</span>A05 Security Misconfiguration</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
</div>

</div>
