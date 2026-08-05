---
title: "Red Teaming & Adversary Simulation"
date: 2026-08-02
tags: ["red-teaming", "adversary-simulation", "MITRE-ATT&CK", "security-engineering", "level-3"]
categories: ["security-engineering"]
description: "Complete guide to Red Teaming — from basic penetration testing through to full adversary simulation using MITRE ATT&CK."
showToc: true
weight: 3
---

## What is Red Teaming?

Red Teaming is the authorised simulation of a real-world adversary against your organisation's people, processes, and technology. It goes far beyond penetration testing — rather than finding vulnerabilities in isolation, a red team simulates a complete attack campaign from initial access through to the attacker's end goal (data theft, ransomware deployment, business disruption).

The term comes from military wargaming, where a "red team" plays the role of the enemy to test defensive plans.

### Red Team vs Penetration Test

| Dimension | Penetration Test | Red Team |
|---|---|---|
| Goal | Find as many vulnerabilities as possible | Achieve a specific attacker goal |
| Duration | Days to weeks | Weeks to months |
| Scope | Defined list of systems | Entire organisation |
| Rules | Specific targets in scope | Anything in scope to reach the goal |
| Stealth | Not required | Critical — avoid detection |
| Output | Vulnerability list | Attack narrative + detection gaps |
| Frequency | Annually / per compliance | Annually or after major changes |

---

## MITRE ATT&CK Framework

Every red team operation should be mapped to MITRE ATT&CK — the world's most comprehensive knowledge base of real adversary tactics and techniques, built from analysis of thousands of real-world incidents.

### The ATT&CK Matrix

ATT&CK organises adversary behaviour into **14 Tactics** (the why) and **hundreds of Techniques** (the how):

| Tactic | Description | Example technique |
|---|---|---|
| Reconnaissance | Gather information | T1595: Active Scanning |
| Resource Development | Build attack infrastructure | T1583: Acquire Infrastructure |
| Initial Access | Get into the environment | T1566: Phishing |
| Execution | Run malicious code | T1059: Command and Scripting |
| Persistence | Maintain foothold | T1053: Scheduled Task/Job |
| Privilege Escalation | Gain higher permissions | T1068: Exploit Vulnerabilities |
| Defense Evasion | Avoid detection | T1070: Indicator Removal |
| Credential Access | Steal credentials | T1003: OS Credential Dumping |
| Discovery | Explore the environment | T1046: Network Service Scanning |
| Lateral Movement | Move between systems | T1021: Remote Services |
| Collection | Gather data of interest | T1005: Data from Local System |
| Command & Control | Communicate with compromised systems | T1071: App Layer Protocol |
| Exfiltration | Steal data | T1041: Exfil over C2 Channel |
| Impact | Achieve attacker goal | T1486: Data Encrypted for Impact |

---

## Red Team operation phases

### Phase 1 — Planning and scoping

Define:
- **Objective:** What is the attacker trying to achieve? (e.g. access customer database, deploy ransomware on 10 systems, access CFO email)
- **Threat actor profile:** Which real-world attacker group are we emulating? (e.g. FIN7 for financial sector, APT29 for government)
- **Rules of engagement:** What is explicitly out of scope? (production databases, specific systems)
- **Success criteria:** How will we measure success or failure?
- **Emergency procedures:** How does the red team stop if something goes wrong?

### Phase 2 — Reconnaissance

Gather intelligence on the target without touching their systems:

```bash
# OSINT on the target organisation
theHarvester -d targetcompany.com -b all

# Find employee names and roles on LinkedIn
# Identify technology stack from job postings
# Enumerate subdomains and IP ranges
subfinder -d targetcompany.com | httpx -title -tech-detect

# Search for leaked credentials
# Check HaveIBeenPwned API for compromised accounts
```

### Phase 3 — Initial access

Attempt to gain a foothold using the threat actor's preferred techniques:

**Common initial access vectors:**
- Spear phishing with malicious attachments or links
- Exploiting internet-facing applications (VPN, email, web apps)
- Supply chain compromise (trojanised software update)
- Valid credentials (obtained via OSINT, credential stuffing, or purchase)
- Physical access (USB drops, tailgating)

### Phase 4 — Establish persistence

Once inside, ensure the foothold survives reboots and credential rotations:

```bash
# Common persistence mechanisms (ATT&CK T1053)
# Scheduled tasks (Windows)
schtasks /create /tn "WindowsUpdate" /tr "C:\Users\Public\beacon.exe" /sc onlogon

# Cron jobs (Linux)
echo "*/5 * * * * /tmp/.update" >> /var/spool/cron/root

# Registry run keys (Windows)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Update" /t REG_SZ /d "C:\beacon.exe"
```

### Phase 5 — Privilege escalation

Escalate from standard user to administrator/root:

