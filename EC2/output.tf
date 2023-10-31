output "instance_private_ip" {
  value = aws_instance.EC2_NGINX.private_ip
}

output "load_balancer_dns_name" {
  value = aws_lb.webapp_load_balancer.dns_name
}

/*output "instance_public_ip" {
  value = aws_instance.public_EC2_NGINX.public_ip
}*/


