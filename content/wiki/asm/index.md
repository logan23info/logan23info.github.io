---
title: "Attack Surface Management (ASM)"
date: 2026-08-02
tags: ["ASM", "attack-surface", "security-engineering", "level-2"]
categories: ["security-engineering"]
description: "Complete guide to Attack Surface Management — continuous discovery, inventory, and risk scoring of every externally exposed asset."
showToc: true
weight: 2
---

## What is Attack Surface Management?

Attack Surface Management (ASM) is the continuous process of discovering, inventorying, classifying, and monitoring every asset an organisation exposes to the internet — including assets the organisation may not know it has.

Where threat modelling is a **design-time** activity (what could go wrong?), ASM is **runtime** (what is actually exposed right now?).

The attack surface includes:
- Web applications and APIs
- Cloud storage buckets and databases
- Subdomains and DNS records
- SSL/TLS certificates and their expiry dates
- Open ports and running services
- Third-party SaaS integrations
- Shadow IT — systems deployed without IT's knowledge

---

## Why ASM matters

### The shadow IT problem

In a 2023 survey, organisations discovered an average of **30% more internet-facing assets** than they had in their official inventory. Every untracked asset is a potential entry point an attacker can find — and an organisation can't defend what it doesn't know exists.

### The speed problem

Attackers scan the entire internet continuously. Tools like Shodan and Censys index new exposures within **hours** of them appearing. The average organisation takes **days to weeks** to discover a new exposure through manual processes. ASM closes this gap.

### The third-party problem

Your attack surface includes your suppliers, partners, and SaaS providers. A breach at a third party can expose your data and systems — as demonstrated by the SolarWinds supply chain attack, which compromised thousands of organisations through a single vendor update.

---

## The ASM process

```
Discover → Inventory → Classify → Prioritise → Monitor → Remediate
    ↑                                                          |
    └──────────────────── continuous loop ─────────────────────┘
```

### 1. Discovery

Enumerate all assets associated with your organisation using:

- **DNS enumeration** — subdomains, MX records, TXT records
- **Certificate transparency logs** — every SSL certificate issued for your domains
- **ASN (Autonomous System Number) lookup** — IP ranges registered to your organisation
- **Reverse IP lookup** — all domains hosted on your IP addresses
- **Search engine dorking** — Google/Bing queries that surface exposed assets
- **Port scanning** — open services on discovered IP ranges

**Tools:**
```bash
# Subdomain enumeration
subfinder -d example.com -o subdomains.txt
amass enum -d example.com

# Certificate transparency
curl "https://crt.sh/?q=%.example.com&output=json" | jq '.[].name_value'

# Port scanning
nmap -sV -p- --open <IP_RANGE>
```

### 2. Inventory

Build a structured asset register:

```yaml
asset:
  id: "asset-001"
  hostname: "api.example.com"
  ip: "203.0.113.42"
  type: "web-application"
  owner: "payments-team"
  discovered: "2026-08-01"
  last_seen: "2026-08-02"
  ports:
    - port: 443
      service: "HTTPS"
      certificate_expiry: "2026-12-01"
  tags:
    - "internet-facing"
    - "handles-pii"
    - "pci-scope"
```

### 3. Classify

Rate each asset by sensitivity and business criticality:

| Classification | Description | Example |
|---|---|---|
| Critical | Directly handles sensitive data or auth | Payment API, SSO endpoint |
| High | Supports critical systems | Internal admin portal |
| Medium | Business function, limited data | Marketing site |
| Low | Minimal business impact | Static documentation |

### 4. Prioritise

Score each exposure by combining asset criticality with vulnerability severity:

```
Risk score = Asset criticality × Vulnerability severity × Exploitability
```

A critical-severity vulnerability on a low-criticality asset may rank lower than a medium-severity vulnerability on a payment API.

### 5. Monitor

Set up continuous monitoring for:
- New subdomains appearing (possible shadow IT or typosquatting)
- SSL certificate expiry (within 30 days)
- New open ports on known assets
- Changes to DNS records
- New vulnerabilities in services you run

### 6. Remediate

For each finding, route to the owning team with:
- Asset details and discovery method
- Risk score and business impact
- Recommended remediation steps
- SLA based on severity (Critical: 24h, High: 7 days, Medium: 30 days)

