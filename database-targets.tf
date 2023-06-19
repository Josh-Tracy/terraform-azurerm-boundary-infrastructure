resource "azurerm_private_dns_zone" "postgres" {
  count = var.deploy_database_target == true ? 1 : 0

  resource_group_name = azurerm_resource_group.boundary-rg.name
  name                = "${var.friendly_name_prefix}-boundary.postgres.database.azure.com"
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = var.deploy_database_target == true ? 1 : 0

  resource_group_name   = azurerm_resource_group.boundary-rg.name
  name                  = "${var.friendly_name_prefix}-boundary-postgres-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.boundary-vnet.id
}

resource "azurerm_postgresql_flexible_server" "boundary" {
  count = var.deploy_database_target == true ? 1 : 0

  resource_group_name          = azurerm_resource_group.boundary-rg.name
  location                     = azurerm_resource_group.boundary-rg.location
  name                         = "${var.friendly_name_prefix}-boundry-postgres-db"
  version                      = 14
  sku_name                     = "GP_Standard_D2ds_v4"
  storage_mb                   = "65536"
  delegated_subnet_id          = azurerm_subnet.database_subnet[0].id
  private_dns_zone_id          = azurerm_private_dns_zone.postgres[0].id
  zone                         = 1
  administrator_login          = var.database_target_username
  administrator_password       = var.database_target_password
  backup_retention_days        = 35
  geo_redundant_backup_enabled = false
  create_mode                  = "Default"

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]
}

resource "azurerm_postgresql_flexible_server_database" "boundary" {
  count = var.deploy_database_target == true ? 1 : 0

  name      = "${var.friendly_name_prefix}-boundary"
  server_id = azurerm_postgresql_flexible_server.boundary[0].id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "boundary_credential_store_static" "database" {
  count = var.deploy_database_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-database"
  description = "Database credentials store"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_credential_username_password" "database" {
  count = var.deploy_database_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-db-userpass"
  description         = "Username Password for PostgreSQL server"
  credential_store_id = boundary_credential_store_static.database[0].id
  username            = var.database_target_username
  password            = var.database_target_password
}

resource "boundary_host_catalog_static" "database-targets" {
  count = var.deploy_database_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-database-targets"
  description = "Database targets"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_host_static" "database" {
  count = var.deploy_database_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-postgresql-flex"
  host_catalog_id = boundary_host_catalog_static.database-targets[0].id
  address         = azurerm_postgresql_flexible_server.boundary[0].fqdn
}

resource "boundary_host_set_static" "database" {
  count = var.deploy_database_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-databases"
  host_catalog_id = boundary_host_catalog_static.database-targets[0].id

  host_ids = [
    boundary_host_static.database[0].id,
  ]
}

resource "boundary_target" "database" {
  count = var.deploy_database_target == true ? 1 : 0

  name                  = "${var.friendly_name_prefix}-postgresql-db"
  description           = "PostgreSQL flex server database target"
  type                  = "tcp"
  default_port          = "5432"
  scope_id              = var.boundary_scope_project_id
  ingress_worker_filter = var.deploy_self_managed_worker == true ? "\"azure-worker\" in \"/tags/type\"" : null
  egress_worker_filter  = var.deploy_self_managed_worker == true ? "\"azure-worker\" in \"/tags/type\"" : null
  host_source_ids = [
    boundary_host_set_static.database[0].id
  ]
  brokered_credential_source_ids = [
    boundary_credential_username_password.database[0].id
  ]
}