resource "azurerm_public_ip" "public_ip" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-ssh-target"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "boundary-nic" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-ssh-target"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.boundary-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[0].id
  }
}

resource "azurerm_linux_virtual_machine" "boundary-servers" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-ssh-target"
  resource_group_name = azurerm_resource_group.boundary-rg.name
  location            = azurerm_resource_group.boundary-rg.location
  size                = "Standard_D1_v2"
  admin_username      = var.ssh_target_username
  network_interface_ids = [
    azurerm_network_interface.boundary-nic[0].id,
  ]

  admin_ssh_key {
    username   = var.ssh_target_username
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts"
    version   = "latest"
  }
}

resource "boundary_credential_store_static" "ssh-keys" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-ssh-keys"
  description = "SSh key credentials store"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_credential_ssh_private_key" "ssh-linux-vm" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-ssh-linux-vm-key"
  description         = "ssh key to the linux vm"
  credential_store_id = boundary_credential_store_static.ssh-keys[0].id
  username            = var.ssh_target_username
  private_key         = file(var.ssh_private_key)
}

resource "boundary_host_catalog_static" "ssh-targets" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-ssh-targets"
  description = "Azure VMs that are SSH targets"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_host_static" "ssh" {
  count = var.deploy_ssh_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-ssh-linux-vm"
  host_catalog_id = boundary_host_catalog_static.ssh-targets[0].id
  address         = azurerm_public_ip.public_ip[0].ip_address
}

resource "boundary_host_set_static" "ssh" {
  count = var.deploy_ssh_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-ssh-linux-vms"
  host_catalog_id = boundary_host_catalog_static.ssh-targets[0].id

  host_ids = [
    boundary_host_static.ssh[0].id,
  ]
}

resource "boundary_target" "ssh" {
  count = var.deploy_ssh_target == true ? 1 : 0

  name         = "${var.friendly_name_prefix}-ssh-linux-vms"
  description  = "Ssh target"
  type         = "ssh"
  default_port = "22"
  scope_id     = var.boundary_scope_project_id
  ingress_worker_filter = "\"azure-worker\" in \"/tags/type\""
  egress_worker_filter = "\"azure-worker\" in \"/tags/type\""
  host_source_ids = [
    boundary_host_set_static.ssh[0].id
  ]
  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.ssh-linux-vm[0].id
  ]
}
