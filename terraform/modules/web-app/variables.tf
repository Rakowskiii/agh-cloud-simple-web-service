variable "vpc_id" {}
variable "public_subnets_ids" {}
variable "web_app_port" {
  description = "Port used by web app"
  default     = "8080"
}

variable "web_app_sg_id" {}

variable "alb_sg_id" {}

variable "ssh_key_name" {}

variable "db_pass_secret" {}
variable "aws_region" {}
variable "db_name" {}