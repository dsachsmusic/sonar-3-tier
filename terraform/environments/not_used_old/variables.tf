variable "environment" {
  default = "dev"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "ecs_ec2_instance_type" {
  default = "t2.micro"
}

variable "ecs_ec2_ami" {
  default = "ami-07ae7190a74b334a0"
}

variable "aurora_instance_class" {
  default = "db.t2.small"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}