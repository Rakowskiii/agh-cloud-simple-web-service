output "web_instances_ips" {
  value = module.web_app.web_instances_ips
}

output "bast_instance_ip" {
  value = module.bastion.bast_instance_ip
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

output "web_app_url" {
  value = module.web_app.alb_dns_name
}

output "ssh_private_key" {
  value     = tls_private_key.web_app_ssh_private_key.private_key_pem
  sensitive = true
}



