---
title: "Threat Modelling in DevSecOps Pipelines"
date: 2026-08-02
tags: ["DevSecOps", "CI/CD", "threat-modelling", "automation", "GitHub-Actions"]
categories: ["devsecops"]
series: ["Security Engineering Maturity"]
description: "How to integrate threat modelling into your CI/CD pipeline so security is a gate, not an afterthought."
showToc: true
weight: 5
---

## The problem with point-in-time threat modelling

Most organisations treat threat modelling as an annual exercise. By the next quarter the system has changed enough that the report is obsolete. DevSecOps flips this — security reviews happen continuously, at the pace of engineering.

---

## Where threat modelling fits in the pipeline

| Pipeline stage | Security activity | Threat modelling touchpoint |
|---|---|---|
| Plan / design | Architecture review | Full threat model for new features |
| Code | Pre-commit hooks | STRIDE checklist for the component |
| Build | SAST, dependency scanning | Checks against threat register |
| Test | DAST, fuzzing | Attack scenarios from threat model |
| Release | Security gate | Unmitigated critical threats block release |
| Deploy | IaC scanning (Checkov) | Infrastructure threat model validated |
| Monitor | SIEM, anomaly detection | Threat model informs detection rules |

---

## Pattern 1 — Threat model as code

Store your threat model as YAML alongside your code:

```yaml
version: "1.0"
component: "auth-service"
last_reviewed: "2026-08-02"
threats:
  - id: T-01
    category: spoofing
    description: "JWT replay attack using stolen token"
    dread_score: 8.4
    status: mitigated
    mitigation: "15-minute TTL enforced, refresh token rotation"
  - id: T-02
    category: tampering
    description: "alg:none JWT forgery"
    dread_score: 9.0
    status: open
    owner: "team-auth"
    due: "2026-08-09"
```

---

## Pattern 2 — Security gate in GitHub Actions

Block deployments if open Critical threats exist:

```yaml
- name: Check for open critical threats
  run: |
    python3 - << 'PYEOF'
    import yaml, sys
    with open("threat-model.yml") as f:
        model = yaml.safe_load(f)
    open_critical = [
        t for t in model.get("threats", [])
        if t.get("status") == "open" and t.get("dread_score", 0) >= 9.0
    ]
    if open_critical:
        print("BLOCKED: Open critical threats found:")
        for t in open_critical:
            print(f"  [{t['id']}] {t['description']} (DREAD: {t['dread_score']})")
        sys.exit(1)
    print("Security gate passed.")
    PYEOF
```

---

## Pattern 3 — IaC scanning with Checkov

```yaml
- name: Run Checkov on infra
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: infra/
    framework: terraform
    soft_fail: false
```

Checkov maps IaC misconfigurations directly to STRIDE categories — an S3 bucket without encryption is Information Disclosure, an open security group is Elevation of Privilege.

---

## Realistic cadence

| Trigger | Activity | Time |
|---|---|---|
| New service or major feature | Full STRIDE threat model | 60–90 min |
| PR touching auth/payments/PII | STRIDE checklist review | 15 min |
| Every sprint | Review open threat register items | 20 min |
| Quarterly | Full PASTA review for tier-1 services | Half day |
| Post-incident | Threat model update to reflect attacker path | 30 min |

---

## Next level: climbing the maturity ladder

Once threat modelling is embedded in your pipeline, you are ready to climb:

- **[Level 2: Attack Surface Management](/wiki/asm/)** — discover what is actually exposed
- **[Level 3: Red Teaming](/wiki/red-teaming/)** — prove whether your mitigations work
- **[Level 4: Purple Teaming](/wiki/purple-teaming/)** — validate whether you can detect attacks
- **[Level 5: Threat Intelligence](/wiki/threat-intelligence/)** — make your threat models attacker-realistic
- **[Level 6: Zero Trust](/wiki/zero-trust/)** — eliminate entire threat categories architecturally
