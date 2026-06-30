variable "resource_group_name" {
    type        = string
    description = "Nazwa grupy zasobów"
}

variable "location" {
    type        = string
    description = "Lokalizacja zasobu"
}

variable "project_name" {
    type        = string
    description = "Nazwa projektu"
}

variable "environment" {
    type        = string
    description = "Środowisko (np. dev, test, prod)"
}

variable "account_tier" {
    type        = string
    description = "Poziom konta magazynu (Standard lub Premium)"
}

variable "account_replication_type" {
    type        = string
    description = "Typ replikacji konta magazynu (LRS, GRS, RAGRS, ZRS)"
}

variable "tags" {
    type        = map(string)
    description = "Tagi zasobu"
}