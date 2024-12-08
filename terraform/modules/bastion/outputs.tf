# output "bast_instance_ids" {
#   value = aws_instance.bast[*].id
# }

# output "bast_instances_ips" {
#   value = {
#     for instance in aws_instance.bast :
#     instance.id => {
#       public_ip  = instance.public_ip
#       private_ip = instance.private_ip
#     }
#   }
# }


output "bast_instance_id" {
  value = aws_instance.bast.id
}

output "bast_instance_ip" {
  value = {
      public_ip  = aws_instance.bast.public_ip
      private_ip = aws_instance.bast.private_ip
  }
}