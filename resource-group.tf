resource "azurerm_resource_group" "boundary-rg" {
  name     = "${var.friendly_name_prefix}-${var.boundary_rg}"
  location = var.boundary_rg_location
}