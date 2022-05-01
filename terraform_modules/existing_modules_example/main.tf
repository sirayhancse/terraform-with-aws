module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "webapp-${var.env_prefix}-vpc"
  cidr = var.vpc_cidr_block

  azs            = ["${var.availability_zone}a"]
  public_subnets = ["10.0.1.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  public_subnet_tags = {
    Name = "webapp-${var.env_prefix}-subent"
  }

  tags = {
    Name        = "webapp-${var.env_prefix}-vpc"
    Terraform   = "true"
    Environment = var.env_prefix
  }
}


module "webapp_instance" {
  source                   = "./modules/webapp"
  env_prefix               = var.env_prefix
  vpc_id                   = module.vpc.vpc_id
  vpc_name                 = module.vpc.name
  subnet_id                = module.vpc.public_subnets[0]
  availability_zone        = var.availability_zone
  my_ip                    = var.my_ip
  instance_type            = var.instance_type
  public_key_location_path = var.public_key_location_path
}
