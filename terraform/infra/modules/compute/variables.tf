
variable "prefix" { type = string }
variable "location" { type = string }
variable "ressource_group_name" { type = string }
variable "tags" { type = map(string) }

variable "subnet_id" { type = string }
variable "nsg_id" { type = string }

variable "admin_username" { type = string }
variable "ssh_public_key_path" { type = string }

variable "vm_size" {
    type = string
    default = "Standard_B1s"
}
