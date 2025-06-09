

////////////////////////////////////////////////////////[ VPC NETWORKING ]////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Create our dedicated VPC
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "${var.project}-vpc"
  }
}
# ---------------------------------------------------------------------------------------------------------------------#
# Create PUBLIC subnets for each AZ in our dedicated VPC
# ---------------------------------------------------------------------------------------------------------------------#
resource "aws_subnet" "public" {
  for_each                = data.aws_availability_zone.available
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, var.az_number[each.value.name_suffix])
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-subnet-${each.key}"
  }
}
# ---------------------------------------------------------------------------------------------------------------------#
# Create route table for public subnets
# ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project}-public-route-table"
  }
}
# ---------------------------------------------------------------------------------------------------------------------#
# Create default route for public subnets to internet
# ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
# ---------------------------------------------------------------------------------------------------------------------#
# Associate public subnets with public route table
# ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create PRIVATE subnets for each AZ in our dedicated VPC
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_subnet" "private" {
  depends_on              = [aws_subnet.public]
  for_each                = data.aws_availability_zone.available
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, var.az_number[each.value.name_suffix] + var.availability_zone_total)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-private-subnet-${each.key}"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create route table for private subnets
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table" "private" {
  for_each = data.aws_availability_zone.available
  vpc_id   = aws_vpc.this.id
  tags = {
    Name = "${var.project}-private-route-table-${each.key}"
  }
}
# ---------------------------------------------------------------------------------------------------------------------#
# Create default route for private subnets to nat gateway
# ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route" "private" {
  for_each               = data.aws_availability_zone.available
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_gateway[each.key].id
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Assign private subnets to private route table
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table_association" "private" {
  for_each       = data.aws_availability_zone.available
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create DHCP options in our dedicated VPC
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "${data.aws_region.current.name}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = "${var.project}-dhcp"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Assign DHCP options to our dedicated VPC
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create internet gateway in our dedicated VPC
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project}-internet-gateway"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create dedicated PRIVATE DATABASE subnets for each AZ
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_subnet" "database" {
  for_each                = var.create_database_subnet ? data.aws_availability_zone.available : {}
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, var.az_number[each.value.name_suffix] + (var.availability_zone_total * 2))
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-private-database-subnet-${each.key}"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create route tables for DB subnets (no internet route)
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table" "database" {
  for_each = var.create_database_subnet ? data.aws_availability_zone.available : {}
  vpc_id   = aws_vpc.this.id
  tags = {
    Name = "${var.project}-private-database-route-table-${each.key}"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Associate DB subnets with their private route tables
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_route_table_association" "database" {
  for_each       = var.create_database_subnet ? data.aws_availability_zone.available : {}
  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.key].id
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create private database subnet group
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_db_subnet_group" "database" {
  count      = var.create_database_subnet ? 1 : 0
  name       = "${var.project}-private-database-subnet-group"
  subnet_ids = [for subnet in aws_subnet.database : subnet.id]
  tags = {
    Name = "${var.project}-private-database-subnet-group"
  }
}
