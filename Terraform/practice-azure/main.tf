# terraform global config like settings.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # registry.terraform.io/hashicorp/azurerm
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # values are read form terraform.tfvars
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

resource "azurerm_resource_group" "sudip" {
  # id = "" auto generated here.
  name     = "sudip-test"
  location = "centralindia"
}
