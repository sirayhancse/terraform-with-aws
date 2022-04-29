provider "aws" {
  region = var.availability_zone
}

variable "env_prefix" {}
variable "availability_zone" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location_path" {}


data "aws_vpc" "default-vpc" {
  default = true
}


resource "aws_default_subnet" "default-subnet" {
  availability_zone = "${var.availability_zone}a"

}


resource "aws_default_security_group" "default-vpc-security-group" {
  vpc_id = data.aws_vpc.default-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "amazon_latest_linux_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_key_pair" "webapp-key-pair" {
  key_name   = "webapp-server-key-default"
  public_key = file(var.public_key_location_path)
}


resource "aws_instance" "webapp-server" {
  ami                         = data.aws_ami.amazon_latest_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_default_subnet.default-subnet.id
  vpc_security_group_ids      = [aws_default_security_group.default-vpc-security-group.id]
  availability_zone           = "${var.availability_zone}a"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.webapp-key-pair.key_name

  user_data = file("user_data.sh")

  tags = {
    "Name"       = "webapp-${var.env_prefix}-server-default"
    "Descripton" = "Launch webapp server using default resources"
  }
}


output "webapp-server-public-ip" {
  value = aws_instance.webapp-server.public_ip
}
