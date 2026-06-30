data "azurerm_client_config" "current" {}

locals {
  tags = {
    owner       = "szymon.dudziak"
    project     = "iac-lab"
    managed_by  = "Terraform"
    cost_center = "iac-lab"
    lifecycle   = "dev"
  }

  address_groups = {
    "vnet"               = "10.0.0.0/16"
    "FrontendSubnet"     = "10.0.1.0/24"
    "BackendSubnet"      = "10.0.2.0/24"
    "GatewaySubnet"      = "10.0.3.0/24"
    "AzureBastionSubnet" = "10.0.255.0/24"
    "Internet"           = "0.0.0.0/0"
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
    "FrontendSubnet" = {
      address_prefix = [local.address_groups.FrontendSubnet]
    }
    "BackendSubnet" = {
      address_prefix = [local.address_groups.BackendSubnet]
    }
    "GatewaySubnet" = {
      address_prefix = [local.address_groups.GatewaySubnet]
    }
    "AzureBastionSubnet" = {
      address_prefix = [local.address_groups.AzureBastionSubnet]
    }
  }

  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}

module "nsg_frontend_subnet" {
  source = "../../modules/nsg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  purpose             = "FrontendSubnet"
  environment         = var.environment

  subnet_ids = {
    FrontendSubnet = module.network.subnet_ids["FrontendSubnet"]
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
      source_address_prefix      = local.address_groups.FrontendSubnet
      destination_address_prefix = local.address_groups.BackendSubnet
      description                = "Allow outbound traffic from FrontendSubnet to BackendSubnet on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-out"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.FrontendSubnet
      destination_address_prefix = local.address_groups.BackendSubnet
      description                = "Allow outbound traffic from FrontendSubnet to BackendSubnet on port 3306 (MySQL)"
    },
    {
      name                       = "allow-ssh-in"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = local.address_groups.FrontendSubnet
      destination_address_prefix = local.address_groups.Internet
      description                = "Allow inbound SSH traffic from the Internet to FrontendSubnet"
    }
  ]
}

module "nsg_backend_subnet" {
  source = "../../modules/nsg"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  purpose             = "BackendSubnet"
  environment         = var.environment

  subnet_ids = {
    BackendSubnet = module.network.subnet_ids["BackendSubnet"]
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
      source_address_prefix      = local.address_groups.FrontendSubnet
      destination_address_prefix = local.address_groups.BackendSubnet
      description                = "Allow inbound traffic from FrontendSubnet to BackendSubnet on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-in"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.FrontendSubnet
      destination_address_prefix = local.address_groups.BackendSubnet
      description                = "Allow inbound traffic from FrontendSubnet to BackendSubnet on port 3306 (MySQL)"
    },
    {
      name                       = "allow-https-out"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = local.address_groups.BackendSubnet
      destination_address_prefix = local.address_groups.Internet
      description                = "Allow outbound HTTPS traffic from BackendSubnet to the Internet"
    }
  ]
}

module "storage_account" {
  source = "../../modules/storage"

  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  project_name             = var.project_name
  environment              = var.environment
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}

module "storage_containers" {
  source = "../../modules/container"

  storage_account_id = module.storage_account.storage_account_id
  containers = {
    "frontend" = {}
    "backend"  = {}
    "logs"     = {}
    "backup"   = {}
    "publicfiles" = {
      container_access_type = "blob"
    }

  }
}

module "key_vault" {
  source = "../../modules/keyvault"

  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  project_name                  = var.project_name
  environment                   = var.environment
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = true

  tags = merge(
    local.tags,
    { environment = var.environment }
  )
}

module "key_vault_policies" {
  source = "../../modules/keyvault-policies"

  key_vault_id = module.key_vault.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  kv_policies = {
    "app" = {
      key_permissions         = ["Get", "List", "Sign", "Verify", "Encrypt", "Decrypt"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }
    "ci_cd" = {
      key_permissions         = ["Get", "List", "Create", "Delete", "Import", "Update", "Backup", "Restore", "Update"]
      secret_permissions      = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Delete", "Import", "Update"]
    }
    "secadmin" = {
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }
  }
}