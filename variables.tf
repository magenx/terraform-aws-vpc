# # ---------------------------------------------------------------------------------------------------------------------#
# VPC variables
# # ---------------------------------------------------------------------------------------------------------------------#
variable "project" {
  description = "Project name"
  type        = string
}
variable "enable_dns_support" {
  description = "Enable DNS resolution support in the VPC."
  type        = bool
  default     = true
}
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}
variable "instance_tenancy" {
  description = "Tenancy option for instances (default/dedicated)."
  type        = string
  default     = "default"
}
variable "availability_zone_total" {
  description = "Number of AZs to use (minimum 1)."
  type        = number
}
variable "cidr_block" {
  description = "Primary CIDR block for the VPC (e.g., 10.0.0.0/16)."
  type        = string
}
variable "ami_owner" {
  description = "AMI owner to limit search"
  type        = string
}
variable "ami_image" {
  description = "Name of the AMI that was provided during image creation."
  type        = string
}
variable "exclude_zone_ids" {
  description = "List of Availability Zone IDs to exclude"
  type        = list(any)
}
variable "nat_gateway_instance_type" {
  description = "EC2 NAT Gateway instance type"
  type        = string
}
variable "nat_gateway_volume_size" {
  description = "EC2 NAT Gateway volume size"
  type        = string
}
variable "nat_gateway_single" {
  description = "EC2 NAT Gateway single instance"
  type        = bool
}
variable "az_number" {
  description = "Assign a number to each AZ letter used in secondary cidr/subnets configuration"
  default = {
    a = 0
    b = 1
    c = 2
    d = 3
    e = 4
    f = 5
    g = 6
  }
}
variable "create_database_subnet" {
  description = "Whether to create private database subnets"
  type        = bool
  default     = false
}

