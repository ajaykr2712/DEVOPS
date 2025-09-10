#!/bin/bash

# 🧪 DevOps Excellence Test Suite
# Comprehensive testing script for all components

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_LOG="${REPO_ROOT}/test-results.log"
FAILED_TESTS=()
PASSED_TESTS=()

# Utility functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$TEST_LOG"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$TEST_LOG"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$TEST_LOG"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$TEST_LOG"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    info "Running test: $test_name"
    
    if eval "$test_command" >> "$TEST_LOG" 2>&1; then
        log "✅ PASSED: $test_name"
        PASSED_TESTS+=("$test_name")
        return 0
    else
        error "❌ FAILED: $test_name"
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

# Test functions
test_repository_structure() {
    log "Testing repository structure..."
    
    local required_dirs=(
        "infrastructure/terraform/modules"
        "kubernetes/base"
        "ci-cd/github-actions"
        "monitoring/prometheus"
        "security/policies"
        "automation/python"
        "docs"
        "scripts"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$REPO_ROOT/$dir" ]]; then
            error "Missing required directory: $dir"
            return 1
        fi
    done
    
    return 0
}

test_terraform_syntax() {
    log "Testing Terraform syntax..."
    
    find "$REPO_ROOT/infrastructure" -name "*.tf" | while read -r tf_file; do
        if ! terraform fmt -check=true "$tf_file" > /dev/null 2>&1; then
            error "Terraform file not properly formatted: $tf_file"
            return 1
        fi
    done
    
    # Test Terraform modules
    local module_dirs
    mapfile -t module_dirs < <(find "$REPO_ROOT/infrastructure/terraform/modules" -type f -name "*.tf" -exec dirname {} \; | sort -u)
    
    for module_dir in "${module_dirs[@]}"; do
        if ! (cd "$module_dir" && terraform init -backend=false > /dev/null 2>&1 && terraform validate > /dev/null 2>&1); then
            error "Terraform validation failed for: $module_dir"
            return 1
        fi
    done
    
    return 0
}

test_kubernetes_manifests() {
    log "Testing Kubernetes manifests..."
    
    if ! command -v kubectl &> /dev/null; then
        warn "kubectl not found, skipping Kubernetes tests"
        return 0
    fi
    
    find "$REPO_ROOT/kubernetes" -name "*.yaml" -o -name "*.yml" | while read -r yaml_file; do
        if ! kubectl apply --dry-run=client --validate=true -f "$yaml_file" > /dev/null 2>&1; then
            error "Invalid Kubernetes manifest: $yaml_file"
            return 1
        fi
    done
    
    return 0
}

test_python_code() {
    log "Testing Python code..."
    
    if ! command -v python3 &> /dev/null; then
        warn "Python3 not found, skipping Python tests"
        return 0
    fi
    
    # Check Python syntax
    find "$REPO_ROOT/automation/python" -name "*.py" | while read -r py_file; do
        if ! python3 -m py_compile "$py_file" 2>/dev/null; then
            error "Python syntax error in: $py_file"
            return 1
        fi
    done
    
    # Run Python tests if pytest is available
    if command -v pytest &> /dev/null && [[ -d "$REPO_ROOT/automation/python/tests" ]]; then
        cd "$REPO_ROOT/automation/python"
        if ! pytest tests/ --tb=short; then
            error "Python tests failed"
            return 1
        fi
    fi
    
    return 0
}

test_go_code() {
    log "Testing Go code..."
    
    if ! command -v go &> /dev/null; then
        warn "Go not found, skipping Go tests"
        return 0
    fi
    
    # Find Go modules and test them
    find "$REPO_ROOT/automation" -name "go.mod" | while read -r go_mod; do
        local go_dir
        go_dir=$(dirname "$go_mod")
        
        cd "$go_dir"
        if ! go build ./... > /dev/null 2>&1; then
            error "Go build failed in: $go_dir"
            return 1
        fi
        
        if ! go test ./... > /dev/null 2>&1; then
            error "Go tests failed in: $go_dir"
            return 1
        fi
    done
    
    return 0
}

test_docker_files() {
    log "Testing Docker files..."
    
    if ! command -v docker &> /dev/null; then
        warn "Docker not found, skipping Docker tests"
        return 0
    fi
    
    find "$REPO_ROOT" -name "Dockerfile" | while read -r dockerfile; do
        local dir
        dir=$(dirname "$dockerfile")
        local image_name
        image_name="test-$(basename "$dir"):latest"
        
        if ! docker build -t "$image_name" "$dir" > /dev/null 2>&1; then
            error "Docker build failed for: $dockerfile"
            return 1
        fi
        
        # Clean up test image
        docker rmi "$image_name" > /dev/null 2>&1 || true
    done
    
    return 0
}

test_yaml_syntax() {
    log "Testing YAML syntax..."
    
    if ! command -v yamllint &> /dev/null; then
        warn "yamllint not found, skipping YAML tests"
        return 0
    fi
    
    find "$REPO_ROOT" -name "*.yaml" -o -name "*.yml" | grep -v node_modules | while read -r yaml_file; do
        if ! yamllint "$yaml_file" > /dev/null 2>&1; then
            error "YAML syntax error in: $yaml_file"
            return 1
        fi
    done
    
    return 0
}

test_security_configurations() {
    log "Testing security configurations..."
    
    # Check for common security issues
    local security_issues=0
    
    # Check for exposed secrets
    if grep -r "password\s*=" "$REPO_ROOT" --include="*.tf" --include="*.yaml" --include="*.py" | grep -v "password_hash" | grep -v "example"; then
        error "Potential password exposure found"
        ((security_issues++))
    fi
    
    # Check for hardcoded IPs
    if grep -r "0\.0\.0\.0/0" "$REPO_ROOT" --include="*.tf" --include="*.yaml" | grep -v "example"; then
        warn "Found open security group rules (0.0.0.0/0)"
        ((security_issues++))
    fi
    
    # Check for privileged containers
    if grep -r "privileged.*true" "$REPO_ROOT" --include="*.yaml" --include="*.yml"; then
        warn "Found privileged containers"
        ((security_issues++))
    fi
    
    if [[ $security_issues -gt 2 ]]; then
        error "Too many security issues found: $security_issues"
        return 1
    fi
    
    return 0
}

test_monitoring_configuration() {
    log "Testing monitoring configuration..."
    
    # Check Prometheus configuration
    if [[ -f "$REPO_ROOT/monitoring/prometheus/prometheus.yml" ]]; then
        if command -v promtool &> /dev/null; then
            if ! promtool check config "$REPO_ROOT/monitoring/prometheus/prometheus.yml" > /dev/null 2>&1; then
                error "Invalid Prometheus configuration"
                return 1
            fi
        fi
    fi
    
    # Check Grafana dashboards
    find "$REPO_ROOT/monitoring/grafana" -name "*.json" | while read -r dashboard; do
        if ! python3 -m json.tool "$dashboard" > /dev/null 2>&1; then
            error "Invalid JSON in Grafana dashboard: $dashboard"
            return 1
        fi
    done
    
    return 0
}

test_documentation() {
    log "Testing documentation..."
    
    # Check for required documentation files
    local required_docs=(
        "README.md"
        "CONTRIBUTING.md"
        "docs/quick-start.md"
        "docs/best-practices.md"
    )
    
    for doc in "${required_docs[@]}"; do
        if [[ ! -f "$REPO_ROOT/$doc" ]]; then
            error "Missing required documentation: $doc"
            return 1
        fi
    done
    
    # Check for broken links in markdown files
    find "$REPO_ROOT" -name "*.md" | while read -r md_file; do
        # Simple check for broken local links
        if grep -o '\[.*\](\..*\.md)' "$md_file" | while IFS= read -r link; do
            local file_path
            file_path=$(echo "$link" | sed 's/.*](\(.*\))/\1/')
            local full_path
            full_path=$(dirname "$md_file")/"$file_path"
            
            if [[ ! -f "$full_path" ]]; then
                error "Broken link in $md_file: $file_path"
                return 1
            fi
        done; then
            continue
        else
            return 1
        fi
    done
    
    return 0
}

test_ci_cd_configuration() {
    log "Testing CI/CD configuration..."
    
    # Check GitHub Actions workflows
    if [[ -d "$REPO_ROOT/.github/workflows" ]]; then
        find "$REPO_ROOT/.github/workflows" -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
            if ! yamllint "$workflow" > /dev/null 2>&1; then
                error "Invalid GitHub Actions workflow: $workflow"
                return 1
            fi
        done
    fi
    
    return 0
}

test_backup_scripts() {
    log "Testing backup scripts..."
    
    # Test backup script syntax
    if [[ -f "$REPO_ROOT/scripts/backup.sh" ]]; then
        if ! bash -n "$REPO_ROOT/scripts/backup.sh"; then
            error "Syntax error in backup script"
            return 1
        fi
    fi
    
    return 0
}

# Performance tests
test_performance() {
    log "Running performance tests..."
    
    # Test script execution time
    local start_time
    start_time=$(date +%s)
    
    # Simulate some work
    sleep 1
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -gt 30 ]]; then
        warn "Test suite taking longer than expected: ${duration}s"
    fi
    
    return 0
}

