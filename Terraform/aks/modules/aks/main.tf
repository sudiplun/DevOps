# System-assigned identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group
  location            = var.location
}

# Grant AKS identity AcrPull on ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.cluster_name

  kubernetes_version = var.kubernetes_version

  # Use user-assigned identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Enable monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    msi_auth_for_monitoring_enabled = true
  }

  # Network
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.2.0.0/16"
    dns_service_ip    = "10.2.0.10"
  }

  default_node_pool {
    name           = "system"
    vm_size        = var.system_node_vm_size
    node_count     = 2
    min_count      = 2
    max_count      = 5
    enable_auto_scaling = true
    vnet_subnet_id = var.aks_subnet_id
    availability_zones = ["1", "2", "3"]
    os_disk_size_gb = 30
    mode           = "System"
  }

  # User node pool
  node_pool {
    name           = "userpool"
    vm_size        = var.user_node_vm_size
    node_count     = 2
    min_count      = 1
    max_count      = 5
    enable_auto_scaling = true
    vnet_subnet_id = var.aks_subnet_id
    availability_zones = ["1", "2", "3"]
    os_disk_size_gb = 60
    mode           = "User"
  }

  # Cluster autoscaler enabled via node pools above

  tags = {
    Environment = "production"
  }
}

# Log Analytics Workspace for Container Insights
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
