variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "orderagreeting_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "frontend_lb_sg_id" {
  description = "The ID of the frontend load balancer security group"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group for Aurora to join"
  type        = string
}
