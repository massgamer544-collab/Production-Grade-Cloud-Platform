terraform {
    backend "azurerm" {
        ressource_group_name    = "TON_TFSTATE_RG"
        storage_account_name    = azurerm_storage_account.tfstate_sa.name
        container_name          = "tfstate"
        key                     = "dev/infra.tfstate"
    }
}