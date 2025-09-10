.PHONY: help setup test lint format clean install validate deploy monitor security backup

# Shell configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Project configuration
PROJECT_NAME := devops-excellence
PYTHON_VERSION := 3.11
GO_VERSION := 1.21
NODE_VERSION := 18

# Directories
ROOT_DIR := $(shell pwd)
SCRIPTS_DIR := $(ROOT_DIR)/scripts
TERRAFORM_DIR := $(ROOT_DIR)/infrastructure/terraform
KUBERNETES_DIR := $(ROOT_DIR)/kubernetes
AUTOMATION_DIR := $(ROOT_DIR)/automation

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Default target
help: ## Show this help message
	@echo -e "$(BLUE)DevOps Excellence Makefile$(NC)"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Environment setup
setup: ## Setup complete development environment
	@echo -e "$(BLUE)Setting up DevOps Excellence environment...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/setup.sh
	@$(SCRIPTS_DIR)/setup.sh
	@$(MAKE) install

install: ## Install all dependencies
	@echo -e "$(BLUE)Installing dependencies...$(NC)"
	@$(MAKE) install-python
	@$(MAKE) install-go
	@$(MAKE) install-node
	@$(MAKE) install-tools

install-python: ## Install Python dependencies
	@echo -e "$(YELLOW)Installing Python dependencies...$(NC)"
	@cd $(AUTOMATION_DIR)/python && pip3 install -r requirements.txt

install-go: ## Install Go dependencies
	@echo -e "$(YELLOW)Installing Go dependencies...$(NC)"
	@if [ -d "$(AUTOMATION_DIR)/go" ]; then \
		cd $(AUTOMATION_DIR)/go && go mod download; \
	fi

install-node: ## Install Node.js dependencies
	@echo -e "$(YELLOW)Installing Node.js dependencies...$(NC)"
	@if [ -f "package.json" ]; then \
		npm install; \
	fi

install-tools: ## Install development tools
	@echo -e "$(YELLOW)Installing development tools...$(NC)"
	@pip3 install pre-commit
	@pre-commit install

# Testing
test: ## Run all tests
	@echo -e "$(BLUE)Running all tests...$(NC)"
	@$(MAKE) test-python
	@$(MAKE) test-go
	@$(MAKE) test-terraform
	@$(MAKE) test-kubernetes

test-python: ## Run Python tests
	@echo -e "$(YELLOW)Running Python tests...$(NC)"
	@cd $(AUTOMATION_DIR)/python && python -m pytest tests/ -v --cov=. --cov-report=term-missing

test-go: ## Run Go tests
	@echo -e "$(YELLOW)Running Go tests...$(NC)"
	@if [ -d "$(AUTOMATION_DIR)/go" ]; then \
		cd $(AUTOMATION_DIR)/go && go test ./... -v; \
	fi

test-terraform: ## Validate Terraform configurations
	@echo -e "$(YELLOW)Testing Terraform configurations...$(NC)"
	@find $(TERRAFORM_DIR) -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do \
		echo "Validating $$dir"; \
		cd "$$dir" && terraform fmt -check && terraform validate; \
	done

test-kubernetes: ## Validate Kubernetes manifests
	@echo -e "$(YELLOW)Testing Kubernetes manifests...$(NC)"
	@find $(KUBERNETES_DIR) -name "*.yaml" -exec kubectl apply --dry-run=client --validate=true -f {} \;

# Linting and formatting
lint: ## Run all linting
	@echo -e "$(BLUE)Running linters...$(NC)"
	@$(MAKE) lint-python
	@$(MAKE) lint-go
	@$(MAKE) lint-yaml
	@$(MAKE) lint-terraform

lint-python: ## Lint Python code
	@echo -e "$(YELLOW)Linting Python code...$(NC)"
	@cd $(AUTOMATION_DIR)/python && flake8 .
	@cd $(AUTOMATION_DIR)/python && black --check .
	@cd $(AUTOMATION_DIR)/python && isort --check-only .

lint-go: ## Lint Go code
	@echo -e "$(YELLOW)Linting Go code...$(NC)"
	@if [ -d "$(AUTOMATION_DIR)/go" ]; then \
		cd $(AUTOMATION_DIR)/go && golint ./...; \
		cd $(AUTOMATION_DIR)/go && go vet ./...; \
	fi

lint-yaml: ## Lint YAML files
	@echo -e "$(YELLOW)Linting YAML files...$(NC)"
	@find . -name "*.yaml" -o -name "*.yml" | grep -v node_modules | xargs yamllint

lint-terraform: ## Lint Terraform files
	@echo -e "$(YELLOW)Linting Terraform files...$(NC)"
	@terraform fmt -check -recursive $(TERRAFORM_DIR)

