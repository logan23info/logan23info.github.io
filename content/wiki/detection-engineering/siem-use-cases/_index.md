---
title: "SIEM Use Case Library"
date: 2026-08-05
tags: ["SIEM", "detection", "use-cases", "ATT&CK", "alerts"]
categories: ["detection-engineering"]
description: "50+ SIEM use cases across authentication, network, endpoint, cloud, and insider threat — each with MITRE ATT&CK mapping, log source, query logic, and severity."
showToc: true
layout: "single"
---

## How to use this library

Each use case includes:
- **ATT&CK technique** — links to MITRE ATT&CK for full technique detail
- **Log source** — what must be enabled and ingested for this to work
- **Detection logic** — pseudocode query adaptable to any SIEM
- **Severity** — Critical / High / Medium / Low
- **False positive risk** — how noisy this rule is likely to be

Use these as a starting point. Every environment is different — tune thresholds and conditions to match your baseline before deploying.

---

## Domain 1 — Authentication & Identity

### UC-AUTH-01: Brute Force Login Attack
**ATT&CK:** T1110 — Brute Force
**Log source:** Authentication logs (Active Directory, Okta, Azure AD, application logs)
**Severity:** High

```
Detection logic:
  event = "authentication_failure"
  GROUP BY source_ip, username
  WHERE count(*) > 10
  WITHIN 5 minutes
  → alert with source_ip, username, failure_count

Tuning:
  Exclude: known vulnerability scanners, load balancers
  Threshold: adjust based on baseline — start high, tune down
```

---

### UC-AUTH-02: Credential Stuffing (Many Usernames, One IP)
**ATT&CK:** T1110.004 — Credential Stuffing
**Log source:** Authentication logs, WAF logs
**Severity:** High

```
Detection logic:
  event = "authentication_failure"
  GROUP BY source_ip
  WHERE count(DISTINCT username) > 20
  WITHIN 10 minutes
  → alert: credential stuffing pattern

Key differentiator from brute force:
  Brute force = many passwords, one username
  Credential stuffing = many usernames, one IP
```

---

### UC-AUTH-03: Successful Login After Multiple Failures
**ATT&CK:** T1110 — Brute Force (successful)
**Log source:** Authentication logs
**Severity:** High

```
Detection logic:
  SEQUENCE WITHIN 30 minutes:
    1. auth_failure WHERE username = X AND count > 5
    2. auth_success WHERE username = X
  → alert: possible successful brute force
```

---

### UC-AUTH-04: Login From New Country
**ATT&CK:** T1078 — Valid Accounts
**Log source:** Authentication logs with GeoIP enrichment
**Severity:** Medium

```
Detection logic:
  event = "auth_success"
  WHERE country NOT IN user_baseline_countries(username, 90_days)
  AND country NOT IN [approved_travel_countries]
  → alert: first-time country login for user

Enrichment needed: GeoIP database, user travel calendar (optional)
```

---

### UC-AUTH-05: MFA Bypass / Fatigue Attack
**ATT&CK:** T1621 — MFA Request Generation
**Log source:** MFA provider logs (Okta, Duo, Azure MFA)
**Severity:** Critical

```
Detection logic:
  event = "mfa_push_sent"
  GROUP BY username
  WHERE count(*) > 5
  WITHIN 10 minutes
  → alert: possible MFA fatigue attack

Also detect:
  event = "mfa_denied_by_user" followed by "mfa_approved"
  within 2 minutes (user approved after denying = possible fatigue)
```

---

### UC-AUTH-06: Impossible Travel
**ATT&CK:** T1078 — Valid Accounts
**Log source:** Authentication logs with GeoIP
**Severity:** High

```
Detection logic:
  SEQUENCE for same username:
    1. auth_success from country=A, timestamp=T1
    2. auth_success from country=B, timestamp=T2
  WHERE distance(A, B) / time_diff(T1, T2) > 900 km/h
  → alert: physically impossible travel (account sharing or compromise)
```

---

### UC-AUTH-07: Admin Account Created Outside Business Hours
**ATT&CK:** T1136 — Create Account
**Log source:** Active Directory / Entra ID / AWS IAM logs
**Severity:** High

