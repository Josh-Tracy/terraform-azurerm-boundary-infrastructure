resource "azurerm_public_ip" "worker_public_ip" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-worker"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "boundary_worker_nic" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-worker"
  location            = azurerm_resource_group.boundary-rg.location
  resource_group_name = azurerm_resource_group.boundary-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.boundary-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.worker_public_ip[0].id
  }
}

#------------------------------------------------------------------------------
# Custom Data (cloud-init) arguments
#------------------------------------------------------------------------------
locals {
  custom_data_args = {
    hcp_boundary_cluster_id = var.hcp_boundary_cluster_id
    worker_public_address   = azurerm_public_ip.worker_public_ip[0].ip_address

  }
}

resource "azurerm_linux_virtual_machine" "boundary_worker" {
  count = var.deploy_self_managed_worker == true ? 1 : 0

  name                = "${var.friendly_name_prefix}-boundary-worker"
  resource_group_name = azurerm_resource_group.boundary-rg.name
  location            = azurerm_resource_group.boundary-rg.location
  size                = "Standard_D1_v2"
  admin_username      = var.ssh_target_username
  network_interface_ids = [
    azurerm_network_interface.boundary_worker_nic[0].id,
  ]
  custom_data = base64encode(templatefile("${path.module}/templates/worker_custom_data.sh.tpl", local.custom_data_args))

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