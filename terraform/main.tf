module "network" {
  source              = "./modules/network"
  rg_name             = var.rg_name
  location            = var.location
  vnet_address_space  = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
  appgw_subnet_prefix = var.appgw_subnet_prefix
}

module "appgw" {
  source = "./modules/appgw"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = module.network.main_rg
  appgw_subnet_id     = module.network.appgw_subnet_id
  subscription_id     = data.azurerm_client_config.current.subscription_id
  dns_zone_name      = var.dns_zone_name
  dns_resource_group = var.rg_name
  tags               = var.tags
}


module "aks" {
  source           = "./modules/aks"
  rg_name          = var.rg_name
  location         = var.location
  cluster_name     = var.cluster_name
  ssh_pub_key_path = var.ssh_pub_key_path
  subnet_id        = module.network.aks_subnet_id
  node_vm_size     = var.node_vm_size
  node_count       = var.node_count
  app_gateway_id   = module.appgw.gateway_id
  depends_on       = [module.network, module.appgw]
}

module "monitoring" {
  source     = "./modules/monitoring"
  kubeconfig = module.aks.kubeconfig
  depends_on = [module.aks]
}
