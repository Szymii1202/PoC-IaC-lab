variable "project_name" {
    type        = string
    description = "Nazwa projektu"
}

variable "environment" {
    type        = string
    description = "Środowisko"
}

variable "resource_group_name" {
    type        = string
    description = "Nazwa grupy zasobów"
}

variable "location" {
    type        = string
    description = "Lokalizacja zasobów"
}

variable "vnet_address_space" {
    type        = list(string)
    description = "Zakres adresów sieci wirtualnej"
}

variable "subnets" {
    type = map(object({
        address_prefix  = list(string)
    }))
  
}

variable "tags" {
    type        = map(string)
    description = "Tagi dla zasobów"
}