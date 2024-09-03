#Aurora's default setting should already span multiple AZs,
#but ensure subnets are set accordingly.
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "multi-az-cluster"
  engine = "aurora-mysql"
  availability_zones = var.availability_zones
}