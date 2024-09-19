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

variable "frontend_sg_id" {
  description = "ID of the security group corresponding to the frontend"
  type        = string
}

variable "frontend_load_balancer_dnsname" {
  description = "DNS name for the frontend load balancer"
  type        = string
}

variable "inventory_sg_id" {
  description = "ID of the security group corresponding to the inventory service"
  type        = string
}

variable "orders_sg_id" {
  description = "ID of the security group corresponding to the orders service"
  type        = string
}

variable "service_discovery_sg_id" {
  description = "ID of the security group for service discovery"
  type        = string
}


variable "ecs_service_policy_attachment_id" {
  description = "ECS service policy attachment"
  type        = string
}

variable "lb_target_group_arn" {
  description = "ARN for the lb"
  type        = string
}

