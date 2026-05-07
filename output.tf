output "alb_url" {
  description = "Application Load Balancer URL"
  value       = aws_lb.alb-peronal-diary.dns_name
}