variable "public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
  }))
}