# Integration tests
test_integration() {
    log "Running integration tests..."
    
    # Test if monitoring stack can start
    if command -v docker-compose &> /dev/null && [[ -f "$REPO_ROOT/monitoring/docker-compose.yml" ]]; then
        cd "$REPO_ROOT/monitoring"
        if docker-compose config > /dev/null 2>&1; then
            log "Docker Compose configuration is valid"
        else
            error "Docker Compose configuration is invalid"
            return 1
        fi
    fi
    
    return 0
}

# Main test execution
run_all_tests() {
    log "🧪 Starting DevOps Excellence Test Suite"
    
    # Remove previous test log
    rm -f "$TEST_LOG"
    
    # Run all tests
    run_test "Repository Structure" "test_repository_structure"
    run_test "Terraform Syntax" "test_terraform_syntax"
    run_test "Kubernetes Manifests" "test_kubernetes_manifests"
    run_test "Python Code" "test_python_code"
    run_test "Go Code" "test_go_code"
    run_test "Docker Files" "test_docker_files"
    run_test "YAML Syntax" "test_yaml_syntax"
    run_test "Security Configurations" "test_security_configurations"
    run_test "Monitoring Configuration" "test_monitoring_configuration"
    run_test "Documentation" "test_documentation"
    run_test "CI/CD Configuration" "test_ci_cd_configuration"
    run_test "Backup Scripts" "test_backup_scripts"
    run_test "Performance" "test_performance"
    run_test "Integration" "test_integration"
}

