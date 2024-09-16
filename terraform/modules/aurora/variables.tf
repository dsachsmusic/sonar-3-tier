variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the DB servers"
  type        = string
}