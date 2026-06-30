variable "project_name" {
    type        = string
    description = "Nazwa projektu"
}

variable "environment" {
    type        = string
    description = "Środowisko (np. dev, test, prod)"
}

variable "resource_group_name" {
    type        = string
    description = "Nazwa grupy zasobów"
}

variable "location" {
    type        = string
    description = "Lokalizacja zasobu"
}

variable "tenant_id" {
    type        = string
    description = "Identyfikator dzierżawy Azure"
}

variable "sku_name" {
    type        = string
    description = "Nazwa SKU Key Vault (np. standard, premium)"
}

variable "soft_delete_retention_days" {
    type        = number
    description = "Liczba dni przechowywania usuniętych obiektów w Key Vault"
}

variable "purge_protection_enabled" {
    type        = bool
    description = "Czy ochrona przed trwałym usunięciem jest włączona"
}

variable "public_network_access_enabled" {
    type        = bool
    description = "Czy dostęp do Key Vault z publicznej sieci jest włączony"
}

variable "tags" {
    type        = map(string)
    description = "Tagi zasobu"
}