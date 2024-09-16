variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "ami" {
  description = "AMI used for the EC2 instances launched for ECS to run on"
  type        = string
}

variable "instance_type" {
  description = "Instance type of the EC2 instances launched for ECS to run on"
  type        = string
}
