/*
This file/folder defines a module - it is intended to be called by a ...
higher-level configuration, using the a "module" block...
(module invokation)...It is not intended that Terraform apply be in...
this folder
*/
#Define a launch template or configuration for EC2 instances that will join the ECS cluster.
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-launch-template"
  image_id      = "ami-0c02fb55956c7d316" # Use the latest Amazon Linux 2 ECS-optimized AMI ID for your region
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.my_ecs_cluster.name}" >> /etc/ecs/ecs.config
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

#Auto Scaling Group for ECS (corresponds to launch template)
resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = ["subnet-12345678", "subnet-87654321"] # Replace with your subnet IDs
}

#ECS services for running the tasks on EC2 instances.
resource "aws_ecs_service" "inventory" {
  name            = "inventory"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.inventory_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_ecs_service" "orders" {
  name            = "orders"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.orders_task.arn
  desired_count   = 2
  launch_type     = "EC2"

  deployment_controller {
    type = "ECS"
  }
}

# Other EC2 resources...