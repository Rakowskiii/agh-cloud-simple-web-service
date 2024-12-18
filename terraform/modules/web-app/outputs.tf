output "web_instances_ids" {
  value = aws_instance.web[*].id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "load_balancer" {
  value = aws_lb.alb
}

output "web_instances_ips" {
  value = {
    for instance in aws_instance.web :
    instance.id => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}
