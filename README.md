# terraform-azurerm-boundary-infrastructure
Deploys infrastructure for testing HashiCorp Boundary

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
The `deploy_ssh_target` variable is a `bool` variable. Setting to true creates an Azure Linux Ubuntu VM with SSH configured and registers it to the `boundary_scope_project_id` you define.

### Depploy RDP Target
The `deploy_rdp_target` variable is a `bool` variable. Setting to true creates a Windows VM with RDP configured and registers it to the `boundary_scope_project_id` you define.

### Deploy Database Target
The `deploy_database_target` variable is a `bool` variable. Setting to true creates a PostgreSQL Flexible server in Azure (not a VM).

## Create Self-Managed Worker for HCP Boundary
Set `deploy_self_managed_worker = true` if you want this code to deploy a self-managed worker for connection to HCP Boundary and the infrastructure to support it. If set to true, the following will be created:
- A seperate subnet for the worker
- A public IP
- A Network Interface
- A Network Security Group allowing traffic from anywhere on 9202 and SSH from `boundary_ingress_cidr_allow` on port 22.
- A linux Ubuntu VM that installs the Boundary worker binary and configures it.

You must then SSH into the worker VM and retreive the `auth_request_token`.
```bash
ssh -i boundary.pem boundaryadmin@100.1.2.3
cat /opt/boundary/azure-worker/auth_request_token
```



