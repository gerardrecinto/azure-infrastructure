terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "workloads/aks-platform.tfstate"
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

resource "azurerm_resource_group" "aks" {
  name     = "${var.prefix}-aks-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_subnet" "nodes" {
  name                 = "aks-nodes"
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = "${var.prefix}-networking-rg"
}

data "azurerm_subnet" "pods" {
  name                 = "aks-pods"
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = "${var.prefix}-networking-rg"
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.prefix}-aks-identity"
  resource_group_name = azurerm_resource_group.aks.name
  location            = var.location
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_subnet.nodes.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                      = "${var.prefix}-aks"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.aks.name
  dns_prefix                = var.prefix
  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = "patch"

  private_cluster_enabled             = true
  private_dns_zone_id                 = "System"
  private_cluster_public_fqdn_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # CNI Overlay: pod IPs come from an overlay CIDR, not from the VNet subnet.
  # Avoids IP exhaustion that classic Azure CNI causes on large node counts.
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = "userDefinedRouting"
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_D4ds_v5"
    node_count                   = 3
    vnet_subnet_id               = data.azurerm_subnet.nodes.id
    pod_subnet_id                = data.azurerm_subnet.pods.id
    zones                        = ["1", "2", "3"]
    os_disk_type                 = "Ephemeral"
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtemp"
  }

  # Workload Identity: federated OIDC tokens per ServiceAccount.
  # Replaces pod-managed identity where the NMI DaemonSet exposed all node IMDS traffic.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true
  local_account_disabled    = true

  microsoft_defender {
    log_analytics_workspace_id = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
  }

  oms_agent {
    log_analytics_workspace_id = data.terraform_remote_state.monitoring.outputs.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.workload_vm_size
  node_count            = var.workload_node_count
  zones                 = ["1", "2", "3"]
  vnet_subnet_id        = data.azurerm_subnet.nodes.id
  pod_subnet_id         = data.azurerm_subnet.pods.id
  os_disk_type          = "Ephemeral"
  mode                  = "User"
  node_labels           = { "nodepool-type" = "workload" }
  tags                  = var.tags
}
