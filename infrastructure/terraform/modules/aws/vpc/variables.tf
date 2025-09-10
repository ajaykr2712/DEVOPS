variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 3
    error_message = "Must specify between 2 and 3 availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost savings (not recommended for production)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for security monitoring"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
