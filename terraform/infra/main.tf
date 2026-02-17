locals {
  prefix = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "./modules/network"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
  ssh_source_cidr     = var.ssh_source_cidr
}

module "compute" {
  source              = "./modules/compute"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  subnet_id           = module.network.subnet_id
  nsg_id              = module.network.nsg_id

  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
}
