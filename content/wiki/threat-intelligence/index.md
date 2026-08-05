---
title: "Threat Intelligence"
date: 2026-08-02
tags: ["threat-intelligence", "CTI", "MITRE-ATT&CK", "security-engineering", "level-5"]
categories: ["security-engineering"]
description: "Complete guide to Cyber Threat Intelligence — from IOC feeds through to strategic intelligence-driven security programmes."
showToc: true
weight: 5
---

## What is Cyber Threat Intelligence?

Cyber Threat Intelligence (CTI) is structured, curated, and contextualised information about threats and threat actors that enables organisations to make faster and more accurate security decisions. It transforms security from reactive (responding to incidents) to proactive (anticipating and preventing them).

Raw data becomes intelligence through the **Intelligence Cycle:**

```
Direction → Collection → Processing → Analysis → Dissemination → Feedback
    ↑                                                                  |
    └──────────────────────────────────────────────────────────────────┘
```

---

## The three tiers of threat intelligence

### Strategic intelligence
- **Audience:** C-suite, board, business leaders
- **Timeframe:** Months to years
- **Question:** What threats should our business be preparing for?
- **Example:** "Nation-state actors are increasingly targeting critical infrastructure in our sector. We should invest in OT security this year."
- **Sources:** Annual threat reports (Mandiant M-Trends, CrowdStrike Global Threat Report), government advisories (CISA, NCSC)

### Operational intelligence
- **Audience:** Security managers, incident responders, red/purple teams
- **Timeframe:** Days to weeks
- **Question:** What campaigns and threat actors are active right now?
- **Example:** "FIN7 is currently running a campaign targeting finance sector companies using a new phishing kit. Our red team should simulate this technique."
- **Sources:** Threat intel platforms (Recorded Future, Mandiant), ISAC feeds, dark web monitoring

### Tactical intelligence
- **Audience:** SOC analysts, threat hunters, SIEM engineers
- **Timeframe:** Hours to days
- **Question:** What specific indicators should we be blocking and detecting right now?
- **Example:** IOCs — IP addresses, domains, file hashes, URLs associated with active malware campaigns
- **Sources:** MISP, OTX AlienVault, threat intel feeds, VirusTotal

---

## Indicators of Compromise (IOCs)

IOCs are artifacts that indicate a system has been compromised or an attack is in progress:

| IOC type | Example | Detection method |
|---|---|---|
| IP address | 203.0.113.42 (C2 server) | Firewall / proxy block |
| Domain | evil-c2-server.com | DNS sinkhole / block |
| File hash (MD5/SHA256) | d41d8cd98f00b204e9800998ecf8427e | EDR / AV signature |
| URL | https://phishing-site.com/login | Web proxy block |
| Email address | attacker@evil.com | Email gateway block |
| Registry key | HKCU\Software\Malware\persist | EDR detection rule |
| Mutex | \BaseNamedObjects\evil_mutex | Memory scanning |
| User agent | Mozilla/4.0 (compatible; MSIE 6.0) | Web proxy detection |

### The Pyramid of Pain

David Bianco's Pyramid of Pain shows how much disruption each IOC type causes to an attacker when blocked:

```
              [TTPs]             ← hardest for attacker to change (MOST PAIN)
           [Tools]
        [Network/Host Artifacts]
      [Domain Names]
   [IP Addresses]
[File Hashes]                    ← easiest for attacker to change (LEAST PAIN)
```

Focus detection and blocking efforts on the top of the pyramid. Blocking a file hash costs the attacker nothing — they recompile and get a new hash in minutes. Detecting their TTPs (e.g. "this process always dumps LSASS") forces them to fundamentally change their methods.

---

## MITRE ATT&CK for threat intelligence

ATT&CK provides a common language for describing threat actor behaviour, making it possible to compare intelligence from multiple sources and translate it directly into detections.

### Threat actor profiles

ATT&CK Groups catalogue known threat actors with their techniques:

**APT29 (Cozy Bear, SVR)**
- Nation-state: Russia (SVR — Foreign Intelligence Service)
- Targets: Government, think tanks, healthcare, energy
- Known for: SolarWinds supply chain attack, COVID-19 vaccine research theft
- Key techniques: T1566 Phishing, T1195 Supply Chain Compromise, T1027 Obfuscated Files
- ATT&CK profile: https://attack.mitre.org/groups/G0016/

**FIN7 (Carbanak)**
- Motivation: Financial gain
- Targets: Retail, hospitality, finance (POS systems)
- Known for: $1B+ stolen, highly sophisticated spear phishing
- Key techniques: T1566.001 Spear Phishing, T1204 User Execution, T1055 Process Injection
- ATT&CK profile: https://attack.mitre.org/groups/G0046/

**Lazarus Group**
- Nation-state: North Korea (RGB)
- Motivation: Financial gain + espionage
- Targets: Cryptocurrency exchanges, banks, defence
- Known for: Bangladesh Bank heist ($81M), WannaCry ransomware
- Key techniques: T1189 Drive-by Compromise, T1195 Supply Chain, T1486 Ransomware
- ATT&CK profile: https://attack.mitre.org/groups/G0032/