```
Detection logic:
  event = "user_created" OR event = "group_member_added"
  WHERE target_group IN [admin_groups]
  AND hour(timestamp) NOT BETWEEN 8 AND 18
  AND day_of_week(timestamp) NOT IN [Monday..Friday]
  → alert: after-hours privileged account change
```

---

### UC-AUTH-08: Service Account Interactive Login
**ATT&CK:** T1078.003 — Local Accounts
**Log source:** Windows Security Event Log (Event ID 4624)
**Severity:** Medium

```
Detection logic:
  event_id = 4624  (successful logon)
  WHERE account_name LIKE "svc_%" OR account_name LIKE "sa_%"
  AND logon_type IN [2, 10]  (interactive or remote interactive)
  → alert: service account used for interactive login (should use type 5 only)
```

---

## Domain 2 — Privilege Escalation & Lateral Movement

### UC-PRIV-01: New Local Administrator Added
**ATT&CK:** T1098 — Account Manipulation
**Log source:** Windows Security Event Log (Event ID 4732)
**Severity:** High

```
Detection logic:
  event_id = 4732  (member added to security-enabled local group)
  WHERE group_name = "Administrators"
  → alert: local admin group modified
```

---

### UC-PRIV-02: LSASS Memory Access
**ATT&CK:** T1003.001 — LSASS Memory
**Log source:** EDR (Sysmon Event ID 10, CrowdStrike, Defender)
**Severity:** Critical

```
Detection logic:
  event = "process_access"
  WHERE target_process = "lsass.exe"
  AND source_process NOT IN [known_legitimate_processes]
  AND granted_access IN ["0x1010", "0x1438", "0x143a", "0x1fffff"]
  → alert: LSASS memory access — possible credential dumping
```

---

### UC-PRIV-03: Pass-the-Hash (Lateral Movement)
**ATT&CK:** T1550.002 — Pass the Hash
**Log source:** Windows Security Event Log (Event ID 4624)
**Severity:** High

```
Detection logic:
  event_id = 4624
  WHERE logon_type = 3  (network logon)
  AND auth_package = "NTLM"
  AND account_domain = "-"  (no domain = NTLM hash auth)
  AND logon_process = "NtLmSsp"
  AND target_host != source_host
  → alert: NTLM pass-the-hash pattern
```

---

### UC-PRIV-04: Kerberoasting
**ATT&CK:** T1558.003 — Kerberoasting
**Log source:** Windows Security Event Log (Event ID 4769)
**Severity:** High

```
Detection logic:
  event_id = 4769  (Kerberos service ticket request)
  WHERE ticket_encryption_type = "0x17"  (RC4 — weak, used by Kerberoasting tools)
  AND account_name NOT IN [known_service_accounts]
  GROUP BY source_ip
  WHERE count(*) > 5 WITHIN 1 minute
  → alert: Kerberoasting attempt — bulk RC4 ticket requests
```

---

### UC-PRIV-05: Remote Service Execution (PsExec / WMI)
**ATT&CK:** T1021.002 — SMB/Windows Admin Shares
**Log source:** Windows Security Event Log, Sysmon
**Severity:** High

```
Detection logic:
  event = "service_created"
  WHERE service_name LIKE "PSEXESVC%" OR service_path LIKE "%\admin$\%"
  OR (
    event_id = 4688  (process creation)
    WHERE parent_process = "WmiPrvSE.exe"
    AND new_process IN ["cmd.exe", "powershell.exe", "wscript.exe"]
  )
  → alert: remote execution via PsExec or WMI
```

---

## Domain 3 — Command & Control / Network

### UC-NET-01: DNS over HTTPS (DoH) Beaconing
**ATT&CK:** T1071.004 — DNS (C2)
**Log source:** Network proxy logs, DNS logs
**Severity:** Medium

```
Detection logic:
  destination_port = 443
  AND destination_domain IN ["dns.google", "cloudflare-dns.com", "1.1.1.1"]
  GROUP BY source_ip
  WHERE count(*) > 100 WITHIN 1 hour
  → alert: unusual DoH traffic volume — possible C2 tunnel
```

---

### UC-NET-02: Long DNS TTL / DNS Tunneling
**ATT&CK:** T1071.004 — DNS
**Log source:** DNS server logs
**Severity:** Medium

