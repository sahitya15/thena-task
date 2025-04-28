resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data              = var.user_data
  iam_instance_profile   = var.iam_instance_profile

  instance_market_options {
    market_type = "spot"
  }

  tags = {
    Name = "${var.app_name}-ec2-instance"
    Created_By = "ephemeral-deploy"
    App_Branch = var.app_name
  }
}