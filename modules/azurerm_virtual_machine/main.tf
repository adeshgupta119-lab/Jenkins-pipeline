resource "azurerm_network_interface" "nics" {
  for_each = var.virtual_machines

  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(data.azurerm_public_ip.pips[each.key].id, null)
  }

  depends_on = [
    data.azurerm_subnet.subnets,
    data.azurerm_public_ip.pips
  ]
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each = var.virtual_machines

  name                = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.vm_size
  admin_username      = each.value.admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = data.azurerm_key_vault_secret.vm_ssh_key.value
  }

  network_interface_ids = [
    azurerm_network_interface.nics[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
     publisher = "Canonical"
     offer     = "ubuntu-22_04-lts"
     sku       = "server"
   version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = each.value.tags

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    azurerm_network_interface.nics
  ]
}
