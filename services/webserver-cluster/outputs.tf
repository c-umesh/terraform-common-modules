
output "clb_dns_name" {
  value = aws_elb.classic_elb.dns_name
  description = "The domain name of classic load balancer"
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}