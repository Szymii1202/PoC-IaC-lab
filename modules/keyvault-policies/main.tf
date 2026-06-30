resource "azurerm_key_vault_access_policy" "kv_policy" {
  for_each     = var.kv_policies
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions         = coalesce(each.value.key_permissions, null)
  secret_permissions      = coalesce(each.value.secret_permissions, null)
  certificate_permissions = coalesce(each.value.certificate_permissions, null)
}