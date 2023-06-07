variable "friendly_name_prefix" {
  type        = string
  description = "A prefix appended to the name of azure resources."

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.friendly_name_prefix)) && length(var.friendly_name_prefix) < 13
    error_message = "Must only contain alphanumeric characters and be less than 13 characters."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "boundary_rg" {
  type        = string
  description = "The Boundary resource group name."
  default     = "boundary-rg"
}

variable "boundary_rg_location" {
  type        = string
  description = "The location of the Boundary resource group."
  default     = "East US"
}
#-------------------------------------------------------------------------
# Boundary Provider Settings
#-------------------------------------------------------------------------
variable "boundary_addr" {
  type        = string
  description = "The Boundary address to authenticate against."
}

variable "boundary_auth_method_id" {
  type        = string
  description = "The Boundary auth method ID."
}

variable "boundary_password_auth_method_login_name" {
  type        = string
  description = "The Boundary password auth method username."
}

variable "boundary_password_auth_method_password" {
  type        = string
  description = "The Boundary password auth method password."
}

#-------------------------------------------------------------------------
# Self-managed Worker
#-------------------------------------------------------------------------
variable "deploy_self_managed_worker" {
  type        = bool
  description = "True of False. Deploy a self-managed Boundary worker."
  default     = true
}

variable "hcp_boundary_cluster_id" {
  type        = string
  description = "The HCP cluster ID to connect to."
}

variable "boundary_worker_version" {
  type        = string
  description = "The boundary-worker version to download to the self-managed-worker."
  default     = "0.12.3+hcp-1"
}

#-------------------------------------------------------------------------
# SSH Targets
#-------------------------------------------------------------------------

variable "deploy_ssh_target" {
  type        = bool
  description = "True or False. Deploy an SSH target Azure Linux VM."
}

variable "boundary_scope_project_id" {
  type        = string
  description = "The project scope ID to create a static host catalog inside of for SSH targets."
}

variable "ssh_target_username" {
  type        = string
  description = "The username of the admin user that will be created on the VM. Will also be set to the SSH username."
  default     = "boundaryadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "The name of the ssh public key that will be put on the SSH targett VMs. Must be placed relative to the working directory."
}

variable "ssh_private_key" {
  type        = string
  description = "The name of the ssh private key that will be uploaded to boundary credential store. Must be placed relative to the working directory."
}

variable "deploy_database_target" {
  type        = bool
  description = "True or False. Deploy an Azure PostgreSQL Flexible server."
}

#-------------------------------------------------------------------------
# RDP Targets
#-------------------------------------------------------------------------
variable "deploy_rdp_target" {
  type        = bool
  description = "True or False. Deploy an RDP Azure Windows VM."
}

variable "rdp_target_username" {
  type        = string
  description = "The username of the admin user that will be created on the VM. Will also be used to RDP."
  default     = "boundaryadmin"
}

variable "rdp_target_password" {
  type        = string
  description = "The password of the `rdp_target_username` user that will be created on the VM. Will also be used to RDP."
  default     = "B0uNdairyP@ss"
}
#-------------------------------------------------------------------------
# Storage Account
#-------------------------------------------------------------------------
variable "sa_ingress_cidr_allow" {
  type        = list(string)
  description = "List of CIDRs allowed to interact with Azure Blob Storage Account."
  default     = []
}

#-------------------------------------------------------------------------
# VNet
#-------------------------------------------------------------------------
variable "vnet_cidr" {
  type        = list(string)
  description = "CIDR block address space for VNet."
  default     = ["10.0.0.0/16"]
}

variable "boundary_subnet_cidr" {
  type        = string
  description = "CIDR block for boundary subnet1."
  default     = "10.0.1.0/24"
}

variable "boundary_worker_subnet_cidr" {
  type        = string
  description = "CIDR block for boundary worker subnet."
  default     = "10.0.2.0/24"
}

variable "create_nat_gateway" {
  type        = bool
  description = "Boolean to create a NAT Gateway. Useful when Azure Load Balancer is internal but VM(s) require outbound Internet access."
  default     = false
}

variable "boundary_ingress_cidr_allow" {
  type        = list(string)
  description = "List of CIDRs allowed inbound to boundary related servers via SSH (port 22) on vnet."
  default     = []
}