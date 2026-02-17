
variable "prefix" { type = string}
variable "location" { type = string}
variable "ressource_group_name" { type = string}
variable "tags" { type = map(string)}

variable "vnet_dir" {
    type = string
    default = "10.10.0.0/16"
}

variable "subnet_cidr" {
    type = string
    default = "10.10.1.0/24"
}

variable "ssh_source_cidr" {
    type = string
    default = "*"
}