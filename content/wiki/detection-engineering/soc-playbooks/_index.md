---
title: "SOC Playbook Templates"
date: 2026-08-05
tags: ["SOC", "playbooks", "incident-response", "detection-engineering", "triage"]
categories: ["detection-engineering"]
description: "SOC response playbooks for the most common alert types — brute force, phishing, malware, data exfiltration, ransomware, and cloud account compromise."
showToc: true
layout: "single"
---

## What is a SOC playbook?

A SOC playbook is a documented, step-by-step procedure that a SOC analyst follows when a specific alert type fires. Good playbooks mean:
- Consistent response regardless of which analyst is on duty
- Junior analysts can handle complex alerts
- Response time decreases — no thinking, just executing
- Evidence is collected systematically — useful for later forensics

Every detection rule should have a linked playbook. If an alert fires and the analyst doesn't know what to do — the playbook is missing.

---

## Playbook template structure

```yaml
playbook_id: "PB-001"
title: "Brute Force Login Attack"
version: "2.1"
last_updated: "2026-08-05"
author: "SOC Team"
linked_detection_rules:
  - "UC-AUTH-01"
  - "sigma/brute-force-login.yml"
linked_attack_techniques:
  - "T1110"
  - "T1110.004"
severity: high
estimated_time: "20–40 minutes"

trigger: |
  Alert fires when > 20 failed login attempts from a single IP
  within a 5-minute window.

triage_steps: []
investigation_steps: []
containment_steps: []
remediation_steps: []
escalation_criteria: []
evidence_to_collect: []
closure_criteria: []
```

---

## Playbook 1 — Brute Force / Credential Stuffing

**Alert:** Multiple failed authentication attempts
**ATT&CK:** T1110, T1110.004
**Severity:** High
**SLA:** Acknowledge within 1 hour, contain within 4 hours

### Triage (5 minutes)
```
□ 1. Confirm alert is not from a known scanner or automated tool
       → Check source IP against known tool list
       → Check if IP is internal (pen test / red team activity?)

□ 2. Check the targeted account
       → Is it a real user account or a honeypot?
       → Is it a privileged account (admin, service account)?
       → Is it an account that exists (user enumeration vs brute force)?

□ 3. Check if any attempt succeeded
       → Search for auth_success from same IP within ±30 minutes
       → If successful login found → ESCALATE IMMEDIATELY → Playbook PB-003
```

### Investigation (10 minutes)
```
□ 4. Profile the source IP
       → GeoIP lookup — expected country?
       → Threat intel check (VirusTotal, AbuseIPDB)
       → Is this a Tor exit node or VPN?
       → How many accounts were targeted (stuffing vs single-account brute force)?

□ 5. Determine attack type
       → Many IPs, one account = distributed brute force
       → One IP, many accounts = credential stuffing
       → One IP, one account = targeted brute force

□ 6. Review account activity
       → Any successful logins before the attack started?
       → Any suspicious activity in the 24 hours before alert?
       → Is the account currently locked?
```

### Containment (5 minutes)
```
□ 7. Block source IP at WAF / firewall (if external)
       → Document IP, timestamp, and reason for block
       → Set block expiry (24 hours for first offence, permanent after 3)

□ 8. Lock affected account if targeted single account
       → Notify user via secondary channel (phone or manager)
       → Do NOT email the potentially compromised account

□ 9. Force password reset if any successful login occurred
```

### Remediation
```
□ 10. Review rate limiting configuration — is threshold appropriate?
□ 11. Check if MFA is enabled on targeted account — if not, raise ticket
□ 12. Review whether CAPTCHA is implemented on login endpoint
□ 13. Add IP to threat intel blocklist for future correlation
```

### Evidence to collect
```
□ Source IP(s) and request timestamps
□ List of targeted usernames
□ Number of attempts and time range
□ Threat intel report for source IP
□ Screenshot of alert and SIEM query
□ Firewall block rule reference
```

### Escalation criteria
```
Escalate to Incident Response if:
  → Any successful login during or after the attack
  → Target is a privileged account (admin, C-suite, finance)
  → Attack originated from an APT-linked IP
  → More than 1,000 accounts targeted (data breach risk)
```

---

## Playbook 2 — Phishing Email Reported

**Alert:** User reports suspicious email / email gateway detection
**ATT&CK:** T1566.001, T1566.002
**Severity:** High (Critical if executive targeted)
**SLA:** Acknowledge within 15 minutes

### Triage (5 minutes)
```
□ 1. Retrieve the email sample safely
       → Pull from email gateway quarantine — DO NOT open attachment directly
       → Use sandbox environment for any URL or attachment analysis

□ 2. Quick assessment
       → Is the sender spoofing a known domain?
       → Does the email contain a link or attachment?
       → Has anyone clicked the link or opened the attachment?
       → How many recipients received this email?
```

