# terraform-azurerm-boundary-infrastructure
Deploys infrastructure for testing HashiCorp Boundary targets and self-managed workers with HCP Boundary.

## What this Repo Does and When to Use it
This repo is designed to quickly create a self-managed worker in Azure, along with 3 different target types if you choose - SSH, RDP, and PostgreSQL Database, and register them in your HCP Boundary. Use it when you need to quickly test / demo these connections in Azure.

## Prerequisites
You need the following in order to use this repo:
- An existing HCP Boundary cluster
- An Organization and a Project inside of that organization
- An Azure subscription with the ability to create VNETS, VMs, and PostgreSQL Flexible servers.

## How to Use

### 1) Configure Boundary Provider Credentials
Configure the Boundary provider credentials as environment variables on your system or in your Terraform Cloud Workspace. Password auth is used in this example for easy testing. 

```
provider "boundary" {
  addr                            = var.boundary_addr
  auth_method_id                  = var.boundary_auth_method_id
  password_auth_method_login_name = var.boundary_password_auth_method_login_name          
  password_auth_method_password   = var.boundary_password_auth_method_password       
}
```

### 2) Specify Which Targets to Create and Register to Boundary
The following variables can be defined to deploy different targets for testing:

#### Deploy SSH Target
The `deploy_ssh_target` variable is a `bool` variable. Setting to true creates an Azure Linux Ubuntu VM with SSH configured and registers it to the `boundary_scope_project_id` you define. You can initiate a connection via the Boundary desktop app and then use `ssh 127.0.0.1 -p<PORT#>` to connect to the SSH target, or use the `boundary connect ssh -target-id tssh_Bnj6y7sVG5` command.

This will create:
- A Linux VM that is put into a seperate subnet from the worker and allows traffic from `boundary_ingress_cidr_allow` on port 22 as a break glass solution, but only allows port 22 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

#### Deploy RDP Target
The `deploy_rdp_target` variable is a `bool` variable. Setting to true creates a Windows VM with RDP configured and registers it to the `boundary_scope_project_id` you define. You can then initiate a sessions via the Boundary desktop app and use your RDP software of choice to connect, or run `boundary connect rdp -target-id ttcp_QqwiESZwHj` and if you have an RDP program installed, boundary will automatically launch that.

This will create:
- A Windows Server VM that is put into a seperate subnet from the worker and allows traffic from `boundary_ingress_cidr_allow` on port 22 as a break glass solution, but only allows port 3389 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

#### Deploy Database Target
The `deploy_database_target` variable is a `bool` variable. Setting to true creates a PostgreSQL Flexible server in Azure (not a VM). You will see an output `azurerm_postgresql_flexible_server_database_name = "database-name"` when the apply finishes. You will then be able to run `boundary connect postgres -target-id ttcp_oEwOMuMpfg -dbname database-name` to connect to the database.

This will create:
- A PostgreSQL Flexible Server that is put into a seperate subnet from the worker and allows traffic on port 5432 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

## 3) Create Self-Managed Worker for HCP Boundary
Set `deploy_self_managed_worker = true` if you want this code to deploy a self-managed worker for connection to HCP Boundary and the infrastructure to support it. It is true by default. If set to true, the following will be created:
- A seperate subnet for the worker
- A Network Security Group allowing traffic from anywhere on 9202 and SSH from `boundary_ingress_cidr_allow` on port 22 to the worker. 9202 is the default port for connecting  the worker to the HCP Boundary Control Plane. 22 is enabled to allow you to SSH in an retrieve the worker auth request token.
- A linux Ubuntu VM that installs the Boundary worker binary and configures it.

## 4) Terraform Apply
Once you have configured all of the inputs, do an apply and wait for resources to come up.

## 5) Connect the Worker to HCP Boundary
You must then SSH into the worker VM and retreive the `auth_request_token`.
```bash
ssh -i boundary.pem boundaryadmin@100.1.2.3
sudo cat /opt/boundary/azure-worker/auth_request_token
```
Then go back to your HCP Boundary and add the worker.

