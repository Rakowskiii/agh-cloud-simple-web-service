output "vpc_id" {
  value = module.networking.vpc_id
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

output "web_app_url" {
  value = module.web_app.alb_dns_name
}

output "ssh_pubkey" {
  value = tls_private_key.web_app_ssh_private_key.private_key_pem
  sensitive = true
}