resource "aws_vpc" "orderagreeting_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "orderagreeting_public_subnet" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.orderagreeting_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "orderagreeting_private_subnet" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.orderagreeting_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
  }
}

