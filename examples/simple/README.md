## Simple VPC
Configuration in this directory creates set of VPC resources which may be sufficient for MVP or development environment.

There is a public and private subnets created per availability zone.  
ENI and EIP.  
EC2 NAT Gateway for each availability zones.  
S3 endpoint.  
Database subnet.  

This configuration uses yaml configuration file.


## Usage
To run this example you need to execute:

> terraform init -upgrade  
> terraform workspace new development  
> terraform plan  
> terraform apply  

```
 Note that this example creates resources which cost money.
 Run [ terraform destroy ] when you don't need these resources.
```
