# Install Hierarchical Namespace Controller (HNC)
resource "helm_release" "hnc" {
  name       = "hnc"
  repository = "https://kubernetes-sigs.github.io/hierarchical-namespaces"
  chart      = "hnc"
  version    = "1.1.0"
  namespace  = "hnc-system"

  create_namespace = true

  values = [
    file("${path.module}/../../../k8s-manifests/hierarchical-namespaces/helm-values/hnc-values.yaml")
  ]

  depends_on = []
}

# Create parent namespace: ss-automative-nds
resource "kubernetes_namespace" "ss_automative_nds" {
  metadata {
    name = "ss-automative-nds"
    labels = {
      environment = "production"
      team        = "automative"
    }
  }

  depends_on = [helm_release.hnc]
}

# Create parent namespace: ss-integrations-nds
resource "kubernetes_namespace" "ss_integrations_nds" {
  metadata {
    name = "ss-integrations-nds"
    labels = {
      environment = "production"
      team        = "integrations"
    }
  }

  depends_on = [helm_release.hnc]
}

# Create SubnamespaceAnchor for application1-nds under ss-automative-nds
resource "kubernetes_manifest" "application1_nds" {
  manifest = {
    apiVersion = "hnc.x-k8s.io/v1alpha2"
    kind       = "SubnamespaceAnchor"
    metadata = {
      name      = "application1-nds"
      namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    }
  }

  depends_on = [kubernetes_namespace.ss_automative_nds]
}

# Create SubnamespaceAnchor for application2-nds under ss-automative-nds
resource "kubernetes_manifest" "application2_nds" {
  manifest = {
    apiVersion = "hnc.x-k8s.io/v1alpha2"
    kind       = "SubnamespaceAnchor"
    metadata = {
      name      = "application2-nds"
      namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    }
  }

  depends_on = [kubernetes_namespace.ss_automative_nds]
}

# Create SubnamespaceAnchor for integration1-nds under ss-integrations-nds
resource "kubernetes_manifest" "integration1_nds" {
  manifest = {
    apiVersion = "hnc.x-k8s.io/v1alpha2"
    kind       = "SubnamespaceAnchor"
    metadata = {
      name      = "integration1-nds"
      namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    }
  }

  depends_on = [kubernetes_namespace.ss_integrations_nds]
}

# Create SubnamespaceAnchor for integration2-nds under ss-integrations-nds
resource "kubernetes_manifest" "integration2_nds" {
  manifest = {
    apiVersion = "hnc.x-k8s.io/v1alpha2"
    kind       = "SubnamespaceAnchor"
    metadata = {
      name      = "integration2-nds"
      namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    }
  }

  depends_on = [kubernetes_namespace.ss_integrations_nds]
}
