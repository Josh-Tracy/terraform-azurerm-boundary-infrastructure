# terraform-azurerm-boundary-infrastructure
Deploys infrastructure for testing HashiCorp Boundary targets and self-managed workers with HCP Boundary.

## What this Repo Does and When to Use it
This repo is designed to quickly create a self-managed worker in Azure, along with 3 different target types if you choose - SSH, RDP, and PostgreSQL Database, and register them in your HCP Boundary. Use it when you need to quickly test / demo these connections in Azure.

## Prerequisites
You need the following in order to use this repo:
- An existing HCP Boundary cluster
- An Organization and a Project inside of that organization
- An Azure subscription with the ability to create VNETS, VMs, and PostgreSQL Flexible servers.

## Configure Boundary Provider Credentials
Configure the Boundary provider credentials as environment variables on your system or in your Terraform Cloud Workspace. Password auth is used in this example for easy testing. 

```
provider "boundary" {
  addr                            = var.boundary_addr
  auth_method_id                  = var.boundary_auth_method_id
  password_auth_method_login_name = var.boundary_password_auth_method_login_name          
  password_auth_method_password   = var.boundary_password_auth_method_password       
}
```

## Specify Which Targets to Create and Register to Boundary
The following variables can be defined to deploy different targets for testing:

### Deploy SSH Target
The `deploy_ssh_target` variable is a `bool` variable. Setting to true creates an Azure Linux Ubuntu VM with SSH configured and registers it to the `boundary_scope_project_id` you define. You can initiate a connection via the Boundary desktop app and then use `ssh 127.0.0.1 -p<PORT#>` to connect to the SSH target, or use the `boundary connect ssh -target-id tssh_Bnj6y7sVG5` command.

This will create:
- A Linux VM that is put into a seperate subnet from the worker and allows traffic from `boundary_ingress_cidr_allow` on port 22 as a break glass solution, but only allows port 22 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

### Depploy RDP Target
The `deploy_rdp_target` variable is a `bool` variable. Setting to true creates a Windows VM with RDP configured and registers it to the `boundary_scope_project_id` you define. You can then initiate a sessions via the Boundary desktop app and use your RDP software of choice to connect, or run `boundary connect rdp -target-id ttcp_QqwiESZwHj` and if you have an RDP program installed, boundary will automatically launch that.

This will create:
- A Windows Server VM that is put into a seperate subnet from the worker and allows traffic from `boundary_ingress_cidr_allow` on port 22 as a break glass solution, but only allows port 3389 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

### Deploy Database Target
The `deploy_database_target` variable is a `bool` variable. Setting to true creates a PostgreSQL Flexible server in Azure (not a VM). You will see an output `azurerm_postgresql_flexible_server_database_name = "database-name"` when the apply finishes. You will then be able to run `boundary connect postgres -target-id ttcp_oEwOMuMpfg -dbname database-name` to connect to the database.

This will create:
- A PostgreSQL Flexible Server that is put into a seperate subnet from the worker and allows traffic on port 5432 from the Boundary worker public IP for Boundary connections.
- Boundary credentials and targets

## Create Self-Managed Worker for HCP Boundary
Set `deploy_self_managed_worker = true` if you want this code to deploy a self-managed worker for connection to HCP Boundary and the infrastructure to support it. It is true by default. If set to true, the following will be created:
- A seperate subnet for the worker
- A Network Security Group allowing traffic from anywhere on 9202 and SSH from `boundary_ingress_cidr_allow` on port 22 to the worker. 9202 is the default port for connecting  the worker to the HCP Boundary Control Plane. 22 is enabled to allow you to SSH in an retrieve the worker auth request token.
- A linux Ubuntu VM that installs the Boundary worker binary and configures it.

You must then SSH into the worker VM and retreive the `auth_request_token`.
```bash
ssh -i boundary.pem boundaryadmin@100.1.2.3
sudo cat /opt/boundary/azure-worker/auth_request_token
```

Then go back to your HCP Boundary and add the worker.



