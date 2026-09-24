data "azurerm_subnet" "subnets" {
  for_each = var.virtual_machines

  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "pips" {
  for_each = { for k, v in var.virtual_machines : k => v if v.public_ip_name != null }

  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "vm_ssh_key" {
  name         = var.key_vault_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}
