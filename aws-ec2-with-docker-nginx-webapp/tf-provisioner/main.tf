provider "aws" {
  region = var.availability_zone
}


variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "availability_zone" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location_path" {}
variable "private_key_location_path" {}


resource "aws_vpc" "webapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "webapp-${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "webapp-subnet" {
  vpc_id            = aws_vpc.webapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "${var.availability_zone}a"
  tags = {
    "Name" = "webapp-${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "webapp-internet-gateway" {
  vpc_id = aws_vpc.webapp-vpc.id
  tags = {
    "Name" = "${aws_vpc.webapp-vpc.tags.Name}-internet-gateway"
  }
}


resource "aws_route_table" "webapp-route-table" {
  vpc_id = aws_vpc.webapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-internet-gateway.id
  }
  tags = {
    "Name" = "${aws_vpc.webapp-vpc.tags.Name}-route-table"
  }
}

resource "aws_route_table_association" "associate-subnet-with-route-table" {
  subnet_id      = aws_subnet.webapp-subnet.id
  route_table_id = aws_route_table.webapp-route-table.id
}


resource "aws_security_group" "webapp-security-group" {
  name   = "${aws_vpc.webapp-vpc.tags.Name}-sg"
  vpc_id = aws_vpc.webapp-vpc.id
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
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    "Name" = "${aws_vpc.webapp-vpc.tags.Name}-sg"
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
  key_name   = "webapp-server-key"
  public_key = file(var.public_key_location_path)
}


resource "aws_instance" "webapp-server" {
  ami                         = data.aws_ami.amazon_latest_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.webapp-subnet.id
  vpc_security_group_ids      = [aws_security_group.webapp-security-group.id]
  availability_zone           = "${var.availability_zone}a"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.webapp-key-pair.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_location_path)
  }

  provisioner "file" {
    source      = "user_data.sh"
    destination = "/home/ec2-user/user_data.sh"
  }

  provisioner "local-exec" {
    command = "echo Instance IP is ${self.public_ip}"
  }


  provisioner "remote-exec" {
    script = file("user_data.sh")
  }

  tags = {
    "Name" = "webapp-${var.env_prefix}-server"
  }
}


output "vpc-id" {
  value = aws_vpc.webapp-vpc.id
}

output "subnet-id" {
  value = aws_subnet.webapp-subnet.id
}

output "internet-gateway-id" {
  value = aws_internet_gateway.webapp-internet-gateway.id
}

output "route-table-id" {
  value = aws_route_table.webapp-route-table.id
}

output "security-group-id" {
  value = aws_security_group.webapp-security-group.id
}

output "amazon-linux-ami-object" {
  value = data.aws_ami.amazon_latest_linux_image.id
}

output "webapp-server-public_ip" {
  value = aws_instance.webapp-server.public_ip
}
