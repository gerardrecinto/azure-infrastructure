output "hub_vnet_id" {
  value       = module.hub_spoke.hub_vnet_id
  description = "Resource ID of the hub VNet."
}

output "hub_vnet_name" {
  value       = module.hub_spoke.hub_vnet_name
  description = "Name of the hub VNet."
}

output "spoke_vnet_ids" {
  value       = module.hub_spoke.spoke_vnet_ids
  description = "Map of spoke name (aks, api, data) to spoke VNet resource ID."
}

output "firewall_private_ip" {
  value       = module.hub_spoke.firewall_private_ip
  description = "Private IP of the Azure Firewall Premium instance, used as the next hop in spoke route tables."
}

output "private_dns_zone_ids" {
  value       = { for name, zone in azurerm_private_dns_zone.zones : name => zone.id }
  description = "Map of private DNS zone name (e.g. privatelink.vaultcore.azure.net) to zone resource ID."
}
