variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

/*
# this probably should be defined at the environment level...
# ...and, in "outputs"
variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}
*/