resource "aws_lb" "orderagreeting_frontend_load_balancer" {
  name               = "${var.environment}-orderagreeting-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.orderagreeting_frontend_lb_sg.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
  idle_timeout              = 60
  enable_cross_zone_load_balancing = true #ensures traffic is distributed evenly  AZs.
}

resource "aws_lb_target_group" "orderagreeting_frontend_lb_target_group" {
  name     = "${var.environment}-orderagreeting-frontend-lb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.orderagreeting_vpc.id

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
  load_balancer_arn = aws_lb.orderagreeting_frontend_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.orderagreeting_frontend_lb_target_group.arn
      }
    }
  }
}

