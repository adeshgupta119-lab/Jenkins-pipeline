variable "subnets" {
  description = "Map of NSGs to create, one per subnet, with the subnet to associate to"
  type = map(object({
    nsg_name             = string
    location             = string
    resource_group_name  = string
    subnet_id            = string
    allowed_ssh_source   = string
  }))
}
