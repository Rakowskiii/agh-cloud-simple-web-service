variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_id" {}