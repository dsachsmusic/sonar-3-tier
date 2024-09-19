variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the DB servers"
  type        = string
}

variable "aurora_sg_id" {
  description = "Security group for Aurora to join"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group for Aurora to join"
  type        = string
}