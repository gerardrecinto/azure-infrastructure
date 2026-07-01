terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "workloads/messaging.tfstate"
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

data "terraform_remote_state" "monitoring" {
  backend = "azurerm"
  config = {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "platform/monitoring.tfstate"
    use_oidc             = true
  }
}

resource "azurerm_resource_group" "messaging" {
  name     = "${var.prefix}-messaging-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_subnet" "endpoints" {
  name                 = "endpoints"
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = "${var.prefix}-networking-rg"
}

data "azurerm_private_dns_zone" "sb" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = "${var.prefix}-networking-rg"
}

module "servicebus" {
  source = "git::https://github.com/gerardrecinto/Terraform.git//Azure/modules/servicebus?ref=v1.0.0"

  name                       = var.namespace_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.messaging.name
  capacity                   = var.capacity
  private_endpoint_subnet_id = data.azurerm_subnet.endpoints.id
  private_dns_zone_id        = data.azurerm_private_dns_zone.sb.id
  log_analytics_workspace_id = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
  topics                     = var.topics
  queues                     = var.queues
  sender_principal_ids       = var.sender_principal_ids
  receiver_principal_ids     = var.receiver_principal_ids
  tags                       = var.tags
}