### Investigation (15 minutes)
```
□ 3. Analyse the email
       → Extract all URLs from email body and attachments
       → Check URLs against VirusTotal, URLScan.io
       → Extract file attachments — check hashes against VirusTotal
       → Check sender domain registration date (new domain = suspicious)
       → Review email headers — trace routing path

□ 4. Check for clicks / execution
       → Search proxy logs for connections to extracted URLs
         from all recipients in past 24 hours
       → Search EDR for any file execution matching attachment hashes
       → Search for any new processes spawned from Outlook/mail client

□ 5. Scope the campaign
       → Search email gateway for similar emails (same sender, same subject, same URL domain)
       → Identify all recipients organisation-wide
```

### Containment (10 minutes)
```
□ 6. Remove email from all inboxes
       → Use email gateway admin console to search and delete
       → Purge from sent items and deleted items

□ 7. Block malicious indicators at gateway
       → Block sender domain / email address
       → Block URLs at web proxy
       → Block file hashes in EDR

□ 8. Isolate any machines that clicked/executed
       → If EDR shows execution: quarantine endpoint immediately
       → Notify user and their manager
       → Collect forensic image before remediation
```

### Evidence to collect
```
□ Original email (EML format) from quarantine
□ Full email headers
□ List of all recipients
□ URL scan reports (VirusTotal, URLScan)
□ File hash analysis (if attachment)
□ Proxy log entries showing any clicks
□ EDR logs from any affected endpoints
□ Timeline of events
```

### Escalation criteria
```
Escalate to Incident Response if:
  → Any user clicked the link or opened the attachment
  → Any EDR alert for malicious execution on a recipient's machine
  → Target is an executive or privileged user
  → Campaign appears targeted (spear phishing) rather than bulk
```

---

## Playbook 3 — Suspicious Process / Malware Indicator

**Alert:** EDR detection, malicious process, or malware IOC match
**ATT&CK:** T1059, T1055, T1003 (varies)
**Severity:** Critical
**SLA:** Acknowledge within 15 minutes, contain within 1 hour

### Triage (5 minutes)
```
□ 1. Assess severity
       → Is the file executing or just detected?
       → What process spawned it?
       → What user context is it running in (user vs admin)?
       → Is the host a critical asset (server, C-suite, finance)?

□ 2. Check EDR for lateral movement
       → Has this host made any unusual network connections?
       → Has it accessed other hosts on the network?
       → Has it written any new files to unusual locations?
```

### Investigation (20 minutes)
```
□ 3. Collect host forensics via EDR
       → Running processes at time of detection
       → Network connections (established and listening)
       → Recently created files
       → Recently modified registry keys
       → Scheduled tasks and startup items

□ 4. Analyse the malicious file
       → Submit hash to VirusTotal, Hybrid Analysis, Any.run
       → Check if it matches any known malware family
       → Extract IOCs: C2 IPs, domains, file paths, registry keys

□ 5. Determine scope
       → Search EDR for same file hash across all endpoints
       → Search for C2 IP/domain in proxy and firewall logs
       → Check for lateral movement from infected host
```

### Containment (immediate)
```
□ 6. Isolate the infected host
       → EDR network isolation / quarantine
       → Document: hostname, IP, user, time of isolation

□ 7. Disable user account if compromised credentials suspected
       → Reset password, revoke all active sessions
       → Check for OAuth tokens and revoke

□ 8. Block IOCs across the estate
       → Block C2 IPs and domains at firewall/proxy
       → Block file hashes in EDR across all endpoints
       → Update threat intel platform with new IOCs
```

### Evidence to collect
```
□ EDR alert details and process tree
□ Memory dump of suspicious process (if possible)
□ Full forensic image of endpoint (before reimaging)
□ Network logs: all connections from infected host (72 hours)
□ Authentication logs for affected user (30 days)
□ VirusTotal / sandbox analysis report
□ Timeline of infection → detection → isolation
```

---

## Playbook 4 — Data Exfiltration Alert

**Alert:** Large outbound data transfer or DLP alert
**ATT&CK:** T1041, T1567, T1048
**Severity:** Critical
**SLA:** Acknowledge within 15 minutes

### Triage (5 minutes)
```
□ 1. Determine what data may have been exfiltrated
       → What is the destination? (known cloud service vs unknown IP)
       → What is the data volume? (MB vs GB)
       → What user / process initiated the transfer?
       → Is the source system in a sensitive data zone?

□ 2. Distinguish from legitimate activity
       → Is this a scheduled backup to approved destination?
       → Is this an employee doing a large legitimate download?
       → Check against list of approved data transfer tools and destinations
```

