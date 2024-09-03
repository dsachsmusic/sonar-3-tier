module "ec2" {
  source         = "../../modules/ec2"
  ami             = var.ami
  instance_type   = var.instance_type
   subnet_id      = module.vpc.public_subnet_id
}

provider "aws" {
  region = "us-east-1"
}

# Specify the location of .tfvars file
terraform {
  variables = file("${path.module}/dev.tfvars")
}