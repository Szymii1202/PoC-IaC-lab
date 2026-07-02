data "azurerm_client_config" "current" {}

locals {
  address_groups = {
    "vnet"     = "10.0.0.0/16"
    "frontend" = "10.0.1.0/24"
    "backend"  = "10.0.2.0/24"
    "gateway"  = "10.0.3.0/24"
    "bastion"  = "10.0.255.0/24"
    "internet" = "0.0.0.0/0"
  }
}

module "global" {
  source = "../../modules/global"

  project_name = local.project_name
  environment  = var.environment
  location     = local.location

  tags = local.global_tags
}

module "network" {
  source = "../../modules/network"

  project_name        = local.project_name
  environment         = var.environment
  resource_group_name = module.global.resource_group_name
  location            = local.location
  vnet_address_space  = [local.address_groups.vnet]

  subnets = {
    "frontend" = {
      name           = "frontend"
      address_prefix = [local.address_groups.frontend]
    }
    "backend" = {
      name           = "backend"
      address_prefix = [local.address_groups.backend]
    }
    "gateway" = {
      name           = "GatewaySubnet"
      address_prefix = [local.address_groups.gateway]
    }
    "bastion" = {
      name           = "AzureBastionSubnet"
      address_prefix = [local.address_groups.bastion]
    }
  }

  tags = local.global_tags
}

module "nsg_frontend_subnet" {
  source = "../../modules/nsg"

  resource_group_name = module.global.resource_group_name
  location            = local.location
  purpose             = "FrontendSubnet"
  environment         = var.environment

  subnet_ids = {
    frontend = module.network.subnet_ids["frontend"]
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
      source_address_prefix      = local.address_groups.frontend
      destination_address_prefix = local.address_groups.backend
      description                = "Allow outbound traffic from frontend to backend on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-out"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.frontend
      destination_address_prefix = local.address_groups.backend
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
      source_address_prefix      = local.address_groups.frontend
      destination_address_prefix = local.address_groups.internet
      description                = "Allow inbound SSH traffic from the Internet to frontend"
    }
  ]
}

module "nsg_backend_subnet" {
  source = "../../modules/nsg"

  resource_group_name = module.global.resource_group_name
  location            = local.location
  purpose             = "BackendSubnet"
  environment         = var.environment

  subnet_ids = {
    backend = module.network.subnet_ids["backend"]
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
      source_address_prefix      = local.address_groups.frontend
      destination_address_prefix = local.address_groups.backend
      description                = "Allow inbound traffic from frontend to backend on port 1433 (MSSQL)"
    },
    {
      name                       = "allow-mysql-in"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = local.address_groups.frontend
      destination_address_prefix = local.address_groups.backend
      description                = "Allow inbound traffic from frontend to backend on port 3306 (MySQL)"
    },
    {
      name                       = "allow-https-out"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = local.address_groups.backend
      destination_address_prefix = local.address_groups.internet
      description                = "Allow outbound HTTPS traffic from backend to the Internet"
    }
  ]
}

module "storage_account" {
  source = "../../modules/storage"

  resource_group_name      = module.global.resource_group_name
  location                 = local.location
  project_name             = local.project_name
  environment              = var.environment
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = local.global_tags
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

  resource_group_name           = module.global.resource_group_name
  location                      = local.location
  project_name                  = local.project_name
  environment                   = var.environment
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = true

  tags = local.global_tags
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

module "compute" {
  source = "../../modules/compute"

  resource_group_name = module.global.resource_group_name
  location            = local.location
  vms                 = {
    "web" = {
      subnet_id = module.network.subnet_ids["frontend"]
      name      = "vm-web"
      vm_size   = "Standard_B2ats_V2"
      custom_data_path = "${path.module}/cloud-init.yml"
      acc = {
        admin_username = "webadmin"
        admin_ssh_key  = file("~/.ssh/web_vm.pub")
      }
      image = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
      }
    }
    "app" = {
      subnet_id = module.network.subnet_ids["backend"]
      name      = "vm-app"
      vm_size   = "Standard_B2ats_V2"
      acc = {
        admin_username = "appadmin"
        admin_ssh_key  = file("~/.ssh/app_vm.pub")
      }
      image = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
      }
    }
  }

  tags = local.global_tags
}

module "logs" {
  source = "../../modules/monitoring"

  resource_group_name = module.global.resource_group_name
  location            = local.location
  project_name        = local.project_name
  environment         = var.environment

  tags = local.global_tags
}