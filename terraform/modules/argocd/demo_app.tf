resource "kubernetes_manifest" "argocd_demo_app" {
  manifest = yamldecode(file("${path.module}/../argocd/demo-app-application.yaml"))
}
