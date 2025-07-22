# Quick Start Guide

Get up and running with the DevOps Excellence repository in under 10 minutes!

## ⚡ Prerequisites

Before you begin, ensure you have:

- **Git** installed ([Download Git](https://git-scm.com/downloads))
- **Docker** installed ([Download Docker](https://docs.docker.com/get-docker/))
- **Text editor** (VS Code, Vim, etc.)
- **Terminal/Command line** access

### For Cloud Resources (Optional)
- AWS/Azure/GCP account
- Terraform installed ([Download Terraform](https://terraform.io/downloads))
- kubectl installed ([Download kubectl](https://kubernetes.io/docs/tasks/tools/))

## 🚀 5-Minute Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/devops-excellence.git
cd devops-excellence
```

### 2. Initialize Your Environment
```bash
# Make setup script executable
chmod +x scripts/setup.sh

# Run the setup script
./scripts/setup.sh
```

### 3. Verify Installation
```bash
# Check if all tools are installed
./scripts/check-dependencies.sh
```

## 🎯 Choose Your Adventure

### 🌱 New to DevOps?
**Start Here**: [Beginner Learning Path](./learning-path/beginner/)

```bash
cd learning-path/beginner/
cat README.md
```

### 🚀 Ready for Hands-on Projects?
**Deploy Something**: [Example Projects](./examples/)

```bash
# Deploy a sample microservices app
cd examples/microservices-platform/
docker-compose up -d
```

### 🏗️ Infrastructure Focus?
**Build Infrastructure**: [Infrastructure as Code](./infrastructure/)

```bash
# Create a VPC on AWS
cd infrastructure/aws/vpc/
terraform init
terraform plan -var-file="environments/dev.tfvars"
```

### 🔧 Automation Tools?
**Automate Operations**: [Automation Scripts](./automation/)

```bash
# Run AWS cost optimization
cd automation/python/cloud-management/
python aws_cost_optimizer.py --profile default
```

## 📊 Popular Starting Points

### 1. Deploy Your First Container
```bash
# Navigate to examples
cd examples/simple-web-app/

# Build and run
docker build -t my-web-app .
docker run -p 8080:80 my-web-app

# Visit http://localhost:8080
```

### 2. Create Cloud Infrastructure
```bash
# Navigate to infrastructure
cd infrastructure/modules/networking/multi-cloud-vpc/

# Review the example
cat examples/basic/main.tf

# Initialize and plan
terraform init
terraform plan
```

### 3. Monitor Infrastructure
```bash
# Navigate to monitoring
cd monitoring/prometheus/

# Deploy monitoring stack
docker-compose up -d

# Access Grafana at http://localhost:3000
# Default login: admin/admin
```

### 4. Set Up CI/CD Pipeline
```bash
# Navigate to CI/CD examples
cd ci-cd/github-actions/

# Copy workflow to your repo
cp workflows/comprehensive-pipeline.yml .github/workflows/

# Commit and push to trigger pipeline
git add .github/workflows/
git commit -m "Add CI/CD pipeline"
git push
```

## 🔧 Essential Commands

### Infrastructure Management
```bash
# Terraform operations
terraform init      # Initialize working directory
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform destroy   # Destroy infrastructure

# Kubernetes operations
kubectl get pods           # List pods
kubectl describe pod NAME  # Pod details
kubectl logs POD_NAME      # Pod logs
kubectl apply -f file.yaml # Apply configuration
```

### Container Operations
```bash
# Docker operations
docker build -t name .     # Build image
docker run name           # Run container
docker ps                # List running containers
docker logs CONTAINER    # View logs
docker exec -it NAME bash # Access container shell

# Docker Compose operations
docker-compose up -d      # Start services in background
docker-compose down       # Stop and remove services
docker-compose logs       # View logs
docker-compose ps         # List services
```

### Cloud CLI
```bash
# AWS CLI
aws sts get-caller-identity  # Check AWS credentials
aws ec2 describe-instances   # List EC2 instances
aws s3 ls                   # List S3 buckets

# Azure CLI
az account show             # Check Azure account
az vm list                  # List virtual machines
az storage account list     # List storage accounts

# Google Cloud CLI
gcloud auth list           # Check authentication
gcloud compute instances list # List compute instances
gcloud projects list       # List projects
```

## 🎨 Customization

### Configuration Files
Most tools use configuration files you can customize:

```bash
# Terraform variables
cp infrastructure/aws/vpc/environments/dev.tfvars.example environments/dev.tfvars
# Edit the file with your values

# Python automation config
cp automation/python/config/config.json.example config/config.json
# Update with your settings

# Monitoring configuration
cp monitoring/prometheus/prometheus.yml.example prometheus.yml
# Customize your monitoring targets
```

### Environment Variables
Set up your environment variables:

```bash
# AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"

# Azure credentials
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_TENANT_ID="your-tenant-id"

# GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
export GOOGLE_PROJECT="your-project-id"
```

## 🧪 Test Your Setup

### Run Health Checks
```bash
# Check Kubernetes cluster health
cd automation/go-tools/cli/k8s-toolkit/
go run main.go health

# Monitor infrastructure health
cd automation/python/monitoring/
python infrastructure_monitor.py --once

# Validate Terraform configurations
find infrastructure/ -name "*.tf" -exec terraform fmt -check {} \;
```

### Sample Deployments
```bash
# Deploy sample microservices
cd examples/microservices-platform/
./deploy.sh

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/api/users
```

## 🆘 Troubleshooting

### Common Issues

**Permission Denied**
```bash
# Make scripts executable
chmod +x script-name.sh

# Check Docker permissions
sudo usermod -aG docker $USER
# Log out and back in
```

**Terraform Issues**
```bash
# Clear cache and reinitialize
rm -rf .terraform/
terraform init

# Check provider versions
terraform version
```

**Docker Issues**
```bash
# Check Docker daemon
docker info

# Clean up resources
docker system prune -f
```

**Network Issues**
```bash
# Check port availability
netstat -tulpn | grep :8080

# Test connectivity
telnet hostname port
```

### Getting Help

1. **Check the logs** - Most issues are logged
2. **Read error messages** - They usually tell you what's wrong
3. **Check documentation** - Each directory has detailed READMEs
4. **Search issues** - Look for similar problems in the repo
5. **Ask for help** - Create an issue or discussion

## 📚 Next Steps

### Learn More
- [Complete Learning Path](./learning-path/) - Structured curriculum
- [Best Practices](./docs/best-practices/) - Industry standards
- [Architecture Guides](./docs/architecture/) - Design patterns
- [Troubleshooting](./docs/troubleshooting/) - Common solutions

### Join the Community
- [GitHub Discussions](https://github.com/your-repo/discussions)
- [Contributing Guide](./.github/CONTRIBUTING.md)
- [Code of Conduct](./.github/CODE_OF_CONDUCT.md)

### Stay Updated
- ⭐ Star the repository
- 👀 Watch for updates
- 🍴 Fork and customize
- 📝 Share your improvements

---

## 🎉 You're Ready!

You now have a complete DevOps environment ready for learning and experimentation. Choose your path:

- **🎓 Learn**: Start with the [Learning Path](./learning-path/)
- **🏗️ Build**: Explore [Examples](./examples/)
- **🚀 Deploy**: Use [Infrastructure](./infrastructure/)
- **🔧 Automate**: Try [Automation Tools](./automation/)

**Happy DevOps-ing!** 🚀

---

> "The best time to start was yesterday. The second best time is now." - Begin your DevOps journey today!
