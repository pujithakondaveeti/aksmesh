output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "hnc_parent_namespaces" {
  description = "Parent namespaces created for hierarchical structure"
  value       = module.hnc.parent_namespaces
}

output "hnc_child_namespaces" {
  description = "Child namespaces created via SubnamespaceAnchor"
  value       = module.hnc.child_namespaces
}
