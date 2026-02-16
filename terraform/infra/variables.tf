
variable "location" {
    type = string
    default = "canadacentral"
}

variable "project" {
    type = string
    default = "devops-elite"
}

variable "admin_username" {
    type = string
    default = "azureuser"
}

variable "ssh_public_key_path" {
    type = string
    default = "./id_ed25519.pub"
}

variable "environment" {
    type = string
    default = "dev"
}