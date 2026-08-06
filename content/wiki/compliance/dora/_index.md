---
title: "DORA — Digital Operational Resilience Act"
date: 2026-08-05
tags: ["DORA", "compliance", "EU", "financial-regulation", "ICT-risk", "TLPT"]
categories: ["compliance"]
description: "DORA compliance guide — ICT risk management, incident reporting, resilience testing, and third-party risk for EU financial entities."
showToc: true
layout: "single"
---

## What is DORA?

The Digital Operational Resilience Act (EU) 2022/2554 is EU regulation that entered into force on **17 January 2025**. It applies to financial entities (banks, investment firms, payment institutions, insurance companies, crypto-asset service providers) and their critical ICT third-party service providers operating in the EU.

**Core objective:** Ensure financial entities can withstand, respond to, and recover from all ICT-related disruptions and threats.
**Supervisor:** National Competent Authorities (EBA, ESMA, EIOPA for EU entities).
**Penalties:** Significant fines for non-compliance — specific amounts set by national supervisors.

---

## Who DORA applies to

| Entity type | In scope? |
|---|---|
| Credit institutions (banks) | Yes |
| Payment and e-money institutions | Yes |
| Investment firms | Yes |
| Insurance and reinsurance undertakings | Yes |
| Crypto-asset service providers (CASPs) | Yes |
| Critical ICT third-party service providers (CTPPs) | Yes — direct obligations |
| Non-critical ICT providers to financial entities | Indirect — via contractual requirements |

---

## Five pillars of DORA

### Pillar 1 — ICT Risk Management (Articles 5–16)

DORA requires a comprehensive ICT risk management framework integrated into the overall risk framework.

```yaml
# ict-risk-framework.yml
governance:
  board_responsibility:
    - Approve ICT risk strategy annually
    - Ensure adequate budget for ICT security
    - Review ICT risk reports at least quarterly
    - Accountable for DORA compliance

  ict_risk_roles:
    - CISO: responsible for ICT security strategy
    - CIO: responsible for ICT operations
    - CRO: responsible for ICT risk integration

risk_management_process:
  identify:
    - Complete ICT asset inventory with criticality classification
    - Map all ICT systems supporting critical functions
    - Document all third-party ICT dependencies
    - Assess concentration risk (single providers for critical functions)

  protect:
    - Implement controls proportionate to risk
    - Minimum: encryption, MFA, vulnerability management, patch management
    - Network segmentation for critical systems
    - Secure development lifecycle

  detect:
    - Continuous monitoring of ICT systems
    - Anomaly detection and alerting
    - Threat intelligence feeds

  respond_recover:
    - ICT incident response plan
    - Business continuity plan with RTO/RPO targets
    - Communication plan for ICT incidents
    - Annual DR test

evidence_for_supervisors:
  - ICT risk register with treatment decisions
  - Board-approved ICT risk strategy
  - ICT asset inventory
  - Control effectiveness reports
  - Audit results
```

---

### Pillar 2 — ICT Incident Management and Reporting (Articles 17–23)

DORA introduces mandatory reporting of major ICT incidents and significant cyber threats to supervisory authorities.

```yaml
# incident-classification.yml

major_incident_criteria:
  # A major ICT incident must be reported to the supervisor
  # Criteria (any one triggers major classification):
  - client_impact:
      description: "More than a defined number of clients affected"
      threshold: "Determined by national supervisor — typically significant %"

  - data_impact:
      description: "Personal or confidential data breached"
      severity: "Any significant data breach"

  - reputation_impact:
      description: "Significant reputational damage to the entity"

  - financial_impact:
      description: "Direct financial loss above threshold"
      threshold: "Defined by national supervisor"

  - duration:
      description: "Incident lasting longer than a defined period"
      threshold: "Typically 4 hours for critical services"

  - geographic_impact:
      description: "Impact across multiple EU member states"

reporting_timeline:
  initial_notification:
    deadline: "4 hours after classification as major incident"
    content:
      - Incident reference and classification
      - Date/time of detection
      - Nature of incident (preliminary)
      - Initial assessment of impact
      - Containment measures taken

  intermediate_report:
    deadline: "72 hours after initial notification"
    content:
      - Updated impact assessment
      - Root cause (if known)
      - Measures implemented
      - Estimated recovery timeline

  final_report:
    deadline: "1 month after resolution"
    content:
      - Root cause analysis
      - Full impact quantification
      - Measures implemented to prevent recurrence
      - Lessons learned
```

---

### Pillar 3 — Digital Operational Resilience Testing (Articles 24–27)

DORA requires regular testing of ICT systems and, for significant entities, Threat-Led Penetration Testing (TLPT).

