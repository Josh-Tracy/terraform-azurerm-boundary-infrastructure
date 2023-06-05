resource "azurerm_network_security_group" "boundary-nsg" {
  name                = "${var.friendly_name_prefix}-boundary-nsg"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
}

resource "azurerm_network_security_group" "boundary_worker_nsg" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-boundary-worker-nsg"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
}

resource "azurerm_network_security_rule" "boundary_ssh" {
  resource_group_name         = azurerm_resource_group.boundary-rg.name
  network_security_group_name = azurerm_network_security_group.boundary-nsg.name
  name                        = "${var.friendly_name_prefix}-boundary-ingress-ssh"
  description                 = "Allow list for SSH inbound to boundary Servers."
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.boundary_ingress_cidr_allow
  destination_address_prefix  = var.boundary_subnet_cidr
}

resource "azurerm_network_security_rule" "boundary_worker_tcp_listen" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  resource_group_name         = azurerm_resource_group.boundary-rg.name
  network_security_group_name = azurerm_network_security_group.boundary_worker_nsg[0].name
  name                        = "${var.friendly_name_prefix}-boundary-worker-tcp-listen"
  description                 = "Allow incoming connections from Boundary control plan to workers."
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9202"
  source_address_prefixes     = ["0.0.0.0/0"]
  destination_address_prefix  = var.boundary_worker_subnet_cidr
}

resource "azurerm_network_security_rule" "boundary_worker_ssh" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  resource_group_name         = azurerm_resource_group.boundary-rg.name
  network_security_group_name = azurerm_network_security_group.boundary_worker_nsg[0].name
  name                        = "${var.friendly_name_prefix}-boundary-worker-ssh"
  description                 = "Allow incoming connections to ssh from specified IP."
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.boundary_ingress_cidr_allow
  destination_address_prefix  = var.boundary_worker_subnet_cidr
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association1" {
  subnet_id                 = azurerm_subnet.boundary-subnet.id
  network_security_group_id = azurerm_network_security_group.boundary-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association_worker" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  subnet_id                 = azurerm_subnet.boundary_worker_subnet[0].id
  network_security_group_id = azurerm_network_security_group.boundary_worker_nsg[0].id
}