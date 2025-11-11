# # ---------------------------------------------------------------------------------------------------------------------#
# Get single primary AZ from sorted AZs
# # ---------------------------------------------------------------------------------------------------------------------#
locals {
  sorted_az_names = sort(slice(data.aws_availability_zones.available.names, 0, var.availability_zone_total))
  primary_az      = local.sorted_az_names[0]
}
