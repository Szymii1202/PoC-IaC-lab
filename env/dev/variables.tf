variable "project_name" {
  type        = string
  description = "Nazwa projektu"
}

variable "location" {
  type        = string
  description = "Lokalizacja zasobów"
}

variable "environment" {
  type        = string
  description = "Środowisko (dev, test, prod)"
}