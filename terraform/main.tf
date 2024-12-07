provider "aws" {
  region = var.aws_region
}


module "networking" {
  source           = "./modules/networking"
  vpc_cidr_block   = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  vpc_id           = module.networking.vpc_id
  availability_zones  = var.availability_zones
}


module "database" {
  source           = "./modules/database"
  vpc_id           = module.networking.vpc_id
  db_name          = var.db_name
  private_subnets  = module.networking.private_subnets
}


module "web_app" {
  source           = "./modules/web-app"
  public_subnets   = module.networking.public_subnets
  vpc_id           = module.networking.vpc_id
  alb_target_group = module.networking.alb_target_group_arn 
  web_app_port     = var.web_app_port
}