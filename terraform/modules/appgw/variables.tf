variable "prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "appgw_subnet_id" {}
variable "subscription_id" {}
variable "dns_zone_name" {}
variable "dns_resource_group" {}
variable "tags" {
  type    = map(string)
  default = {}
}
