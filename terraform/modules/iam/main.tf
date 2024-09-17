# Role that ECS will assume...that will be attached to policies 
# that grant access to the ECS service itself, access to public logs, get images, etc.
resource "aws_iam_role" "orderagreeting_ecs_task_execution_role" {
  name = "${var.environment}-orderagreeting-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# This policy grants ECS service the necessary permissions to pull container images from ECR, 
# publish logs to CloudWatch, and other essential actions needed for task execution.
resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_task_execution_role_policy_attachment" {
  role      = aws_iam_role.orderagreeting_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Role that ECS will assume...that will be attached to policies that grant ECS tasks...
# permissions to interact with other AWS services (e.g., DynamoDB, S3, Aurora)
resource "aws_iam_role" "orderagreeting_ecs_task_role" {
  name = "${var.environment}-orderagreeting-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the ECS Task Role Policy to the role
# Policy attachment that grants ECS tasks the permissions to interact with ECS service components 
# ...The policy here, when attached to this role allows ECS operations, such as interacting...
# with ECS services or accessing container instance metadata.
resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_task_role_policy_attachment" {
  role      = aws_iam_role.orderagreeting_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role"
}

# Role that EC2 instances running ECS tasks will assume... will be attached to policies that
# allow EC2 instances running ECS tasks to interact with ECS services and perform actions as needed.
resource "aws_iam_role" "orderagreeting_ecs_instance_role" {
  name = "${var.environment}-orderagreeting-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "orderagreeting_ecs_instance_profile" {
  name = "${var.environment}-orderagreeting-ecs-instance-profile"
  role = aws_iam_role.orderagreeting_ecs_instance_role.name
}
# Attach the ECS Instance Role Policy to the role
# # ...The policy here, when attached to this role grants EC2 instances the permissions required 
# to interact with ECS services and perform actions related to running ECS tasks.
resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_instance_role_policy_attachment" {
  role      = aws_iam_role.orderagreeting_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# IAM user for executing commands on ECS tasks using the ECS Exec feature.
resource "aws_iam_user" "orderagreeting_ecs_exec_user" {
  name = "${var.environment}-ecs-exec-user"
}

# Attach the ECS Exec Policy to the user
# This policy grants the user permissions to execute commands on ECS tasks.
resource "aws_iam_user_policy_attachment" "orderagreeting_ecs_exec_user_policy" {
  user      = aws_iam_user.orderagreeting_ecs_exec_user.name
  policy_arn = aws_iam_policy.orderagreeting_ecs_exec_policy.arn
}

# Create access keys for the ECS Exec user
# These keys are used for programmatic access to AWS services by the ECS Exec user.
resource "aws_iam_access_key" "orderagreeting_ecs_exec_user_key" {
  user = aws_iam_user.orderagreeting_ecs_exec_user.name
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


# Custom IAM policy for ECS Exec commands
# This policy grants permissions to execute SSM commands, create log streams, 
# and perform ECS ExecuteCommand operations on ECS tasks and task definitions.
resource "aws_iam_policy" "orderagreeting_ecs_exec_policy" {
  name        = "${var.environment}-orderagreeting-ecs-exec-policy"
  description = "Allows ECS Exec commands on ECS tasks"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:SendCommand",
          "ssm:TerminateSession"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ExecuteCommand"
        ]
        Resource = [
          "arn:aws:ecs:*:*:task/*",
          "arn:aws:ecs:*:*:task-definition/*"
        ]
      }
    ]
  })
}

# Attach the ECS Exec Policy to the ECS Task Execution Role
# This policy attachment grants the ECS Task Execution Role the permissions defined 
# in the ECS Exec Policy, allowing ECS tasks to use the ECS Exec feature.
resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_exec_role_policy_attachment" {
  role      = aws_iam_role.orderagreeting_ecs_task_execution_role.name
  policy_arn = aws_iam_policy.orderagreeting_ecs_exec_policy.arn
}

# Policy allowing ECS itself to to perform to access s3 bucket ...
# (in case we want to, so, have ECS itself upload logs to a bucket?)
resource "aws_iam_role_policy" "orderagreeting_ecs_task_execution_s3_bucket_policy" {
  name   = "${var.environment}-orderagreeting_ecs-task-execution-s3-bucket-policy"
  role   = aws_iam_role.orderagreeting_ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.orderagreeting_general_purpose_bucket_arn}/*"
      }
    ]
  })
}

#Policy allowing ECS tasks to access a bucket...i.e...
#...the code within a container to interact with a bucket
resource "aws_iam_role_policy" "orderagreeting_ecs_task_role_s3_bucket_policy" {
  name   = "${var.environment}-orderagreeting-ecs-task-role-s3-bucket-policy"
  role   = aws_iam_role.orderagreeting_ecs_task_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${var.orderagreeting_general_purpose_bucket_arn}/*"
      }
    ]
  })
}
