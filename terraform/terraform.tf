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
  }
}


#note: could also define other providers here?...if want centralized configuration