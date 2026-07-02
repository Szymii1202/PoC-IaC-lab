variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location of the resources"
}

variable "boot_diag_storage_uri" {
  type        = string
  default     = null
  description = "URI of the storage account for boot diagnostics"
}

variable "vms" {
  type = map(object({
    subnet_id    = string
    name           = string
    vm_size        = string
    custom_data_path = optional(string)
    acc = object({
      admin_username = string
      admin_ssh_key  = string
    })
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
  description = "Map of virtual machines to create, with their names and sizes"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
}