format: ## Format all code
	@echo -e "$(BLUE)Formatting code...$(NC)"
	@$(MAKE) format-python
	@$(MAKE) format-go
	@$(MAKE) format-terraform

format-python: ## Format Python code
	@echo -e "$(YELLOW)Formatting Python code...$(NC)"
	@cd $(AUTOMATION_DIR)/python && black .
	@cd $(AUTOMATION_DIR)/python && isort .

format-go: ## Format Go code
	@echo -e "$(YELLOW)Formatting Go code...$(NC)"
	@if [ -d "$(AUTOMATION_DIR)/go" ]; then \
		cd $(AUTOMATION_DIR)/go && gofmt -w .; \
	fi

format-terraform: ## Format Terraform files
	@echo -e "$(YELLOW)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive $(TERRAFORM_DIR)

# Security
security: ## Run security scans
	@echo -e "$(BLUE)Running security scans...$(NC)"
	@$(MAKE) security-python
	@$(MAKE) security-terraform
	@$(MAKE) security-docker

security-python: ## Run Python security scan
	@echo -e "$(YELLOW)Scanning Python code for security issues...$(NC)"
	@cd $(AUTOMATION_DIR)/python && bandit -r . -f json -o security-report.json
	@cd $(AUTOMATION_DIR)/python && safety check

security-terraform: ## Run Terraform security scan
	@echo -e "$(YELLOW)Scanning Terraform for security issues...$(NC)"
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d $(TERRAFORM_DIR) --framework terraform; \
	else \
		echo "Checkov not installed. Install with: pip install checkov"; \
	fi

security-docker: ## Run Docker security scan
	@echo -e "$(YELLOW)Scanning Docker images for vulnerabilities...$(NC)"
	@if command -v trivy >/dev/null 2>&1; then \
		find . -name "Dockerfile" | while read dockerfile; do \
			echo "Scanning $$dockerfile"; \
			trivy fs $$(dirname "$$dockerfile"); \
		done; \
	else \
		echo "Trivy not installed. Install from: https://aquasecurity.github.io/trivy/"; \
	fi

# Infrastructure deployment
deploy: ## Deploy infrastructure (dev environment)
	@echo -e "$(BLUE)Deploying to development environment...$(NC)"
	@$(MAKE) deploy-dev

deploy-dev: ## Deploy to development environment
	@echo -e "$(YELLOW)Deploying to development...$(NC)"
	@cd $(TERRAFORM_DIR)/environments/dev && terraform init && terraform plan && terraform apply -auto-approve
	@$(MAKE) deploy-k8s-dev

deploy-staging: ## Deploy to staging environment
	@echo -e "$(YELLOW)Deploying to staging...$(NC)"
	@cd $(TERRAFORM_DIR)/environments/staging && terraform init && terraform plan && terraform apply -auto-approve
	@$(MAKE) deploy-k8s-staging

deploy-prod: ## Deploy to production environment (requires confirmation)
	@echo -e "$(RED)WARNING: This will deploy to PRODUCTION!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		cd $(TERRAFORM_DIR)/environments/production && terraform init && terraform plan && terraform apply; \
		$(MAKE) deploy-k8s-prod; \
	else \
		echo ""; \
		echo "Deployment cancelled."; \
	fi

deploy-k8s-dev: ## Deploy Kubernetes resources to dev
	@echo -e "$(YELLOW)Deploying Kubernetes resources to dev...$(NC)"
	@kubectl apply -f $(KUBERNETES_DIR)/base/ --context=dev-cluster

deploy-k8s-staging: ## Deploy Kubernetes resources to staging
	@echo -e "$(YELLOW)Deploying Kubernetes resources to staging...$(NC)"
	@kubectl apply -f $(KUBERNETES_DIR)/base/ --context=staging-cluster

deploy-k8s-prod: ## Deploy Kubernetes resources to production
	@echo -e "$(YELLOW)Deploying Kubernetes resources to production...$(NC)"
	@kubectl apply -f $(KUBERNETES_DIR)/base/ --context=prod-cluster

# Monitoring and observability
monitor: ## Start monitoring stack
	@echo -e "$(BLUE)Starting monitoring stack...$(NC)"
	@cd monitoring && docker-compose up -d
	@echo -e "$(GREEN)Monitoring stack started!$(NC)"
	@echo "Grafana: http://localhost:3000 (admin/devops-excellence)"
	@echo "Prometheus: http://localhost:9090"
	@echo "AlertManager: http://localhost:9093"

monitor-stop: ## Stop monitoring stack
	@echo -e "$(YELLOW)Stopping monitoring stack...$(NC)"
	@cd monitoring && docker-compose down

