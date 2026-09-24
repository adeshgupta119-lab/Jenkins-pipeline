variable "vnets" {
  description = "Map of virtual networks to create"
  type = map(object({
    name                = string
    address_space       = list(string)
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  }))
}
