resource "aws_security_group" "webapp-security-group" {
  name   = "${var.vpc_name}-sg"
  vpc_id = var.vpc_id
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
    "Name" = "${var.vpc_name}-sg"
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
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.webapp-security-group.id]
  availability_zone           = "${var.availability_zone}a"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.webapp-key-pair.key_name

  user_data = file("./user_data.sh")
  tags = {
    "Name" = "webapp-${var.env_prefix}-server"
  }
}
