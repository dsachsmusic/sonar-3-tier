output "inventory_db_endpoint" {
  value = aws_rds_cluster.inventory_db.endpoint
}

output "orders_db_endpoint" {
  value = aws_rds_cluster.orders_db.endpoint
}

output "inventory_db_name" {
  value = aws_rds_cluster.inventory_db.endpoint
}

output "orders_db_name" {
  value = aws_rds_cluster.orders_db.endpoint
}