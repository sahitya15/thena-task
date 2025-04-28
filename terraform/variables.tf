variable "app_name" {}
variable "user_data" {
  description = "User data script for EC2"
  type        = string
  default     = ""
}
