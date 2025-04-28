output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}