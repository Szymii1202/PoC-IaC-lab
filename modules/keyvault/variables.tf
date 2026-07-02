variable "project_name" {
    type        = string
    description = "Name of the project"
}

variable "environment" {
    type        = string
    description = "Type of environment (e.g., dev, test, prod)"
}

variable "resource_group_name" {
    type        = string
    description = "Name of the resource group"
}

variable "location" {
    type        = string
    description = "Location of the resources"
}

variable "tenant_id" {
    type        = string
    description = "Tenant ID of the Azure AD"
}

variable "sku_name" {
    type        = string
    description = "Name of the Key Vault SKU (e.g., standard, premium)"
}

variable "soft_delete_retention_days" {
    type        = number
    description = "Number of days to retain deleted objects in the Key Vault"
}

variable "purge_protection_enabled" {
    type        = bool
    description = "Whether purge protection is enabled"
}

variable "public_network_access_enabled" {
    type        = bool
    description = "Whether public network access is enabled"
}

variable "tags" {
    type        = map(string)
    description = "Tags for the resource"
}