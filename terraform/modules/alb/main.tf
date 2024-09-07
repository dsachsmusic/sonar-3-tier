/*Module for the load balancer to distribute traffic across multiple
AZs.
*/
resource "aws_lb" "main" {
  name = "multi-az-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.main.id]
  subnets = var.subnets
}