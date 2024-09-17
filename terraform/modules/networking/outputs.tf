output "orderagreeting_aurora_sg_id" {
  value = aws_security_group.orderagreeting_aurora_sg.id
}

output "orderagreeting_db_subnet_group_name" {
  value = aws_db_subnet_group.orderagreeting_db_subnet_group.name
}
