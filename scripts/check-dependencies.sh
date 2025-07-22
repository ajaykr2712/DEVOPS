#!/bin/bash

# Dependency Check Script
# Verifies that all required tools are installed and configured properly

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED_CHECKS++))
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check command with version
check_command() {
    local cmd=$1
    local name=${2:-$cmd}
    local min_version=${3:-""}
    
    ((TOTAL_CHECKS++))
    
    if command_exists "$cmd"; then
        local version
        case "$cmd" in
            "docker")
                version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
                ;;
            "docker-compose")
                version=$(docker-compose --version | cut -d' ' -f3 | sed 's/,//')
                ;;
            "terraform")
                version=$(terraform --version | head -n1 | cut -d' ' -f2 | sed 's/v//')
                ;;
            "kubectl")
                version=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 | sed 's/v//')
                ;;
            "go")
                version=$(go version | cut -d' ' -f3 | sed 's/go//')
                ;;
            "python3")
                version=$(python3 --version | cut -d' ' -f2)
                ;;
            "git")
                version=$(git --version | cut -d' ' -f3)
                ;;
            *)
                version=$(${cmd} --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown")
                ;;
        esac
        
        log_success "$name: $version"
        return 0
    else
        log_error "$name: Not installed"
        return 1
    fi
}

# Check file exists
check_file() {
    local file=$1
    local description=$2
    
    ((TOTAL_CHECKS++))
    
    if [[ -f "$file" ]]; then
        log_success "$description: Found"
        return 0
    else
        log_error "$description: Not found"
        return 1
    fi
}

# Check directory exists
check_directory() {
    local dir=$1
    local description=$2
    
    ((TOTAL_CHECKS++))
    
    if [[ -d "$dir" ]]; then
        log_success "$description: Found"
        return 0
    else
        log_error "$description: Not found"
        return 1
    fi
}

# Check Docker daemon
check_docker_daemon() {
    ((TOTAL_CHECKS++))
    
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon: Running"
        return 0
    else
        log_error "Docker daemon: Not running"
        return 1
    fi
}

# Check Python packages
check_python_packages() {
    local packages=("boto3" "requests" "pyyaml" "click" "kubernetes")
    
    for package in "${packages[@]}"; do
        ((TOTAL_CHECKS++))
        if python3 -c "import $package" 2>/dev/null; then
            log_success "Python package $package: Installed"
        else
            log_error "Python package $package: Not installed"
        fi
    done
}

# Check Go modules
check_go_modules() {
    ((TOTAL_CHECKS++))
    
    if [[ -f "automation/go-tools/go.mod" ]]; then
        cd automation/go-tools
        if go mod verify >/dev/null 2>&1; then
            log_success "Go modules: Valid"
            cd ../..
            return 0
        else
            log_error "Go modules: Invalid or missing dependencies"
            cd ../..
            return 1
        fi
    else
        log_error "Go modules: go.mod not found"
        return 1
    fi
}

# Check cloud CLI tools
check_cloud_tools() {
    local tools=("aws" "az" "gcloud")
    
    for tool in "${tools[@]}"; do
        ((TOTAL_CHECKS++))
        if command_exists "$tool"; then
            log_success "Cloud CLI $tool: Installed"
        else
            log_warning "Cloud CLI $tool: Not installed (optional)"
            ((FAILED_CHECKS--))  # Don't count as failure since it's optional
            ((TOTAL_CHECKS--))   # Don't count as total check either
        fi
    done
}

# Check environment configuration
check_environment() {
    ((TOTAL_CHECKS++))
    
    if [[ -f ".env" ]]; then
        log_success "Environment configuration: Found"
        
        # Check if .env is just the template
        if grep -q "your_access_key" .env; then
            log_warning "Environment file appears to be unconfigured template"
        fi
    else
        log_warning "Environment configuration: Not found (run setup.sh to create)"
    fi
}

# Check network connectivity
check_connectivity() {
    local endpoints=("github.com" "docker.io" "registry.terraform.io")
    
    for endpoint in "${endpoints[@]}"; do
        ((TOTAL_CHECKS++))
        if curl -s --connect-timeout 5 "$endpoint" >/dev/null 2>&1; then
            log_success "Connectivity to $endpoint: OK"
        else
            log_error "Connectivity to $endpoint: Failed"
        fi
    done
}

# Main function
main() {
    echo "========================================"
    echo "   DevOps Excellence Dependency Check"
    echo "========================================"
    echo
    
    log_info "Checking core tools..."
    check_command "git" "Git"
    check_command "docker" "Docker"
    check_command "docker-compose" "Docker Compose"
    check_command "terraform" "Terraform"
    check_command "kubectl" "kubectl"
    check_command "python3" "Python 3"
    check_command "go" "Go"
    
    echo
    log_info "Checking Docker daemon..."
    check_docker_daemon
    
    echo
    log_info "Checking project structure..."
    check_directory "infrastructure" "Infrastructure directory"
    check_directory "automation" "Automation directory"
    check_directory "ci-cd" "CI/CD directory"
    check_directory "monitoring" "Monitoring directory"
    check_directory "learning-path" "Learning path directory"
    check_file "README.md" "Main README"
    check_file ".github/workflows/ci.yml" "CI workflow"
    
    echo
    log_info "Checking Python packages..."
    check_python_packages
    
    echo
    log_info "Checking Go modules..."
    check_go_modules
    
    echo
    log_info "Checking cloud CLI tools (optional)..."
    check_cloud_tools
    
    echo
    log_info "Checking environment configuration..."
    check_environment
    
    echo
    log_info "Checking network connectivity..."
    check_connectivity
    
    echo
    log_info "Checking built tools..."
    ((TOTAL_CHECKS++))
    if [[ -f "bin/k8s-toolkit" ]]; then
        log_success "k8s-toolkit: Built"
    else
        log_error "k8s-toolkit: Not built (run 'make build' or setup.sh)"
    fi
    
    echo
    echo "========================================"
    echo "           Summary"
    echo "========================================"
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        log_success "All checks passed! ($PASSED_CHECKS/$TOTAL_CHECKS)"
        echo
        echo "🎉 Your environment is ready for DevOps Excellence!"
        echo
        echo "Next steps:"
        echo "1. Configure your cloud credentials in .env"
        echo "2. Read the Quick Start Guide: docs/quick-start.md"
        echo "3. Explore the learning path: learning-path/"
        echo "4. Try some examples: examples/"
        exit 0
    else
        log_error "$FAILED_CHECKS checks failed out of $TOTAL_CHECKS total"
        echo
        echo "🔧 Some dependencies are missing or misconfigured."
        echo
        echo "To fix issues:"
        echo "1. Run ./scripts/setup.sh to install missing tools"
        echo "2. Check the installation guides in docs/"
        echo "3. Verify your network connectivity"
        echo "4. Check the troubleshooting guide: docs/troubleshooting.md"
        exit 1
    fi
}

# Run main function
main "$@"
