output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
  description = "The ID of the Virtual Network."
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
  description = "The name of the Virtual Network."
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
  description = "The address space of the Virtual Network."
}

output "subnet_ids" {
  value = {
    for s in azurerm_subnet.subnets :
    s.name => s.id
  }
  description = "A map of subnet names to their IDs."
}

output "subnet_names" {
  value = [for s in azurerm_subnet.subnets : s.name]
  description = "A list of subnet names."
}