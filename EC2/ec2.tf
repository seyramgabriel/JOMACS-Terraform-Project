resource "aws_security_group" "ec2_public_security_group" {
  name        = "ec2_public_security_group"
  description = "public facing"
  vpc_id      =  data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port   = var.web_port
    protocol    = "TCP"
    to_port     = var.web_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    protocol    = "TCP"
    to_port     = var.ssh_port
    cidr_blocks = [var.ssh_IP]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_private_security_group" {
  name        = "ec2_private_security_group"
  description = "only allow public sg resources to access these instances"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port       = var.ssh_port
    protocol        = "TCP"
    to_port         = var.ssh_port
    security_groups = [aws_security_group.ec2_public_security_group.id]
    description     = "Allow ssh from public instance"
  }

  ingress {
    from_port       = var.web_port
    protocol        = "TCP"
    to_port         = var.web_port
    security_groups = [aws_security_group.elb_security_group.id]
    description     = "Allow routing from elb through NAT gateway"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_security_group" {
  name        = "elb_sg"
  description = "route traffic to private instance through NAT gateway"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow web traffic to load balancer"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "EC2_NGINX" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = element(split(",", data.aws_ssm_parameter.subnets_ids.value), 2)
  security_groups             = ["${aws_security_group.ec2_private_security_group.id}"]
  key_name                    = var.keyname
  associate_public_ip_address = false
  user_data                   = file("${path.module}/user_data.sh")
  tags = {
    Name = "${var.instance_name}"
  }
}

/*resource "aws_instance" "public_EC2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = element(split(",", data.aws_ssm_parameter.subnets_ids.value), 0)
  security_groups             = ["${aws_security_group.ec2_public_security_group.id}"]
  key_name                    = var.keyname
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data1.sh")
  tags = {
    Name = "public_instance"
  }
}*/

/*resource "aws_key_pair" "starkey" {
  key_name   = var.keyname
  public_key = var.key
}*/

resource "aws_lb" "webapp_load_balancer" {
  name               = "nginx-EC2-load-balancer"
  internal           = false
  load_balancer_type = var.ld_type
  security_groups    = ["${aws_security_group.elb_security_group.id}"]
  subnets            = [element(split(",", data.aws_ssm_parameter.subnets_ids.value), 0 ), element(split(",", data.aws_ssm_parameter.subnets_ids.value), 1 )]
}

resource "aws_lb_listener" "star_listener" {
  load_balancer_arn = aws_lb.webapp_load_balancer.arn
  port              = var.web_port
  protocol          = "HTTP"

  default_action {
    type             = var.listener_forward_type
    target_group_arn = aws_lb_target_group.for_nginx_ec2.arn
  }
}

resource "aws_lb_target_group" "for_nginx_ec2" {
  name     = "ec2-nginx-as-target"
  port     = var.web_port
  protocol = var.web_protocol
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_lb_target_group_attachment" "for_nginx_ec2_attachment" {
  target_group_arn = aws_lb_target_group.for_nginx_ec2.arn
  target_id        = aws_instance.EC2_NGINX.id
  port             = var.web_port
}

