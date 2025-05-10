

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

output "public_subnet_objects" {
  description = "A list of all public subnets, containing the full objects."
  value       = aws_subnet.public
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = compact(aws_subnet.public[*].cidr_block)
}

output "private_subnet_objects" {
  description = "A list of all private subnets, containing the full objects."
  value       = aws_subnet.private
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = compact(aws_subnet.private[*].cidr_block)
}

output "resolver" {
  description = "RESOLVER address for this vpc"
  value       = cidrhost(aws_vpc.this.cidr_block, 2)
}
