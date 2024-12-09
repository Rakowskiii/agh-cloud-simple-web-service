output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_pass_secret" {
 value = aws_secretsmanager_secret.db_secret
}

output "rds" {
  value = aws_db_instance.main
}