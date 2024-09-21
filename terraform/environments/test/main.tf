module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  cidr_block           = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "s3" {
  source = "../../modules/s3"
  environment = var.environment
  # S3-specific variables
}

module "networking" {
  vpc_id = module.vpc.orderagreeting_vpc_id
  source = "../../modules/networking"
  environment           = var.environment
  public_subnet_ids     = module.vpc.orderagreeting_public_subnet_ids
  private_subnet_ids    = module.vpc.orderagreeting_private_subnet_ids
  # Networking-specific variables
}

module "iam" {
  source = "../../modules/iam"
  environment                = var.environment
  general_purpose_bucket_arn = module.s3.orderagreeting_general_purpose_bucket_arn
  # IAM-specific variables
}

module "alb" {
  source               = "../../modules/alb"
  environment          = var.environment
  vpc_id               = module.vpc.orderagreeting_vpc_id
  frontend_lb_sg_id    = module.networking.orderagreeting_frontend_lb_sg_id
  db_subnet_group_name = module.networking.orderagreeting_db_subnet_group_name
  public_subnet_ids    = module.vpc.orderagreeting_public_subnet_ids
  # ALB-specific variables
}
 #### careful - this will cost a lot - specifically:
 #"RDS db.r5.large Single-AZ instance hour (or partial hour) running Aurora PostgreSQL"
 # uncomment to create anyway
/*module "aurora" {
  source = "../../modules/aurora"
  environment                 = var.environment
  instance_class              = var.aurora_instance_class
  db_subnet_group_name        = module.networking.orderagreeting_db_subnet_group_name
  aurora_sg_id                = module.networking.orderagreeting_aurora_sg_id
}
*/
module "ecs" {
  source = "../../modules/ecs"
  orderagreeting_vpc_id              = module.vpc.orderagreeting_vpc_id
  environment                        = var.environment
  instance_type                      = var.ecs_ec2_instance_type
  ami                                = var.ecs_ec2_ami
  iam_instance_profile_name          = module.iam.orderagreeting_ecs_instance_profile_name
  ecs_task_execution_role_arn        = module.iam.orderagreeting_ecs_task_execution_role_arn
  ecs_task_role_arn                  = module.iam.orderagreeting_ecs_task_role_arn
  inventory_db_endpoint              = module.aurora.inventory_db_endpoint
  orders_db_endpoint                 = module.aurora.orders_db_endpoint
  inventory_db_name                  = module.aurora.inventory_db_name
  orders_db_name                     = module.aurora.orders_db_name
  public_subnet_ids                  = module.vpc.orderagreeting_public_subnet_ids
  private_subnet_ids                 = module.vpc.orderagreeting_private_subnet_ids
  frontend_sg_id                     = module.networking.orderagreeting_frontend_sg_id
  inventory_sg_id                    = module.networking.orderagreeting_inventory_sg_id
  orders_sg_id                       = module.networking.orderagreeting_orders_sg_id
  service_discovery_sg_id            = module.networking.orderagreeting_service_discovery_sg_id
  ecs_service_policy_attachment_id   = module.iam.orderagreeting_ecs_service_policy_attachment_id
  frontend_load_balancer_dnsname     = module.alb.orderagreeting_frontend_load_balancer_dnsname
  lb_target_group_arn                = module.alb.orderagreeting_frontend_lb_target_group_arn
  # ECS-specific variables
}