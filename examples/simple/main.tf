

//////////////////////////////////////////////////////////[ PROVIDER ]////////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Define provider
# # ---------------------------------------------------------------------------------------------------------------------#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}
provider "aws" {
  default_tags {
    tags = local.default_tags
  }
}

///////////////////////////////////////////////////////////[ LOCALS ]/////////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Define locals
# # ---------------------------------------------------------------------------------------------------------------------#
locals {
  # Get environment name from workspace name
  environment = lower(terraform.workspace)

  # Create global project name to be assigned to all resources
  project = lower("${local.env.brand}-${local.env.codename}-${substr(local.environment, 0, 1)}")

  # Provider default tags for every resource
  default_tags = {
    Terraform   = true
    Brand       = local.env.brand
    Codename    = local.env.codename
    Config      = base64decode("TWFnZW5Y")
    Environment = local.environment
  }

  # YAML files with variables per environment
  config_files = {
    staging     = try(file("${abspath(path.root)}/staging.config.yaml"), "")
    development = try(file("${abspath(path.root)}/development.config.yaml"), "")
    production  = try(file("${abspath(path.root)}/production.config.yaml"), "")
  }

  # Variables constructor to pass in root module [ var = local.env.cird_block ]
  env = yamldecode(local.config_files[local.environment])
}

////////////////////////////////////////////////[ INFRASTRUCTURE CONFIGURATION ]//////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Create VPC and base networking layout per environment
# # ---------------------------------------------------------------------------------------------------------------------#
module "vpc" {
  # mini vpc mudule to create private subnets and nat ec2 instace per az
  source                    = "magenx/vpc/aws"
  version                   = "~> 1.0"
  project                   = local.project
  enable_dns_support        = local.env.vpc.enable_dns_support
  enable_dns_hostnames      = local.env.vpc.enable_dns_hostnames
  instance_tenancy          = local.env.vpc.instance_tenancy
  availability_zone_total   = local.env.vpc.availability_zone_total
  create_database_subnet    = local.env.vpc.create_database_subnet
  cidr_block                = local.env.vpc.cidr_block
  exclude_zone_ids          = local.env.vpc.exclude_zone_ids
  nat_gateway_single        = local.env.nat_gateway.single
  nat_gateway_instance_type = local.env.nat_gateway.instance_type
  nat_gateway_volume_size   = local.env.nat_gateway.volume_size
  ami_owner                 = local.env.nat_gateway.ami_owner
  ami_image                 = local.env.nat_gateway.ami_image
}

