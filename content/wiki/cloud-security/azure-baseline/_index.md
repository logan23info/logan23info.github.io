---
title: "Azure Security Baseline"
date: 2026-08-05
tags: ["Azure", "cloud-security", "Entra-ID", "RBAC", "Defender", "Sentinel", "CIS-benchmark"]
categories: ["cloud-security"]
description: "Azure security baseline — Entra ID, RBAC, Storage, NSGs, Defender for Cloud, Microsoft Sentinel, and CIS Azure Benchmark controls."
showToc: true
layout: "single"
---

## Overview

Microsoft Azure's security model centres on **Entra ID** (formerly Azure AD) for identity and **Azure RBAC** for access control. Azure has the deepest integration with enterprise identity and compliance tooling of the three major clouds, making it the dominant choice for regulated industries. This baseline covers CIS Microsoft Azure Foundations Benchmark v2.0.

**Automated check:**
```bash
pip install prowler
prowler azure --compliance cis_azure_2.0
```

---

## 1. Entra ID (Azure Active Directory)

### MFA and Conditional Access

```bash
# Check MFA status for all users (requires Microsoft Graph API)
az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/reports/credentialUserRegistrationDetails" \
  --headers "ConsistencyLevel=eventual" | \
  jq '.value[] | select(.isMfaRegistered == false) | {displayName, userPrincipalName}'

# List users without MFA registered
az rest --method GET \
  --url "https://graph.microsoft.com/beta/reports/authenticationMethods/userRegistrationDetails?\$filter=isMfaRegistered eq false" | \
  jq '.value[].userPrincipalName'
```

```hcl
# infra/entra.tf — Conditional Access policies via Terraform

resource "azuread_conditional_access_policy" "require_mfa" {
  display_name = "Require MFA for all users"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]
    users {
      included_users = ["All"]
      excluded_users = [azuread_user.break_glass.object_id]  # emergency account exempt
    }
    applications {
      included_applications = ["All"]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "Block legacy authentication"
  state        = "enabled"

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azuread_conditional_access_policy" "require_compliant_device" {
  display_name = "Require compliant device for sensitive apps"
  state        = "enabled"

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = [
        "00000003-0000-0000-c000-000000000000",  # Microsoft Graph
        "797f4846-ba00-4fd7-ba43-dac1f8f63013",  # Azure Management
      ]
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["mfa", "compliantDevice"]
  }
}
```

---

## 2. Azure RBAC — Role-Based Access Control

```bash
# List all users with Owner role at subscription level — should be minimal
az role assignment list \
  --role "Owner" \
  --scope "/subscriptions/$(az account show --query id -o tsv)" \
  --query "[].{principalName:principalName,principalType:principalType}" \
  -o table

# Find all service principals with high-privilege roles
az role assignment list --all \
  --query "[?principalType=='ServicePrincipal' && (roleDefinitionName=='Owner' || roleDefinitionName=='Contributor')]" \
  --output table

# Audit all role assignments — export for review
az role assignment list --all \
  --query "[].{name:principalName,type:principalType,role:roleDefinitionName,scope:scope}" \
  -o table > role-assignments-audit.txt
```

```hcl
# infra/rbac.tf — least privilege RBAC

# Custom role — only what the application needs
resource "azurerm_role_definition" "payment_processor" {
  name        = "Payment Processor"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Allows reading payment-related secrets and writing to payment queue"

  permissions {
    actions = [
      "Microsoft.KeyVault/vaults/secrets/read",
      "Microsoft.ServiceBus/namespaces/queues/write",
      "Microsoft.ServiceBus/namespaces/queues/read",
    ]
    not_actions = []
    data_actions = [
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    ]
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}"
  ]
}

resource "azurerm_role_assignment" "payment_app" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}"
  role_definition_name = azurerm_role_definition.payment_processor.name
  principal_id         = azurerm_user_assigned_identity.payment_app.principal_id
}

# Managed Identity — no credentials to manage
resource "azurerm_user_assigned_identity" "payment_app" {
  name                = "payment-app-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}
```

---

## 3. Storage Security

