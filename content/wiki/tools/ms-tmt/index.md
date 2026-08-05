---
title: "Microsoft Threat Modelling Tool"
date: 2026-08-02
tags: ["tools", "threat-modelling", "Microsoft", "STRIDE"]
categories: ["tools"]
description: "Guide to the Microsoft Threat Modelling Tool — the classic free STRIDE-based DFD tool from the team that invented STRIDE."
showToc: true
---

## What is the Microsoft Threat Modelling Tool?

The Microsoft Threat Modelling Tool (TMT) is a free Windows application developed by Microsoft's Security Engineering team — the same team that invented STRIDE. It provides a graphical DFD editor and automatically generates a list of potential threats for each element using a built-in threat template library.

**Download:** https://aka.ms/threatmodelingtool
**Platform:** Windows only
**Cost:** Free

---

## Key features

| Feature | Description |
|---|---|
| DFD editor | Visual drag-and-drop diagram builder |
| Auto threat generation | Automatically suggests threats per element based on STRIDE |
| Built-in templates | Azure, generic web app, IoT, and custom templates |
| Threat library | 100+ pre-built threats with mitigations |
| SDL integration | Built for Microsoft's Security Development Lifecycle |
| Report export | HTML and CSV reports |

---

## Installation

1. Go to → https://aka.ms/threatmodelingtool
2. Download the installer (Windows only)
3. Run `ThreatModelingTool.msi`
4. Launch from Start menu

For non-Windows users, use [OWASP Threat Dragon](/wiki/tools/threat-dragon/) or [Threagile](/wiki/tools/threagile/) instead.

---

## Quickstart

### Step 1 — Create a new model
File → New → give it a name

### Step 2 — Draw your DFD
Drag from the stencil panel:
- **Browser / Generic External Interactor** — external entities
- **Generic Process / Web Application** — your services
- **Generic Data Store / SQL Database** — databases
- **Flow** — connect elements with arrows
- **Boundary** — draw trust boundaries as boxes around groups

### Step 3 — Generate threats
Go to **View → Analysis View** (or press F5).
The tool automatically generates threats for every element and data flow. Each threat includes:
- Threat category (STRIDE)
- Threat title and description
- Suggested mitigation
- Priority (High / Medium / Low)

### Step 4 — Review and mitigate
For each generated threat, set the state:
- **Mitigated** — add your mitigation text
- **Not Applicable** — explain why it does not apply
- **Needs Investigation** — flag for follow-up

### Step 5 — Export report
View → Reports → Generate Full Report → saves as HTML

---

## Microsoft TMT vs OWASP Threat Dragon

| Feature | Microsoft TMT | OWASP Threat Dragon |
|---|---|---|
| Platform | Windows only | Web + Desktop + Docker |
| Open source | No | Yes |
| Threat library | Extensive (Azure-focused) | Basic |
| Auto threat generation | Yes | Partial |
| Git integration | No | Yes (GitHub) |
| Report quality | Excellent | Good |
| Best for | Windows / Azure teams | Cross-platform teams |

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/tools/threat-dragon/">
    <span class="ref-label">Tool</span>OWASP Threat Dragon
  </a>
  <a class="ref-card" href="/wiki/tools/threagile/">
    <span class="ref-label">Tool</span>Threagile — TM as YAML
  </a>
  <a class="ref-card" href="/wiki/stride/">
    <span class="ref-label">Framework</span>STRIDE Reference
  </a>
  <a class="ref-card" href="/wiki/templates/dfd/">
    <span class="ref-label">Template</span>Data Flow Diagram Guide
  </a>
  <a class="ref-card" href="/posts/02-stride-methodology/">
    <span class="ref-label">Post</span>STRIDE Practitioner's Guide
  </a>
</div>

</div>
