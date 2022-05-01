output "subnet" {
  value = aws_subnet.webapp-subnet
}

output "internet-gateway" {
  value = aws_internet_gateway.webapp-internet-gateway
}

output "route-table" {
  value = aws_route_table.webapp-route-table
}
