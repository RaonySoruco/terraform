terraform {
  required_version = ">= 0.12"
}

# AZs disponíveis
data "aws_availability_zones" "available" {
  state = "available"
}

# ----------------------------------------------------------------------------------------------------------------------
# VPC
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = merge({ "Name" = var.vpc_name }, var.default_tags) #map
}

# ----------------------------------------------------------------------------------------------------------------------
# Public Subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = "public-${element(data.aws_availability_zones.available.names, count.index)}-subnet" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

# ----------------------------------------------------------------------------------------------------------------------
# Private Subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnet)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "private-${element(data.aws_availability_zones.available.names, count.index)}-subnet" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

# ----------------------------------------------------------------------------------------------------------------------
# Database Subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "database" {
  count = length(var.database_subnet)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.database_subnet, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "database-${element(data.aws_availability_zones.available.names, count.index)}-subnet" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

resource "aws_db_subnet_group" "default" {
  count      = length(var.database_subnet) > 0 ? 1 : 0
  name       = var.db_subnet_group_name
  subnet_ids = aws_subnet.database.*.id

  tags = merge({ "Name" = var.db_subnet_group_name }, var.default_tags)

  depends_on = [aws_subnet.database]
}

# ----------------------------------------------------------------------------------------------------------------------
# Internet gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.internet_gateway_tags, var.default_tags)

  depends_on = [aws_vpc.main]
}

# ----------------------------------------------------------------------------------------------------------------------
# NAT gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count = length(var.private_subnet) > 0 ? length(var.public_subnet) : 0
  vpc   = true
}

resource "aws_nat_gateway" "ng" {
  count = length(var.private_subnet) > 0 ? length(var.public_subnet) : 0

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags          = merge(var.nat_gateway_tags, var.default_tags)

  depends_on = [aws_vpc.main, aws_eip.nat]
}

# ----------------------------------------------------------------------------------------------------------------------
# Public route table
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge({ "Name" = "Public-route-table" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public, aws_subnet.public]
}

# ----------------------------------------------------------------------------------------------------------------------
# Private route table
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  count  = length(var.private_subnet) > 0 ? length(var.public_subnet) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.ng.*.id, count.index)
  }
  tags = merge({ "Name" = "private-${element(aws_subnet.private.*.availability_zone, count.index)}" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet) > 0 ? length(var.public_subnet) : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  depends_on = [aws_route_table.private, aws_subnet.private]
}

# ----------------------------------------------------------------------------------------------------------------------
# Database route table
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "database" {
  count  = length(var.database_subnet) > 0 ? length(var.public_subnet) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.ng.*.id, count.index)
  }
  tags = merge({ "Name" = "database-${element(aws_subnet.database.*.availability_zone, count.index)}" }, var.default_tags)

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet) > 0 ? length(var.public_subnet) : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  depends_on = [aws_route_table.private, aws_subnet.private]
}

# ----------------------------------------------------------------------------------------------------------------------
# Route 53 privarte
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
  count = var.r53_is_enable == true ? 1 : 0
  name  = var.r53_dsn_name

  vpc {
    vpc_id = aws_vpc.main.id
  }
}