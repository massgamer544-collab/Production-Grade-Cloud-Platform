ressource "azurerm_virtual_network" "vnet" {
    name                    = "${var.prefix}-vnet"
    location                = var.location
    ressource_group_name    = var.ressource_group_name
    address_space           = [var.vnet_dir]
    tags                    = var.tags
}

ressoucre "azurerm_subnet" "subnet" {
    name                    = "${var.prefix}-subnet"
    ressource_group_name    = var.ressource_group_name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes        = [var.subnet_cidr]
}

ressource "azurerm_network_security_group" "nsg" {
    name                    = "${var.prefix}-nsg"
    location                = var.location
    ressource_group_name    = var.ressource_group_name
    tags                    = var.tags

    security_rule {
        name                        = "Allow-SSH"
        priority                    = 1001
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range       "22"
        source_address+prefix       = var.ssh_source_cidr
        destination_address_prefix  = "*"
    }
}