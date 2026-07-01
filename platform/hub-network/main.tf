terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "platform/hub-network.tfstate"
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

resource "azurerm_resource_group" "networking" {
  name     = "${var.prefix}-networking-rg"
  location = var.location
  tags     = var.tags
}

module "hub_spoke" {
  source = "git::https://github.com/gerardrecinto/Terraform.git//Azure/modules/networking?ref=v1.0.0"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name

  hub_address_space      = [var.hub_address_space]
  firewall_subnet_prefix = var.firewall_subnet_prefix
  gateway_subnet_prefix  = var.gateway_subnet_prefix
  bastion_subnet_prefix  = var.bastion_subnet_prefix

  spokes             = var.spokes
  deploy_bastion     = true
  gateway_deployed   = false
  availability_zones = ["1", "2", "3"]

  tags = var.tags
}

# Private DNS zones for Azure PaaS services — linked to hub VNet
resource "azurerm_private_dns_zone" "zones" {
  for_each = toset([
    "privatelink.vaultcore.azure.net",
    "privatelink.servicebus.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.azurecr.io",
  ])

  name                = each.value
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.zones

  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.hub_spoke.hub_vnet_id
  registration_enabled  = false
}
