resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.web_app_sg_id]
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
 security_groups    = [var.alb_sg_id]

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

