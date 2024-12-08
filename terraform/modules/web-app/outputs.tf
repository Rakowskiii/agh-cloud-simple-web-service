output "web_instance_id" {
  value = aws_instance.web.id
}

output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}
