resource "azurerm_virtual_network" "boundary-vnet" {
  name                = "${var.friendly_name_prefix}-vnet"
  address_space       = var.vnet_cidr
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
}

resource "azurerm_subnet" "boundary-subnet" {
  name                 = "${var.friendly_name_prefix}-subnet1"
  address_prefixes     = [var.boundary_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.boundary-vnet.name
  resource_group_name  = azurerm_resource_group.boundary-rg.name
  service_endpoints = [
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_subnet" "boundary_worker_subnet" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  name                 = "${var.friendly_name_prefix}-workers"
  address_prefixes     = [var.boundary_worker_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.boundary-vnet.name
  resource_group_name  = azurerm_resource_group.boundary-rg.name
  service_endpoints = [
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                    = "${var.friendly_name_prefix}-natgw"
  location                = azurerm_resource_group.boundary-rg.location
  resource_group_name     = azurerm_resource_group.boundary-rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_route_table" "route_table" {
  name                = "${var.friendly_name_prefix}-natgw-rt"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name

  route {
    name           = "DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "subnet_rt_association1" {
  subnet_id      = azurerm_subnet.boundary-subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

resource "azurerm_subnet_route_table_association" "subnet_rt_association_worker" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  subnet_id      = azurerm_subnet.boundary_worker_subnet[0].id
  route_table_id = azurerm_route_table.route_table.id
}