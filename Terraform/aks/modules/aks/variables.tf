variable "location" {}
variable "resource_group" {}
variable "cluster_name" {}
variable "vnet_id" {}
variable "aks_subnet_id" {}
variable "acr_id" {}
variable "system_node_vm_size" {
  default = "Standard_B2s"
}
variable "user_node_vm_size" {
  default = "Standard_D2s_v3"
}
variable "kubernetes_version" {
  default = "1.30"
}
