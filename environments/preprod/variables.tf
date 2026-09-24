variable "project" {
  type        = string
  description = "Short project code, used as a naming prefix (e.g. axion)"
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "preprod", "prod"], var.environment)
    error_message = "environment must be one of: dev, preprod, prod."
  }
}

variable "region_code" {
  type        = string
  description = "Short region code used in naming (e.g. cin for Central India)"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

variable "subnet_prefixes" {
  type = object({
    frontend = list(string)
    backend  = list(string)
    database = list(string)
  })
  description = "Address prefixes for the frontend, backend and database subnets"
}

variable "allowed_ssh_source" {
  type        = string
  description = "CIDR allowed to SSH into the VMs (e.g. your admin IP, x.x.x.x/32)"
}

variable "vm_size" {
  type        = string
  description = "VM size, must be free-tier eligible"
  default     = "Standard_F1alds_v7"

  validation {
    condition     = contains(["Standard_F1alds_v7", "Standard_F2alds_v7", "Standard_F4alds_v7"], var.vm_size)
    error_message = "vm_size must be one of: Standard_F1alds_v7, Standard_F2alds_v7, Standard_F4alds_v7 (free-tier eligible)."
  }
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VMs"
  default     = "azureadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key (contents of your .pub file) used to log in to all VMs"
}
