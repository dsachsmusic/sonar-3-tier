variable "region" {
  description = "Our default AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

#for use if creating OUs, etc.
variable "root_id" {
    type    = string
    default = "r-lce9"
}