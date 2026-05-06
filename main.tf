
#security group for load balancer
resource "aws_security_group" "personal-diary-alb-sg" {
  name        = "personal-diary-alb-sg"
  description = "alb SG for perosnl diary"
  vpc_id      = "aws_vpc.main.id"
  ingress {
    protocol = local.tcp_protocol
    to_port = local.tg_port
    from_port = local.tg_from_port
    cidr_blocks = local.all_ips
  }

    tags = {
        Name = "personal-diary-alb-sg"
    }
}
# security group for ec2 
resource "aws_security_group" "personal-diary-ec2-sg" {
  name        = "personal-diary-ec2-sg"
  description = "SG for perosnl diary"
  vpc_id      = "aws_vpc.main.id"
  ingress {
    protocol =  local.tcp_protocol
    to_port =   local.tcp_port
    from_port = local.tg_from_port
    cidr_blocks = local.all_ips 
  }

    tags = {
        Name = "personal-diary-ec2-sg"
    }
}
#key pair for ec2
resource "awscc_ec2_key_pair" "diary-key" {
  key_name            = "diary-key"
  #public_key_material = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

#launch template
resource "aws_launch_template" "peronal-diary-launch-template" {
  name = "peronal-diary-launch-template"
  image_id = var.instance
  instance_type = var.instance-type
  key_name = "id.awscc_ec2_key_pair"
  vpc_security_group_ids = ["vpc-02216d73455e25736"]

  user_data = filebase64("app.js")

  lifecycle {
    create_before_destroy = true
  }
}

# target group
resource "aws_lb_target_group" "tg_peronal_diary" {
  name     = "tg_peronal_diary"
  port     = local.tg_port
  protocol = local.http_protocol
  vpc_id   = "vpc-02216d73455e25736"

  # Optional: Health Check Configuration
  health_check {
    enabled = true
    path    = "/"
  }

  tags = {
    Name = "tg-peronal_diary"
  }
}   
# application load balancer
resource "aws_lb" "alb-peronal-diary" {
  name               = "alb-peronal-diary"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_personal-diary-alb-sg.id
  subnets            = aws_subnet.public.*.id
}
# alb - listener
resource "aws_lb_listener" "alb-listener-personal-diary" {
  load_balancer_arn = alb-peronal-diary.arn
  port              = local.tcp_port
  protocol          = local.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = tg-peronal_diary.arn
  }
}
#Auto scaling group
resource "aws_autoscaling_group" "asg-perona-diary" {
  name_prefix = "asg-perona-diary"

  #launch_configuration = peronal-diary-launch-template.name
  availability_zones   = [data.aws_availability_zones.available.names[0]]
  target_group_arns = [tg-peronal_diary.arn]
  launch_template {
    id      = peronal-diary-launch-template.id
    version = "$Latest"
  }

  min_size = 0
  max_size = 3
  desired_capacity = 2
}

