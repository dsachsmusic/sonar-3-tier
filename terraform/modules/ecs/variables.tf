variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "orderagreeting_vpc_id" {
  description = "The ID of the VPC"
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

variable "iam_instance_profile_name" {
  description = "IAM instance profile from ECS instance IAM role "
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN for IAM ECS task execution role "
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN for IAM ECS task role "
  type        = string
}

variable "inventory_db_endpoint" {
  description = "RDS endpoint for inventory DB"
  type        = string
}

variable "orders_db_endpoint" {
  description = "RDS endpoint for orders DB"
  type        = string
}

variable "inventory_db_name" {
  description = "Name of inventory DB"
  type        = string
}

variable "orders_db_name" {
  description = "Name of for orders DB"
  type        = string
}

variable "public_subnet_ids" {
  description = "list of the public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "list of the private subnet ids"
  type        = list(string)
}



