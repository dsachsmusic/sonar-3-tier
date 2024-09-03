/*
Define the VPC and associated networking resources for the development
environment.
*/

module "vpc" {
  source = "../../modules/vpc"
  environment = "dev"
  cidr_block = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = data.aws_availability_zones.available.names
}

# Include additional environment-specific configurations if needed...