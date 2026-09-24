variable "storage_account_name" {
  type        = string
  description = "Globally unique storage account name, lowercase, no hyphens"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to create the storage account"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
