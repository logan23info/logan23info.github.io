---
title: "Sigma Rule Writing Guide"
date: 2026-08-05
tags: ["Sigma", "detection", "SIEM", "rules", "ATT&CK", "detection-engineering"]
categories: ["detection-engineering"]
description: "Complete guide to writing, testing, and deploying Sigma detection rules — the vendor-neutral format for SIEM detections."
showToc: true
layout: "single"
---

## What is Sigma?

Sigma is a vendor-neutral, open-source format for writing SIEM detection rules. A Sigma rule written once can be converted to Splunk SPL, Elastic EQL, Microsoft Sentinel KQL, Chronicle YARA-L, and 30+ other SIEM query languages using the `sigma-cli` converter.

**Why Sigma matters:**
- Write once, deploy everywhere — no SIEM vendor lock-in
- Rules are human-readable YAML — reviewable in Git
- Community library of 3,000+ rules (SigmaHQ)
- Direct integration with MITRE ATT&CK
- Enables detection-as-code — rules tested in CI/CD

**GitHub:** https://github.com/SigmaHQ/sigma
**Rule library:** https://github.com/SigmaHQ/sigma/tree/master/rules

---

## Sigma rule anatomy

```yaml
title: Suspicious PowerShell Encoded Command Execution     # Human-readable name
id: a2b2f5c6-3d4e-5f6a-7b8c-9d0e1f2a3b4c                 # UUID — generate with uuidgen
status: production        # test | experimental | production | stable | deprecated
description: |
  Detects PowerShell execution with encoded command arguments,
  a common technique used by malware to obfuscate command content.
references:               # link to ATT&CK, CVEs, blog posts
  - https://attack.mitre.org/techniques/T1059/001/
  - https://blogs.blackberry.com/en/2023/01/powershell-evasion-techniques
author: Logan
date: 2026-08-05
modified: 2026-08-05
tags:
  - attack.execution
  - attack.t1059.001
  - attack.defense_evasion
  - attack.t1027

# ── Log source ──────────────────────────────────────────────────────
logsource:
  category: process_creation    # generic category — works across platforms
  product: windows              # windows | linux | macos

# ── Detection logic ─────────────────────────────────────────────────
detection:
  selection:
    Image|endswith:
      - '\powershell.exe'
      - '\pwsh.exe'
    CommandLine|contains:
      - ' -EncodedCommand '
      - ' -enc '
      - ' -e '
  filter_legitimate:
    # Exclude known-good encoded commands from management tools
    ParentImage|endswith:
      - '\sccm.exe'
      - '\configmgr.exe'
  condition: selection and not filter_legitimate

# ── Context ─────────────────────────────────────────────────────────
falsepositives:
  - Legitimate administrative scripts using encoded commands
  - Software management tools (SCCM, Intune)
  - Developer tooling (Chocolatey, Boxstarter)
level: high          # informational | low | medium | high | critical
```

---

## Log source categories

Sigma uses generic categories that map to specific log sources per SIEM:

| Category | Windows source | Linux source | SIEM field |
|---|---|---|---|
| `process_creation` | Sysmon Event 1, Event 4688 | Auditd, auditbeat | Image, CommandLine, ParentImage |
| `network_connection` | Sysmon Event 3 | auditd network | dst_ip, dst_port, src_ip |
| `file_event` | Sysmon Event 11 | auditd file | TargetFilename |
| `registry_event` | Sysmon Event 13 | — | TargetObject |
| `dns_query` | Sysmon Event 22 | auditbeat | query, answer |
| `process_access` | Sysmon Event 10 | — | TargetImage, GrantedAccess |
| `webserver` | IIS / Apache logs | Apache / nginx | cs-uri-stem, status |
| `cloud` (AWS) | CloudTrail | — | eventName, userIdentity |
| `cloud` (Azure) | Activity Log | — | operationName |

---

## Detection conditions — field modifiers

```yaml
# Contains — substring match
CommandLine|contains: '-enc'

# Contains any — OR logic within a single field
CommandLine|contains|all:
  - 'powershell'
  - '-nop'
  - '-w hidden'
# ALL three must be present

# Endswith
Image|endswith: '\cmd.exe'

# Startswith
CommandLine|startswith: 'C:\Windows\Temp\'

# Regular expression
CommandLine|re: '^.*-[Ee][Nn][Cc].*$'

# Case insensitive (default for most SIEMs)
CommandLine|contains|windash: '-enc'    # also matches /enc

# Greater than / less than (numeric fields)
ParentProcessId|gt: 1000
BytesSent|lt: 100

# Null check
CommandLine|is: null
```

## Condition operators

```yaml
# AND — both selections must match
condition: selection_base and selection_encoded

# OR — either selection matches
condition: selection_base or selection_alternate

# NOT — exclude matches
condition: selection and not filter_legitimate

# Count — aggregate detection
condition: selection | count(source_ip) by username > 10

# Near — temporal proximity (not all SIEMs support)
condition: selection_login | near selection_admin_action
timeframe: 5m
```

---

## Writing your first rule — step by step

### Step 1 — Write the detection hypothesis

Before writing YAML, write the hypothesis in plain language:

```
Hypothesis: If an attacker dumps LSASS credentials using Mimikatz,
we would see a process (not lsass.exe itself) accessing lsass.exe
memory with high-privilege access rights (0x1010 or 0x1438),
where the accessing process is not a known security tool.
```

### Step 2 — Identify the log source

```bash
# Check what fields are available in your SIEM for process_access events
# Sysmon Event ID 10 fields:
# - SourceImage (the attacker process)
# - TargetImage (lsass.exe)
# - GrantedAccess (the access rights requested)
# - CallTrace (stack trace — shows if from known DLL)
```

### Step 3 — Build the detection

```yaml
title: LSASS Memory Access by Suspicious Process
id: f7e8d9c0-1a2b-3c4d-5e6f-7a8b9c0d1e2f
status: production
description: Detects access to LSASS process memory by processes that should not access it — indicative of credential dumping tools like Mimikatz.
references:
  - https://attack.mitre.org/techniques/T1003/001/
author: Logan
date: 2026-08-05
tags:
  - attack.credential_access
  - attack.t1003.001
logsource:
  category: process_access
  product: windows
detection:
  selection:
    TargetImage|endswith: '\lsass.exe'
    GrantedAccess|contains:
      - '0x1010'
      - '0x1438'
      - '0x143a'
      - '0x1fffff'
  filter_legitimate:
    SourceImage|contains:
      - '\Windows\System32\'
      - '\Windows\SysWOW64\'
      - '\Program Files\Windows Defender\'
      - '\Program Files (x86)\Windows Defender\'
      - 'MsMpEng.exe'     # Windows Defender
      - 'csrss.exe'       # Windows system
      - 'wininit.exe'
  condition: selection and not filter_legitimate
falsepositives:
  - Security tools performing legitimate credential inspection
  - AV/EDR products accessing LSASS for monitoring
level: critical
```

### Step 4 — Test the rule

```bash
# Install sigma-cli
pip install sigma-cli

# Install SIEM backends
sigma plugin install splunk
sigma plugin install elasticsearch
sigma plugin install sentinel

# Convert to Splunk SPL
sigma convert -t splunk -p splunk_wineventlog rules/lsass-access.yml

# Convert to Elastic EQL
sigma convert -t elasticsearch -p ecs_windows rules/lsass-access.yml

# Convert to Microsoft Sentinel KQL
sigma convert -t sentinel -p sentinel rules/lsass-access.yml

# Validate rule syntax
sigma check rules/lsass-access.yml
```

### Step 5 — Test with Atomic Red Team

```powershell
# Simulate the attack
Import-Module invoke-atomicredteam
Invoke-AtomicTest T1003.001    # LSASS memory dump

# Verify your rule fires in SIEM within 60 seconds
# If it doesn't fire: check log source, check field names, check filter
```

### Step 6 — Tune to reduce false positives

```yaml
# Add exclusions based on what you see in your environment
filter_legitimate:
  SourceImage|contains:
    - '\Windows\System32\'
    - 'CrowdStrikeFalcon'    # add your EDR
    - 'SentinelOne'
    - 'CarbonBlack'
  # Or by process signed by trusted certificate
  SourceImage|contains: '\Symantec\'
```

---

## Sigma rule quality checklist

```
□ title is specific — not "Suspicious Activity"
□ id is a unique UUID
□ status reflects readiness (test → production)
□ description explains what the rule detects AND why it matters
□ references link to ATT&CK technique and supporting research
□ tags include attack.tXXXX.XXX technique ID
□ logsource specifies category and product
□ detection logic is tested against real log data
□ filter excludes known-legitimate processes
□ falsepositives documents expected noise
□ level is calibrated — not everything is critical
□ rule is tested with Atomic Red Team before deployment
□ rule has been through peer review (PR in detection repo)
```

---

## CI/CD pipeline for detection rules

```yaml
# .github/workflows/detection-ci.yml
name: Detection rule validation

on:
  pull_request:
    paths:
      - 'detections/**/*.yml'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install sigma-cli
        run: pip install sigma-cli

      - name: Validate rule syntax
        run: |
          for rule in detections/**/*.yml; do
            sigma check "$rule" && echo "OK: $rule" || exit 1
          done

      - name: Convert to Splunk
        run: |
          sigma convert -t splunk -p splunk_wineventlog detections/ \
            --output-format savedsearches > output/splunk-rules.conf

      - name: Convert to Sentinel
        run: |
          sigma convert -t sentinel -p sentinel detections/ \
            --output-format json > output/sentinel-rules.json

      - name: Upload converted rules
        uses: actions/upload-artifact@v4
        with:
          name: converted-rules
          path: output/
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Case Library</a>
  <a class="ref-card" href="/wiki/detection-engineering/detection-metrics/"><span class="ref-label">Detection</span>Detection Coverage Metrics</a>
  <a class="ref-card" href="/wiki/detection-engineering/alert-fatigue/"><span class="ref-label">Detection</span>Alert Fatigue Guide</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/owasp-top10/a09-logging-failures/"><span class="ref-label">OWASP</span>A09 Logging Failures</a>
</div>

</div>
