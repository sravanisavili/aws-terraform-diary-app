
#security group for load balancer
resource "aws_security_group" "personal-diary-alb-sg" {
  name        = "personal-diary-alb-sg"
  description = "alb SG for perosnl diary"
  vpc_id      = "aws_vpc.main.id"
  ingress {
    protocol = TCP
    to_port = 3000
    cidr_blocks = ["0.0.0.0/0"]
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
    protocol = TCP
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "personal-diary-ec2-sg"
    }
}
#key pair for ec2
resource "awscc_ec2_key_pair" "diary-key" {
  key_name            = "diary-key"
  public_key_material = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"

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
  vpc_security_group_ids = "aws.personal-diary-ec2-sg"

  user_data = filebase64("app.js")
}

# target group
resource "aws_lb_target_group" "tg-peronal_diary" {
  name     = "tg-peronal_diary"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id

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
  security_groups    = [personal-diary-alb-sg.id]
  subnets            = aws_subnet.public.*.id
}
# alb - listener
resource "aws_lb_listener" "alb-listener-personal-diary" {
  load_balancer_arn = alb-peronal-diary.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = tg-peronal_diary.arn
  }
}
#Auto scaling group
resource "aws_autoscaling_group" "asg-perona-diary" {
  name_prefix = "asg-perona-diary"

  launch_configuration = peronal-diary-launch-template.name
  availability_zones   = [data.aws_availability_zones.available.names[0]]

  min_size = 0
  max_size = 3
  desired_capacity = 2
}

