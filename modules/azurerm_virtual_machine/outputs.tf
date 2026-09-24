output "vm_ips" {
  value = {
    for k, v in azurerm_linux_virtual_machine.vms :
    k => try(data.azurerm_public_ip.pips[k].ip_address, azurerm_network_interface.nics[k].private_ip_address)
  }
}