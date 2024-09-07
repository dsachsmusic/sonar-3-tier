#variable type is inherited from upper levels? does this work?
variable "environment" {
 default     = "dev"
}

variable "vpc_cidr_block" {
 default     = "10.0.0.1/24"
}
