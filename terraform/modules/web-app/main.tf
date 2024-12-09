resource "aws_instance" "web" {
  count                       = length(var.private_subnets_ids)
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type               = "t2.micro"
  subnet_id                   = element(var.private_subnets_ids, count.index)
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.web_app_sg_id]
  user_data                   = data.template_file.init.rendered
  user_data_replace_on_change = true
  iam_instance_profile        = "LabInstanceProfile"


  depends_on = [
    var.db_pass_secret
  ]

  tags = {
    Name = "web-app-instance-${count.index}"
  }
}

data "template_file" "init" {
  template = file("${path.root}/deploy_app.sh.tpl")

  vars = {
    db_name   = var.db_name
    region    = var.aws_region
    secret_id = var.db_pass_secret
    db_user   = var.db_user
    db_addr   = var.db_addr
  }
}

resource "aws_lb" "alb" {
  name               = "alb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]

  subnets = var.public_subnets_ids
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