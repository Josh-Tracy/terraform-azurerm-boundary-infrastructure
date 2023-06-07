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

output "azurerm_postgresql_flexible_server_fqdn" {
  value       = [azurerm_postgresql_flexible_server.boundary[0].fqdn]
  description = "FQDN of Azurerm PostgreSQL Flexible server."
}


output "azurerm_postgresql_flexible_server_database_name" {
  value       = azurerm_postgresql_flexible_server_database.boundary[0].name
  description = "Name of Azurerm PostgreSQL Flexible database to connect to."
}