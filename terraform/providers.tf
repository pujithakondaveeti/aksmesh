terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm    = { source = "hashicorp/azurerm", version = "~>3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~>2.0" }
    helm       = { source = "hashicorp/helm", version = "~>2.0" }
  }
}


provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.kubeadminconfig[0].host
  client_certificate     = base64decode(module.aks.kubeadminconfig[0].client_certificate)
  client_key             = base64decode(module.aks.kubeadminconfig[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kubeadminconfig[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kubeadminconfig[0].host
    client_certificate     = base64decode(module.aks.kubeadminconfig[0].client_certificate)
    client_key             = base64decode(module.aks.kubeadminconfig[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.kubeadminconfig[0].cluster_ca_certificate)
  }
}
