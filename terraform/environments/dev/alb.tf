resource "aws_lb" "main" {
  name               = "${var.environment}-main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true
}
