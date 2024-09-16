resource "aws_ecs_cluster" "orderagreeting_public_cluster" {
  name = "${var.environment}-orderagreeting-public-cluster"
}

resource "aws_launch_configuration" "orderagreeting_public_launch_configuration" {
  name          = "${var.environment}-orderagreeting-public-lc"
  image_id      = var.ami
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.orderagreeting_ecs_instance_profile.name


  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.orderagreeting_public_cluster.name} >> /etc/ecs/ecs.config
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "orderagreeting_public_autoscaling_group" {
  launch_configuration  = aws_launch_configuration.orderagreeting_public_launch_configuration.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 3


  vpc_zone_identifier = [
    aws_subnet.orderagreeting_public_subnet[0].id,
    aws_subnet.orderagreeting_public_subnet[1].id,
    aws_subnet.orderagreeting_public_subnet[2].id
  ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-orderagreeting-public-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "orderagreeting_private_cluster" {
  name = "${var.environment}-orderagreeting-private-cluster"
}

resource "aws_launch_configuration" "orderagreeting_private_launch_configuration" {
  name          = "${var.environment}-orderagreeting-private-lc"
  image_id      = var.ami
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.orderagreeting_ecs_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.orderagreeting_private_cluster.name} >> /etc/ecs/ecs.config
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "orderagreeting_private_autoscaling_group" {
  launch_configuration  = aws_launch_configuration.orderagreeting_private_launch_configuration.id
  min_size             = 2
  max_size             = 4
  desired_capacity     = 3

  vpc_zone_identifier = [
    aws_subnet.orderagreeting_private_subnet[0].id,
    aws_subnet.orderagreeting_private_subnet[1].id,
    aws_subnet.orderagreeting_private_subnet[2].id
  ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-orderagreeting-private-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "orderagreeting_frontend_task" {
  family                   = "${var.environment}-frontend-task"
  network_mode             = "bridge" #tasks are assigned private IPs from the subnet they’re in.
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.orderagreeting_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.orderagreeting_ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "dsachsmusic/order-a-greeting-frontend:latest"
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
        { name = "PLATFORM", value = "ECS" },
        { name = "FQDN_INVENTORY", value = "inventory.orderagreeting.svc.cluster.local" },
        { name = "PORT_INVENTORY", value = "5001"},
        { name = "FQDN_ORDERS", value = "orders.orderagreeting.svc.cluster.local"},
        { name = "PORT_ORDERS", value = "5002"},
        { name = "FQDN_FRONTEND_EXTERNAL", value = "need_alb_dns_name"},
        { name = "PORT_FRONTEND_EXTERNAL", value = "80"},
        { name = "PORT_FLASK_FRONTEND", value = "5000"}
      ]
    }
  ])
}

#ECS task definitions
resource "aws_ecs_task_definition" "orderagreeting_inventory_task" {
  family                   = "${var.environment}-inventory-task"
  network_mode             = "bridge" #tasks are assigned private IPs from the subnet they’re in.
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.orderagreeting_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.orderagreeting_ecs_task_role.arn

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
          hostPort      = 5001
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

resource "aws_ecs_task_definition" "orderagreeting_orders_task" {
  family                   = "${var.environment}-orders-task"
  network_mode             = "bridge" #tasks are assigned private IPs from the subnet they’re in.
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.orderagreeting_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.orderagreeting_ecs_task_role.arn

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
          hostPort      = 5002
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_rds_cluster.orders_db.endpoint },
        { name = "DB_NAME", value = aws_rds_cluster.orders_db.database_name },
        { name = "DB_USER", value = "postgres" },
        { name = "DB_PASSWORD", value = "postgres" },
        { name = "DB_PORT", value = "5432" },
        { name = "PLATFORM", value = "ECS" },
        { name = "FQDN_INVENTORY", value = "inventory.orderagreeting.svc.cluster.local"},
        { name = "PORT_INVENTORY", value = "5001"},
        { name = "PORT_FLASK_ORDERS", value = "5000"}
      ]
    }
  ])
}

resource "aws_ecs_service" "orderagreeting_frontend_service" {
  name            = "${var.environment}-frontend-service"
  cluster         = aws_ecs_cluster.orderagreeting_public_cluster.id
  task_definition = aws_ecs_task_definition.orderagreeting_frontend_task.arn
  desired_count   = 2  # Adjust based on your needs

  network_configuration {
    subnets          = aws_subnet.orderagreeting_public_subnet[*].id
    security_groups  = [aws_security_group.orderaservice_frontend_sg.id, aws_security_group.service_discovery_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.orderagreeting_frontend_service.arn
  }
  
  launch_type = "EC2"

  depends_on = [
    aws_iam_role_policy_attachment.ecs_service_policy
  ]
}

resource "aws_ecs_service" "orderagreeting_inventory_service" {
  name            = "${var.environment}-inventory-service"
  cluster         = aws_ecs_cluster.orderagreeting_private_cluster.id
  task_definition = aws_ecs_task_definition.orderagreeting_inventory_task.arn
  desired_count   = 2  # Adjust based on your needs

  network_configuration {
    subnets          = aws_subnet.orderagreeting_private_subnet[*].id
    security_groups  = [aws_security_group.orderagreeting_inventory_sg.id, aws_security_group.service_discovery_sg.id]
    assign_public_ip = true
  }

    service_registries {
    registry_arn = aws_service_discovery_service.orderagreeting_inventory_service.arn
  }

  launch_type = "EC2"

  depends_on = [
    aws_iam_role_policy_attachment.ecs_service_policy
  ]
}

resource "aws_ecs_service" "orderagreeting_orders_service" {
  name            = "${var.environment}-orders-service"
  cluster         = aws_ecs_cluster.orderagreeting_private_cluster.id
  task_definition = aws_ecs_task_definition.orderagreeting_orders_task.arn
  desired_count   = 2  # Adjust based on your needs

  network_configuration {
    subnets          = aws_subnet.orderagreeting_private_subnet[*].id
    security_groups  = [aws_security_group.orderagreeting_orders_sg.id, aws_security_group.service_discovery_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.orderagreeting_orders_service.arn
  }

  launch_type = "EC2"

  depends_on = [
    aws_iam_role_policy_attachment.ecs_service_policy
  ]
}

# Cloud Map Namespace
resource "aws_service_discovery_private_dns_namespace" "orderagreeting_namespace" {
  name        = "${var.environment}-orderagreeting-namespace"
  vpc         = aws_vpc.orderagreeting_vpc.id
  description  = "Namespace for orderagreeting services"

  tags = {
    Name = "${var.environment}-orderagreeting-namespace"
  }
}

# Cloud Map Service for Frontend
resource "aws_service_discovery_service" "orderagreeting_frontend_service" {
  name = "${var.environment}-frontend-service"
  namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  tags = {
    Name = "${var.environment}-frontend-service"
  }
}

# Cloud Map Service for Inventory
resource "aws_service_discovery_service" "orderagreeting_inventory_service" {
  name = "${var.environment}-inventory-service"
  namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  tags = {
    Name = "${var.environment}-inventory-service"
  }
}

# Cloud Map Service for Orders
resource "aws_service_discovery_service" "orderagreeting_orders_service" {
  name = "${var.environment}-orders-service"
  namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.orderagreeting_namespace.id
    routing_policy = "MULTIVALUE"
    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  tags = {
    Name = "${var.environment}-orders-service"
  }
}

