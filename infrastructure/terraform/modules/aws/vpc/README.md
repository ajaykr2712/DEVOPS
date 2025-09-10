# AWS VPC Module

This module creates a production-ready VPC with public and private subnets across multiple availability zones.

## Features

- Multi-AZ deployment for high availability
- Public and private subnets
- NAT Gateway for private subnet internet access
- VPC Flow Logs for security monitoring
- Proper tagging for resource management
- Cost optimization with single NAT Gateway option

## Usage

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  project_name     = "my-project"
  environment      = "production"
  vpc_cidr         = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  # Subnets
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # NAT Gateway
  single_nat_gateway = false  # Set to true for cost savings in dev
  
  # Monitoring
  enable_flow_logs = true
  
  tags = {
    Project     = "my-project"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | n/a | yes |
| private_subnet_cidrs | CIDR blocks for private subnets | `list(string)` | n/a | yes |
| single_nat_gateway | Use single NAT Gateway for cost savings | `bool` | `false` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| public_subnet_ids | IDs of the public subnets |
| private_subnet_ids | IDs of the private subnets |
| internet_gateway_id | ID of the Internet Gateway |
| nat_gateway_ids | IDs of the NAT Gateways |
| route_table_ids | IDs of the route tables |

## Examples

See the [examples](../../examples) directory for complete usage examples.
