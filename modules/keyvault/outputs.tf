output "keyvault_id" {
    value = azurerm_key_vault.kv.id
    description = "The ID of the Key Vault."
}

output "keyvault_name" {
    value = azurerm_key_vault.kv.name
    description = "The name of the Key Vault."
}