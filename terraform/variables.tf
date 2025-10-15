variable "location" { default = "australiaeast" }
variable "rg_name" { default = "aks-mesh-rg" }
variable "cluster_name" { default = "aks-mesh" }
variable "ssh_pub_key_path" { default = "~/.ssh/id_rsa.pub" }
variable "vnet_address_space" { default = ["10.1.0.0/16"] }
variable "aks_subnet_prefix" { default = "10.1.4.0/22" }
variable "appgw_subnet_prefix" { default = "10.1.8.0/22" }
variable "node_vm_size" { default = "Standard_D4s_v3" }
variable "node_count" { default = 3 }
variable "prefix" { default = "demo" }
variable "appgw_subnet_id" { default = "default" }
variable "dns_zone_name" { default = "mesh.oak-it.com.au" }
variable "dns_resource_group" { default = "aks-mesh-rg" }
variable "tags" {
  type = map(string)
  default = {
    CostCentre     = "Demo"
    Environment    = "Dev"
    SupportContact = "admin@demo.com"
  }
}
