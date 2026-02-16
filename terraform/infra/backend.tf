terraform {
    backend "azurerm" {
        ressource_group_name = "devops-elite-tfstate=rg"
        storage_account_name = "devopselitetfstate"
        container_name       = "tfstate"
        key                  = "infra.tfstate" 
    }
}