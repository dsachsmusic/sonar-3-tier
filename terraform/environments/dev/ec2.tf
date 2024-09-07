resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  tags = {
    Name = "${var.environment}-webserver-instance"
  }
}