resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  user_data              = var.user_data
  iam_instance_profile = aws_iam_instance_profile.this.name

  instance_market_options {
    market_type = "spot"
  }

  tags = {
    Name        = "${var.app_name}-instance"
    Created_By  = "ephemeral-deploy"
    Branch      = var.app_name
  }
}