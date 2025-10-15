# This will create the ArgoCD Application resource in namespace 'argocd'.
resource "kubernetes_manifest" "argocd_istio_application" {
  manifest = yamldecode(file("${path.module}/../argocd/istio-application.yaml"))
}
resource "kubernetes_manifest" "argocd_istio_config" {
  manifest = yamldecode(file("${path.module}/../argocd/istio-config-application.yaml"))
}
