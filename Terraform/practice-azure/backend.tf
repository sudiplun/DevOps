# this for backup terraform.tfvars 
terraform {
  backend "azurerm" {
    resource_group_name  = "LUNIOX"
    storage_account_name = "mystatestore"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
