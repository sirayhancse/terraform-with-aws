output "security-group" {
  value = aws_security_group.webapp-security-group
}

output "amazon-linux-ami-object" {
  value = data.aws_ami.amazon_latest_linux_image
}

output "webapp-server-instance" {
  value = aws_instance.webapp-server
}
