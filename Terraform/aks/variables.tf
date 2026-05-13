variable "azure_subscription_id" {
  type = string
}
variable "azure_client_id" {
  type = string
}
variable "azure_client_secret" {
  type = string
}
variable "azure_tenant_id" {
  type = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "webapp"
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}
