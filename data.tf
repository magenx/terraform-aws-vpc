# # ---------------------------------------------------------------------------------------------------------------------#
# Get the name of the region where the Terraform deployment is running
# # ---------------------------------------------------------------------------------------------------------------------#
data "aws_region" "current" {}
# # ---------------------------------------------------------------------------------------------------------------------#
# Get the list of AWS Availability Zones available in this region
# # ---------------------------------------------------------------------------------------------------------------------#
data "aws_availability_zones" "available" {
  state            = "available"
  exclude_zone_ids = var.exclude_zone_ids
}
data "aws_availability_zone" "available" {
  for_each = toset(slice(data.aws_availability_zones.available.names, 0, var.availability_zone_total))
  name     = each.key
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Get the latest ID of a registered Debian AMI
# # ---------------------------------------------------------------------------------------------------------------------#
data "aws_ami" "this" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "name"
    values = [var.ami_image]
  }
}
