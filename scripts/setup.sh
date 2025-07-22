#!/bin/bash

# DevOps Excellence Environment Setup Script
# This script sets up the development environment for the DevOps Excellence repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install packages based on OS
install_package() {
    local package=$1
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y "$package"
        elif command_exists yum; then
            sudo yum install -y "$package"
        elif command_exists dnf; then
            sudo dnf install -y "$package"
        else
            log_error "Unsupported Linux distribution"
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists brew; then
            brew install "$package"
        else
            log_error "Homebrew not found. Please install Homebrew first."
            return 1
        fi
    else
        log_error "Unsupported operating system: $OSTYPE"
        return 1
    fi
}

# Main setup function
main() {
    log_info "Starting DevOps Excellence environment setup..."
    
    # Create necessary directories
    log_info "Creating project directories..."
    mkdir -p {logs,tmp,config,secrets}
    
    # Check and install Git
    if ! command_exists git; then
        log_warning "Git not found. Installing..."
        install_package git
    else
        log_success "Git is already installed"
    fi
    
    # Check and install Docker
    if ! command_exists docker; then
        log_warning "Docker not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Install Docker on Linux
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker "$USER"
            rm get-docker.sh
            log_warning "Please log out and back in for Docker permissions to take effect"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            log_warning "Please install Docker Desktop for Mac manually from https://docs.docker.com/docker-for-mac/install/"
        fi
    else
        log_success "Docker is already installed"
    fi
    
    # Check and install Docker Compose
    if ! command_exists docker-compose; then
        log_warning "Docker Compose not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install docker-compose
        fi
    else
        log_success "Docker Compose is already installed"
    fi
    
    # Check and install Terraform
    if ! command_exists terraform; then
        log_warning "Terraform not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install terraform
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
        fi
    else
        log_success "Terraform is already installed"
    fi
    
    # Check and install kubectl
    if ! command_exists kubectl; then
        log_warning "kubectl not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm kubectl
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install kubectl
        fi
    else
        log_success "kubectl is already installed"
    fi
    
    # Check and install Python 3
    if ! command_exists python3; then
        log_warning "Python 3 not found. Installing..."
        install_package python3
        install_package python3-pip
    else
        log_success "Python 3 is already installed"
    fi
    
    # Check and install Go
    if ! command_exists go; then
        log_warning "Go not found. Installing..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            GO_VERSION="1.21.0"
            wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            rm "go${GO_VERSION}.linux-amd64.tar.gz"
            log_info "Please run 'source ~/.bashrc' or restart your shell"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install go
        fi
    else
        log_success "Go is already installed"
    fi
    
    # Install Python dependencies
    if [[ -f "automation/python/requirements.txt" ]]; then
        log_info "Installing Python dependencies..."
        python3 -m pip install --user -r automation/python/requirements.txt
        log_success "Python dependencies installed"
    fi
    
    # Build Go tools
    if [[ -d "automation/go-tools" ]]; then
        log_info "Building Go tools..."
        cd automation/go-tools
        go mod tidy
        go build -o ../../bin/k8s-toolkit ./cli/k8s-toolkit/
        cd ../..
        log_success "Go tools built successfully"
    fi
    
    # Set up Git hooks (if .git directory exists)
    if [[ -d ".git" ]]; then
        log_info "Setting up Git hooks..."
        if [[ -f "scripts/pre-commit-hook.sh" ]]; then
            cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
            chmod +x .git/hooks/pre-commit
            log_success "Git hooks installed"
        fi
    fi
    
    # Create environment file template
    if [[ ! -f ".env" ]]; then
        log_info "Creating environment file template..."
        cat > .env << 'EOF'
# DevOps Excellence Environment Configuration
# Copy this file and update with your values

# AWS Configuration
# AWS_ACCESS_KEY_ID=your_access_key
# AWS_SECRET_ACCESS_KEY=your_secret_key
# AWS_DEFAULT_REGION=us-west-2

# Azure Configuration
# AZURE_CLIENT_ID=your_client_id
# AZURE_CLIENT_SECRET=your_client_secret
# AZURE_TENANT_ID=your_tenant_id
# AZURE_SUBSCRIPTION_ID=your_subscription_id

# GCP Configuration
# GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
# GOOGLE_PROJECT=your_project_id

# Kubernetes Configuration
# KUBECONFIG=/path/to/kubeconfig

# Monitoring Configuration
# PROMETHEUS_URL=http://localhost:9090
# GRAFANA_URL=http://localhost:3000

# Notification Configuration
# SLACK_WEBHOOK_URL=your_slack_webhook
# EMAIL_SMTP_SERVER=smtp.gmail.com
# EMAIL_USERNAME=your_email
# EMAIL_PASSWORD=your_password
EOF
        log_success "Environment file template created (.env)"
    fi
    
    # Create config directory structure
    log_info "Creating configuration structure..."
    mkdir -p config/{terraform,kubernetes,monitoring,automation}
    
    # Create example configurations
    if [[ ! -f "config/terraform/terraform.tfvars.example" ]]; then
        cat > config/terraform/terraform.tfvars.example << 'EOF'
# Terraform Variables Example
# Copy this file to terraform.tfvars and update with your values

project_name = "devops-excellence"
environment  = "dev"
region      = "us-west-2"

# Networking
vpc_cidr = "10.0.0.0/16"

# Tags
common_tags = {
  Project     = "devops-excellence"
  Environment = "dev"
  ManagedBy   = "terraform"
}
EOF
        log_success "Terraform config example created"
    fi
    
    # Set up aliases for convenience
    log_info "Setting up useful aliases..."
    cat >> ~/.bashrc << 'EOF'

# DevOps Excellence Aliases
alias tf='terraform'
alias k='kubectl'
alias dc='docker-compose'
alias ll='ls -la'
alias ..='cd ..'
alias grep='grep --color=auto'

# DevOps Excellence Functions
function k8s-health() {
    ./bin/k8s-toolkit health "$@"
}

function aws-cost() {
    python3 automation/python/cloud-management/aws_cost_optimizer.py "$@"
}

function infra-monitor() {
    python3 automation/python/monitoring/infrastructure_monitor.py "$@"
}
EOF
    
    log_success "Aliases added to ~/.bashrc"
    
    # Final verification
    log_info "Verifying installation..."
    
    echo
    echo "=== Installation Verification ==="
    
    tools=("git" "docker" "docker-compose" "terraform" "kubectl" "python3" "go")
    all_good=true
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            version=$($tool --version 2>/dev/null | head -n1 || echo "Unknown version")
            log_success "$tool: $version"
        else
            log_error "$tool: Not found"
            all_good=false
        fi
    done
    
    echo
    if $all_good; then
        log_success "All tools installed successfully!"
        echo
        echo "🎉 Setup Complete! 🎉"
        echo
        echo "Next steps:"
        echo "1. Source your shell configuration: source ~/.bashrc"
        echo "2. Configure your cloud credentials in .env file"
        echo "3. Run ./scripts/check-dependencies.sh to verify everything"
        echo "4. Start with the Quick Start Guide: docs/quick-start.md"
        echo
        echo "Happy DevOps-ing! 🚀"
    else
        log_warning "Some tools failed to install. Please check the errors above and install manually."
        echo
        echo "Manual installation guides:"
        echo "- Docker: https://docs.docker.com/get-docker/"
        echo "- Terraform: https://terraform.io/downloads"
        echo "- kubectl: https://kubernetes.io/docs/tasks/tools/"
        echo "- Go: https://golang.org/doc/install"
    fi
}

# Run main function
main "$@"
