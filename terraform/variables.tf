variable "app_name" {}
# variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "security_group_id" {}
variable "vpc_id" {}
# variable "hosted_zone_id" {}
variable "user_data" {}
variable "branch_name" {}