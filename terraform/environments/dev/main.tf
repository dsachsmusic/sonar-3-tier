module "ec2" {
  source         = "../../modules/ec2"
  environment = var.environment
  ami            = var.ami
  instance_type  = var.instance_type
  subnet_id      = module.vpc.public_subnet_id
}

module "vpc" {
  source = "../../modules/vpc"
  environment = var.environment
  
  # Other VPC-specific variables
}

module "ecs" {
  source = "../modules/ecs"
  environment = var.environment
  # ECS-specific variables
}

module "alb" {
  source = "../modules/alb"
  environment = var.environment
  # ALB-specific variables
}

module "aurora" {
  source = "../modules/aurora"
  environment = var.environment
  # Aurora-specific variables
}

module "s3" {
  source = "../modules/s3"
  environment = var.environment
  # S3-specific variables
}

module "networking" {
  source = "../modules/networking"
  environment = var.environment
  # Networking-specific variables
}

module "iam" {
  source = "../modules/iam"
  environment = var.environment
  # IAM-specific variables
}

/*
override here to put dev in a different region, from what is defined in 
if defined in top level main.tf
*/
provider "aws" {
  region = "us-east-2"
  environment = var.environment
}

# Specify the location of .tfvars file
terraform {
  variables = file("${path.module}/dev.tfvars")
}