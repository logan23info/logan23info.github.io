---
title: "OWASP Threat Dragon"
date: 2026-08-02
tags: ["tools", "threat-modelling", "OWASP", "DFD"]
categories: ["tools"]
description: "Complete guide to OWASP Threat Dragon — the free, open-source threat modelling tool for creating DFDs and running STRIDE analysis."
showToc: true
---

## What is OWASP Threat Dragon?

OWASP Threat Dragon is a free, open-source threat modelling tool that lets you draw data flow diagrams (DFDs) and run STRIDE analysis against each component. It is part of the OWASP (Open Web Application Security Project) toolset and is available as a web app, desktop app, and Docker container.

**Website:** https://owasp.org/www-project-threat-dragon/
**GitHub:** https://github.com/OWASP/threat-dragon

---

## Key features

| Feature | Description |
|---|---|
| Visual DFD editor | Drag-and-drop diagram builder with all DFD elements |
| STRIDE per element | Automated STRIDE checklist per process, data store, and data flow |
| Threat library | Built-in threats with descriptions and mitigations |
| JSON export | Store threat model as code in your Git repo |
| GitHub integration | Load and save models directly from GitHub repos |
| Report generation | Export threat model as PDF or HTML report |
| Open source | Free forever, no vendor lock-in |

---

## Installation options

### Option 1 — Web app (no install)
Go to: https://www.threatdragon.com

Log in with GitHub → your threat models are saved as JSON files in a GitHub repo.

### Option 2 — Desktop app

```bash
# Download from GitHub releases
# https://github.com/OWASP/threat-dragon/releases

# Mac
brew install --cask owasp-threat-dragon

# Linux (AppImage)
chmod +x threat-dragon-*.AppImage
./threat-dragon-*.AppImage

# Windows: download the .exe installer from GitHub releases
```

### Option 3 — Docker

```bash
# Pull and run
docker pull owasp/threat-dragon:latest
docker run -it --rm \
  -p 3000:3000 \
  -e NODE_ENV=production \
  owasp/threat-dragon:latest

# Open http://localhost:3000
```

---

## Quickstart walkthrough

### Step 1 — Create a new model

1. Open Threat Dragon (web or desktop)
2. Click **"New Model"**
3. Name it: `auth-service-threat-model`
4. Add metadata: owner, description, reviewer

### Step 2 — Draw your DFD

Use the left panel to drag elements onto the canvas:

- **Actor** (external entity) — drag for User, Third-party API
- **Process** (rounded box) — drag for each service
- **Data Store** (parallel lines) — drag for each database
- **Data Flow** (arrow) — connect elements
- **Trust Boundary** (dashed box) — surround internal components

### Step 3 — Add threats per element

Click any process or data flow → click **"Edit Threats"** → the STRIDE checklist appears. For each relevant category:

1. Click **"Add Threat"**
2. Fill in: Title, Description, STRIDE category, Severity (Critical/High/Medium/Low)
3. Add mitigation text
4. Set status: Open / Mitigated / Not Applicable

### Step 4 — Export

- **JSON** → commit to your Git repo alongside the code
- **PDF report** → share with stakeholders
- **PNG** → embed in Confluence/Notion

---

## Storing threat models as code

Threat Dragon saves models as JSON. Commit this to your repo:

```
your-repo/
├── src/
├── infra/
└── threat-models/
    ├── auth-service.json          ← Threat Dragon model
    ├── payment-service.json
    └── api-gateway.json
```

Add a GitHub Actions step to validate models on every PR:

```yaml
- name: Validate threat models
  run: |
    for f in threat-models/*.json; do
      python3 -c "
import json, sys
with open('$f') as f:
    model = json.load(f)
# Check for open critical threats
diagrams = model.get('detail', {}).get('diagrams', [])
open_critical = []
for diagram in diagrams:
    for cell in diagram.get('cells', []):
        for threat in cell.get('threats', []):
            if threat.get('status') == 'Open' and threat.get('severity') == 'Critical':
                open_critical.append(threat.get('title', 'Unknown'))
if open_critical:
    print(f'BLOCKED in $f: Open Critical threats: {open_critical}')
    sys.exit(1)
print(f'OK: $f')
"
    done
```

---

## Threat Dragon vs Microsoft TMT

| Feature | OWASP Threat Dragon | Microsoft TMT |
|---|---|---|
| Cost | Free | Free |
| Platform | Web + Desktop + Docker | Windows only |
| Open source | Yes | No |
| Git integration | Yes (GitHub) | No |
| STRIDE support | Yes | Yes |
| Threat library | Basic | Extensive |
| Report quality | Good | Excellent |
| Active development | Yes | Limited |
| Best for | Cross-platform teams | Windows / Azure-focused teams |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/tools/ms-tmt/">
    <span class="ref-label">Tool</span>Microsoft Threat Modelling Tool
  </a>
  <a class="ref-card" href="/wiki/tools/threagile/">
    <span class="ref-label">Tool</span>Threagile — TM as YAML
  </a>
  <a class="ref-card" href="/wiki/templates/dfd/">
    <span class="ref-label">Template</span>Data Flow Diagram Guide
  </a>
  <a class="ref-card" href="/wiki/stride/">
    <span class="ref-label">Framework</span>STRIDE Reference
  </a>
  <a class="ref-card" href="/posts/01-intro-to-threat-modelling/">
    <span class="ref-label">Post</span>Introduction to Threat Modelling
  </a>
  <a class="ref-card" href="/posts/05-threat-modelling-in-devsecops/">
    <span class="ref-label">Post</span>Threat Modelling in DevSecOps
  </a>
</div>

</div>
