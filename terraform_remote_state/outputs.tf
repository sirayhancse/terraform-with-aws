output "vpc-id" {
  value = module.vpc.vpc_id
}

output "security-group-id" {
  value = module.webapp_instance.security-group.id
}

output "amazon-linux-ami-object" {
  value = module.webapp_instance.amazon-linux-ami-object.id
}

output "webapp-server-public_ip" {
  value = module.webapp_instance.webapp-server-instance.public_ip
}
