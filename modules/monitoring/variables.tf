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
    description = "Azure region for the resources"
}

variable "retention_in_days" {
    type        = number
    default = 30
    description = "Number of days to retain logs in Log Analytics workspace"
}

variable "application_type" {
    type        = string
    default     = "web"
    description = "Type of application for Application Insights (e.g., web, other)"
}

variable "tags" {
    type        = map(string)
    description = "Tags to apply to resources"
}