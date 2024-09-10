#Aurora's default setting should already span multiple AZs,
#but ensure subnets are set accordingly.
resource "aws_rds_cluster" "inventory_db" {
  cluster_identifier      = "inventory-world-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "13.4"
  database_name           = "inventory_world"
  master_username         = "postgres"
  master_password         = "postgres"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "inventory_instance" {
  cluster_identifier = aws_rds_cluster.inventory_db.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.inventory_db.engine
}

resource "aws_rds_cluster" "orders_db" {
  cluster_identifier      = "orders-world-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "13.4"
  database_name           = "orders_world"
  master_username         = "postgres"
  master_password         = "postgres"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "orders_instance" {
  cluster_identifier = aws_rds_cluster.orders_db.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.orders_db.engine
}

#define the tables 
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
  provider = postgresql
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

