variable "environment" {
    type        = string
    description = "Type of environment (e.g., dev, test, prod)"
}

variable "purpose" {
    type        = string
    description = "Purpose of the resource"
}

variable "resource_group_name" {
    type        = string
    description = "Name of the resource group"
}

variable "location" {
    type        = string
    description = "Location of the resources"
}

variable "nsg_rules" {
    type = list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
        description                = string

        destination_address_prefixes                = optional(list(string))
        destination_application_security_group_ids  = optional(list(string))
        destination_port_ranges                     = optional(list(string))
        source_address_prefixes                     = optional(list(string))
        source_application_security_group_ids       = optional(list(string))
        source_port_ranges                          = optional(list(string))
    }))
    description = "List of NSG rules"
}

variable "subnet_ids" {
    type        = map(string)
    description = "List of subnet IDs"
}