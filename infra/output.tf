# 1. Load Balancer dns Output
output "alb_dns_name" {
  description = "The DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}