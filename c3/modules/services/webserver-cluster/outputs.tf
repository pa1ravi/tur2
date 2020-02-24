output "alb_dns_name" {
  value       = aws_lb.exampleLB.dns_name
  description = "DNS endpoint of the load balancer"
}