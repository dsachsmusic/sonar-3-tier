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

output "orderagreeting_ecs_service_policy_attachment_id" {
  value = aws_iam_role_policy_attachment.orderagreeting_ecs_service_policy_attachment.id
}

# Output the access key ID for the ECS Exec user
# This output provides the access key ID for use in accessing AWS services programmatically.
output "orderagreeting_ecs_exec_user_access_key_id" {
  value = aws_iam_access_key.orderagreeting_ecs_exec_user_key.id
}

# Output the secret access key for the ECS Exec user
# This output provides the secret access key for use in accessing AWS services programmatically.
output "orderagreeting_ecs_exec_user_secret_access_key" {
  value = aws_iam_access_key.orderagreeting_ecs_exec_user_key.secret
}

