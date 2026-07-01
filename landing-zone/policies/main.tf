terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

data "azurerm_management_group" "org" {
  display_name = var.org_management_group_name
}

# Deny Key Vault public network access org-wide
resource "azurerm_management_group_policy_assignment" "deny_kv_public" {
  name                 = "deny-kv-public-access"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/405c5871-3e91-4644-8a63-58e19d68ff5b"
  management_group_id  = data.azurerm_management_group.org.id
  display_name         = "Deny Key Vault public network access"
  enforce              = true
}

# Block privileged containers in AKS
resource "azurerm_management_group_policy_assignment" "deny_aks_privileged" {
  name                 = "deny-aks-privileged"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4"
  management_group_id  = data.azurerm_management_group.org.id
  display_name         = "Kubernetes cluster should not allow privileged containers"
  enforce              = true
}

# Require environment tag on all resource groups
resource "azurerm_management_group_policy_assignment" "require_env_tag" {
  name                 = "require-rg-env-tag"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  management_group_id  = data.azurerm_management_group.org.id
  display_name         = "Require environment tag on resource groups"
  enforce              = true

  parameters = jsonencode({
    tagName = { value = "environment" }
  })
}

# Restrict deployments to approved Azure regions
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  management_group_id  = data.azurerm_management_group.org.id
  display_name         = "Allowed locations"
  enforce              = true

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# Audit SQL servers lacking AAD admin — non-blocking, surfaces in compliance dashboard
resource "azurerm_management_group_policy_assignment" "audit_sql_aad" {
  name                 = "audit-sql-no-aad"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f314764-cb73-4fc9-b863-8eca98ac36e9"
  management_group_id  = data.azurerm_management_group.org.id
  display_name         = "Audit SQL servers without AAD admin"
  enforce              = false
}
