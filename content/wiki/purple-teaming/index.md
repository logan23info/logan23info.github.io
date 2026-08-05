---
title: "Purple Teaming"
date: 2026-08-02
tags: ["purple-teaming", "detection-engineering", "MITRE-ATT&CK", "security-engineering", "level-4"]
categories: ["security-engineering"]
description: "Complete guide to Purple Teaming — collaborative red and blue team exercises to validate and improve detection and response capabilities."
showToc: true
weight: 4
---

## What is Purple Teaming?

Purple Teaming is a collaborative security exercise where the Red Team (attackers) and Blue Team (defenders) work together simultaneously. The red team executes attack techniques one at a time, the blue team monitors whether their detection tools catch it, and both teams immediately discuss and fix gaps.

**Red = Attacker. Blue = Defender. Purple = Both working together.**

Unlike traditional red teaming where findings are only shared at the end in a report, purple teaming produces immediate improvements — gaps are fixed in real time during the exercise.

---

## Purple vs Red vs Blue

| Dimension | Red Team | Blue Team | Purple Team |
|---|---|---|---|
| Goal | Achieve attacker objective | Detect and respond | Improve detection coverage |
| Timing | Sequential (attack then report) | Reactive | Simultaneous collaboration |
| Output | Attack narrative | Incident reports | Detection coverage map |
| Feedback loop | Weeks (end of engagement) | After incident | Real-time |
| Improvement | Slow | Slow | Immediate |
| Frequency | Annually | Continuous | Quarterly / monthly |

---

## The Purple Team exercise structure

### Pre-exercise

**1. Define scope using ATT&CK Navigator**

Select the techniques you want to test based on:
- Threat intelligence about actors targeting your sector
- Previous red team findings that weren't detected
- Compliance requirements (e.g. DORA, TIBER)
- Recent high-profile incidents in your industry

Export the technique list as a checklist for the exercise.

**2. Prepare the environment**

- Confirm SIEM and EDR are fully operational
- Ensure log sources are all feeding correctly
- Set up a dedicated exercise channel (Slack/Teams)
- Agree on communication protocol between red and blue

**3. Set up tracking**

Use VECTR (free, open source) or a simple spreadsheet:

```
Technique ID | Name                  | Executed | Alert fired | Log found | Result
T1566.001    | Phishing - Attachment | ✓        | ✗           | ✓         | PARTIAL
T1003.001    | LSASS Memory Dump     | ✓        | ✓           | ✓         | DETECTED
T1021.002    | SMB/Admin Shares      | ✓        | ✗           | ✗         | MISSED
T1486        | Data Encrypted        | ✓        | ✓           | ✓         | DETECTED
```

---

## Exercise execution

### The purple team loop

For each technique:

```
Red executes technique
        ↓
Blue checks SIEM/EDR (5-10 minutes)
        ↓
     Detected?
    ↙         ↘
  YES           NO
   ↓             ↓
Document      Find the log
as detected   evidence manually
              ↓
         Log exists?
        ↙         ↘
      YES           NO
       ↓             ↓
  Write/tune      Fix log
  detection rule  collection
       ↓             ↓
  Re-test         Re-test
```

### Example exercise session

**09:00 — Technique: T1566.001 Spear Phishing**

Red team sends a test phishing email with a benign payload to a test account.

Blue team checks:
- Email gateway logs → email received and delivered
- EDR → macro execution detected? → YES, alert fired
- SIEM → correlation rule triggered? → NO, no SIEM alert

Result: PARTIAL. EDR detects it, SIEM has no correlation rule.
Action: Blue team creates SIEM rule to correlate EDR macro alert with email gateway log.
Re-test: Rule fires correctly. Mark as DETECTED.

---

**10:30 — Technique: T1003.001 LSASS Memory Dump**

Red team runs `mimikatz.exe sekurlsa::logonpasswords` on a test endpoint.

Blue team checks:
- EDR → lsass access by unknown process → Alert fired, process quarantined
- SIEM → alert correlated → YES
- SOC analyst → alert reviewed in under 5 minutes

Result: FULLY DETECTED. No action needed.

---

**11:15 — Technique: T1021.002 SMB Lateral Movement**

Red team connects to a network share on another system using valid credentials.

Blue team checks:
- Network logs → SMB connection logged? → YES in firewall
- SIEM → alert fired? → NO
- EDR → anything? → NO (valid credentials, no malware)

