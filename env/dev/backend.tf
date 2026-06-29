terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-iac-lab"
    storage_account_name = "sttfstateiaclabeuw"
    container_name       = "tfstate"
    key                 = "dev/iac-lab.tfstate"
  }
}