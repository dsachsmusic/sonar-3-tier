/*
Define variables needed for networking, 
such as VPC ID, subnet CIDRs, and AZs.
*/

variable "environment" {
  description = "Environment that the resources will be deployed to"
  type        = string
}