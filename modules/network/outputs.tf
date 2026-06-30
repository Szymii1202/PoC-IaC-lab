output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  value = {
    for s in azurerm_subnet.subnets :
    s.name => s.id
  }
}

output "subnet_names" {
  value = [for s in azurerm_subnet.subnets : s.name]
}