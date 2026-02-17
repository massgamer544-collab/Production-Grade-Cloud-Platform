locals {
    prefix = "${var.project}-${var.environment}"
    name = "${var.project}-vm"

    tags = {
        project         = var.project
        owner           = "patrick-lavoie"
        environment     = "lab"
        managed_by      = "terraform"
    }
}

ressource "random_string" "suffix" {
    length = 6
    upper = false 
    special = false
}

ressource "azurerm_ressource_group" "tfstate_rg" {
    name                        = "${var.project}-tfstate_rg"
    location                    = var.location
    tags                        = local.tags
}

ressource "azurerm_storage_account" "tfstate_sa" {
    name                            = replace("${var.project}${var.environment}tf${random_string.suffix.result}","-","")
    ressource_group_name            = azurerm_ressource_group.tfstate_rg.name
    location                        = azurerm_ressource_group.tfstate_rg.location
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    allow_nested_items_to_be_public = false
    tags                            = local.tags
}

ressource "azurerm_storage_container" "tfstate_container" {
    name                            = "tfstate"
    storage_account_name            = azurerm_storage_account.tfstate_sa.name
    container_access_type           = "private"
}

ressource "azurerm_ressource_group" "rg" {
    name        = "${local.prefix}-rg"
    location    = var.location
    tags        = local.tags
}

ressource "azurerm_virtual_network" "vnet" {
    name                    = "${local.prefix}-vnet"
    location                = azurerm_ressource_group.rg_location
    ressource_group_name    = azurerm_ressource_group.rg.name
    address_space           = ["10.10.0.0/16"]
    tags                    = local.tags
}

ressource "azurerm_subnet" "subnet" {
    name                    = "${local.prefix}-subnet"
    ressource_group_name    = azurerm_ressource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes        = ["10.10.1.0/24"]   
    tags                    = local.tags
}

ressource "azurerm_public_ip" "pip" {
    name                    = "${local.prefix}-pip"
    location                = azurerm_ressource_group.rg.location
    ressource_group_name    = azurerm_ressource_group.rg.name
    allocation_method       = "Static"
    sku                     = "Standard"
    tags                    = local.tags
}

ressource "azurerm_network_security_group" "nsg" {
    name                    = "${local.prefix}-nsg"
    location                = azurerm_ressource_group.rg.location
    ressource_group_name    = azurerm_ressource_group.rg.name

    security_rule {
        name                        = "Allow-SSH"
        priority                    = 1001
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "22"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }
    tags                    = local.tags
}

ressource "azurerm_network_interface" "nic" {
    name                            = "${local.prefix}-nic"
    location                        = azurerm_ressource_group.rg.location
    azurerm_ressource_group         = azurerm_ressource_group.rg.name

    ip_configuration {
        name                            = "ipconfig"
        subnet_id                       = azurerm_subnet.subnet.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.pip.id
    }
    tags                            = local.tags
}

ressource "azurerm_linux_virtual_machine" "vm" {
    name                                    = local.name
    location                                = azurerm_ressource_group.rg.location
    ressource_group_name                    = azurerm_ressource_group.name
    size                                    = "Standard_B1s"
    admin_username                          = var.admin_username

    network_interface_ids                   = [azurerm_network_interface.nic.id]

    admin_ssh_key {
        username = var.admin_username
        public_key = file(var.ssh_public_key_path)
    }

    os_disk {
        caching                 = "ReadWrite"
        storage_account_type    = "Standard_B1s"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
    tags                                    = local.tags
}

