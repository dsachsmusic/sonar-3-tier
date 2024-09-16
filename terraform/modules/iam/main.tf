#Gives ECS tasks and services permisssions to interact with AWS services
#pull images (if using ECR) and publish logs.
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

resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_task_execution_policy" {
  role       = aws_iam_role.orderagreeting_ecs_task_execution_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Enable tasks/containers to connect with services like Dynamo DB and S3 (and Aurora?)
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


resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_task_role_policy" {
  role       = aws_iam_role.orderagreeting_ecs_task_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role"
}

#IAM role for EC2 instances running ECS tasks
#Enables ECS agent running on the EC2 instances to interact with ECS 
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

resource "aws_iam_role_policy_attachment" "orderagreeting_ecs_instance_role_policy" {
  role       = aws_iam_role.orderagreeting_ecs_instance_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#create a user and enable the user to run commands on tasks
resource "aws_iam_user" "ecs_exec_user" {
  name = "${var.environment}-ecs-exec-user"
}

resource "aws_iam_user_policy_attachment" "ecs_exec_user_policy" {
  user       = aws_iam_user.ecs_exec_user.name
  policy_arn  = aws_iam_policy.ecs_exec_policy.arn
}

resource "aws_iam_access_key" "ecs_exec_user_key" {
  user = aws_iam_user.ecs_exec_user.name
}

output "ecs_exec_user_access_key_id" {
  value = aws_iam_access_key.ecs_exec_user_key.id
}

output "ecs_exec_user_secret_access_key" {
  value = aws_iam_access_key.ecs_exec_user_key.secret
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "${var.environment}-ecs-exec-policy"
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

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy_attachment" {
  role       = aws_iam_role.orderagreeting_ecs_task_execution_role.name
  policy_arn  = aws_iam_policy.ecs_exec_policy.arn
}
