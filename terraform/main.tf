provider "aws" {
  region = var.aws_region
}


module "security_groups" {
  source = "./modules/security-groups"
  web_app_port     = var.web_app_port
  vpc_id           = module.networking.vpc_id
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
  db_sg_id    = module.security_groups.db_sg_id
}


resource "tls_private_key" "web_app_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_app_ssh_keypair" {
  key_name   = "web-app-ssh-keypair-${terraform.workspace}"
  public_key = tls_private_key.web_app_ssh_private_key.public_key_openssh
}

module "web_app" {
  source           = "./modules/web-app"
  public_subnets_ids   = module.networking.public_subnets
  vpc_id           = module.networking.vpc_id
  web_app_port     = var.web_app_port
  web_app_sg_id    = module.security_groups.web_app_sg_id
  alb_sg_id    = module.security_groups.alb_sg_id
  ssh_key_name     = aws_key_pair.web_app_ssh_keypair.key_name
}