### Mapping intelligence to detections

When you receive intelligence about a threat actor, translate their TTPs directly into SIEM detection rules:

```
Intelligence: APT29 uses T1003.001 (LSASS Memory Dump) via custom tool "MiniDump"

→ Detection rule: Alert on any process accessing lsass.exe memory
   that is not a known legitimate security tool

→ Sigma rule:
title: Suspicious LSASS Access - APT29 MiniDump Pattern
tags:
  - attack.t1003.001
  - attribution.apt29
detection:
  selection:
    TargetImage|endswith: '\lsass.exe'
    GrantedAccess: '0x1010'
```

---

## Threat intelligence platforms

### Open source / free

| Platform | Description |
|---|---|
| MISP | Most widely used open-source TI sharing platform |
| OpenCTI | Modern, graph-based TI platform with ATT&CK integration |
| OTX AlienVault | Free community threat intel feed |
| VirusTotal | File and URL analysis + community intelligence |
| Shodan | Internet scanning data (limited free tier) |
| URLhaus | Malicious URL database |
| MalwareBazaar | Malware sample repository |
| ThreatFox | IOC sharing platform by |

### Commercial

| Platform | Strengths |
|---|---|
| Recorded Future | Broadest coverage, AI-powered, dark web |
| Mandiant Advantage | Incident response heritage, actor attribution |
| CrowdStrike Falcon Intel | Strong nation-state tracking |
| Microsoft Sentinel TI | Azure-native, MSTI integration |
| MISP (enterprise) | Self-hosted, full control, large community |

---

## Setting up a free threat intelligence pipeline

```yaml
# docker-compose.yml — free TI stack
version: "3.8"
services:
  misp:
    image: ghcr.io/misp/misp-docker/misp-core:latest
    ports:
      - "443:443"
    environment:
      MISP_ADMIN_EMAIL: "admin@example.com"

  opencti:
    image: opencti/platform:latest
    ports:
      - "8080:8080"
    environment:
      APP__SECRET: "changeme"
      OPENCTI__URL: "http://localhost:8080"
```

**Free intelligence feeds to connect:**

```python
# Connect MISP to free feeds
feeds = [
    "https://www.circl.lu/doc/misp/feed-osint/",      # CIRCL OSINT
    "https://bazaar.abuse.ch/export/csv/recent/",      # MalwareBazaar
    "https://feodotracker.abuse.ch/downloads/ipblocklist.csv",  # Feodo C2
    "https://urlhaus.abuse.ch/downloads/csv_recent/",  # URLhaus
    "https://otx.alienvault.com/api/v1/pulses/subscribed",     # OTX
]
```

---

## Intelligence-driven threat modelling

The most powerful use of threat intelligence is feeding it directly into your threat models:

### Without threat intelligence
```
Threat: "An attacker could perform SQL injection on the login endpoint"
Severity: High (DREAD score 7.2)
```

### With threat intelligence
```
Threat: "FIN7 (active in our sector, confirmed targeting peers in Q3 2026)
uses T1190 (Exploit Public-Facing Application) as primary initial access.
Our login endpoint is internet-facing and handles authentication.
FIN7 has used SQLi in 40% of confirmed incidents against retail targets."

Severity: Critical (DREAD score 9.1)
Priority: Immediate — active threat actor, confirmed sector targeting
```

The second version drives urgency that gets executive attention and budget.

---

## Threat hunting

Threat intelligence enables proactive threat hunting — searching for attacker presence in your environment before an alert fires.

### Hypothesis-driven hunting

```
Intelligence: APT29 uses T1078 (Valid Accounts) — stolen credentials
              to authenticate to VPN from unusual geographies

Hypothesis: If APT29 has stolen a user's VPN credentials, we would see
            successful VPN logins from IPs in Russia/Eastern Europe
            at unusual times

Hunt query (Splunk):
index=vpn_logs action=success
| iplocation src_ip
| where Country != "India"
| stats count by user, Country, src_ip
| where count > 2
| join user [search index=vpn_logs | stats earliest(_time) as first_seen by user]
| where relative_time(now(), "-7d") > first_seen
```

---

## Key metrics

| Metric | Target |
|---|---|
| Mean Time to Ingest IOC | < 1 hour from feed to blocking |
| IOC False Positive Rate | < 5% (too high = analyst fatigue) |
| Threat actor coverage | All sector-relevant groups profiled |
| Intelligence-to-detection rate | > 80% of TTPs translated to detections |
| Feed freshness | All feeds updated within 24 hours |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming — uses threat intel</a>
  <a class="ref-card" href="/wiki/purple-teaming/"><span class="ref-label">Wiki</span>Purple Teaming — Level 4</a>
  <a class="ref-card" href="/wiki/asm/"><span class="ref-label">Wiki</span>Attack Surface Management</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Maturity Ladder Overview</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — intelligence-driven threat modelling</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
</div>

</div>
