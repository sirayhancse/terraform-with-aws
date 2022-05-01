
resource "aws_subnet" "webapp-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "${var.availability_zone}a"
  tags = {
    "Name" = "webapp-${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "webapp-internet-gateway" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.vpc_name}-internet-gateway"
  }
}


resource "aws_route_table" "webapp-route-table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-internet-gateway.id
  }
  tags = {
    "Name" = "${var.vpc_name}-route-table"
  }
}

resource "aws_route_table_association" "associate-subnet-with-route-table" {
  subnet_id      = aws_subnet.webapp-subnet.id
  route_table_id = aws_route_table.webapp-route-table.id
}
