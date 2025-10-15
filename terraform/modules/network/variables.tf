variable "rg_name" {}
variable "location" {}
variable "vnet_address_space" { type = list(string) }
variable "aks_subnet_prefix" {}
variable "appgw_subnet_prefix" {}
