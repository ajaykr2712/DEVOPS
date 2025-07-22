# Infrastructure as Code

This directory contains production-ready Infrastructure as Code (IaC) templates and modules for multiple cloud providers.

## 📁 Structure

```
infrastructure/
├── aws/                    # Amazon Web Services
│   ├── vpc/               # Virtual Private Cloud setups
│   ├── ec2/               # Compute instances
│   ├── rds/               # Managed databases
│   ├── eks/               # Elastic Kubernetes Service
│   └── lambda/            # Serverless functions
├── azure/                 # Microsoft Azure
│   ├── resource-groups/   # Resource organization
│   ├── virtual-networks/  # Networking
│   ├── aks/               # Azure Kubernetes Service
│   └── app-services/      # PaaS offerings
├── gcp/                   # Google Cloud Platform
│   ├── vpc/               # Virtual Private Cloud
│   ├── gke/               # Google Kubernetes Engine
│   ├── cloud-functions/   # Serverless
│   └── cloud-sql/         # Managed databases
├── kubernetes/            # Kubernetes manifests
│   ├── core/              # Core components
│   ├── monitoring/        # Observability
│   ├── security/          # Security policies
│   └── applications/      # Sample applications
└── modules/               # Reusable modules
    ├── networking/        # Common networking patterns
    ├── security/          # Security configurations
    └── monitoring/        # Observability components
```

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.5.0
- Cloud provider CLI tools (aws-cli, az-cli, gcloud)
- kubectl for Kubernetes deployments

### Basic Usage

```bash
# AWS VPC deployment
cd aws/vpc
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply

# Kubernetes cluster
cd kubernetes/core
kubectl apply -f namespace.yaml
kubectl apply -f .
```

## 🏗️ Featured Modules

### 1. Multi-Cloud VPC
- **Location**: `modules/networking/multi-cloud-vpc/`
- **Description**: Standardized VPC setup across AWS, Azure, and GCP
- **Features**: 
  - Consistent CIDR allocation
  - Cross-cloud VPN connectivity
  - Standardized security groups
  - DNS and routing configuration

### 2. Kubernetes Foundation
- **Location**: `kubernetes/core/`
- **Description**: Essential Kubernetes components for production clusters
- **Includes**:
  - Namespace organization
  - RBAC policies
  - Network policies
  - Resource quotas
  - Pod security policies

### 3. Observability Stack
- **Location**: `modules/monitoring/observability-stack/`
- **Description**: Complete monitoring solution
- **Components**:
  - Prometheus for metrics
  - Grafana for visualization
  - Alertmanager for notifications
  - Loki for log aggregation

## 🔧 Advanced Configurations

### Environment Management
Each module supports multiple environments through variable files:

```hcl
# environments/production.tfvars
environment = "production"
instance_count = 5
enable_monitoring = true
backup_retention = 30

# environments/staging.tfvars  
environment = "staging"
instance_count = 2
enable_monitoring = false
backup_retention = 7
```

### Security Hardening
All modules include security best practices:
- Encrypted storage and transmission
- Principle of least privilege
- Regular security updates
- Compliance with industry standards

### Cost Optimization
- Right-sizing recommendations
- Automated resource cleanup
- Reserved instance planning
- Multi-cloud cost comparison

## 📊 Monitoring and Maintenance

### Health Checks
```bash
# Run validation across all modules
./scripts/validate-infrastructure.sh

# Security scanning
./scripts/security-scan.sh

# Cost analysis
./scripts/cost-analysis.sh
```

### Backup and Recovery
- Automated backup schedules
- Cross-region replication
- Disaster recovery procedures
- Recovery time objectives (RTO) < 4 hours

## 🔗 Related Resources

- [Automation Scripts](../automation/) - Complementary automation tools
- [CI/CD Pipelines](../ci-cd/) - Infrastructure deployment pipelines
- [Security Policies](../security/) - Security configurations
- [Monitoring](../monitoring/) - Observability configurations

## 📝 Best Practices

1. **Version Control**: Always use terraform state versioning
2. **Environment Isolation**: Separate state files per environment
3. **Module Versioning**: Pin module versions for stability
4. **Security**: Never commit secrets to version control
5. **Documentation**: Maintain up-to-date README for each module

## 🤝 Contributing

When contributing infrastructure code:
1. Follow Terraform best practices
2. Include comprehensive documentation
3. Add examples and test cases
4. Ensure security compliance
5. Test in isolated environments first

---

For detailed implementation guides, see the [documentation](../docs/infrastructure/) section.
