module "boundary" {
  source = "../.."

  friendly_name_prefix = "dev"
  boundary_rg          = "boundary"
  boundary_rg_location = "East US"
  common_tags = {
    "App"         = "Boundary"
    "Owner"       = "admin@company.com"
    "Terraform"   = "cli"
    "Environment" = "dev"
  }

  boundary_addr                            = "https://11112223333444455566666.boundary.hashicorp.cloud"
  boundary_auth_method_id                  = "ampw_Qs04BHhECs"
  boundary_password_auth_method_login_name = "username"
  boundary_password_auth_method_password   = "password"

  boundary_ingress_cidr_allow = ["1.2.3.4/32"]

  vnet_cidr            = ["10.0.0.0/16"]
  boundary_subnet_cidr = "10.0.1.0/24"

  boundary_scope_project_id = "p_3r567k7fG53"

  deploy_self_managed_worker  = true
  boundary_worker_version     = "0.12.3+hcp-1"
  boundary_worker_subnet_cidr = "10.0.2.0/24"
  hcp_boundary_cluster_id     = "11112223333444455566666"

  deploy_ssh_target   = true
  ssh_target_username = "boundaryadmin"
  ssh_public_key      = "boundary.pub"
  ssh_private_key     = "boundary"

  deploy_rdp_target   = true
  rdp_target_username = "boundaryadmin"
  rdp_target_password = "B0uNdairyP@ss"

  deploy_database_target   = true
  database_subnet_cidr     = "10.0.3.0/24"
  database_target_username = "boundaryadmin"
  database_target_password = "B0uNdairyP@ss"
}