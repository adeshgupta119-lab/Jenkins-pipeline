variable "virtual_machines" {
  description = "Map of virtual machines to create, one NIC + one VM per entry"
  type = map(object({
    vm_name              = string
    nic_name             = string
    location             = string
    resource_group_name  = string
    virtual_network_name = string
    subnet_name          = string
    public_ip_name       = optional(string)
    vm_size              = string
    admin_username       = string
    tags                 = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for vm in var.virtual_machines : contains(
        ["Standard_F1alds_v7", "Standard_F2alds_v7", "Standard_F4alds_v7"],
        vm.vm_size
      )
    ])
    error_message = "vm_size must be a free-tier eligible size: Standard_F1alds_v7, Standard_F2alds_v7, or Standard_F4alds_v7."
  }
}

variable "key_vault_name" {
  type        = string
  description = "Name of the key vault holding the VM admin password"
}

variable "key_vault_secret_name" {
  type        = string
  description = "Name of the secret in the key vault holding the VM SSH public key"
  default     = "vm-ssh-public-key"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the key vault lives"
}
