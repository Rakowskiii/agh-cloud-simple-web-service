resource "aws_db_instance" "main" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  username               = var.db_user
  password               = random_password.db_password.result
  db_name                = var.db_name

  skip_final_snapshot = true

  tags = {
    Name = "web-app-db"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!@#%^&*()-_=+[]{}<>?"
}

resource "aws_secretsmanager_secret" "db_secret" {
  recovery_window_in_days = 0
  name                    = "db-credentials-${terraform.workspace}"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_user
    password = random_password.db_password.result
    host     = aws_db_instance.main.address
  })
}


resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group-${terraform.workspace}"
  subnet_ids = var.private_subnets

  tags = {
    Name = "db-subnet-group"
  }
}


resource "aws_secretsmanager_secret_rotation" "db_secret_rotation" {
  secret_id           = aws_secretsmanager_secret.db_secret.id
  rotation_lambda_arn = aws_lambda_function.rotation_lambda.arn
  rotation_rules {
    automatically_after_days = 1
  }
}

resource "aws_lambda_function" "rotation_lambda" {
  filename         = "lambda_rotation.zip"  
  function_name    = "SecretRotationFunction-${terraform.workspace}"
  role             = "arn:aws:iam::313167975375:role/LabRole" 
  handler          = "rotation.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda_rotation.zip")

  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.db_secret.arn
    }
  }
}

resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}