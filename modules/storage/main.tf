resource "azurerm_storage_account" "sa" {
  name                     = "sa${var.project_name}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version = "TLS1_2"
  public_network_access_enabled = false

  tags = var.tags
}