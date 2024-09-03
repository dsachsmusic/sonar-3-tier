#Define the VPC and associated networking resources for the production
#environment.

module "vpc" {
  source = "../../modules/vpc"
  environment = "prod"
  cidr_block = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  availability_zones = data.aws_availability_zones.available.names
}

# Include additional environment-specific configurations if needed...
