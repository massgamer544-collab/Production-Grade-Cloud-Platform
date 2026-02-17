# Azure Platform Lab (Terraform)

Production-style infrastructure deployed on Azure using Terraform, with environment separation (dev/test) and remote state support.

## What this deploys
- Resource Group
- Virtual Network + Subnet
- Network Security Group (SSH inbound rule)
- Public IP + NIC
- Ubuntu Linux VM (22.04)
- Consistent naming + tagging (`project`, `environment`, `managed_by`)

## Requirements
- Terraform >= 1.6
- Azure CLI (`az login`)
- An Azure subscription with permission to create resources



## Quick start (dev)

cd infra
cp terraform.tfvars.example terraform.tfvars
cp backend-dev.tf.example backend-dev.tf   # optional if using remote state
terraform init
terraform plan
terraform apply


## SSH into the VM 
After Apply , Terraform outputs a public IP

ssh -i id_ed25519 azureuser@<PUBLIC_IP>

## Destroy (clean teardown)

terraform destroy

## Environments
This repo supports environment separation via variables ( e.g., environment = "dev" / "test") , allowing 
isolated resource groups and naming.

To create a test environment : 

cd infra 
cd terraform.tfvars.example test.tfvars

terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars

## Remote State (Azure backend)
Use backend-dev.tf.example as a template , fill the storage account details, then:

terraform init -migrate-state

## Notes 
- Terraform state files and .tfvars are intentionally excluded from Git.
- This project is designed to reflect production patterns ( indempotent deploy/destroy)