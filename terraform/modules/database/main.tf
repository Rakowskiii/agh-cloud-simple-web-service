resource "aws_db_instance" "main" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  username = var.db_user
  password = random_password.db_password.result  

  skip_final_snapshot = true

  tags = {
    Name = "web-app-db"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_user 
    password = random_password.db_password.result
    host     = aws_db_instance.main.address
  })
}


//TODO: why main
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group-${terraform.workspace}"
  subnet_ids = var.private_subnets

  tags = {
    Name = "db-subnet-group"
  }
}

