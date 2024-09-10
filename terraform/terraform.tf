# Terraform configuration block
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform/state"
    region = "us-east-1"
  }

  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14"  # Specify the correct version of the postgresql provider
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# PostgreSQL Provider Configurations
provider "postgresql" {
  alias    = "inventory"
  host     = aws_rds_cluster.inventory_db.endpoint
  port     = 5432
  username = "admin"
  password = "your_password"
  database = "inventory_world"
}

provider "postgresql" {
  alias    = "orders"
  host     = aws_rds_cluster.orders_db.endpoint
  port     = 5432
  username = "admin"
  password = "your_password"
  database = "orders_world"
}