```
Detection logic:
  event = "dns_query"
  WHERE LENGTH(query_name) > 50  (long subdomain = data in DNS)
  OR count(DISTINCT query_name UNDER same_domain) > 200 WITHIN 1 hour
  → alert: possible DNS tunneling (data exfiltration via DNS)
```

---

### UC-NET-03: Beaconing — Regular Outbound Intervals
**ATT&CK:** T1071 — Application Layer Protocol
**Log source:** Proxy logs, firewall logs, network flow
**Severity:** High

```
Detection logic:
  GROUP BY source_ip, destination_ip
  CALCULATE std_deviation(time_between_connections)
  WHERE std_deviation < 30 seconds  (very regular = automated)
  AND count(*) > 20 WITHIN 1 hour
  AND destination NOT IN [known_good_domains]
  → alert: regular beaconing pattern — possible C2
```

---

### UC-NET-04: Large Outbound Data Transfer
**ATT&CK:** T1041 — Exfiltration Over C2 Channel
**Log source:** Firewall/proxy logs with bytes transferred
**Severity:** High

```
Detection logic:
  GROUP BY source_ip, destination_ip
  WHERE SUM(bytes_out) > 500MB WITHIN 1 hour
  AND destination NOT IN [approved_cloud_services, backup_destinations]
  AND destination NOT IN [CDN_ranges]
  → alert: large outbound transfer to unknown destination
```

---

## Domain 4 — Endpoint & Process

### UC-PROC-01: Living-off-the-Land Binary Abuse
**ATT&CK:** T1218 — System Binary Proxy Execution
**Log source:** EDR, Sysmon (Event ID 1)
**Severity:** High

```
Detection logic:
  event = "process_created"
  WHERE process_name IN [
    "certutil.exe", "regsvr32.exe", "rundll32.exe", "mshta.exe",
    "wscript.exe", "cscript.exe", "bitsadmin.exe", "odbcconf.exe"
  ]
  AND (
    command_line CONTAINS "http" OR
    command_line CONTAINS "urlcache" OR
    command_line CONTAINS ".ps1" OR
    parent_process NOT IN [known_legitimate_parents]
  )
  → alert: LOLBin abuse — possible malware execution
```

---

### UC-PROC-02: PowerShell Encoded Command
**ATT&CK:** T1059.001 — PowerShell
**Log source:** Windows Event Log 4688, PowerShell logs (4103, 4104)
**Severity:** High

```
Detection logic:
  event = "process_created"
  WHERE process_name = "powershell.exe"
  AND (
    command_line CONTAINS "-EncodedCommand" OR
    command_line CONTAINS "-enc " OR
    command_line CONTAINS "-e " AND LENGTH(base64_block) > 100
  )
  → alert: PowerShell encoded command — obfuscation indicator
```

---

### UC-PROC-03: Script Interpreter Spawned by Office Application
**ATT&CK:** T1566.001 — Phishing with Attachment
**Log source:** EDR, Sysmon
**Severity:** Critical

```
Detection logic:
  event = "process_created"
  WHERE parent_process IN ["WINWORD.EXE", "EXCEL.EXE", "POWERPNT.EXE", "OUTLOOK.EXE"]
  AND child_process IN ["cmd.exe", "powershell.exe", "wscript.exe", "mshta.exe",
                        "cmstp.exe", "regsvr32.exe"]
  → alert: Office application spawned script interpreter — malicious macro
```

---

## Domain 5 — Cloud & Infrastructure

### UC-CLOUD-01: AWS Root Account Login
**ATT&CK:** T1078.004 — Cloud Accounts
**Log source:** AWS CloudTrail
**Severity:** Critical

```
Detection logic:
  source = cloudtrail
  WHERE userIdentity.type = "Root"
  AND eventName = "ConsoleLogin"
  → alert immediately: root account console login

No tuning needed — root login is always anomalous
```

---

### UC-CLOUD-02: IAM Policy Attached to User (Privilege Escalation)
**ATT&CK:** T1098.003 — Additional Cloud Credentials
**Log source:** AWS CloudTrail
**Severity:** High

