provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "vpc" {
  source = "./modules/vpc"
  name   = var.app_name
  region = "ap-south-1"
}

module "iam" {
  source = "./modules/iam"
  app_name = var.app_name
}

module "ec2" {
  source                = "./modules/ec2"
  app_name              = var.app_name
  ami_id                = data.aws_ami.amazon_linux_2.id
  instance_type         = "t3.micro"
  subnet_id             = element(module.vpc.subnet_ids, 0)
  security_group_ids    = [module.vpc.security_group_id]
  user_data             = var.user_data
  iam_instance_profile  = module.iam.ec2_instance_profile_name
}

module "alb" {
  source            = "./modules/alb"
  app_name          = var.app_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.vpc.security_group_id
  target_id         = module.ec2.instance_id
}