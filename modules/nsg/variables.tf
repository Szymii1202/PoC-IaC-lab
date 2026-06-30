variable "environment" {
    type = string
    description = "Środowisko"
}

variable "purpose" {
    type = string
    description = "Cel zasobu"
}

variable "resource_group_name" {
    type = string
    description = "Nazwa grupy zasobów"
}

variable "location" {
    type = string
    description = "Lokalizacja zasobów"
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

        destination_address_prefixes = optional(list(string))
        destination_application_security_group_ids = optional(list(string))
        destination_port_ranges = optional(list(string))
        source_address_prefixes = optional(list(string))
        source_application_security_group_ids = optional(list(string))
        source_port_ranges = optional(list(string))
    }))
    description = "Lista reguł NSG"
}

variable "subnet_ids" {
    type = map(string)
    description = "Lista ID podsieci"
}