variable "key_vault_name" {
  type        = string
  description = "Globally unique key vault name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secret name => secret value to store in the vault"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
