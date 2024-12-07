resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = file("${path.root}/deploy_app.sh")

  tags = {
    Name = "web-app-instance"
  }
}

resource "aws_lb_target_group_attachment" "web_app" {
  target_group_arn = var.alb_target_group
  target_id        = aws_instance.web.id
  port             = var.web_app_port 
}

resource "aws_lb" "alb" {
 name               = "alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.alb.id]

 subnets            = var.public_subnets
}

resource "aws_lb_listener" "my_alb_listener" {
 load_balancer_arn = aws_lb.alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = var.alb_target_group
 }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "web" {
  name_prefix = "web-sg"
  vpc_id      = var.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80 
    to_port     = 80 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "alb_to_web" {
  type              = "egress"
  from_port         = var.web_app_port
  to_port           = var.web_app_port
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  source_security_group_id = aws_security_group.web.id
}


resource "aws_security_group_rule" "web_from_alb" {
  type              = "ingress"
  from_port         = var.web_app_port
  to_port           = var.web_app_port
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
}
