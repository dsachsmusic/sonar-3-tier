output "orderagreeting_vpc_id" {
  description = "The ID of the VPC."
  value = aws_vpc.orderagreeting_vpc.id
}

output "orderagreeting_public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.orderagreeting_public_subnet[*].id
}

output "orderagreeting_private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.orderagreeting_private_subnet[*].id
}