---

## ASM tooling

### Open source tools

| Tool | Purpose | Cost |
|---|---|---|
| Subfinder | Subdomain discovery | Free |
| Amass | Attack surface mapping | Free |
| Shodan CLI | Internet-wide scanning data | Free tier |
| Nuclei | Vulnerability scanning at scale | Free |
| httpx | HTTP probe and response analysis | Free |
| Nmap | Port scanning and service detection | Free |
| theHarvester | OSINT gathering | Free |

### Commercial ASM platforms

| Platform | Strengths |
|---|---|
| Microsoft Defender EASM | Deep Azure integration, continuous monitoring |
| Censys ASM | Best discovery coverage, certificate data |
| Tenable ASM | Integrates with vulnerability management |
| CyCognito | Strong third-party/subsidiary discovery |
| Palo Alto Cortex Xpanse | Enterprise-grade, XSOAR integration |

---

## ASM in a DevSecOps pipeline

Integrate ASM into CI/CD so new exposures are caught before they reach production:

```yaml
# .github/workflows/asm-scan.yml
name: ASM — Attack Surface Scan

on:
  schedule:
    - cron: '0 6 * * *'    # daily at 06:00
  push:
    branches: [main]

jobs:
  surface-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
          go install github.com/projectdiscovery/httpx/cmd/httpx@latest
          go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

      - name: Enumerate subdomains
        run: subfinder -d ${{ vars.TARGET_DOMAIN }} -o subdomains.txt

      - name: Probe live hosts
        run: httpx -l subdomains.txt -o live-hosts.txt -status-code -title

      - name: Run vulnerability scan
        run: nuclei -l live-hosts.txt -severity critical,high -o nuclei-findings.json

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: asm-results
          path: |
            subdomains.txt
            live-hosts.txt
            nuclei-findings.json
```

---

## Advanced ASM concepts

### Continuous Threat Exposure Management (CTEM)

CTEM (coined by Gartner) extends ASM into a five-stage programme:

1. **Scoping** — define what is in scope for exposure management
2. **Discovery** — find all assets and vulnerabilities
3. **Prioritisation** — rank by exploitability and business impact
4. **Validation** — verify exploitability with red team or automated tools
5. **Mobilisation** — route findings to owners with SLAs

### Attack Path Analysis

Beyond individual asset exposure, model how an attacker could chain multiple exposures together:

```
Exposed Jenkins CI server
  → Steal AWS credentials from build logs
    → Access S3 bucket containing customer PII
      → Exfiltrate 2M customer records
```

Each step alone might be low severity. The chain is critical. Tools like XM Cyber and Skybox Security automate attack path analysis across your full environment.

### External vs Internal attack surface

| Surface | Definition | Tools |
|---|---|---|
| External | Internet-facing assets | Censys, Shodan, ASM platforms |
| Internal | Assets on corporate network | Rumble, Nmap, vulnerability scanners |
| Cloud | Cloud resources (S3, RDS, etc.) | Prowler, ScoutSuite, CloudSploit |
| Third-party | Supplier and partner exposure | BitSight, SecurityScorecard |

### Integration with threat modelling

ASM findings should feed directly back into threat models:

- A newly discovered exposed admin portal → adds an entry point to the DFD
- An expired SSL certificate on a payment endpoint → maps to STRIDE Information Disclosure
- A shadow IT database → triggers a new threat modelling session for that system

This creates a continuous loop: threat models define what to look for, ASM finds real exposures, findings update threat models.

---

## Key metrics

| Metric | Target |
|---|---|
| Mean Time to Discover (MTTD) | < 4 hours for new internet-facing assets |
| Mean Time to Remediate Critical | < 24 hours |
| Unknown asset ratio | < 5% of total inventory |
| Certificate expiry coverage | 100% alerted 30 days before expiry |
| Third-party coverage | 100% of tier-1 suppliers monitored |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming — Level 3</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence — Level 5</a>
  <a class="ref-card" href="/wiki/stride/"><span class="ref-label">Framework</span>STRIDE — feeds into ASM findings</a>
  <a class="ref-card" href="/posts/06-security-engineering-maturity/"><span class="ref-label">Post</span>Full Maturity Ladder Post</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
</div>

</div>
