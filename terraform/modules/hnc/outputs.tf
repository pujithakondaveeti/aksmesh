output "parent_namespaces" {
  description = "List of parent namespaces created"
  value = [
    kubernetes_namespace.ss_automative_nds.metadata[0].name,
    kubernetes_namespace.ss_integrations_nds.metadata[0].name
  ]
}

output "child_namespaces" {
  description = "List of child namespaces created via SubnamespaceAnchor"
  value = [
    "application1-nds",
    "application2-nds",
    "integration1-nds",
    "integration2-nds"
  ]
}

output "hnc_namespace" {
  description = "Namespace where HNC is installed"
  value       = helm_release.hnc.namespace
}
