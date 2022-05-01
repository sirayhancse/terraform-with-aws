resource "aws_vpc" "webapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "webapp-${var.env_prefix}-vpc"
  }
}

module "custom_subnet" {
  source            = "./modules/custom_subnet"
  vpc_id            = aws_vpc.webapp-vpc.id
  vpc_name          = aws_vpc.webapp-vpc.tags.Name
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix        = var.env_prefix
}

module "webapp_instance" {
  source                   = "./modules/webapp"
  env_prefix               = var.env_prefix
  vpc_id                   = aws_vpc.webapp-vpc.id
  vpc_name                 = aws_vpc.webapp-vpc.tags.Name
  subnet_id                = module.custom_subnet.subnet.id
  availability_zone        = var.availability_zone
  my_ip                    = var.my_ip
  instance_type            = var.instance_type
  public_key_location_path = var.public_key_location_path
}
