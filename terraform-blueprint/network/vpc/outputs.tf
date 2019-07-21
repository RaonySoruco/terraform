output "aws_vpc" {
  value = module.vpc.aws_vpc
}

output "subnet_private" {
  value = module.vpc.subnet_private
}

output "subnet_public" {
  value = module.vpc.subnet_public
}

output "subnet_database" {
  value = module.vpc.subnet_database
}

output "db_subnet_group" {
  value = module.vpc.db_subnet_group
}

output "internet_gateway" {
  value = module.vpc.internet_gateway
}

output "nat_gateway" {
  value = module.vpc.nat_gateway
}

output "route_table_public" {
  value = module.vpc.route_table_public
}

output "route_table_private" {
  value = module.vpc.route_table_private
}

output "route_table_database" {
  value = module.vpc.route_table_database
}

output "r53_private" {
  value = module.vpc.r53_private
}
