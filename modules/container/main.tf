resource "azurerm_storage_container" "container" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = var.storage_account_id
  container_access_type = each.value.container_access_type
}