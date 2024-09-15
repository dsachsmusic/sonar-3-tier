#Define ECS cluster
resource "aws_ecs_cluster" "example" {
  name = "${var.environment}-cluster"
}


#ECS task definitions
resource "aws_ecs_task_definition" "inventory_task" {
  family                   = "inventory"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "inventory"
      image     = "dsachsmusic/order-a-greeting-inventory:latest"
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
        { name = "DB_USER", value = "postgres" },
        { name = "DB_PASSWORD", value = "postgres" },
        { name = "DB_PORT", value = "5432" },
        { name = "PLATFORM", value = "ECS" }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "orders_task" {
  family                   = "orders"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "orders"
      image     = "dsachsmusic/order-a-greeting-orders:latest"
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
        { name = "DB_USER", value = "postgres" },
        { name = "DB_PASSWORD", value = "postgres" },
        { name = "DB_PORT", value = "5432" },
        { name = "PLATFORM", value = "ECS" },
        { name = "FQDN_INVENTORY", value = "inventory"},
        { name = "PORT_INVENTORY", value = "80"},
        { name = "FQDN_ORDERS", value = "orders"},
        { name = "PORT_FLASK_EXPOSES", value = "5000"}
      ]
    }
  ])
}


