resource "aws_lb" "orderagreeting_frontend_load_balancer" {
  name               = "${var.environment}-orderagreeting-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.frontend_lb_sg_id]
  subnets            = var.public_subnet_ids.*

  enable_deletion_protection = false
  idle_timeout              = 60
  enable_cross_zone_load_balancing = true #ensures traffic is distributed evenly  AZs.
}

resource "aws_lb_target_group" "orderagreeting_frontend_lb_tg" {
  name     = "${var.environment}-orderagreeting-fe-lb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  target_type = "ip"

  health_check {
    path                = "/" 
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}


#port and protocol you want to expose to clients
resource "aws_lb_listener" "orderagreeting_frontend_lb_listener" { 
  load_balancer_arn = aws_lb.orderagreeting_frontend_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.orderagreeting_frontend_lb_tg.arn
      }
    }
  }
}

