output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.chat_aks.name
}

output "aks_kubeconfig" {
  value     = azurerm_kubernetes_cluster.chat_aks.kube_config_raw
  sensitive = true
}

output "acr_login_server" {
  value = azurerm_container_registry.chat_acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.chat_acr.admin_username
}

output "resource_group_name" {
  value = azurerm_resource_group.chat_rg.name
}
