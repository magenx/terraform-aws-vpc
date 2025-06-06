

//////////////////////////////////////////////////////////////[ OUTPUTS ]/////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Save VPC output values into SSM Parameter store
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_ssm_parameter" "vpc_id" {
  name        = "/${var.project}/VPC_ID"
  description = "VPC_ID for ${var.project}"
  type        = "String"
  value       = aws_vpc.this.id
}

resource "aws_ssm_parameter" "cidr_block" {
  name        = "/${var.project}/CIDR_BLOCK"
  description = "CIDR_BLOCK for ${var.project}"
  type        = "String"
  value       = aws_vpc.this.cidr_block
}

resource "aws_ssm_parameter" "public_subnet_id" {
  for_each    = aws_subnet.public
  name        = "/${var.project}/PUBLIC_SUBNET_ID_${upper(substr(each.key, -1, 1))}"
  description = "PUBLIC_SUBNET_ID for ${var.project} in ${each.key}"
  type        = "String"
  value       = each.value.id
}

resource "aws_ssm_parameter" "private_subnet_id" {
  for_each    = aws_subnet.private
  name        = "/${var.project}/PRIVATE_SUBNET_ID_${upper(substr(each.key, -1, 1))}"
  description = "PRIVATE_SUBNET_ID for ${var.project} in ${each.key}"
  type        = "String"
  value       = each.value.id
}

resource "aws_ssm_parameter" "resolver" {
  name        = "/${var.project}/RESOLVER"
  description = "RESOLVER address for this vpc"
  type        = "String"
  value       = cidrhost(aws_vpc.this.cidr_block, 2)
}
# # ---------------------------------------------------------------------------------------------------------------------#
# VPC values outputs
# # ---------------------------------------------------------------------------------------------------------------------#

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = [for subnet in aws_subnet.public : subnet.ipv6_cidr_block]
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = [aws_route_table.public.id]
}

output "public_subnets_azs" {
  description = "List of Availability Zones of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.availability_zone]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.arn]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.cidr_block]
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = [for subnet in aws_subnet.private : subnet.ipv6_cidr_block]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = [for rt in aws_route_table.private : rt.id]
}

output "private_subnets_azs" {
  description = "List of Availability Zones of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.availability_zone]
}

output "database_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = try(aws_db_subnet_group.database[0].name, null)
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = [for eni in aws_network_interface.nat_gateway : eni.id]
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = [for eip in aws_eip.nat_gateway : eip.public_ip]
}

output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = aws_vpc_dhcp_options.this.id
}

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = keys(data.aws_availability_zone.available)
}

output "resolver" {
  description = "RESOLVER address for this vpc"
  value       = cidrhost(aws_vpc.this.cidr_block, 2)
}
