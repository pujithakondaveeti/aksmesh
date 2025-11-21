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
}

##############################################
# RBAC: Roles and RoleBindings (propagated)
##############################################

# Admin Role for ss-automative-nds (propagates to children)
resource "kubernetes_role" "automative_admin" {
  metadata {
    name      = "namespace-admin"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

# Developer Role for ss-automative-nds (propagates to children)
resource "kubernetes_role" "automative_developer" {
  metadata {
    name      = "namespace-developer"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "deployments", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
}

# Admin RoleBinding for ss-automative-nds (propagates to children)
resource "kubernetes_role_binding" "automative_admin_binding" {
  metadata {
    name      = "admin-binding"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.automative_admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "automative-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Developer RoleBinding for ss-automative-nds (propagates to children)
resource "kubernetes_role_binding" "automative_developer_binding" {
  metadata {
    name      = "developer-binding"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.automative_developer.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "automative-developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Admin Role for ss-integrations-nds (propagates to children)
resource "kubernetes_role" "integrations_admin" {
  metadata {
    name      = "namespace-admin"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

# Developer Role for ss-integrations-nds (propagates to children)
resource "kubernetes_role" "integrations_developer" {
  metadata {
    name      = "namespace-developer"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "deployments", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
}

# Admin RoleBinding for ss-integrations-nds (propagates to children)
resource "kubernetes_role_binding" "integrations_admin_binding" {
  metadata {
    name      = "admin-binding"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.integrations_admin.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "integrations-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Developer RoleBinding for ss-integrations-nds (propagates to children)
resource "kubernetes_role_binding" "integrations_developer_binding" {
  metadata {
    name      = "developer-binding"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.integrations_developer.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "integrations-developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

##############################################
# Resource Quotas (propagated)
##############################################

# Compute Quota for ss-automative-nds (propagates to children)
resource "kubernetes_resource_quota" "automative_compute_quota" {
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    hard = {
      "requests.cpu"           = "10"
      "requests.memory"        = "20Gi"
      "limits.cpu"             = "20"
      "limits.memory"          = "40Gi"
      "persistentvolumeclaims" = "10"
      "requests.storage"       = "100Gi"
    }
  }
}

# Object Count Quota for ss-automative-nds (propagates to children)
resource "kubernetes_resource_quota" "automative_object_quota" {
  metadata {
    name      = "object-quota"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    hard = {
      "pods"                   = "50"
      "services"               = "20"
      "configmaps"             = "20"
      "secrets"                = "20"
      "persistentvolumeclaims" = "10"
    }
  }
}

# LimitRange for ss-automative-nds (propagates to children)
resource "kubernetes_limit_range" "automative_limits" {
  metadata {
    name      = "resource-limits"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    limit {
      type = "Container"
      max = {
        cpu    = "2"
        memory = "4Gi"
      }
      min = {
        cpu    = "100m"
        memory = "128Mi"
      }
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "200m"
        memory = "256Mi"
      }
    }

    limit {
      type = "Pod"
      max = {
        cpu    = "4"
        memory = "8Gi"
      }
      min = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}

# Compute Quota for ss-integrations-nds (propagates to children)
resource "kubernetes_resource_quota" "integrations_compute_quota" {
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    hard = {
      "requests.cpu"           = "8"
      "requests.memory"        = "16Gi"
      "limits.cpu"             = "16"
      "limits.memory"          = "32Gi"
      "persistentvolumeclaims" = "8"
      "requests.storage"       = "80Gi"
    }
  }
}

# Object Count Quota for ss-integrations-nds (propagates to children)
resource "kubernetes_resource_quota" "integrations_object_quota" {
  metadata {
    name      = "object-quota"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    hard = {
      "pods"                   = "40"
      "services"               = "15"
      "configmaps"             = "15"
      "secrets"                = "15"
      "persistentvolumeclaims" = "8"
    }
  }
}

# LimitRange for ss-integrations-nds (propagates to children)
resource "kubernetes_limit_range" "integrations_limits" {
  metadata {
    name      = "resource-limits"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    limit {
      type = "Container"
      max = {
        cpu    = "2"
        memory = "4Gi"
      }
      min = {
        cpu    = "100m"
        memory = "128Mi"
      }
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "200m"
        memory = "256Mi"
      }
    }

    limit {
      type = "Pod"
      max = {
        cpu    = "4"
        memory = "8Gi"
      }
      min = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}

##############################################
# Network Policies (propagated)
##############################################

# Default Deny Ingress for ss-automative-nds (propagates to children)
resource "kubernetes_network_policy" "automative_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# Allow Same Namespace for ss-automative-nds (propagates to children)
resource "kubernetes_network_policy" "automative_allow_same_ns" {
  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {}
      }
    }
  }
}

# Allow Istio Ingress for ss-automative-nds (propagates to children)
resource "kubernetes_network_policy" "automative_allow_istio" {
  metadata {
    name      = "allow-istio-ingress"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "aks-istio-ingress"
          }
        }
      }
    }
  }
}

# Allow Monitoring for ss-automative-nds (propagates to children)
resource "kubernetes_network_policy" "automative_allow_monitoring" {
  metadata {
    name      = "allow-monitoring"
    namespace = kubernetes_namespace.ss_automative_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "8080"
      }
      ports {
        protocol = "TCP"
        port     = "9090"
      }
    }
  }
}

# Default Deny Ingress for ss-integrations-nds (propagates to children)
resource "kubernetes_network_policy" "integrations_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# Allow Same Namespace for ss-integrations-nds (propagates to children)
resource "kubernetes_network_policy" "integrations_allow_same_ns" {
  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {}
      }
    }
  }
}

# Allow Istio Ingress for ss-integrations-nds (propagates to children)
resource "kubernetes_network_policy" "integrations_allow_istio" {
  metadata {
    name      = "allow-istio-ingress"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "aks-istio-ingress"
          }
        }
      }
    }
  }
}

# Allow Monitoring for ss-integrations-nds (propagates to children)
resource "kubernetes_network_policy" "integrations_allow_monitoring" {
  metadata {
    name      = "allow-monitoring"
    namespace = kubernetes_namespace.ss_integrations_nds.metadata[0].name
    labels = {
      "propagate.hnc.x-k8s.io/treeSelect" = "true"
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "8080"
      }
      ports {
        protocol = "TCP"
        port     = "9090"
      }
    }
  }
}
