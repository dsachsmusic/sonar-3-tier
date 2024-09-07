#NAT Gateway, Internet Gateway, and route tables?

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = var.public_subnet_id
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  subnet_id = var.public_subnet_id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id = var.private_subnet_id
  route_table_id = aws_route_table.private.id
}
