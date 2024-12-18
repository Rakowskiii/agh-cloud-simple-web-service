output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_pass_secret" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "db_addr" {
  value = aws_db_instance.main.address
}

output "rds" {
  value = aws_db_instance.main
}