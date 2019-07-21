output "aws_vpc" {
  value       = aws_vpc.main
}

output "subnet_private" {
  value       = aws_subnet.private
}

output "subnet_public" {
  value = aws_subnet.public
}

output "subnet_database" {
  value = aws_subnet.database
}

output "db_subnet_group" {
  value = aws_db_subnet_group.default
}

output "internet_gateway" {
  value = aws_internet_gateway.gw
}

output "nat_gateway" {
  value = aws_nat_gateway.ng
}

output "route_table_public" {
  value = aws_route_table.public
}

output "route_table_private" {
  value = aws_route_table.private
}

output "route_table_database" {
  value = aws_route_table.database
}

output "r53_private" {
  value = aws_route53_zone.private
}