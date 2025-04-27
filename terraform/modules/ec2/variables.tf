variable "app_name" {}
variable "instance_type" {}
variable "ami_id" {}
variable "key_name" {}
variable "subnet_id" {}
variable "security_group_ids" { type = list(string) }
variable "user_data" {}