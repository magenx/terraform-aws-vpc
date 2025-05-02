

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
  description = "VPC_ID"
  value       = aws_vpc.this.id
}

output "cidr_block" {
  description = "CIDR_BLOCK"
  value       = aws_vpc.this.cidr_block
}

output "public_subnets" {
  description = "PUBLIC_SUBNETS"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets" {
  description = "PRIVATE_SUBNETS"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "resolver" {
  description = "RESOLVER address for this vpc"
  value       = cidrhost(aws_vpc.this.cidr_block, 2)
}
