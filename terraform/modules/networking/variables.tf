/*
Define variables needed for networking, 
such as VPC ID, subnet CIDRs, and AZs.
*/

variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}

variable "orderagreeting_vpc_id" {
  description = "The ID of the VPC"
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