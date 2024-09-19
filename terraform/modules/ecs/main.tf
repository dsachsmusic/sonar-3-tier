

  resource "aws_ecs_cluster" "orderagreeting_public_cluster" {
    name = "${var.environment}-orderagreeting-public-cluster"
  }

  resource "aws_launch_configuration" "orderagreeting_public_launch_configuration" {
    name          = "${var.environment}-orderagreeting-public-lc"
    image_id      = var.ami
    instance_type = var.instance_type
    iam_instance_profile = var.iam_instance_profile_name


    user_data = <<-EOF
                #!/bin/bash
                echo ECS_CLUSTER=${aws_ecs_cluster.orderagreeting_public_cluster.name} >> /etc/ecs/ecs.config
                EOF

    lifecycle {
      create_before_destroy = true
    }
  }
  
  
  /*resource "aws_launch_configuration" "orderagreeting_public_launch_configuration2" {
    name          = "${var.environment}-orderagreeting-public-lc2"
    image_id      = var.ami
    instance_type = var.instance_type
    iam_instance_profile = var.iam_instance_profile_name
    associate_public_ip_address = true
    


    user_data = <<-EOF
                #!/bin/bash
                echo ECS_CLUSTER=${aws_ecs_cluster.orderagreeting_public_cluster.name} >> /etc/ecs/ecs.config
                EOF

    lifecycle {
      create_before_destroy = true
    }
  }
*/
  resource "aws_autoscaling_group" "orderagreeting_public_autoscaling_group" {
    launch_configuration  = aws_launch_configuration.orderagreeting_public_launch_configuration.id
    min_size             = 2
    max_size             = 4
    desired_capacity     = 3


    vpc_zone_identifier = [
      var.public_subnet_ids[0],
      var.public_subnet_ids[1],
      var.public_subnet_ids[2]
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
    iam_instance_profile = var.iam_instance_profile_name

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
      var.private_subnet_ids[0],
      var.private_subnet_ids[1],
      var.private_subnet_ids[2]
    ]

    tag {
      key                 = "Name"
      value               = "${var.environment}-orderagreeting-private-ecs-instance"
      propagate_at_launch = true
    }
  }

  resource "aws_ecs_task_definition" "orderagreeting_frontend_task" {
    family                   = "${var.environment}-frontend-task"
    network_mode             = "awsvpc"
    requires_compatibilities = ["EC2"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = var.ecs_task_execution_role_arn
    task_role_arn            = var.ecs_task_role_arn

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
          { name = "DB_HOST", value = var.inventory_db_endpoint },
          { name = "DB_NAME", value = var.orders_db_endpoint },
          { name = "DB_USER", value = "postgres" },
          { name = "DB_PASSWORD", value = "postgres" },
          { name = "DB_PORT", value = "5432" },
          { name = "PLATFORM", value = "ECS" },
          { name = "FQDN_INVENTORY", value = "inventory.orderagreeting.svc.cluster.local" },
          { name = "PORT_INVENTORY", value = "5001"},
          { name = "FQDN_ORDERS", value = "orders.orderagreeting.svc.cluster.local"},
          { name = "PORT_ORDERS", value = "5002"},
          { name = "FQDN_FRONTEND_EXTERNAL", value = var.frontend_load_balancer_dnsname}, 
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
    execution_role_arn       = var.ecs_task_execution_role_arn
    task_role_arn            = var.ecs_task_role_arn

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
          { name = "DB_HOST", value = var.inventory_db_endpoint },
          { name = "DB_NAME", value = var.orders_db_name },
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
    execution_role_arn       = var.ecs_task_execution_role_arn
    task_role_arn            = var.ecs_task_role_arn

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
          { name = "DB_HOST", value = var.orders_db_endpoint },
          { name = "DB_NAME", value = var.orders_db_name },
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
    
    #don't need network configuration for bridge mode
    network_configuration {
      subnets          = var.public_subnet_ids.*
      security_groups  = [var.frontend_sg_id, var.service_discovery_sg_id]
    }
    
    load_balancer {
      target_group_arn = var.lb_target_group_arn
      container_name   = "frontend"
      container_port   = 5000
    }

    service_registries {
      registry_arn = aws_service_discovery_service.orderagreeting_frontend_service.arn
      container_port = "5000" 
      container_name = "frontend"
    }
    
    launch_type = "EC2"

    depends_on = [
      var.ecs_service_policy_attachment_id
    ]
  }

  resource "aws_ecs_service" "orderagreeting_inventory_service" {
    name            = "${var.environment}-inventory-service"
    cluster         = aws_ecs_cluster.orderagreeting_private_cluster.id
    task_definition = aws_ecs_task_definition.orderagreeting_inventory_task.arn
    desired_count   = 2  # Adjust based on your needs

  #don't need for bridge mode
  #network_configuration {
  #  subnets          = var.private_subnet_ids.*
  #  security_groups  = [var.inventory_sg_id, var.service_discovery_sg_id]
  #}

      service_registries {
        registry_arn = aws_service_discovery_service.orderagreeting_inventory_service.arn
        container_port = "5000" 
        container_name = "inventory"
    }

    launch_type = "EC2"

    depends_on = [
      var.ecs_service_policy_attachment_id
    ]
  }

  resource "aws_ecs_service" "orderagreeting_orders_service" {
    name            = "${var.environment}-orders-service"
    cluster         = aws_ecs_cluster.orderagreeting_private_cluster.id
    task_definition = aws_ecs_task_definition.orderagreeting_orders_task.arn
    desired_count   = 2  # Adjust based on your needs
    
    #don't need for bridge mode
    #network_configuration {
    #  subnets          = var.private_subnet_ids.*
    #  security_groups  = [var.orders_sg_id, var.service_discovery_sg_id]
    #}

    service_registries {
      registry_arn = aws_service_discovery_service.orderagreeting_orders_service.arn
      container_port = "5000" 
      container_name = "orders"
    }

    launch_type = "EC2"

    depends_on = [
      var.ecs_service_policy_attachment_id
    ]
  }

  # Cloud Map Namespace
  resource "aws_service_discovery_private_dns_namespace" "orderagreeting_namespace" {
    name        = "${var.environment}-orderagreeting-namespace"
    vpc         = var.orderagreeting_vpc_id
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
        type = "SRV"
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
        type = "SRV"
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
        type = "SRV"
        ttl  = 60
      }
    }

    tags = {
      Name = "${var.environment}-orders-service"
    }
  }