```yaml
# resilience-testing-programme.yml

basic_testing:
  # Required for all in-scope entities
  frequency: "At least annual"
  types:
    - vulnerability_assessments: "Quarterly"
    - network_security_assessments: "Annual"
    - gap_analyses: "Annual"
    - physical_security_reviews: "Annual"
    - scenario_based_tests: "Annual"
    - penetration_tests: "Annual"

  evidence:
    - Vulnerability scan reports with remediation tracking
    - Pen test reports from qualified provider
    - Test results reviewed by management
    - Remediation tracked to closure

advanced_testing_tlpt:
  # Required for significant financial entities
  # Threat-Led Penetration Testing (TLPT) based on TIBER-EU methodology
  frequency: "Every 3 years minimum"
  
  phases:
    intelligence_gathering:
      description: "Threat intelligence provider produces target threat landscape"
      output: "Generic Threat Intelligence Report + Targeted Threat Intelligence Report"
      duration: "6–8 weeks"

    red_team_test:
      description: "Red team conducts full adversarial simulation"
      scope: "Production systems supporting critical functions — live environment"
      duration: "12+ weeks"
      techniques: "Based on TTIs from intelligence phase"

    closure:
      description: "Results shared with blue team, remediation plan agreed"
      output: "TLPT Summary Report, remediation roadmap"
      attestation: "Supervisor attestation upon completion"

  providers:
    - Must use accredited TLPT providers
    - Threat intelligence provider and red team must be separate organisations
    - At least one provider must be external to the organisation
```

---

### Pillar 4 — ICT Third-Party Risk Management (Articles 28–44)

DORA requires financial entities to manage ICT third-party risk systematically, with enhanced requirements for Critical Third-Party Providers (CTPPs).

```yaml
# third-party-ict-risk.yml

ict_provider_register:
  # Article 28 — maintain register of all ICT third-party arrangements
  required_fields:
    - provider_name_and_contact
    - service_description
    - date_of_contract_start
    - criticality_classification  # critical / important / non-critical
    - data_processed
    - sub-processors
    - country_of_data_processing
    - exit_strategy
    - last_risk_assessment_date

pre_contract_due_diligence:
  - Security certifications (ISO 27001, SOC 2)
  - Penetration test results (last 12 months)
  - Business continuity and DR capabilities
  - Sub-processor disclosure
  - Data breach history
  - Regulatory standing

contractual_requirements:
  # Article 30 — mandatory contractual provisions for critical providers
  mandatory_clauses:
    - full_service_level_descriptions: true
    - data_location_and_portability: true
    - audit_rights: true          # financial entity must be able to audit
    - incident_notification: true  # provider must notify within defined SLA
    - business_continuity_obligations: true
    - right_to_terminate_and_exit: true
    - sub-contractor_disclosure: true

concentration_risk:
  # Monitor dependence on single providers
  assessment:
    - Identify critical functions dependent on single ICT provider
    - Assess impact if provider fails or is sanctioned
    - Develop exit strategies for critical dependencies
    - Report concentration risk to management quarterly
```

---

### Pillar 5 — Information Sharing (Article 45)

DORA encourages (but does not mandate) sharing of cyber threat intelligence between financial entities.

---

## DORA gap assessment checklist

```
Governance (Articles 5–6)
□ Board formally allocated ICT risk responsibility
□ ICT risk strategy approved by board annually
□ CISO/CRO accountable for DORA compliance
□ ICT risk integrated into enterprise risk framework

ICT Risk Management (Articles 8–16)
□ Complete ICT asset inventory with criticality classification
□ ICT risk register with all material risks documented
□ Vulnerability management: quarterly scans, tracked remediation
□ Patch management: critical patches within 24 hours
□ Network segmentation for critical ICT systems
□ Encryption at rest and in transit for all critical data
□ MFA for all access to critical ICT systems

Incident Management (Articles 17–20)
□ Incident classification criteria defined and aligned to DORA thresholds
□ Major incident reporting procedure documented (4h / 72h / 1 month)
□ Incident response team trained and tested annually
□ Incident register maintained

Resilience Testing (Articles 24–27)
□ Annual penetration test of critical systems
□ Quarterly vulnerability assessments
□ Annual DR test with documented RTO/RPO results
□ TLPT completed every 3 years (if significant entity)

Third-Party Risk (Articles 28–44)
□ Complete register of all ICT third-party arrangements
□ Criticality assessment for all ICT providers
□ Due diligence completed for all critical/important providers
□ Contractual provisions meet Article 30 requirements
□ Concentration risk assessed and reported to management
□ Exit strategies documented for critical dependencies
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/compliance/iso-27001/"><span class="ref-label">Compliance</span>ISO 27001:2022</a>
  <a class="ref-card" href="/wiki/red-teaming/"><span class="ref-label">Wiki</span>Red Teaming — TLPT basis</a>
  <a class="ref-card" href="/wiki/threat-intelligence/"><span class="ref-label">Wiki</span>Threat Intelligence</a>
  <a class="ref-card" href="/wiki/advisory-assurance/tooe/"><span class="ref-label">Assurance</span>Test of Operating Effectiveness</a>
  <a class="ref-card" href="/wiki/supply-chain/"><span class="ref-label">Wiki</span>Supply Chain Security</a>
  <a class="ref-card" href="/wiki/maturity-ladder/"><span class="ref-label">Wiki</span>Security Engineering Maturity Ladder</a>
</div>

</div>