```
Detection logic:
  source = cloudtrail
  WHERE eventName IN ["AttachUserPolicy", "AttachGroupPolicy", "AttachRolePolicy",
                      "PutUserPolicy", "PutGroupPolicy", "PutRolePolicy"]
  AND requestParameters.policyArn CONTAINS "AdministratorAccess"
  → alert: admin policy attached

Also detect:
  eventName = "CreatePolicyVersion" (new version may escalate privileges)
```

---

### UC-CLOUD-03: AWS S3 Bucket Made Public
**ATT&CK:** T1530 — Data from Cloud Storage
**Log source:** AWS CloudTrail
**Severity:** Critical

```
Detection logic:
  source = cloudtrail
  WHERE eventName IN ["PutBucketAcl", "PutBucketPolicy"]
  AND (
    requestParameters CONTAINS "AllUsers" OR
    requestParameters CONTAINS "AuthenticatedUsers" OR
    requestParameters.bucketPolicy CONTAINS '"Principal":"*"'
  )
  → alert immediately: S3 bucket policy allows public access
```

---

### UC-CLOUD-04: EC2 Instance Metadata Service Accessed (SSRF Indicator)
**ATT&CK:** T1552.005 — Cloud Instance Metadata API
**Log source:** VPC Flow Logs, application logs
**Severity:** High

```
Detection logic:
  source = vpc_flow_logs OR application_proxy_logs
  WHERE destination_ip = "169.254.169.254"
  AND destination_port = 80
  AND source NOT IN [known_monitoring_agents]
  → alert: metadata service accessed — possible SSRF
```

---

### UC-CLOUD-05: Unusual API Call Volume (Reconnaissance)
**ATT&CK:** T1526 — Cloud Service Discovery
**Log source:** AWS CloudTrail, GCP Audit Logs
**Severity:** Medium

```
Detection logic:
  source = cloudtrail
  WHERE eventName IN ["ListBuckets", "DescribeInstances", "ListUsers",
                      "GetCallerIdentity", "ListRoles", "DescribeSecurityGroups"]
  GROUP BY userIdentity.arn
  WHERE count(*) > 50 WITHIN 5 minutes
  → alert: enumeration / reconnaissance activity
```

---

## Domain 6 — Insider Threat

### UC-INSIDER-01: Bulk File Download
**ATT&CK:** T1005 — Data from Local System
**Log source:** DLP, SharePoint/OneDrive logs, proxy logs
**Severity:** High

```
Detection logic:
  event = "file_download" OR event = "file_copy"
  GROUP BY username
  WHERE count(*) > 100 WITHIN 1 hour
  OR total_bytes > 1GB WITHIN 1 hour
  → alert: bulk data download — possible exfiltration or resignation
```

---

### UC-INSIDER-02: Access to Sensitive Data Outside Normal Hours
**ATT&CK:** T1078 — Valid Accounts
**Log source:** Application audit logs, DLP
**Severity:** Medium

```
Detection logic:
  event = "data_access"
  WHERE data_classification IN ["restricted", "confidential"]
  AND hour(timestamp) NOT BETWEEN 7 AND 20
  AND username NOT IN [known_night_shift_workers]
  → alert: sensitive data access outside business hours
```

---

### UC-INSIDER-03: Corporate Data Sent to Personal Email / Cloud
**ATT&CK:** T1567 — Exfiltration to Web Service
**Log source:** Email gateway, proxy/DLP logs
**Severity:** High

```
Detection logic:
  event = "email_sent"
  WHERE recipient_domain IN [personal_email_domains]  # gmail.com, yahoo.com, etc.
  AND (attachment_count > 0 OR body_size > 10KB)
  AND sender_domain = corporate_domain
  → alert: corporate data to personal email

OR:
  event = "file_upload"
  WHERE destination IN ["dropbox.com", "wetransfer.com", "mega.nz"]
  AND NOT destination IN [approved_cloud_services]
  → alert: upload to unapproved cloud storage
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/detection-engineering/sigma-rules/"><span class="ref-label">Detection</span>Sigma Rule Writing Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/alert-fatigue/"><span class="ref-label">Detection</span>Alert Fatigue Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/soc-playbooks/"><span class="ref-label">Detection</span>SOC Playbook Templates</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
</div>

</div>