```bash
# Check for misconfigured sudo (Linux)
sudo -l

# Look for SUID binaries
find / -perm -4000 2>/dev/null

# Windows: check for unquoted service paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\"

# Token impersonation with tools like Rubeus or Mimikatz
```

### Phase 6 — Lateral movement

Move from the initial foothold to higher-value targets:

```
Initial foothold (developer laptop)
  → Steal credentials from memory (Mimikatz)
    → Authenticate to internal file server
      → Find database connection strings in config files
        → Access production database
          → Exfiltrate customer records
```

**Common techniques:**
- Pass-the-Hash (PTH) — reuse NTLM hashes without cracking
- Pass-the-Ticket (PTT) — Kerberos ticket reuse (Golden/Silver ticket attacks)
- Remote services — RDP, WMI, PSExec, SSH
- Living-off-the-land — using built-in tools (PowerShell, WMI, certutil) to avoid AV detection

### Phase 7 — Objective completion and reporting

Once the objective is achieved (or time runs out), document:

- Complete attack narrative with timestamps
- Every technique used, mapped to ATT&CK
- Evidence (screenshots, command output, data samples)
- Detection opportunities missed by the blue team
- Recommendations for each gap

---

## Red Team tooling

### Command and Control (C2) frameworks

| Tool | Type | Notes |
|---|---|---|
| Cobalt Strike | Commercial | Industry standard, expensive (~$3,500/year) |
| Sliver | Open source | Modern Go-based C2, Cobalt Strike alternative |
| Metasploit | Open source | Broad exploit coverage, well-known (easily detected) |
| Havoc | Open source | Modern, evasion-focused |
| Brute Ratel | Commercial | Designed to evade EDR products |

### Supporting tools

| Tool | Purpose |
|---|---|
| Mimikatz | Credential extraction from Windows memory |
| Rubeus | Kerberos attacks |
| BloodHound | Active Directory attack path analysis |
| Impacket | Python tools for Windows protocols |
| CrackMapExec | Network attack automation |
| Responder | Network credential capture |
| Burp Suite | Web application attacks |
| Nessus / OpenVAS | Vulnerability scanning |

---

## Threat-intelligence-driven red teaming

The most advanced form of red teaming uses threat intelligence to emulate a specific threat actor relevant to your organisation and sector.

### Frameworks for intelligence-driven red teaming

**TIBER-EU** (Threat Intelligence-Based Ethical Red Teaming)
- Developed by the European Central Bank
- Mandatory for financial institutions in many EU countries
- Three phases: preparation, red team test, closure
- Requires accredited threat intelligence provider + red team provider

**CBEST** (UK)
- Bank of England framework for UK financial sector
- Similar structure to TIBER-EU
- Uses CREST-accredited providers

**DORA** (Digital Operational Resilience Act)
- EU regulation requiring TLPT (Threat-Led Penetration Testing) for financial entities
- Effective January 2025
- Based on TIBER-EU methodology

### Selecting a threat actor profile

Research which threat actor groups target your sector using:

- MITRE ATT&CK Groups: https://attack.mitre.org/groups/
- Mandiant M-Trends annual report
- CrowdStrike Global Threat Report
- Sector-specific ISACs (Information Sharing and Analysis Centers)

**Example: Financial sector threat actor profile**

```
Threat actor: FIN7 (Carbanak)
Primary motivation: Financial gain
Typical initial access: Spear phishing with malicious Word docs
Common tools: Carbanak malware, Cobalt Strike
Target: Point-of-sale systems, wire transfer fraud
Notable incidents: $1B+ stolen from banks globally
MITRE ATT&CK group: https://attack.mitre.org/groups/G0046/
```

---

## Red Team reporting

A red team report contains:

### Executive summary (1–2 pages)
- Objective and outcome
- Key findings in business impact terms
- Top 3–5 recommendations

### Attack narrative
- Chronological story of the attack campaign
- Each step explained in plain language
- Business risk at each stage

### Technical findings
- Each technique used, mapped to ATT&CK
- Evidence screenshots
- Detection status (detected / missed)
- Remediation recommendation

### ATT&CK Navigator heat map
A visual showing which techniques were used and which were detected:

```
Technique             | Used | Detected | Gap
T1566 Phishing        |  ✓   |    ✓     | None
T1003 Credential Dump |  ✓   |    ✗     | HIGH GAP
T1021 Remote Services |  ✓   |    ✗     | HIGH GAP
T1486 Ransomware Sim  |  ✓   |    ✓     | None
```

---

## Key metrics

| Metric | Description |
|---|---|
| Time to objective | How long to achieve the attacker's goal |
| Detection rate | % of techniques detected by blue team |
| Dwell time | Time between initial access and detection |
| Blast radius | Maximum access achieved |
| Coverage against ATT&CK | % of relevant techniques tested |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming — Level 4</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence — Level 5</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
  <a class="ref-card" href="/wiki/attack-trees/"><span class="ref-label">Framework</span>Attack Trees</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder Overview</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
