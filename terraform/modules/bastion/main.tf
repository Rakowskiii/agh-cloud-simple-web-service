
# resource "aws_instance" "bast" {
#   count      = length(var.public_subnets_ids)
#   ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
#   instance_type = "t2.micro"
#   subnet_id     = element(var.public_subnets_ids, count.index) 
#   key_name      = var.ssh_key_name
#   vpc_security_group_ids = [var.bast_sg_id]

#   tags = {
#     Name = "bast-instance-${count.index}"
#   }
# }


resource "aws_instance" "bast" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = element(var.public_subnets_ids, 0) 
  key_name      = var.ssh_key_name
  vpc_security_group_ids = [var.bast_sg_id]

  tags = {
    Name = "bast-instance"
  }
}
