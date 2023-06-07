output "ssh_target_public_ip_addr" {
  value = azurerm_linux_virtual_machine.boundary-servers[0].public_ip_address
}

output "ssh_target_private_ip_addr" {
  value = azurerm_linux_virtual_machine.boundary-servers[0].private_ip_address
}

output "worker_public_ip_addr" {
  value = azurerm_linux_virtual_machine.boundary_worker[0].public_ip_address
}

output "worker_private_ip_addr" {
  value = azurerm_linux_virtual_machine.boundary_worker[0].private_ip_address
}

output "rdp_target_public_ip_addr" {
  value = azurerm_windows_virtual_machine.rdp_boundary_servers[0].public_ip_address
}

output "rdp_target_private_ip_addr" {
  value = azurerm_windows_virtual_machine.rdp_boundary_servers[0].private_ip_address
}