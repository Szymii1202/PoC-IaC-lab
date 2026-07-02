variable "project_name" {
    type        = string
    description = "Name of the project"
}

variable "environment" {
    type        = string
    description = "Type of environment (e.g., dev, test, prod)"
}

variable "location" {
    type        = string
    description = "Location of the resources"
}

variable "tags" {
    type        = map(string)
    description = "Tags for the resource"
}