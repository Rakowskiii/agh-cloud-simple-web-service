variable "db_name" {}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the database"
  default     = ["10.0.1.0/24"]
}

variable "db_sg_id" {}

variable "db_user" {
  default = "dbuser"
}