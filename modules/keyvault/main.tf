resource "azurerm_key_vault" "kv" {
  name                        = "kv${var.project_name}${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    bypass         = "None"
    default_action = "Deny"
  }

  tags = var.tags
}