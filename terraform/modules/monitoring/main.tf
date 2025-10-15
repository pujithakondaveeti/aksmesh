# Add helm repos (these can be pulled in by specifying repository in helm_release)
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prom-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "78.2.0"
  namespace  = "monitoring"

  create_namespace = true

  values = [
    file("${path.module}/../../helm-values/kube-prom-values.yaml")
  ]

  depends_on = []
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "monitoring"
  create_namespace = false
  values = [
    file("${path.module}/../../helm-values/loki-values.yaml")
  ]

  depends_on = [helm_release.kube_prometheus_stack]
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.5.2"
  namespace  = "kyverno"

  create_namespace = true


  depends_on = [helm_release.loki]
}

resource "kubernetes_manifest" "limits" {
  manifest = yamldecode(file("${path.module}/../../../kyverno-policies/cpulimits.yaml"))
}
