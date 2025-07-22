# Multi-Cloud VPC Terraform Configuration

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge(var.common_tags, {
      Provider = "AWS"
      Module   = "multi-cloud-vpc"
    })
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Google Cloud Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Local values for consistent naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "multi-cloud-vpc"
  })
}

# AWS VPC
resource "aws_vpc" "main" {
  cidr_block           = var.aws_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-aws"
  })
}

# AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw-aws"
  })
}

# AWS Public Subnets
resource "aws_subnet" "public" {
  count = length(var.aws_availability_zones)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.aws_cidr, 8, count.index + 1)
  availability_zone       = var.aws_availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${substr(var.aws_availability_zones[count.index], -1, 1)}"
    Type = "public"
  })
}

# AWS Private Subnets
resource "aws_subnet" "private" {
  count = length(var.aws_availability_zones)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.aws_cidr, 8, count.index + 10)
  availability_zone = var.aws_availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${substr(var.aws_availability_zones[count.index], -1, 1)}"
    Type = "private"
  })
}

# AWS NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.aws_availability_zones) : 0
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-eip-nat-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.aws_availability_zones) : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# AWS Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt-public"
  })
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.aws_availability_zones) : 1
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt-private-${count.index + 1}"
  })
}

# AWS Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# AWS Security Groups
resource "aws_security_group" "default" {
  name_prefix = "${local.name_prefix}-default-"
  description = "Default security group for ${local.name_prefix}"
  vpc_id      = aws_vpc.main.id
  
  # Allow inbound traffic from VPC CIDR
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.aws_cidr]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-default"
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# AWS VPC Flow Logs
resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0
  
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  
  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name              = "/aws/vpc/flowlogs/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  
  tags = local.common_tags
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name_prefix = "${local.name_prefix}-flow-log-"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  
  name_prefix = "${local.name_prefix}-flow-log-"
  role        = aws_iam_role.flow_log[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
