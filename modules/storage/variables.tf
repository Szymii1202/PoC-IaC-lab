variable "resource_group_name" {
    type        = string
    description = "Name of the resource group where the storage account will be created"
}

variable "location" {
    type        = string
    description = "Location of the storage account"
}

variable "project_name" {
    type        = string
    description = "Name of the project"
}

variable "environment" {
    type        = string
    description = "Type of environment (e.g., dev, test, prod)"
}

variable "account_tier" {
    type        = string
    description = "Level of the storage account (Standard or Premium)"
}

variable "account_replication_type" {
    type        = string
    description = "Type of replication for the storage account (LRS, GRS, RAGRS, ZRS)"
}

variable "tags" {
    type        = map(string)
    description = "Tags for the resource"
}