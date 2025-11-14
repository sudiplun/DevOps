output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.aks.principal_id
}
