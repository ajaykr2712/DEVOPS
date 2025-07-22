# Core variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.aws_cidr, 0))
    error_message = "AWS CIDR must be a valid IPv4 CIDR block."
  }
}

variable "aws_availability_zones" {
  description = "List of AWS availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# Azure Configuration
variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "West US 2"
}

variable "azure_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrhost(var.azure_cidr, 0))
    error_message = "Azure CIDR must be a valid IPv4 CIDR block."
  }
}

# GCP Configuration
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-west2"
}

variable "gcp_cidr" {
  description = "CIDR block for GCP VPC"
  type        = string
  default     = "10.2.0.0/16"
  validation {
    condition     = can(cidrhost(var.gcp_cidr, 0))
    error_message = "GCP CIDR must be a valid IPv4 CIDR block."
  }
}

# Feature flags
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_connections" {
  description = "Enable VPN connections between clouds"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption at rest and in transit"
  type        = bool
  default     = true
}

# Security
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Monitoring and logging
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "Log retention days must be between 1 and 365."
  }
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = ""
}

# Cost optimization
variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "auto_scaling_enabled" {
  description = "Enable auto scaling for resources"
  type        = bool
  default     = true
}

# Backup and disaster recovery
variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "cross_region_backup" {
  description = "Enable cross-region backup"
  type        = bool
  default     = false
}

# Compliance
variable "compliance_framework" {
  description = "Compliance framework (SOC2, PCI-DSS, HIPAA)"
  type        = string
  default     = "SOC2"
  validation {
    condition     = contains(["SOC2", "PCI-DSS", "HIPAA", "GDPR", "none"], var.compliance_framework)
    error_message = "Compliance framework must be one of: SOC2, PCI-DSS, HIPAA, GDPR, none."
  }
}

# Tags
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Module    = "multi-cloud-vpc"
  }
}

variable "additional_tags" {
  description = "Additional tags for specific resources"
  type        = map(string)
  default     = {}
}

# Advanced networking
variable "custom_route_tables" {
  description = "Custom route table configurations"
  type = map(object({
    routes = list(object({
      destination_cidr = string
      target          = string
    }))
  }))
  default = {}
}

variable "custom_security_groups" {
  description = "Custom security group configurations"
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
  default = {}
}

# DNS configuration
variable "enable_private_dns" {
  description = "Enable private DNS resolution"
  type        = bool
  default     = true
}

variable "dns_domain_name" {
  description = "Domain name for private DNS"
  type        = string
  default     = "internal.local"
}

# Load balancing
variable "enable_load_balancer" {
  description = "Enable application load balancer"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Type of load balancer (application, network, gateway)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network", "gateway"], var.load_balancer_type)
    error_message = "Load balancer type must be one of: application, network, gateway."
  }
}
