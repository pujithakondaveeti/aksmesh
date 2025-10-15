output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}
output "kubeadminconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}
output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "managed_identity_principal_id" {
  description = "The Principal ID of the AKS Managed Identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

