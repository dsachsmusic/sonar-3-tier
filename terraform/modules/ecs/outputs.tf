output "orderagreeting_public_cluster_id" {
  value = aws_ecs_cluster.orderagreeting_public_cluster.id
  description = "The ID of the public ECS cluster."
}

output "orderagreeting_public_cluster_name" {
  value = aws_ecs_cluster.orderagreeting_public_cluster.name
  description = "The name of the public ECS cluster."
}

output "orderagreeting_private_cluster_id" {
  value = aws_ecs_cluster.orderagreeting_private_cluster.id
  description = "The ID of the private ECS cluster."
}

output "orderagreeting_private_cluster_name" {
  value = aws_ecs_cluster.orderagreeting_private_cluster.name
  description = "The name of the private ECS cluster."
}

output "orderagreeting_public_launch_configuration_id" {
  value = aws_launch_configuration.orderagreeting_public_launch_configuration.id
  description = "The ID of the public launch configuration."
}

output "orderagreeting_private_launch_configuration_id" {
  value = aws_launch_configuration.orderagreeting_private_launch_configuration.id
  description = "The ID of the private launch configuration."
}

output "orderagreeting_frontend_task_definition_arn" {
  value = aws_ecs_task_definition.orderagreeting_frontend_task.arn
  description = "The ARN of the frontend ECS task definition."
}

output "orderagreeting_inventory_task_definition_arn" {
  value = aws_ecs_task_definition.orderagreeting_inventory_task.arn
  description = "The ARN of the inventory ECS task definition."
}

output "orderagreeting_orders_task_definition_arn" {
  value = aws_ecs_task_definition.orderagreeting_orders_task.arn
  description = "The ARN of the orders ECS task definition."
}