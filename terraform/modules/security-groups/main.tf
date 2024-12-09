// WEB Security Group
resource "aws_security_group" "web" {
  name_prefix = "web-sg"
  vpc_id      = var.vpc_id
}


resource "aws_security_group_rule" "web_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  from_port                = var.web_app_port
  to_port                  = var.web_app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "web_to_db" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.db.id
}

// ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_web" {
  type                     = "egress"
  from_port                = var.web_app_port
  to_port                  = var.web_app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.web.id
}




// DB Security Group
resource "aws_security_group" "db" {
  name_prefix = "db-sg"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "db_from_webapp" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
}


// Bastion Security Group

resource "aws_security_group" "bast" {
  name_prefix = "bast-sg"
  vpc_id      = var.vpc_id
}


resource "aws_security_group_rule" "bast_http_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bast.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "bast_to_web" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bast.id
  source_security_group_id = aws_security_group.web.id
}


resource "aws_security_group_rule" "web_from_bast" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  source_security_group_id = aws_security_group.bast.id
}



