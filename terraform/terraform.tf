# Terraform configuration block
terraform {
  #comment out because will use local state
  #backend "s3" {
  #  bucket = "my-terraform-state-bucket"
  #  key    = "terraform/state"
  #  region = "us-east-1"
  #}
  
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
  region = var.region
  #AWS_ACCESS_KEY_ID     : inherently defined via PowerShell Environment variable.
  #AWS_SECRET_ACCESS_KEY : inherently defined via PowerShell environment varaible.
}

# PostgreSQL Provider Configurations
provider "postgresql" {
  alias    = "inventory"
  host     = aws_rds_cluster.inventory_db.endpoint
  port     = 5432
  username = "postgres"
  password = "postgres"
  database = "inventory"
}

provider "postgresql" {
  alias    = "orders"
  host     = aws_rds_cluster.orders_db.endpoint
  port     = 5432
  username = "postgres"
  password = "postgres"
  database = "orders"
}