monitor-logs: ## Show monitoring stack logs
	@cd monitoring && docker-compose logs -f

# Infrastructure management
infra-check: ## Check infrastructure health
	@echo -e "$(BLUE)Checking infrastructure health...$(NC)"
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py aws list-resources
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py k8s health-check

infra-optimize: ## Analyze cost optimization opportunities
	@echo -e "$(BLUE)Analyzing cost optimization...$(NC)"
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py aws optimize-costs

# Backup and disaster recovery
backup: ## Create full backup
	@echo -e "$(BLUE)Creating full backup...$(NC)"
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py backup create --type full

backup-aws: ## Create AWS backup
	@echo -e "$(BLUE)Creating AWS backup...$(NC)"
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py backup create --type aws

backup-k8s: ## Create Kubernetes backup
	@echo -e "$(BLUE)Creating Kubernetes backup...$(NC)"
	@python3 $(AUTOMATION_DIR)/python/infrastructure_manager.py backup create --type k8s

# Documentation
docs: ## Generate documentation
	@echo -e "$(BLUE)Generating documentation...$(NC)"
	@cd docs && sphinx-build -b html . _build/html
	@echo -e "$(GREEN)Documentation generated in docs/_build/html/$(NC)"

docs-serve: ## Serve documentation locally
	@echo -e "$(BLUE)Serving documentation...$(NC)"
	@cd docs/_build/html && python3 -m http.server 8000

# Cleanup
clean: ## Clean temporary files and caches
	@echo -e "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} +
	@find . -name "*.tfstate.backup" -delete
	@find . -name ".terraform" -type d -exec rm -rf {} +
	@find . -name "node_modules" -type d -exec rm -rf {} +
	@find . -name "*.log" -delete
	@echo -e "$(GREEN)Cleanup completed!$(NC)"

destroy: ## Destroy all infrastructure (DANGEROUS!)
	@echo -e "$(RED)WARNING: This will DESTROY all infrastructure!$(NC)"
	@read -p "Are you absolutely sure? Type 'destroy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy" ]; then \
		echo "Destroying infrastructure..."; \
		cd $(TERRAFORM_DIR)/environments/dev && terraform destroy -auto-approve; \
		cd $(TERRAFORM_DIR)/environments/staging && terraform destroy -auto-approve; \
		echo -e "$(RED)Infrastructure destroyed!$(NC)"; \
	else \
		echo "Destruction cancelled."; \
	fi

# Utility targets
validate: ## Validate all configurations
	@echo -e "$(BLUE)Validating all configurations...$(NC)"
	@$(MAKE) test-terraform
	@$(MAKE) test-kubernetes
	@$(MAKE) lint

build: ## Build all applications
	@echo -e "$(BLUE)Building applications...$(NC)"
	@if [ -d "$(AUTOMATION_DIR)/go" ]; then \
		cd $(AUTOMATION_DIR)/go && go build ./...; \
	fi
	@find . -name "Dockerfile" | while read dockerfile; do \
		dir=$$(dirname "$$dockerfile"); \
		echo "Building Docker image in $$dir"; \
		docker build -t devops-excellence/$$(basename "$$dir"):latest "$$dir"; \
	done

status: ## Show project status
	@echo -e "$(BLUE)DevOps Excellence Project Status$(NC)"
	@echo ""
	@echo -e "$(YELLOW)Infrastructure:$(NC)"
	@if command -v terraform >/dev/null 2>&1; then \
		cd $(TERRAFORM_DIR)/environments/dev && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[] | select(.type == "aws_instance") | .values.tags.Name' 2>/dev/null || echo "No dev infrastructure deployed"; \
	fi
	@echo ""
	@echo -e "$(YELLOW)Kubernetes:$(NC)"
	@if command -v kubectl >/dev/null 2>&1; then \
		kubectl get nodes 2>/dev/null || echo "No Kubernetes cluster accessible"; \
	fi
	@echo ""
	@echo -e "$(YELLOW)Monitoring:$(NC)"
	@if docker ps | grep -q prometheus; then \
		echo "✓ Monitoring stack is running"; \
	else \
		echo "✗ Monitoring stack is not running"; \
	fi

# Quick commands
dev: ## Quick development setup
	@$(MAKE) setup
	@$(MAKE) monitor
	@$(MAKE) deploy-dev

ci: ## Run CI pipeline locally
	@$(MAKE) lint
	@$(MAKE) test
	@$(MAKE) security
	@$(MAKE) build

release: ## Prepare release
	@$(MAKE) ci
	@$(MAKE) docs
	@echo -e "$(GREEN)Release preparation completed!$(NC)"
