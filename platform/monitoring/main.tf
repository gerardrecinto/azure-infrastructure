terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "platform/monitoring.tfstate"
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
  use_oidc        = true
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "monitoring" {
  name     = "${var.prefix}-monitoring-rg"
  location = var.location
  tags     = var.tags
}

module "monitoring" {
  source = "git::https://github.com/gerardrecinto/Terraform.git//Azure/modules/monitoring?ref=main"

  prefix                = var.prefix
  location              = var.location
  resource_group_name   = azurerm_resource_group.monitoring.name
  log_retention_days    = var.log_retention_days
  alert_email_receivers = var.alert_email_receivers
  tags                  = var.tags
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}

output "action_group_id" {
  value = module.monitoring.action_group_id
}
