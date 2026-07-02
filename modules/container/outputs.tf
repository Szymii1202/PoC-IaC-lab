output "containers_id" {
    value = { for k, v in azurerm_storage_container.container : k => v.id }
    description = "The IDs of the storage containers."
}