resource "aws_db_instance" "main" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]

  manage_master_user_password = true

  username               = var.db_user
  db_name                = var.db_name

  skip_final_snapshot = true

  tags = {
    Name = "web-app-db"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group-${terraform.workspace}"
  subnet_ids = var.private_subnets

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_secretsmanager_secret_rotation" "example" {
  secret_id = aws_db_instance.main.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}


# resource "aws_secretsmanager_secret_rotation" "db_secret_rotation" {
#   secret_id           = aws_db_instance.main.master_user_secret[0].secret_arn
#   rotation_lambda_arn = aws_lambda_function.rotation_lambda.arn
#   rotation_rules {
#     automatically_after_days = 1
#   }
# }

# resource "aws_lambda_function" "rotation_lambda" {
#   filename         = "lambda_rotation.zip"  
#   function_name    = "SecretRotationFunction-${terraform.workspace}"
#   role             = "arn:aws:iam::313167975375:role/LabRole" 
#   handler          = "rotation.lambda_handler"
#   runtime          = "python3.8"
#   source_code_hash = filebase64sha256("lambda_rotation.zip")

#   environment {
#     variables = {
#       SECRET_ARN = aws_db_instance.main.master_user_secret[0].secret_arn
#     }
#   }
# }


