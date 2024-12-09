output "bast_instance_id" {
  value = aws_instance.bast.id
}

output "bast_instance_ip" {
  value = {
      public_ip  = aws_instance.bast.public_ip
      private_ip = aws_instance.bast.private_ip
  }
}