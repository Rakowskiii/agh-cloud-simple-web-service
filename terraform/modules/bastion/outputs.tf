output "bast_instance_ids" {
  value = aws_instance.bast[*].id
}

output "bast_instances_ips" {
  value = {
    for instance in aws_instance.bast :
    instance.id => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}