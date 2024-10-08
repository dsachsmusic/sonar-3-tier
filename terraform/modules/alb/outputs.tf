output "orderagreeting_frontend_lb_target_group_arn" {
  value = aws_lb_target_group.orderagreeting_frontend_lb_tg.arn
  description = "The ARN of the frontend load balancer target group."
}

output "orderagreeting_frontend_load_balancer_dnsname" {
  value = aws_lb.orderagreeting_frontend_load_balancer.dns_name
  description = "The ARN of the frontend load balancer."
}