### Investigation (20 minutes)
```
□ 3. Identify what was transferred
       → Review proxy/DLP logs for file names or content categories
       → Check source host for recently accessed sensitive files
       → Review endpoint activity for file archiving / compression (zip, rar, tar)
       → Check if data was encrypted before transfer (exfiltration prep)

□ 4. Build the timeline
       → When did the user first access the sensitive data?
       → When did the exfiltration occur?
       → Any other anomalous activity before or after?

□ 5. Identify the exfiltration channel
       → HTTP/HTTPS upload (proxy logs)
       → Email (email gateway logs)
       → Cloud sync (OneDrive, Dropbox, Google Drive activity)
       → Physical media (USB — check endpoint logs)
       → DNS tunneling (DNS query logs)
```

### Containment
```
□ 6. Block destination at proxy/firewall (if external)
□ 7. Preserve forensic evidence — do NOT immediately remove access
       (may tip off insider — coordinate with HR/Legal first)
□ 8. Notify: Security Manager, Legal, HR, Privacy Officer
□ 9. Determine if data breach notification required (GDPR 72 hours)
```

### Escalation criteria
```
Escalate to Incident Response AND Legal/Privacy team if:
  → Personal data (PII, health, financial) involved
  → Volume > 10,000 records
  → Destination is a competitor or nation-state actor
  → Insider threat suspected (resignation, disciplinary action pending)
  → Regulatory notification may be required
```

---

## Playbook 5 — Cloud Account Compromise

**Alert:** Unusual cloud API activity, impossible travel, new admin account
**ATT&CK:** T1078.004, T1136.003, T1098.003
**Severity:** Critical
**SLA:** Acknowledge within 15 minutes, contain within 30 minutes

### Triage (5 minutes)
```
□ 1. Identify the compromised account
       → Is it a human account or a service account?
       → What level of privilege does it have?
       → What resources can it access?

□ 2. Assess immediate impact
       → What API calls have been made since the anomaly started?
       → Have any resources been created, modified, or deleted?
       → Have any IAM changes been made?
       → Has any data been accessed or downloaded?
```

### Investigation (15 minutes)
```
□ 3. Review CloudTrail / audit logs
       → All API calls from the account in past 24 hours
       → Any IAM policy changes (privilege escalation)
       → Any new resources created (cryptomining EC2s, outbound data pipelines)
       → Any secrets accessed (Secrets Manager, Parameter Store)
       → Any S3 data downloads or bucket policy changes

□ 4. Identify how compromise occurred
       → Phishing → OAuth token theft?
       → Leaked access key (check GitHub, Pastebin, dark web)?
       → Credential stuffing on cloud console?
       → Compromised developer workstation?

□ 5. Determine blast radius
       → What did the attacker enumerate? (ListBuckets, DescribeInstances etc.)
       → What was accessed or exfiltrated?
       → Did they pivot to other accounts or services?
```

### Containment (immediate)
```
□ 6. Revoke all sessions for the compromised account
       → AWS: aws iam delete-login-profile && revoke all session tokens
       → GCP: revoke OAuth tokens
       → Azure: revoke all refresh tokens via Entra ID

□ 7. Disable / rotate compromised credentials
       → Disable access key immediately
       → Rotate any secrets the account accessed

□ 8. Remove any resources created by the attacker
       → Terminate unauthorised EC2 instances
       → Delete unauthorised IAM users or roles
       → Revert IAM policy changes

□ 9. Apply SCPs / deny policies to limit blast radius during investigation
```

### Evidence to collect
```
□ CloudTrail logs: full API call history 72 hours before and after compromise
□ IAM credential report: access key last used timestamps
□ List of all resources created/modified during compromise window
□ Network flow logs showing unusual egress
□ List of all secrets and data accessed
□ Copy of any new IAM policies or roles created
```

---

## Playbook index

| ID | Playbook | Alert types | Severity |
|---|---|---|---|
| PB-001 | Brute Force / Credential Stuffing | UC-AUTH-01, UC-AUTH-02 | High |
| PB-002 | Phishing Email | Email gateway, user report | High |
| PB-003 | Malware / Suspicious Process | EDR alerts | Critical |
| PB-004 | Data Exfiltration | DLP, large transfer | Critical |
| PB-005 | Cloud Account Compromise | CloudTrail, impossible travel | Critical |
| PB-006 | Ransomware | EDR mass encryption | Critical |
| PB-007 | Insider Threat | Bulk download, off-hours access | High |
| PB-008 | DDoS Attack | Network monitoring | High |
| PB-009 | Privilege Escalation | LSASS, new admin | Critical |
| PB-010 | Supply Chain Alert | Dependency CVE, build anomaly | High |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Case Library</a>
  <a class="ref-card" href="/wiki/detection-engineering/sigma-rules/"><span class="ref-label">Detection</span>Sigma Rule Writing Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/alert-fatigue/"><span class="ref-label">Detection</span>Alert Fatigue Guide</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence — MON domain</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming</a>
</div>

</div>
