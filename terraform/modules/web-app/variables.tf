variable "vpc_id" {}
variable "public_subnets" {}
variable "web_app_port" {
  description = "Port used by web app"
  default = "8080"
}

variable "web_app_sg_id" {}

variable "alb_sg_id" {}