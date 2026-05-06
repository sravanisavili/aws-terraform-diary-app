variable "instance" {
   default =  "ubuntu"
}

variable "instance-type" {
   default =   "t3.micro"
}

locals {
  tcp_port    = 80
  tg_port     = 3000
  tg_from_port = 80
  tcp_protocol = "tcp"
  http_protocol = "HTTP"
  all_ips      = ["0.0.0.0/0"]
}