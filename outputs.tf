output "dns-load-balancer-name" {
  description = "load balancers DNS name"
  value       = aws_lb.app_load_balancer.dns_name
}

output "load-balancer-zone-id" {
  description = "load balancer zone ID"
  value       = aws_lb.app_load_balancer.zone_id
}