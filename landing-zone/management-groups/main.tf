terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "landing-zone/management-groups.tfstate"
    use_oidc             = true
  }

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

data "azurerm_management_group" "tenant_root" {
  name = var.tenant_id
}

resource "azurerm_management_group" "org" {
  display_name               = var.org_name
  parent_management_group_id = data.azurerm_management_group.tenant_root.id
}

# Platform: connectivity, identity, management subscriptions
resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.org.id
}

# Workloads: prod and non-prod application subscriptions
resource "azurerm_management_group" "workloads" {
  display_name               = "Workloads"
  parent_management_group_id = azurerm_management_group.org.id
}

# Sandbox: developer experimentation, relaxed policies
resource "azurerm_management_group" "sandbox" {
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.org.id
}

resource "azurerm_management_group" "connectivity" {
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "prod" {
  display_name               = "Production"
  parent_management_group_id = azurerm_management_group.workloads.id
}

resource "azurerm_management_group" "nonprod" {
  display_name               = "Non-Production"
  parent_management_group_id = azurerm_management_group.workloads.id
}
