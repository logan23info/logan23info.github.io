---
title: "DDoS Response Playbook"
date: 2026-08-05
tags: ["DDoS", "incident-response", "playbook", "availability", "WAF"]
categories: ["incident-response"]
description: "DDoS incident response — attack identification, classification, defensive escalation, and recovery."
showToc: true
layout: "single"
---

## DDoS response — immediate actions

**Key principle:** DDoS response is a race between the attack overwhelming your capacity and your defences scaling to absorb it.

---

## Identify and classify (minutes 0–15)

```
□ Confirm it is DDoS — not a legitimate traffic spike
  → Compare to normal traffic baseline
  → Check request patterns (legitimate users don't all do the same thing)
  → Check geographic distribution (legitimate traffic is diverse)
  → Check user agents (bot traffic often has uniform or missing user agents)

□ Classify the attack type:

VOLUMETRIC (Layer 3/4):
  → Bandwidth saturation: Gbps scale traffic (UDP flood, ICMP flood, amplification)
  → Symptoms: network interface saturated, upstream provider sees traffic
  → Detection: flow monitoring (NetFlow, sFlow), upstream provider alerts

PROTOCOL (Layer 4):
  → SYN flood: half-open TCP connections exhaust server state
  → Symptoms: high connection table utilisation, server unresponsive
  → Detection: netstat shows thousands of SYN_RECV connections

APPLICATION (Layer 7):
  → HTTP flood: legitimate-looking requests overwhelm application
  → Slowloris: slowly draining connection pool
  → Symptoms: app CPU high, requests timing out, low network utilisation
  → Detection: application logs showing high request rate from limited IPs
```

---

## Defensive escalation (minutes 15–60)

```
LAYER 1: Edge / CDN protection
□ Enable DDoS protection mode on CDN (CloudFront, Cloudflare, Akamai)
□ Enable rate limiting at CDN edge
□ Block attacking IP ranges at CDN if identified
□ Enable CAPTCHA for suspicious traffic patterns

LAYER 2: Cloud provider DDoS protection
□ AWS: Enable AWS Shield Advanced (if not already active)
       Contact AWS Shield Response Team (SRT) for P1 DDoS
□ GCP: Enable Cloud Armor adaptive protection
□ Azure: Enable Azure DDoS Protection Standard
         Contact Azure DDoS Rapid Response team

LAYER 3: WAF rules
□ Deploy rate limiting rules (requests per IP per minute)
□ Block known bad user agents
□ Block geographic regions if attack originates from specific countries
□ Enable bot management / JavaScript challenge

LAYER 4: Application-level
□ Enable application-level rate limiting (if not already active)
□ Enable connection limits per IP
□ Cache aggressively — reduce backend load
□ Scale up auto-scaling group limits temporarily
□ Enable circuit breakers to protect downstream services

LAYER 5: Upstream provider
□ Contact ISP/upstream provider to enable BGP blackholing or scrubbing
□ Request traffic null-routing for most severe attacks
```

---

## Recovery and post-attack

```
RECOVERY
□ Gradually remove emergency blocks (some may be over-blocking legitimate users)
□ Review CDN/WAF logs for traffic normalisation
□ Verify all services are responding correctly
□ Clear any cached error pages
□ Resume normal auto-scaling configuration

POST-ATTACK (within 48 hours)
□ Quantify impact: duration, peak traffic, customer impact
□ Identify attack vector and origin (best effort — DDoS is often spoofed)
□ Review which defences were most effective
□ Identify gaps: what would have helped that we didn't have?
□ Update runbook based on lessons learned
□ Consider DDoS simulation to validate defences before next attack
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/incident-response/ir-plan/"><span class="ref-label">IR</span>IR Plan</a>
  <a class="ref-card" href="/wiki/incident-response/post-incident-review/"><span class="ref-label">IR</span>Post-Incident Review</a>
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/owasp-top10/a04-insecure-design/"><span class="ref-label">OWASP</span>A04 Insecure Design — rate limiting</a>
  <a class="ref-card" href="/wiki/detection-engineering/siem-use-cases/"><span class="ref-label">Detection</span>SIEM Use Cases</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence</a>
</div>

</div>
