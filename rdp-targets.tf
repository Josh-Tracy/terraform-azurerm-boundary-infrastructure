resource "azurerm_public_ip" "rdp_public_ip" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-rdp-target"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "rdp_boundary_nic" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-rdp-target"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.boundary-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rdp_public_ip[0].id
  }
}

resource "azurerm_windows_virtual_machine" "rdp_boundary_servers" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-rdp"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
  size                = "Standard_F2"
  admin_username      = var.rdp_target_username
  admin_password      = var.rdp_target_password
  network_interface_ids = [
    azurerm_network_interface.rdp_boundary_nic[0].id,
  ]
  custom_data = base64encode(templatefile("${path.module}/templates/rdp_custom_data.ps1.tpl", local.custom_data_args))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

}

resource "boundary_credential_store_static" "rdp" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-rdp"
  description = "RDP credentials store"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_credential_username_password" "rdp" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-rdp-userpass"
  description         = "Username Password for RDP Windows VM"
  credential_store_id = boundary_credential_store_static.rdp[0].id
  username            = var.rdp_target_username
  password            = var.rdp_target_password
}

resource "boundary_host_catalog_static" "rdp-targets" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-rdp-targets"
  description = "Azure VMs that are RDP targets"
  scope_id    = var.boundary_scope_project_id
}

resource "boundary_host_static" "rdp" {
  count = var.deploy_rdp_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-rdp-windows-vm"
  host_catalog_id = boundary_host_catalog_static.rdp-targets[0].id
  address         = azurerm_public_ip.rdp_public_ip[0].ip_address
}

resource "boundary_host_set_static" "rdp" {
  count = var.deploy_rdp_target == true ? 1 : 0

  type            = "static"
  name            = "${var.friendly_name_prefix}-rdp-windows-vms"
  host_catalog_id = boundary_host_catalog_static.rdp-targets[0].id

  host_ids = [
    boundary_host_static.rdp[0].id,
  ]
}

resource "boundary_target" "rdp" {
  count = var.deploy_rdp_target == true ? 1 : 0

  name                  = "${var.friendly_name_prefix}-rdp-windows-vms"
  description           = "RDP target"
  type                  = "tcp"
  default_port          = "3389"
  scope_id              = var.boundary_scope_project_id
  ingress_worker_filter = var.deploy_self_managed_worker == true ? "\"azure-worker\" in \"/tags/type\"" : null
  egress_worker_filter  = var.deploy_self_managed_worker == true ? "\"azure-worker\" in \"/tags/type\"" : null
  host_source_ids = [
    boundary_host_set_static.rdp[0].id
  ]
  brokered_credential_source_ids = [
    boundary_credential_username_password.rdp[0].id
  ]
}