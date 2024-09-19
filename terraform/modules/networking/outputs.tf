output "orderagreeting_aurora_sg_id" {
  value = aws_security_group.orderagreeting_aurora_sg.id
}

output "orderagreeting_db_subnet_group_name" {
  value = aws_db_subnet_group.orderagreeting_db_subnet_group.name
}

output "orderagreeting_frontend_lb_sg_id" {
  value = aws_security_group.orderagreeting_frontend_lb_sg.id
}

output "orderagreeting_frontend_sg_id" {
  value = aws_security_group.orderagreeting_frontend_sg.id
}

output "orderagreeting_service_discovery_sg_id" {
  value = aws_security_group.orderagreeting_service_discovery_sg.id
}

output "orderagreeting_inventory_sg_id" {
  value = aws_security_group.orderagreeting_inventory_sg.id
}

output "orderagreeting_orders_sg_id" {
  value = aws_security_group.orderagreeting_orders_sg.id
}