## 6) Test the Target Connections
#### `ssh`
You can initiate a connection via the Boundary desktop app and then use `ssh 127.0.0.1 -p<PORT#>` to connect to the SSH target, or use the `boundary connect ssh -target-id tssh_Bnj6y7sVG5` command.

#### `rdp`
You can then initiate a sessions via the Boundary desktop app and use your RDP software of choice to connect, or run `boundary connect rdp -target-id ttcp_QqwiESZwHj` and if you have an RDP program installed, boundary will automatically launch that.

#### `database`
You will see an output `azurerm_postgresql_flexible_server_database_name = "database-name"` when the apply finishes. You will then be able to run `boundary connect postgres -target-id ttcp_oEwOMuMpfg -dbname database-name` to connect to the database.

## Requirements

| Name | Version |
|------|---------|
| azurerm | 3.58.0 |
| boundary | 1.1.7 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 3.58.0 |
| boundary | 1.1.7 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.boundary-servers](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_linux_virtual_machine.boundary_worker](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/nat_gateway) | resource |
| [azurerm_network_interface.boundary-nic](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface.boundary_worker_nic](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface.rdp_boundary_nic](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.boundary-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.boundary_worker_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.database_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.boundary_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.boundary_ssh_outofband](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.boundary_worker_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.boundary_worker_tcp_listen](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.rdp](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/network_security_rule) | resource |
| [azurerm_postgresql_flexible_server.boundary](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_database.boundary](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_private_dns_zone.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/public_ip) | resource |
| [azurerm_public_ip.rdp_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/public_ip) | resource |
| [azurerm_public_ip.worker_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/public_ip) | resource |
| [azurerm_resource_group.boundary-rg](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/resource_group) | resource |
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/route_table) | resource |
| [azurerm_subnet.boundary-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet) | resource |
| [azurerm_subnet.boundary_worker_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet) | resource |
| [azurerm_subnet.database_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.subnet_nsg_association1](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.subnet_nsg_association_db](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.subnet_nsg_association_worker](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.subnet_rt_association1](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.subnet_rt_association_worker](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.boundary-vnet](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/virtual_network) | resource |
| [azurerm_windows_virtual_machine.rdp_boundary_servers](https://registry.terraform.io/providers/hashicorp/azurerm/3.58.0/docs/resources/windows_virtual_machine) | resource |
| [boundary_credential_ssh_private_key.ssh-linux-vm](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_ssh_private_key) | resource |
| [boundary_credential_store_static.database](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_store_static) | resource |
| [boundary_credential_store_static.rdp](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_store_static) | resource |
| [boundary_credential_store_static.ssh-keys](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_store_static) | resource |
| [boundary_credential_username_password.database](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_username_password) | resource |
| [boundary_credential_username_password.rdp](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/credential_username_password) | resource |
| [boundary_host_catalog_static.database-targets](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_catalog_static) | resource |
| [boundary_host_catalog_static.rdp-targets](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_catalog_static) | resource |
| [boundary_host_catalog_static.ssh-targets](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_catalog_static) | resource |
| [boundary_host_set_static.database](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_set_static) | resource |
| [boundary_host_set_static.rdp](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_set_static) | resource |
| [boundary_host_set_static.ssh](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_set_static) | resource |
| [boundary_host_static.database](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_static) | resource |
| [boundary_host_static.rdp](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_static) | resource |
| [boundary_host_static.ssh](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/host_static) | resource |
| [boundary_target.database](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/target) | resource |
| [boundary_target.rdp](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/target) | resource |
| [boundary_target.ssh](https://registry.terraform.io/providers/hashicorp/boundary/1.1.7/docs/resources/target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| boundary\_addr | The Boundary address to authenticate against. | `string` | n/a | yes |
| boundary\_auth\_method\_id | The Boundary auth method ID. | `string` | n/a | yes |
| boundary\_ingress\_cidr\_allow | List of CIDRs allowed inbound to boundary related servers via SSH (port 22) on vnet. | `list(string)` | `[]` | no |
| boundary\_password\_auth\_method\_login\_name | The Boundary password auth method username. | `string` | n/a | yes |
| boundary\_password\_auth\_method\_password | The Boundary password auth method password. | `string` | n/a | yes |
| boundary\_rg | The Boundary resource group name. | `string` | `"boundary-rg"` | no |
| boundary\_rg\_location | The location of the Boundary resource group. | `string` | `"East US"` | no |
| boundary\_scope\_project\_id | The project scope ID to create a static host catalog inside of for SSH targets. | `string` | n/a | yes |
| boundary\_subnet\_cidr | CIDR block for boundary subnet1. | `string` | `"10.0.1.0/24"` | no |
| boundary\_worker\_subnet\_cidr | CIDR block for boundary worker subnet. | `string` | `"10.0.2.0/24"` | no |
| boundary\_worker\_version | The boundary-worker version to download to the self-managed-worker. | `string` | `"0.12.3+hcp-1"` | no |
| common\_tags | Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| create\_nat\_gateway | Boolean to create a NAT Gateway. Useful when Azure Load Balancer is internal but VM(s) require outbound Internet access. | `bool` | `false` | no |
| database\_subnet\_cidr | True or False. Deploy an Azure PostgreSQL Flexible server. | `string` | `"10.0.3.0/24"` | no |
| database\_target\_password | The password of the `database_target_username` user that will be created. | `string` | `"B0uNdairyP@ss"` | no |
| database\_target\_username | The username of the PostgreSQL user that will be created. | `string` | `"boundaryadmin"` | no |
| deploy\_database\_target | True or False. Deploy an Azure PostgreSQL Flexible server. | `bool` | n/a | yes |
| deploy\_rdp\_target | True or False. Deploy an RDP Azure Windows VM. | `bool` | n/a | yes |
| deploy\_self\_managed\_worker | True of False. Deploy a self-managed Boundary worker. | `bool` | `true` | no |
| deploy\_ssh\_target | True or False. Deploy an SSH target Azure Linux VM. | `bool` | n/a | yes |
| friendly\_name\_prefix | A prefix appended to the name of azure resources. | `string` | n/a | yes |
| hcp\_boundary\_cluster\_id | The HCP cluster ID to connect to. | `string` | n/a | yes |
| rdp\_target\_password | The password of the `rdp_target_username` user that will be created on the VM. Will also be used to RDP. | `string` | `"B0uNdairyP@ss"` | no |
| rdp\_target\_username | The username of the admin user that will be created on the VM. Will also be used to RDP. | `string` | `"boundaryadmin"` | no |
| sa\_ingress\_cidr\_allow | List of CIDRs allowed to interact with Azure Blob Storage Account. | `list(string)` | `[]` | no |
| ssh\_private\_key | The name of the ssh private key that will be uploaded to boundary credential store. Must be placed relative to the working directory. | `string` | n/a | yes |
| ssh\_public\_key | The name of the ssh public key that will be put on the SSH targett VMs. Must be placed relative to the working directory. | `string` | n/a | yes |
| ssh\_target\_username | The username of the admin user that will be created on the VM. Will also be set to the SSH username. | `string` | `"boundaryadmin"` | no |
| vnet\_cidr | CIDR block address space for VNet. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_postgresql\_flexible\_server\_database\_name | Name of Azurerm PostgreSQL Flexible database to connect to. |
| azurerm\_postgresql\_flexible\_server\_fqdn | FQDN of Azurerm PostgreSQL Flexible server. |
| rdp\_target\_private\_ip\_addr | n/a |
| rdp\_target\_public\_ip\_addr | n/a |
| ssh\_target\_private\_ip\_addr | n/a |
| ssh\_target\_public\_ip\_addr | n/a |
| worker\_private\_ip\_addr | n/a |
| worker\_public\_ip\_addr | n/a |