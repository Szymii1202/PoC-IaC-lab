resource "azurerm_network_security_group" "nsg" {
  name                  = "nsg-${var.purpose}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name

  security_rule         = var.nsg_rules
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each                  = var.subnet_ids
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg.id
}