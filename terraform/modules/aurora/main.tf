#Aurora's default setting should already span multiple AZs,
#but ensure subnets are set accordingly.

# Terraform configuration block - because postgres provider needs
# to be declared in subfolders...
#https://stackoverflow.com/questions/69190343/terraform-problem-to-define-cyrilgdn-postgresql-provider-properly
terraform {

  #postgres provider 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.23"  # Correct version of the postgresql provider
    }
  }

  required_version = ">= 1.0.0"
}
provider "postgresql" {
  alias    = "inventory"
  host     = aws_rds_cluster_instance.inventory_instance.endpoint
  port     = 5432
  username = "postgres"
  password = "postgres"
  database = "inventory"
  sslmode  = "disable" # If you are not using SSL
}

provider "postgresql" {
  alias    = "orders"
  host     = aws_rds_cluster_instance.orders_instance.endpoint
  port     = 5432
  username = "postgres"
  password = "postgres"
  database = "orders"
  sslmode  = "disable" # If you are not using SSL
}

resource "aws_rds_cluster" "inventory_db" {
  cluster_identifier      = "${var.environment}-inventory-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = "inventory"
  master_username         = "postgres"
  master_password         = "postgres"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.aurora_sg_id]
}

resource "aws_rds_cluster_instance" "inventory_instance" {
  cluster_identifier = aws_rds_cluster.inventory_db.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.inventory_db.engine
}

resource "aws_rds_cluster" "orders_db" {
  cluster_identifier      = "${var.environment}-orders-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = "orders"
  master_username         = "postgres"
  master_password         = "postgres"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [var.aurora_sg_id]
}

resource "aws_rds_cluster_instance" "orders_instance" {
  cluster_identifier = aws_rds_cluster.orders_db.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.orders_db.engine
}

/*#define the tables 
resource "postgresql_schema" "inventory_schema" {
  provider = postgresql.inventory
  name = "public"
}

resource "postgresql_table" "inventory_table" {
  provider = postgresql.inventory
  name   = "inventory"
  schema = postgresql_schema.inventory_schema.name

  owner = "admin"

  columns = [
    {
      name = "item"
      type = "text"
    },
    {
      name = "count"
      type = "integer"
    }
  ]
}

resource "postgresql_schema" "orders_schema" {
  provider = postgresql.orders
  name = "public"
}

resource "postgresql_table" "orders_table" {
  provider = postgresql.orders
  name     = "orders"
  schema   = postgresql_schema.orders_schema.name

  owner = "admin"

  columns = [
    {
      name    = "time"
      type    = "timestamp"
      default = "CURRENT_TIMESTAMP"
    },
    {
      name    = "item"
      type    = "text"
    }
  ]
}
*/
