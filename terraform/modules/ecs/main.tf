#Define ECS cluster
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
}

#ECS task definitions
resource "aws_ecs_task_definition" "inventory_service_task" {
  family                   = "inventory-service"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "inventory-service"
      image     = "your_docker_repo/inventory-service:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_rds_cluster.inventory_db.endpoint },
        { name = "DB_NAME", value = aws_rds_cluster.inventory_db.database_name },
        { name = "DB_USER", value = "admin" },
        { name = "DB_PASSWORD", value = "your_password" }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "orders_service_task" {
  family                   = "orders-service"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "orders-service"
      image     = "your_docker_repo/orders-service:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_rds_cluster.orders_db.endpoint },
        { name = "DB_NAME", value = aws_rds_cluster.orders_db.database_name },
        { name = "DB_USER", value = "admin" },
        { name = "DB_PASSWORD", value = "your_password" }
      ]
    }
  ])
}


