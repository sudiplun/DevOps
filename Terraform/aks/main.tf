terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.46.0"
    }
  }
}

# provier
provider "azurerm" {
  features {
  }
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# resource "azurerm_resource_group" "rg1" {
#   name     = "AKS"
#   location = "Central India"
# }

# resource "azurerm_virtual_network" "vnet1" {
#   name                = "rg1-vnet"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }

# Resource Group
module "resource_group" {
  source   = "./modules/resource-group"
  location = var.location
  name     = "${var.prefix}-${var.environment}-rg"
}

# Networking
module "networking" {
  source          = "./modules/networking"
  location        = var.location
  resource_group  = module.resource_group.name
  vnet_name       = "${var.prefix}-vnet"
  vnet_cidr       = "10.0.0.0/16"
  aks_subnet_cidr = "10.0.1.0/24"
  svc_subnet_cidr = "10.0.2.0/24"
}

# Storage for Terraform state
module "storage" {
  source         = "./modules/storage"
  location       = var.location
  resource_group = module.resource_group.name
  account_name   = "${var.prefix}${var.environment}tfstate"
}
# ACR
module "acr" {
  source         = "./modules/acr"
  location       = var.location
  resource_group = module.resource_group.name
  acr_name       = "${var.prefix}${var.environment}acr"
  sku            = var.environment == "prod" ? "Standard" : "Basic"
}

# AKS
module "aks" {
  source              = "./modules/aks"
  location            = var.location
  resource_group      = module.resource_group.name
  cluster_name        = "${var.prefix}-${var.environment}-aks"
  vnet_id             = module.networking.vnet_id
  aks_subnet_id       = module.networking.aks_subnet_id
  acr_id              = module.acr.acr_id
  system_node_vm_size = "Standard_B2s"
  user_node_vm_size   = "Standard_D2s_v3"
  kubernetes_version  = "1.30"
}
