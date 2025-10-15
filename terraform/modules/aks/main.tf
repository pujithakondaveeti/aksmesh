resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.cluster_name


  default_node_pool {
    name            = "pool1"
    vm_size         = var.node_vm_size
    node_count      = var.node_count
    vnet_subnet_id  = var.subnet_id
    zones           = ["1", "2", "3"]
    os_disk_size_gb = 100
    max_pods        = 110
  }

  network_profile {
    network_plugin    = "azure" # Azure CNI
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  role_based_access_control_enabled = true

  identity {
    type = "SystemAssigned"
  }


  linux_profile {
    admin_username = "azureuser"
    ssh_key { key_data = file(var.ssh_pub_key_path) }
  }
  #Enable AGIC Add On
  ingress_application_gateway {
    gateway_id = var.app_gateway_id
  }
  // Enable Azure Service Mesh (Istio)
  service_mesh_profile {
    mode                             = "Istio"
    external_ingress_gateway_enabled = true
  }
  depends_on = [var.subnet_id]
  tags       = var.tags
  lifecycle {
    ignore_changes = [default_node_pool]
  }
}

########################
# AGIC Permissions
########################

data "azurerm_user_assigned_identity" "pod_identity_appgw" {
  name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name = "MC_${data.azurerm_resource_group.rg.name}_${azurerm_kubernetes_cluster.aks.name}_${var.location}"
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_role_assignment" "identity_appgw_contributor_ra" {
  scope                = var.app_gateway_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.pod_identity_appgw.principal_id
  lifecycle {
    ignore_changes = [
      skip_service_principal_aad_check,
    ]
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks,
  ]
}

resource "azurerm_role_assignment" "identity_appgw_reader_ra" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.pod_identity_appgw.principal_id
  lifecycle {
    ignore_changes = [
      skip_service_principal_aad_check
    ]
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    data.azurerm_resource_group.rg
  ]
}

resource "azurerm_role_assignment" "identity_appgw_network_contributor_ra" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.pod_identity_appgw.principal_id
  lifecycle {
    ignore_changes = [
      skip_service_principal_aad_check,
    ]
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks,
  ]
}