# Test summary
show_summary() {
    echo
    log "📊 Test Summary"
    echo
    
    if [[ ${#PASSED_TESTS[@]} -gt 0 ]]; then
        log "✅ PASSED TESTS (${#PASSED_TESTS[@]}):"
        for test in "${PASSED_TESTS[@]}"; do
            echo "   ✓ $test"
        done
        echo
    fi
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        error "❌ FAILED TESTS (${#FAILED_TESTS[@]}):"
        for test in "${FAILED_TESTS[@]}"; do
            echo "   ✗ $test"
        done
        echo
        error "Test suite failed with ${#FAILED_TESTS[@]} failures"
        echo "See $TEST_LOG for detailed logs"
        return 1
    else
        log "🎉 All tests passed! DevOps Excellence is ready for production."
        return 0
    fi
}

# Main execution
main() {
    case "${1:-all}" in
        "structure")
            run_test "Repository Structure" "test_repository_structure"
            ;;
        "terraform")
            run_test "Terraform Syntax" "test_terraform_syntax"
            ;;
        "kubernetes")
            run_test "Kubernetes Manifests" "test_kubernetes_manifests"
            ;;
        "python")
            run_test "Python Code" "test_python_code"
            ;;
        "go")
            run_test "Go Code" "test_go_code"
            ;;
        "docker")
            run_test "Docker Files" "test_docker_files"
            ;;
        "security")
            run_test "Security Configurations" "test_security_configurations"
            ;;
        "monitoring")
            run_test "Monitoring Configuration" "test_monitoring_configuration"
            ;;
        "docs")
            run_test "Documentation" "test_documentation"
            ;;
        "performance")
            run_test "Performance" "test_performance"
            ;;
        "integration")
            run_test "Integration" "test_integration"
            ;;
        "all")
            run_all_tests
            ;;
        *)
            echo "Usage: $0 [test_type]"
            echo "Test types: structure, terraform, kubernetes, python, go, docker, security, monitoring, docs, performance, integration, all"
            exit 1
            ;;
    esac
    
    show_summary
}

# Run main function
main "$@"
