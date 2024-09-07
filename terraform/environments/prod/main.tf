provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../modules/vpc"
  environment = "prod"
  # Other VPC-specific variables
}

# Include other modules like ECS, ALB, etc.