Result: MISSED. Legitimate-looking SMB with valid creds — no rule covers this.
Action: Build a SIEM rule that alerts on SMB connections from workstations to workstations (unusual in most environments). Add user-entity baseline to detect off-hours access.

---

## Detection engineering from purple team findings

Each "MISSED" result becomes a detection engineering task.

### Detection rule lifecycle

```
Purple team finds gap
        ↓
Write detection rule hypothesis
        ↓
Identify required log sources
        ↓
Verify logs are being collected
        ↓
Write SIEM rule / EDR policy
        ↓
Test rule with purple team re-execution
        ↓
Tune to reduce false positives
        ↓
Document and deploy to production
        ↓
Add to regression test suite
```

### Example SIEM rule (Sigma format)

Sigma is a vendor-neutral format for SIEM detection rules:

```yaml
title: Suspicious LSASS Access by Non-System Process
id: 4a1c6c5e-3d8b-4f4a-9c2d-1e0a3b7f8d2c
status: production
description: Detects access to LSASS memory by processes that should not access it
tags:
  - attack.credential_access
  - attack.t1003.001
logsource:
  category: process_access
  product: windows
detection:
  selection:
    TargetImage|endswith: '\lsass.exe'
  filter:
    SourceImage|startswith:
      - 'C:\Windows\System32\'
      - 'C:\Windows\SysWOW64\'
      - 'C:\Program Files\Windows Defender\'
  condition: selection and not filter
falsepositives:
  - Legitimate security tools
  - AV software
level: high
```

---

## Tooling

### Free and open source

| Tool | Purpose |
|---|---|
| VECTR | Purple team exercise tracking and reporting |
| Atomic Red Team | Library of ATT&CK technique test scripts |
| ATT&CK Navigator | Visual ATT&CK coverage mapping |
| Sigma | Vendor-neutral SIEM detection rule format |
| Caldera | Automated adversary emulation (MITRE project) |
| Invoke-AtomicRedTeam | PowerShell runner for Atomic Red Team |

### Running Atomic Red Team tests

```powershell
# Install Atomic Red Team
Install-Module -Name invoke-atomicredteam -Scope CurrentUser

# Import
Import-Module invoke-atomicredteam

# Test T1003.001 — LSASS Memory Dump
Invoke-AtomicTest T1003.001

# List all available tests for a technique
Invoke-AtomicTest T1003.001 -ShowDetails

# Run specific test number
Invoke-AtomicTest T1003.001 -TestNumbers 1

# Clean up after test
Invoke-AtomicTest T1003.001 -Cleanup
```

### VECTR — tracking exercise results

VECTR is a free, open-source platform for tracking purple team exercises:

```bash
# Deploy VECTR with Docker
git clone https://github.com/SecurityRiskAdvisors/VECTR
cd VECTR
docker-compose up -d
# Access at http://localhost:8081
```

---

## Coverage measurement

After each exercise, measure your ATT&CK coverage:

```
Total techniques tested:          45
Fully detected:                   28  (62%)
Partially detected:                8  (18%)
Missed:                            9  (20%)

By tactic:
Initial Access:      4/5 detected  (80%)
Execution:           6/8 detected  (75%)
Persistence:         3/6 detected  (50%)   ← gap
Credential Access:   2/7 detected  (29%)   ← major gap
Lateral Movement:    4/6 detected  (67%)
Exfiltration:        2/3 detected  (67%)
```

This coverage map directly drives your detection engineering roadmap — address the lowest-coverage tactics first.

---

## Purple Team maturity levels

| Maturity | Description |
|---|---|
| Level 1 | Ad-hoc: occasional exercises with no tracking |
| Level 2 | Defined: regular exercises tracked in spreadsheet |
| Level 3 | Managed: VECTR-tracked, ATT&CK mapped, metrics reported |
| Level 4 | Optimised: automated continuous testing, integrated with CI/CD |

Level 4 is sometimes called **Continuous Purple Teaming** — detection rules are tested automatically on every deployment, like unit tests for your SIEM.

---

## Key outputs

| Output | Description |
|---|---|
| ATT&CK coverage heat map | Visual of detected vs missed techniques |
| Detection gap backlog | Prioritised list of rules to write |
| SOC playbook updates | New response procedures for newly detected techniques |
| Log source gaps | Missing data that prevents detection |
| MTTD improvement | Mean time to detect improving over time |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming — Level 3</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence — Level 5</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder Overview</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — maps to ATT&CK techniques</a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/"><span class="ref-label">Post</span>Threat Modelling in DevSecOps</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
