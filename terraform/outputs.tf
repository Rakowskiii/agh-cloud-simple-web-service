output "vpc_id" {
  value = module.networking.vpc_id
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

output "web_app_url" {
  value = module.web_app.alb_dns_name
}