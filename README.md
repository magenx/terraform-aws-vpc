
# AWS VPC Terraform module
#### Terraform mini module which creates VPC resources on AWS
- VPC with AZ configurable
- Subnets [public, private]
- Database subnet
- EC2 NAT per AZ
- SSM Instance profile
- SSM document association to setup EC2 NAT
- S3 endpoint
- Outputs with Parameters store  
  
  
> usage
```
//////////////////////////////////////////////////////////[ PROVIDER ]////////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Define provider
# # ---------------------------------------------------------------------------------------------------------------------#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
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
    Terraform    = true
    Brand        = local.env.brand
    Codename     = local.env.codename
    Config       = base64decode("TWFnZW5Y")
    Environment  = local.environment
  }

  # YAML files with variables per environment
  config_files = {
    staging    = try(file("${abspath(path.root)}/staging.config.yaml"), "")
    developer  = try(file("${abspath(path.root)}/developer.config.yaml"), "")
    production = try(file("${abspath(path.root)}/production.config.yaml"), "")
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
  source                  = "magenx/vpc/aws"
  version                 = "~> 1.0"
  project                 = local.project
  enable_dns_support      = local.env.vpc.enable_dns_support
  enable_dns_hostnames    = local.env.vpc.enable_dns_hostnames
  instance_tenancy        = local.env.vpc.instance_tenancy
  availability_zone_total = local.env.vpc.availability_zone_total
  create_database_subnet  = local.env.vpc.create_database_subnet
  cidr_block              = local.env.vpc.cidr_block
  exclude_zone_ids        = local.env.vpc.exclude_zone_ids
  nat_gateway_instance_type = local.env.nat_gateway.instance_type
  nat_gateway_volume_size   = local.env.nat_gateway.volume_size
  ami_owner                 = local.env.nat_gateway.ami_owner
  ami_image                 = local.env.nat_gateway.ami_image
}
```

  
> production.config.yaml
```
brand: magenx
codename: cloud
domain: "magenx.org"

vpc:
  cidr_block: "10.0.0.0/16"
  availability_zone_total: 2
  enable_dns_support: true
  enable_dns_hostnames: true
  create_database_subnet: true
  instance_tenancy: default
  exclude_zone_ids: ["use1-az3"]

nat_gateway:
  instance_type: "t4g.nano"
  ami_owner: "136693071363"
  ami_image: "debian-12-arm64*"
  volume_size: 25
  firewall: true
```

  
> deploy
```
terraform init
terraform workspace new production
terraform apply
```




