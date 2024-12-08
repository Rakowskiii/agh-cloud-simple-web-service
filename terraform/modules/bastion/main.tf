resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]
  key_name      = var.ssh_key_name
  vpc_security_group_ids = [var.bastion_sg_id]

  tags = {
    Name = "bastion-instance"
  }
}



