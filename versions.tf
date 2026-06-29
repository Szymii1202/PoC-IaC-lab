terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 4.70.0"
    }
  }

  required_version = "~> 1.15.7"
}