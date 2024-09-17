output "orderagreeting_ecs_task_execution_role_name" {
  value = aws_iam_role.orderagreeting_ecs_task_execution_role.name
  description = "The name of the ECS task execution role."
}

output "orderagreeting_ecs_instance_profile_name" {
  value = aws_iam_instance_profile.orderagreeting_ecs_instance_profile.name
}

output "orderagreeting_ecs_task_execution_role_arn" {
  value = aws_iam_role.orderagreeting_ecs_task_execution_role.arn
}

output "orderagreeting_ecs_task_role_arn" {
  value = aws_iam_role.orderagreeting_ecs_task_role.arn
}