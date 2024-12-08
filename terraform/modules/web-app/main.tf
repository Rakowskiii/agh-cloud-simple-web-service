resource "aws_instance" "web" {
  count      = length(var.public_subnets_ids)
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = element(var.public_subnets_ids, count.index) 
  key_name      = var.ssh_key_name
  vpc_security_group_ids = [var.web_app_sg_id]
  user_data = file("${path.root}/deploy_app.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "web-app-instance-${count.index}"
  }
}

resource "aws_lb" "alb" {
 name               = "alb-${terraform.workspace}"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [var.alb_sg_id]

 subnets            = var.public_subnets_ids
}

resource "aws_lb_target_group" "web_app" {
  name     = "web-app-target-group-${terraform.workspace}"
  port     = var.web_app_port 
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_lb_target_group_attachment" "web_app" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.web_app.arn 
  target_id        = aws_instance.web[count.index].id
  port             = var.web_app_port 
}

resource "aws_lb_listener" "my_alb_listener" {
 load_balancer_arn = aws_lb.alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.web_app.arn 
 }
}


resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets-manager-policy"
  description = "Policy to allow access to AWS Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          var.db_pass_secret.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}