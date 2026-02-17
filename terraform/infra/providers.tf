terraform {
    required_version = ">= 1.6.0"

    required_providers {
        azurem = {
            source = "hashicorp/azurem"
            version = "~> 3.110"
        }
    }
    random = {
        source = "hashicorp/random"
        version = "~> 3.6"
    }
}

provider "azurem" {
    features {}
}