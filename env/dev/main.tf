locals {
  tags = {
    owner       = "szymon.dudziak"
    project     = "iac-lab"
    managed_by  = "Terraform"
    cost_center = "iac-lab"
    lifecycle   = "dev"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}

module "network" {
  source = "../../modules/network"

  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_address_space  = ["10.0.0.0/16"]

  subnets = {
    "Frontend" = {
      address_prefix = ["10.0.1.0/24"]
    }
    "Backend" = {
      address_prefix = ["10.0.2.0/24"]
    }
    "AzureBastion" = {
      address_prefix = ["10.0.255.0/24"]
    }
    "Gateway" = {
      address_prefix = ["10.0.3.0/24"]
    }
  }

  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}