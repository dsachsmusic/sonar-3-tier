#NAT Gateway, Internet Gateway, and route tables?

# Internet Gateway ...so public subnet can access the internet
resource "aws_internet_gateway" "orderagreeting_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-orderagreeting-igw"
  }
}

# Elastic IP for a the NAT gateway
# Note - using only one NAT gateway/EIP...to save some money...not as fault tolerant, though
resource "aws_eip" "orderagreeting_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-orderagreeting-nat-eip"
  }
}

# NAT Gateway ... so machines running on private subnets can...
# reach out to Docker Hub, etc. on the internet (perhaps to S3)
# Note: using only one NAT gateway/EIP...to save some money...not as fault tolerant, though...
# ...all the outbound traffic goes through a single NAT gatway in a single AZ
resource "aws_nat_gateway" "orderagreeting_nat_gateway" {
  allocation_id = aws_eip.orderagreeting_nat_eip.id
  subnet_id     = var.public_subnet_ids[0]  # Use any public subnet

  tags = {
    Name = "${var.environment}-orderagreeting-nat-gateway"
  }
}

# Route Tables
# route table with default route traffic to the internet
#for...public subnet...through internet gateway
resource "aws_route_table" "orderagreeting_public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.orderagreeting_igw.id
  }

  tags = {
    Name = "${var.environment}-orderagreeting-public-rt"
  }
}

resource "aws_route_table_association" "orderagreeting_public_subnet_association" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(var.public_subnet_ids.*, count.index)
  route_table_id = aws_route_table.orderagreeting_public_route_table.id
}

# route table with default route traffic to the internet
#for...public subnet...through internet gateway
resource "aws_route_table" "orderagreeting_private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.orderagreeting_nat_gateway.id
  }

  tags = {
    Name = "${var.environment}-orderagreeting-private-rt"
  }
}

resource "aws_route_table_association" "orderagreeting_private_subnet_association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = element(var.private_subnet_ids.*, count.index)
  route_table_id = aws_route_table.orderagreeting_private_route_table.id
}

#Security groups
resource "aws_security_group" "orderagreeting_frontend_lb_sg" {
  name        = "${var.environment}-orderagreeting-frontend-lb-sg"
  description = "Allow inbound traffic to the load balancer"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound HTTP traffic from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic to frontend service"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #shortcut, instead of security groups, to avoid cyclical dependencies
    #security_groups = [aws_security_group.orderagreeting_frontend_sg.id]
  }
}

resource "aws_security_group" "orderagreeting_frontend_sg" {
  name        = "${var.environment}-orderagreeting-frontend-sg"
  description = "Frontend service security group"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from the load balancer to the host port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #shortcut, instead of security groups, to avoid cyclical dependencies
    #security_groups = [aws_security_group.orderagreeting_frontend_lb_sg.id]
  }

  egress {
    description = "Allow outbound traffic to port inventory service"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    security_groups = [
      aws_security_group.orderagreeting_inventory_sg.id
    ]
  }

  egress {
    description = "Allow outbound traffic to orders service"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    security_groups = [
      aws_security_group.orderagreeting_orders_sg.id,
    ]
  }
}

resource "aws_security_group" "orderagreeting_orders_sg" {
  name        = "${var.environment}-orderagreeting-orders-sg"
  description = "Orders service security group"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from frontend service"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #shortcut, instead of security groups, to avoid cyclical dependencies
    /*security_groups = [aws_security_group.orderagreeting_frontend_sg.id]*/
  }

  egress {
    description = "Allow outbound traffic to Aurora database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust to Aurora's security group
  }
}

resource "aws_security_group" "orderagreeting_inventory_sg" {
  name        = "${var.environment}-orderagreeting-inventory-sg"
  description = "Inventory service security group"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from frontend and orders services"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #shortcut, instead of security groups, to avoid cyclical dependencies
    /*
    security_groups = [
      aws_security_group.orderagreeting_frontend_sg.id,
      aws_security_group.orderagreeting_orders.sg.id
    ]
    */
  }

  egress {
    description = "Allow outbound traffic to Aurora database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust to Aurora's security group if necessary
  }
}

resource "aws_security_group" "orderagreeting_aurora_sg" {
  name        = "${var.environment}-orderagreeting-aurora-sg"
  description = "Aurora DB security group"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic from orders and inventory services"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"] #shortcut, instead of security groups, to avoid cyclical dependencies
    /*security_groups = [
      aws_security_group.orderagreeting_orders_sg.id,
      aws_security_group.orderagreeting_inventory_sg.id
    ]
    */
  }
}

# Security Group for Service Discovery
resource "aws_security_group" "orderagreeting_service_discovery_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    description = "Allow DNS traffic for service discovery"
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    description = "Allow DNS traffic for service discovery"
  }
  
  #this egress rule might need to be locked down
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-service-discovery-sg"
  }
}

# DB Subnet Group (for Aurora)
resource "aws_db_subnet_group" "orderagreeting_db_subnet_group" {
  name       = "${var.environment}-orderagreeting-db-subnet-group"
  subnet_ids = var.private_subnet_ids.*

  tags = {
    Name = "${var.environment}-orderagreeting-db-subnet-group"
  }
}