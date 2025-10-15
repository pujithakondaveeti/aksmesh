variable "rg_name" {}
variable "location" {}
variable "cluster_name" {}
variable "ssh_pub_key_path" {}
variable "subnet_id" {}
variable "node_vm_size" {}
variable "node_count" {}
variable "app_gateway_id" {
  type = string
}
variable "tags" {
  default = {}
}
