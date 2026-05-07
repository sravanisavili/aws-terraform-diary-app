
#security group for load balancer
resource "aws_security_group" "personal_diary_alb_sg" {
  name        = "personal-diary-alb-sg"
  description = "ALB SG for personal diary"
  vpc_id      = data.aws_vpc.default.id   

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]   # Internet → ALB
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0

    # ALB can talk to anywhere (needed for EC2)
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# security group for ec2 
resource "aws_security_group" "personal_diary_ec2_sg" {
  name        = "personal-diary-ec2-sg"
  description = "SG for personal diary EC2"
  vpc_id      = data.aws_vpc.default.id   

  ingress {
    protocol    = local.tcp_protocol
    from_port   = local.tg_port    # usually 3000
    to_port     = local.tg_port        # usually 3000

    
    security_groups = [aws_security_group.personal_diary_alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
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
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  key_name = awscc_ec2_key_pair.diary-key.key_name
  vpc_security_group_ids = [aws_security_group.personal_diary_ec2_sg.id]

  user_data = filebase64("setup.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# target group
resource "aws_lb_target_group" "tg-peronal-diary" {
  name     = "tg-peronal-diary"
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

#subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for var.region"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for var.region"
  }
}
# application load balancer
resource "aws_lb" "alb-peronal-diary" {
  name               = "alb-peronal-diary"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.personal_diary_alb_sg.id]
  subnets            = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
}
# alb - listener
resource "aws_lb_listener" "alb-listener-personal-diary" {
  load_balancer_arn = aws_lb.alb-peronal-diary.arn
  port              = local.tcp_port
  protocol          = local.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-peronal-diary.arn
  }
}
#Auto scaling group
resource "aws_autoscaling_group" "asg-perona-diary" {
  name_prefix = "asg-perona-diary"
  vpc_zone_identifier = [
  aws_default_subnet.default_az1.id,
  aws_default_subnet.default_az2.id
]

  #launch_configuration = peronal-diary-launch-template.name
  #availability_zones   = [data.aws_availability_zones.names[0]]
  target_group_arns = [aws_lb_target_group.tg-peronal-diary.arn]
  launch_template {
    id      = aws_launch_template.peronal-diary-launch-template.id
    version = "$Latest"
  }

  min_size = 0
  max_size = 3
  desired_capacity = 2
}