```hcl
# infra/storage.tf — secure Azure Storage

resource "azurerm_storage_account" "data" {
  name                     = "${replace(var.project, "-", "")}data"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"   # zone-redundant

  # Security settings
  enable_https_traffic_only       = true   # deny HTTP
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false  # no public blobs
  shared_access_key_enabled       = false  # use Entra ID only — disable storage keys

  # Encryption with customer-managed key
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_cmk.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_cmk.id]
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  network_rules {
    default_action             = "Deny"     # deny all by default
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.private.id]
    # No ip_rules with 0.0.0.0/0
  }
}

# Diagnostic settings — log all storage operations
resource "azurerm_monitor_diagnostic_setting" "storage" {
  name               = "storage-diagnostics"
  target_resource_id = "${azurerm_storage_account.data.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }
  metric { category = "Transaction" }
}
```

---

## 4. Network Security Groups

```hcl
# infra/nsg.tf — network security baseline

resource "azurerm_network_security_group" "app" {
  name                = "${var.project}-app-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# DENY all internet inbound — explicit deny rule
resource "azurerm_network_security_rule" "deny_internet_inbound" {
  name                        = "DenyInternetInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}

# Allow only from load balancer
resource "azurerm_network_security_rule" "allow_lb" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}

# NEVER allow: source_address_prefix = "*" on SSH (22) or RDP (3389)
# Use Azure Bastion for administrative access instead
resource "azurerm_bastion_host" "main" {
  name                = "${var.project}-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
```

---

## 5. Defender for Cloud & Microsoft Sentinel

```hcl
# infra/defender.tf

# Enable Defender for Cloud on all supported resource types
resource "azurerm_security_center_subscription_pricing" "defender_servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "defender_containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

# Microsoft Sentinel — SIEM
resource "azurerm_log_analytics_workspace" "security" {
  name                = "${var.project}-security-workspace"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 365
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = azurerm_log_analytics_workspace.security.id
}

# Activity Log — ship all Azure control plane operations to Sentinel
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name               = "activity-log-to-sentinel"
  target_resource_id = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  enabled_log { category = "Administrative" }
  enabled_log { category = "Security" }
  enabled_log { category = "ServiceHealth" }
  enabled_log { category = "Alert" }
  enabled_log { category = "Policy" }
}
```

---

## Azure Security Baseline Checklist

```
Entra ID
□ MFA enforced via Conditional Access for all users
□ Legacy authentication blocked via Conditional Access
□ Privileged Identity Management (PIM) for admin roles — time-limited access
□ No permanent Global Administrator assignments (use PIM)
□ Break-glass accounts: 2, cloud-only, hardware MFA, monitored
□ Password Protection: banned password list enabled
□ Self-service password reset enabled with MFA

RBAC
□ No users with Owner at subscription level except emergency
□ Contributor role reviewed quarterly — remove if unused
□ Custom roles used instead of built-in for application workloads
□ Managed Identities used instead of service principals with secrets
□ Shared access keys disabled on storage accounts

Storage
□ enable_https_traffic_only = true
□ min_tls_version = TLS1_2
□ allow_nested_items_to_be_public = false
□ Shared access keys disabled
□ CMEK encryption on sensitive storage
□ Soft delete enabled (30 days)
□ Network rules: default_action = Deny

Network
□ No NSG rule allowing Internet → SSH/RDP
□ Azure Bastion used for administrative access
□ NSG flow logs enabled on all NSGs
□ Azure DDoS Protection Standard enabled on production VNets
□ Private Endpoints for PaaS services (Storage, SQL, Key Vault)

Detection
□ Defender for Cloud enabled (all resource types)
□ Microsoft Sentinel connected to Log Analytics
□ Activity Logs exported to Sentinel
□ Entra ID sign-in logs shipped to Sentinel
□ Alert rules for: global admin added, MFA disabled, bulk download
```

<div class="references-section">

## 📚 Related pages

<div class="ref-grid">
  <a class="ref-card" href="/wiki/cloud-security/aws-baseline/"><span class="ref-label">Cloud</span>AWS Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/gcp-baseline/"><span class="ref-label">Cloud</span>GCP Security Baseline</a>
  <a class="ref-card" href="/wiki/cloud-security/cloud-misconfig-top10/"><span class="ref-label">Cloud</span>Cloud Misconfiguration Top 10</a>
  <a class="ref-card" href="/wiki/zero-trust/"><span class="ref-label">Wiki</span>Zero Trust Architecture</a>
  <a class="ref-card" href="/wiki/secure-architecture/secrets-management/"><span class="ref-label">Architecture</span>Secrets Management</a>
  <a class="ref-card" href="/wiki/advisory-assurance/controls-evidence/"><span class="ref-label">Assurance</span>Controls & Evidence Catalogue</a>
</div>

</div>
