variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "You must provide exactly 3 public subnet CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "You must provide exactly 3 private subnet CIDR blocks."
  }
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) <= length(data.aws_availability_zones.available.names)
    error_message = "The number of availability zones provided exceeds the number of available AZs in the region."
  }
}