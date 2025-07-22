# AWS Outputs
output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = aws_vpc.main.id
}

output "aws_vpc_cidr" {
  description = "CIDR block of the AWS VPC"
  value       = aws_vpc.main.cidr_block
}

output "aws_public_subnet_ids" {
  description = "IDs of the AWS public subnets"
  value       = aws_subnet.public[*].id
}

output "aws_private_subnet_ids" {
  description = "IDs of the AWS private subnets"
  value       = aws_subnet.private[*].id
}

output "aws_public_subnet_cidrs" {
  description = "CIDR blocks of the AWS public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "aws_private_subnet_cidrs" {
  description = "CIDR blocks of the AWS private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "aws_internet_gateway_id" {
  description = "ID of the AWS Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "aws_nat_gateway_ids" {
  description = "IDs of the AWS NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "aws_nat_gateway_public_ips" {
  description = "Public IP addresses of the AWS NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "aws_route_table_public_id" {
  description = "ID of the AWS public route table"
  value       = aws_route_table.public.id
}

output "aws_route_table_private_ids" {
  description = "IDs of the AWS private route tables"
  value       = aws_route_table.private[*].id
}

output "aws_default_security_group_id" {
  description = "ID of the AWS default security group"
  value       = aws_security_group.default.id
}

# Azure Outputs (placeholder - implement when Azure resources are added)
output "azure_vnet_id" {
  description = "ID of the Azure Virtual Network"
  value       = null # Replace with actual Azure VNet resource
}

output "azure_vnet_cidr" {
  description = "CIDR block of the Azure Virtual Network"
  value       = var.azure_cidr
}

output "azure_subnet_ids" {
  description = "IDs of the Azure subnets"
  value       = [] # Replace with actual Azure subnet resources
}

output "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  value       = null # Replace with actual Azure resource group
}

# GCP Outputs (placeholder - implement when GCP resources are added)
output "gcp_vpc_id" {
  description = "ID of the GCP VPC"
  value       = null # Replace with actual GCP VPC resource
}

output "gcp_vpc_cidr" {
  description = "CIDR block of the GCP VPC"
  value       = var.gcp_cidr
}

output "gcp_subnet_ids" {
  description = "IDs of the GCP subnets"
  value       = [] # Replace with actual GCP subnet resources
}

output "gcp_project_id" {
  description = "GCP project ID"
  value       = var.gcp_project_id
}

# Cross-Cloud Connectivity
output "vpn_gateway_ips" {
  description = "IP addresses of VPN gateways for cross-cloud connectivity"
  value = {
    aws   = var.enable_vpn_connections ? [] : [] # Implement VPN gateway IPs
    azure = var.enable_vpn_connections ? [] : []
    gcp   = var.enable_vpn_connections ? [] : []
  }
}

# Network Configuration Summary
output "network_summary" {
  description = "Summary of network configuration across all clouds"
  value = {
    aws = {
      vpc_id              = aws_vpc.main.id
      cidr_block          = aws_vpc.main.cidr_block
      availability_zones  = var.aws_availability_zones
      public_subnets      = length(aws_subnet.public)
      private_subnets     = length(aws_subnet.private)
      nat_gateways        = length(aws_nat_gateway.main)
    }
    azure = {
      cidr_block = var.azure_cidr
      region     = var.azure_region
    }
    gcp = {
      cidr_block = var.gcp_cidr
      region     = var.gcp_region
      project_id = var.gcp_project_id
    }
  }
}

# Security Configuration
output "security_summary" {
  description = "Summary of security configurations"
  value = {
    flow_logs_enabled     = var.enable_flow_logs
    encryption_enabled    = var.enable_encryption
    monitoring_enabled    = var.enable_monitoring
    compliance_framework  = var.compliance_framework
    default_security_group = aws_security_group.default.id
  }
}

# Cost Optimization
output "cost_optimization_summary" {
  description = "Summary of cost optimization features"
  value = {
    nat_gateways_count    = length(aws_nat_gateway.main)
    spot_instances_enabled = var.enable_spot_instances
    auto_scaling_enabled   = var.auto_scaling_enabled
    estimated_monthly_cost = "Calculate based on resources"
  }
}

# Monitoring and Logging
output "monitoring_summary" {
  description = "Summary of monitoring and logging configuration"
  value = {
    flow_logs_group      = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_log[0].name : null
    log_retention_days   = var.log_retention_days
    monitoring_enabled   = var.enable_monitoring
    alert_email         = var.alert_email
  }
}

# Tags
output "applied_tags" {
  description = "Tags applied to resources"
  value = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "multi-cloud-vpc"
  })
}

# Resource Count Summary
output "resource_count" {
  description = "Count of created resources"
  value = {
    aws_vpc               = 1
    aws_subnets_public    = length(aws_subnet.public)
    aws_subnets_private   = length(aws_subnet.private)
    aws_nat_gateways      = length(aws_nat_gateway.main)
    aws_route_tables      = 1 + length(aws_route_table.private)
    aws_security_groups   = 1
    aws_eips              = length(aws_eip.nat)
  }
}

# DNS Configuration
output "dns_configuration" {
  description = "DNS configuration details"
  value = {
    private_dns_enabled = var.enable_private_dns
    domain_name        = var.dns_domain_name
    aws_dns_hostnames  = aws_vpc.main.enable_dns_hostnames
    aws_dns_support    = aws_vpc.main.enable_dns_support
  }
}

# Backup and DR Configuration
output "backup_dr_summary" {
  description = "Backup and disaster recovery configuration"
  value = {
    backup_retention_days = var.backup_retention_days
    cross_region_backup  = var.cross_region_backup
    dr_strategy          = "Multi-cloud redundancy"
  }
}
