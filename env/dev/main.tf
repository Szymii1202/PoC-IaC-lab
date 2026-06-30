locals {
  tags = {
    owner       = "szymon.dudziak"
    project     = "iac-lab"
    managed_by  = "Terraform"
    cost_center = "iac-lab"
    lifecycle   = "dev"
  }

  address_groups = {
    "vnet"         = "10.0.0.0/16"
    "Frontend"     = "10.0.1.0/24"
    "Backend"      = "10.0.2.0/24"
    "Gateway"      = "10.0.3.0/24"
    "Internet"     = "0.0.0.0/0"
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
  vnet_address_space  = [local.address_groups.vnet]

  subnets = {
    "Frontend" = {
      address_prefix = [local.address_groups.Frontend]
    }
    "Backend" = {
      address_prefix = [local.address_groups.Backend]
    }
    "Gateway" = {
      address_prefix = [local.address_groups.Gateway]
    }
  }

  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}

module "nsg_frontend" {
  source = "../../modules/nsg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  purpose             = "Frontend"
  environment         = var.environment

  subnet_ids = {
    Frontend = module.network.subnet_ids["Frontend"]
  }

  nsg_rules = [
    {
      name                       = "allow-mssql-out"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = local.address_groups.Frontend
      destination_address_prefix = local.address_groups.Backend
      description = "Allow outbound traffic from Frontend to Backend on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-out"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.Frontend
      destination_address_prefix = local.address_groups.Backend
      description = "Allow outbound traffic from Frontend to Backend on port 3306 (MySQL)"
    },
    {
      name                       = "allow-ssh-in"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = local.address_groups.Frontend
      destination_address_prefix = local.address_groups.Internet
      description = "Allow inbound SSH traffic from the Internet to Frontend"
    }
  ]
}

module "nsg_backend" {
  source = "../../modules/nsg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  purpose             = "Backend"
  environment         = var.environment

  subnet_ids = {
    Backend = module.network.subnet_ids["Backend"]
  }

  nsg_rules = [
    {
      name                       = "allow-mssql-in"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = local.address_groups.Frontend
      destination_address_prefix = local.address_groups.Backend
      description = "Allow inbound traffic from Frontend to Backend on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-in"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.Frontend
      destination_address_prefix = local.address_groups.Backend
      description = "Allow inbound traffic from Frontend to Backend on port 3306 (MySQL)"
    },
    {
      name                       = "allow-https-out"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = local.address_groups.Backend
      destination_address_prefix = local.address_groups.Internet
      description = "Allow outbound HTTPS traffic from Backend to the Internet"
    }
  ]
}