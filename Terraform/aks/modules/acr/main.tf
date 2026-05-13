resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false  # Best practice: disable admin user
}
