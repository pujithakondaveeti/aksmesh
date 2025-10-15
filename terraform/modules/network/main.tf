# resource "azurerm_route_table" "local" {
#   name                = "default-route-table"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   route {
#     name           = "vnet"
#     address_prefix = "10.1.0.0/16"
#     next_hop_type  = "VnetLocal"
#   }

#   route {
#     name           = "default"
#     address_prefix = "0.0.0.0/0"
#     next_hop_type  = "VirtualNetworkGateway"
#   }

#   tags = {
#     environment = "Demo"
#   }
# }

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


resource "azurerm_virtual_network" "vnet" {
  name                = "${var.rg_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_prefix]

  # delegation {
  #   name = "aks-delegation"
  #   service_delegation {
  #     name    = "Microsoft.ContainerService/managedClusters"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }
}

# resource "azurerm_subnet_route_table_association" "aks" {
#   subnet_id      = azurerm_subnet.aks_subnet.id
#   route_table_id = azurerm_route_table.local.id
# }

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

