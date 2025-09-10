#!/bin/bash

# 🚀 DevOps Excellence Repository Setup Script
# This script sets up a production-ready DevOps repository with best practices

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${REPO_ROOT}/setup.log"

# Utility functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    local tools=("git" "docker" "kubectl" "terraform" "helm" "python3" "go" "node")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        warn "Missing tools: ${missing_tools[*]}"
        info "Please install missing tools and run setup again"
        info "Installation guides: https://github.com/your-repo/docs/prerequisites.md"
    else
        log "All prerequisites satisfied ✓"
    fi
}

# Create directory structure
create_directory_structure() {
    log "Creating directory structure..."
    
    local directories=(
        ".github/workflows"
        ".github/ISSUE_TEMPLATE"
        "infrastructure/terraform/modules/aws"
        "infrastructure/terraform/modules/azure"
        "infrastructure/terraform/modules/gcp"
        "infrastructure/terraform/modules/shared"
        "infrastructure/terraform/environments/dev"
        "infrastructure/terraform/environments/staging"
        "infrastructure/terraform/environments/production"
        "infrastructure/terraform/examples"
        "infrastructure/helm/charts"
        "infrastructure/helm/values"
        "infrastructure/ansible/playbooks"
        "infrastructure/ansible/roles"
        "infrastructure/ansible/inventory"
        "kubernetes/base"
        "kubernetes/overlays"
        "kubernetes/operators"
        "kubernetes/policies"
        "kubernetes/examples"
        "ci-cd/github-actions"
        "ci-cd/gitlab-ci"
        "ci-cd/jenkins"
        "ci-cd/argo-workflows"
        "ci-cd/tekton"
        "monitoring/prometheus"
        "monitoring/grafana"
        "monitoring/alertmanager"
        "monitoring/jaeger"
        "monitoring/fluent-bit"
        "monitoring/uptime"
        "security/policies"
        "security/vault"
        "security/falco"
        "security/trivy"
        "security/gatekeeper"
        "automation/python"
        "automation/go"
        "automation/bash"
        "automation/powershell"
        "automation/tools"
        "applications/microservices"
        "applications/monolith"
        "applications/serverless"
        "applications/legacy"
        "docs/architecture"
        "docs/runbooks"
        "docs/guides"
        "docs/standards"
        "docs/api"
        "examples/full-stack-deployment"
        "examples/disaster-recovery"
        "examples/cost-optimization"
        "examples/migration"
        "tests/infrastructure"
        "tests/security"
        "tests/performance"
        "tests/integration"
        "tools/cli"
        "tools/vscode"
        "tools/makefile"
        "tools/docker"
        "community/contributing"
        "community/templates"
        "community/examples"
        "community/feedback"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$REPO_ROOT/$dir"
        touch "$REPO_ROOT/$dir/.gitkeep"
    done
    
    log "Directory structure created ✓"
}

# Setup Git hooks
setup_git_hooks() {
    log "Setting up Git hooks..."
    
    # Pre-commit hook
    cat > "$REPO_ROOT/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for DevOps repository

set -e

echo "Running pre-commit checks..."

# Check for secrets
if command -v git-secrets &> /dev/null; then
    git secrets --scan
fi

# Terraform format check
if command -v terraform &> /dev/null; then
    find . -name "*.tf" -exec terraform fmt -check=true {} \;
fi

# Python linting
if command -v flake8 &> /dev/null; then
    find . -name "*.py" -exec flake8 {} \;
fi

# YAML linting
if command -v yamllint &> /dev/null; then
    find . -name "*.yaml" -o -name "*.yml" | xargs yamllint
fi

echo "Pre-commit checks passed ✓"
EOF

    chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
    
    # Pre-push hook
    cat > "$REPO_ROOT/.git/hooks/pre-push" << 'EOF'
#!/bin/bash
# Pre-push hook for DevOps repository

set -e

echo "Running pre-push checks..."

# Run tests if they exist
if [ -f "scripts/test.sh" ]; then
    ./scripts/test.sh
fi

echo "Pre-push checks passed ✓"
EOF

    chmod +x "$REPO_ROOT/.git/hooks/pre-push"
    
    log "Git hooks configured ✓"
}

# Create configuration files
create_config_files() {
    log "Creating configuration files..."
    
    # .gitignore
    cat > "$REPO_ROOT/.gitignore" << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.tfplan

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.env
.venv
pip-log.txt
pip-delete-this-directory.txt

# Go
vendor/
*.exe
*.test
*.prof

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Secrets and sensitive data
*.pem
*.key
secrets/
.secrets
*.env.local
*.env.production

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
*.tmp
*.temp

# Build artifacts
dist/
build/
target/

# Kubernetes
*.kubeconfig

# Helm
charts/*.tgz

# Docker
.dockerignore
EOF

    # EditorConfig
    cat > "$REPO_ROOT/.editorconfig" << 'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,py,go,tf,yaml,yml,json}]
indent_style = space
indent_size = 2

[*.{py,go}]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF

    # Pre-commit configuration
    cat > "$REPO_ROOT/.pre-commit-config.yaml" << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key

  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.2
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint

  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black

  - repo: https://github.com/adrienverge/yamllint
    rev: v1.32.0
    hooks:
      - id: yamllint
EOF

    log "Configuration files created ✓"
}

# Install development tools
install_dev_tools() {
    log "Installing development tools..."
    
    # Install pre-commit if not present
    if ! command -v pre-commit &> /dev/null; then
        if command -v pip3 &> /dev/null; then
            pip3 install pre-commit
        else
            warn "pip3 not found, skipping pre-commit installation"
        fi
    fi
    
    # Install pre-commit hooks
    if command -v pre-commit &> /dev/null; then
        cd "$REPO_ROOT" && pre-commit install
    fi
    
    log "Development tools installed ✓"
}

# Create initial documentation
create_initial_docs() {
    log "Creating initial documentation..."
    
    # Contributing guidelines
    cat > "$REPO_ROOT/CONTRIBUTING.md" << 'EOF'
# Contributing to DevOps Excellence

Thank you for your interest in contributing! This document provides guidelines for contributing to this repository.

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Development Setup

Run the setup script:
```bash
./scripts/setup.sh
```

## Testing

Before submitting a PR, ensure:
- All tests pass: `./scripts/test.sh`
- Code is properly formatted
- Documentation is updated

## Commit Messages

Follow conventional commits:
- `feat: add new feature`
- `fix: resolve issue`
- `docs: update documentation`
- `test: add tests`
- `refactor: code refactoring`

## Pull Request Guidelines

- Include description of changes
- Reference related issues
- Add tests for new functionality
- Update documentation as needed
EOF

    log "Initial documentation created ✓"
}

# Setup Makefile
create_makefile() {
    log "Creating Makefile..."
    
    cat > "$REPO_ROOT/Makefile" << 'EOF'
.PHONY: help setup test lint format clean install validate

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Setup development environment
	@echo "Setting up development environment..."
	./scripts/setup.sh

test: ## Run all tests
	@echo "Running tests..."
	./scripts/test.sh

lint: ## Run linting
	@echo "Running linters..."
	pre-commit run --all-files

format: ## Format code
	@echo "Formatting code..."
	terraform fmt -recursive infrastructure/
	black automation/python/
	gofmt -w automation/go/

validate: ## Validate configurations
	@echo "Validating configurations..."
	find infrastructure/ -name "*.tf" -exec terraform validate {} \;
	find kubernetes/ -name "*.yaml" -exec kubectl --dry-run=client apply -f {} \;

install: ## Install dependencies
	@echo "Installing dependencies..."
	pip3 install -r automation/python/requirements.txt
	cd automation/go && go mod download

clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	find . -name "*.tfstate*" -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "__pycache__" -type d -exec rm -rf {} +
	find . -name "*.pyc" -delete

deploy-dev: ## Deploy to development environment
	@echo "Deploying to development..."
	cd infrastructure/terraform/environments/dev && terraform apply

deploy-staging: ## Deploy to staging environment
	@echo "Deploying to staging..."
	cd infrastructure/terraform/environments/staging && terraform apply

deploy-prod: ## Deploy to production environment
	@echo "Deploying to production..."
	cd infrastructure/terraform/environments/production && terraform apply
EOF

    log "Makefile created ✓"
}

# Main setup function
main() {
    log "🚀 Starting DevOps Excellence Repository Setup"
    
    # Remove existing log file
    rm -f "$LOG_FILE"
    
    # Run setup steps
    check_prerequisites
    create_directory_structure
    setup_git_hooks
    create_config_files
    install_dev_tools
    create_initial_docs
    create_makefile
    
    log "✅ Setup completed successfully!"
    info "Next steps:"
    info "1. Review the ENHANCEMENT_ROADMAP.md"
    info "2. Check the REPOSITORY_STRUCTURE.md"
    info "3. Run 'make help' to see available commands"
    info "4. Start with 'make validate' to verify your setup"
    info ""
    info "Happy DevOps-ing! 🎉"
}

# Run main function
main "$@"
