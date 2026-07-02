variable "project_name" {
    type        = string
    description = "Nazwa projektu"
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

variable "vnet_address_space" {
    type        = list(string)
    description = "Address space of the virtual network"
}

variable "subnets" {
    type = map(object({
        name = string
        address_prefix  = list(string)
    }))
    description = "Map of subnets with their names and address prefixes"
}

variable "tags" {
    type        = map(string)
    description = "Tags for the resources"
}