# Project 4: Advanced Shell Scripting for DevOps Automation

## Project Overview
Create a comprehensive collection of shell scripts for common DevOps tasks including deployment automation, system monitoring, log analysis, and infrastructure management.

## Architecture
```
Shell Scripting Toolkit
├── deployment/
│   ├── deploy-app.sh
│   ├── rollback.sh
│   └── health-check.sh
├── monitoring/
│   ├── system-monitor.sh
│   ├── log-analyzer.sh
│   └── alert-manager.sh
├── maintenance/
│   ├── backup-manager.sh
│   ├── cleanup.sh
│   └── security-audit.sh
├── utilities/
│   ├── config-manager.sh
│   ├── user-manager.sh
│   └── service-manager.sh
└── lib/
    ├── common.sh
    └── logging.sh
```

## Phase 1: Common Library Functions

### lib/common.sh - Shared Functions
```bash
#!/bin/bash
# common.sh - Shared functions for all scripts

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly LOG_DIR="${LOG_DIR:-/var/log/devops-scripts}"
readonly CONFIG_DIR="${CONFIG_DIR:-/etc/devops-scripts}"

# Ensure directories exist
mkdir -p "$LOG_DIR" "$CONFIG_DIR"

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_DIR/script.log"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_DIR/script.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_DIR/script.log" >&2
}

log_debug() {
    if [ "${DEBUG:-false}" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_DIR/debug.log"
    fi
}

# Error handling
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Validation functions
validate_user() {
    if [ "$EUID" -eq 0 ]; then
        error_exit "This script should not be run as root"
    fi
}

validate_root() {
    if [ "$EUID" -ne 0 ]; then
        error_exit "This script must be run as root"
    fi
}

validate_file() {
    local file="$1"
    [ -f "$file" ] || error_exit "File not found: $file"
    [ -r "$file" ] || error_exit "File not readable: $file"
}

validate_directory() {
    local dir="$1"
    [ -d "$dir" ] || error_exit "Directory not found: $dir"
}

validate_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || error_exit "Command not found: $cmd"
}

# Network functions
check_connectivity() {
    local host="$1"
    local port="${2:-80}"
    
    if command -v nc >/dev/null 2>&1; then
        nc -z "$host" "$port" 2>/dev/null
    elif command -v timeout >/dev/null 2>&1; then
        timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null
    else
        ping -c 1 "$host" >/dev/null 2>&1
    fi
}

wait_for_service() {
    local host="$1"
    local port="$2"
    local timeout="${3:-30}"
    local elapsed=0
    
    log_info "Waiting for $host:$port to be available..."
    
    while [ $elapsed -lt $timeout ]; do
        if check_connectivity "$host" "$port"; then
            log_info "Service $host:$port is available"
            return 0
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done
    
    error_exit "Timeout waiting for $host:$port"
}

# Configuration management
load_config() {
    local config_file="${1:-$CONFIG_DIR/default.conf}"
    
    if [ -f "$config_file" ]; then
        log_debug "Loading configuration from $config_file"
        # shellcheck source=/dev/null
        source "$config_file"
    else
        log_warn "Configuration file not found: $config_file"
    fi
}

save_config() {
    local config_file="$1"
    shift
    
    log_info "Saving configuration to $config_file"
    
    for var in "$@"; do
        if [ -n "${!var:-}" ]; then
            echo "$var=${!var}" >> "$config_file"
        fi
    done
}

# System information
get_os_info() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "$NAME $VERSION"
    elif [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release
    else
        uname -s
    fi
}

get_memory_usage() {
    free | awk 'NR==2{printf "%.2f", $3*100/$2}'
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
}

get_disk_usage() {
    local path="${1:-/}"
    df -h "$path" | awk 'NR==2{print $5}' | cut -d'%' -f1
}

# Service management
is_service_running() {
    local service="$1"
    systemctl is-active --quiet "$service"
}

start_service() {
    local service="$1"
    log_info "Starting service: $service"
    systemctl start "$service" || error_exit "Failed to start $service"
}

stop_service() {
    local service="$1"
    log_info "Stopping service: $service"
    systemctl stop "$service" || error_exit "Failed to stop $service"
}

restart_service() {
    local service="$1"
    log_info "Restarting service: $service"
    systemctl restart "$service" || error_exit "Failed to restart $service"
}

# Backup functions
create_backup() {
    local source="$1"
    local destination="$2"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    validate_directory "$(dirname "$source")"
    mkdir -p "$(dirname "$destination")"
    
    log_info "Creating backup: $source -> $destination.$timestamp"
    
    if [ -d "$source" ]; then
        tar -czf "$destination.$timestamp.tar.gz" -C "$(dirname "$source")" "$(basename "$source")"
    else
        cp "$source" "$destination.$timestamp"
    fi
}

restore_backup() {
    local backup="$1"
    local destination="$2"
    
    validate_file "$backup"
    
    log_info "Restoring backup: $backup -> $destination"
    
    if [[ "$backup" == *.tar.gz ]]; then
        tar -xzf "$backup" -C "$(dirname "$destination")"
    else
        cp "$backup" "$destination"
    fi
}

# Lock file management
acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-300}"
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if (set -C; echo $$ > "$lock_file") 2>/dev/null; then
            log_debug "Acquired lock: $lock_file"
            return 0
        fi
        
        if [ -f "$lock_file" ]; then
            local pid=$(cat "$lock_file" 2>/dev/null)
            if ! kill -0 "$pid" 2>/dev/null; then
                log_warn "Removing stale lock file: $lock_file"
                rm -f "$lock_file"
                continue
            fi
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    error_exit "Failed to acquire lock: $lock_file"
}

release_lock() {
    local lock_file="$1"
    if [ -f "$lock_file" ]; then
        rm -f "$lock_file"
        log_debug "Released lock: $lock_file"
    fi
}

# Cleanup function
cleanup() {
    local lock_file="${1:-}"
    
    log_debug "Performing cleanup..."
    
    if [ -n "$lock_file" ] && [ -f "$lock_file" ]; then
        release_lock "$lock_file"
    fi
    
    # Additional cleanup tasks can be added here
}

# Signal handling
setup_signal_handlers() {
    local lock_file="${1:-}"
    
    trap "cleanup '$lock_file'; exit 1" INT TERM
    trap "cleanup '$lock_file'" EXIT
}
```

## Phase 2: Deployment Scripts

### deployment/deploy-app.sh - Application Deployment
```bash
#!/bin/bash
# deploy-app.sh - Application deployment script

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Configuration
readonly APP_NAME="${APP_NAME:-myapp}"
readonly DEPLOY_USER="${DEPLOY_USER:-deploy}"
readonly APP_DIR="${APP_DIR:-/opt/$APP_NAME}"
readonly BACKUP_DIR="${BACKUP_DIR:-/backup/$APP_NAME}"
readonly SERVICE_NAME="${SERVICE_NAME:-$APP_NAME}"
readonly LOCK_FILE="/var/lock/${APP_NAME}-deploy.lock"

# Deployment configuration
ARTIFACT_URL=""
ARTIFACT_TYPE="tar.gz"
HEALTH_CHECK_URL="http://localhost:8080/health"
ROLLBACK_ON_FAILURE="true"
SKIP_TESTS="false"
BLUE_GREEN_DEPLOYMENT="false"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -u, --url URL           Artifact URL (required)
    -t, --type TYPE         Artifact type (tar.gz, jar, war) [default: tar.gz]
    -s, --skip-tests        Skip health checks
    -r, --no-rollback      Don't rollback on failure
    -b, --blue-green       Use blue-green deployment
    -h, --help             Show this help message

Environment Variables:
    APP_NAME               Application name [default: myapp]
    DEPLOY_USER            Deployment user [default: deploy]
    APP_DIR                Application directory [default: /opt/\$APP_NAME]
    HEALTH_CHECK_URL       Health check endpoint
    
Examples:
    $0 -u https://releases.company.com/myapp-1.2.3.tar.gz
    $0 -u /path/to/artifact.jar -t jar --skip-tests
    $0 -u s3://bucket/myapp.war -t war --blue-green
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--url)
                ARTIFACT_URL="$2"
                shift 2
                ;;
            -t|--type)
                ARTIFACT_TYPE="$2"
                shift 2
                ;;
            -s|--skip-tests)
                SKIP_TESTS="true"
                shift
                ;;
            -r|--no-rollback)
                ROLLBACK_ON_FAILURE="false"
                shift
                ;;
            -b|--blue-green)
                BLUE_GREEN_DEPLOYMENT="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
    
    [ -n "$ARTIFACT_URL" ] || error_exit "Artifact URL is required"
}

validate_environment() {
    log_info "Validating deployment environment..."
    
    # Check user permissions
    if [ "$(whoami)" != "$DEPLOY_USER" ] && [ "$EUID" -ne 0 ]; then
        error_exit "Must run as $DEPLOY_USER or root"
    fi
    
    # Check required commands
    local required_commands=("curl" "tar" "systemctl")
    for cmd in "${required_commands[@]}"; do
        validate_command "$cmd"
    done
    
    # Check directories
    [ -d "$APP_DIR" ] || mkdir -p "$APP_DIR"
    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"
    
    # Check service exists
    if ! systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        log_warn "Service $SERVICE_NAME not found, skipping service management"
    fi
}

download_artifact() {
    log_info "Downloading artifact: $ARTIFACT_URL"
    
    local temp_dir=$(mktemp -d)
    local artifact_file="$temp_dir/artifact.$ARTIFACT_TYPE"
    
    case "$ARTIFACT_URL" in
        http://*|https://*)
            curl -fsSL "$ARTIFACT_URL" -o "$artifact_file"
            ;;
        s3://*)
            aws s3 cp "$ARTIFACT_URL" "$artifact_file"
            ;;
        /*)
            cp "$ARTIFACT_URL" "$artifact_file"
            ;;
        *)
            error_exit "Unsupported artifact URL: $ARTIFACT_URL"
            ;;
    esac
    
    validate_file "$artifact_file"
    echo "$artifact_file"
}

backup_current_version() {
    log_info "Creating backup of current version..."
    
    if [ -d "$APP_DIR" ] && [ "$(ls -A "$APP_DIR")" ]; then
        local backup_name="backup-$(date +%Y%m%d_%H%M%S)"
        create_backup "$APP_DIR" "$BACKUP_DIR/$backup_name"
        echo "$BACKUP_DIR/$backup_name"
    else
        log_info "No existing version to backup"
        echo ""
    fi
}

deploy_artifact() {
    local artifact_file="$1"
    local temp_app_dir="$2"
    
    log_info "Deploying artifact to $temp_app_dir..."
    
    mkdir -p "$temp_app_dir"
    
    case "$ARTIFACT_TYPE" in
        tar.gz|tgz)
            tar -xzf "$artifact_file" -C "$temp_app_dir" --strip-components=1
            ;;
        zip)
            unzip -q "$artifact_file" -d "$temp_app_dir"
            ;;
        jar|war)
            cp "$artifact_file" "$temp_app_dir/"
            ;;
        *)
            error_exit "Unsupported artifact type: $ARTIFACT_TYPE"
            ;;
    esac
    
    # Set permissions
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "$temp_app_dir"
    find "$temp_app_dir" -type f -name "*.sh" -exec chmod +x {} \;
}

run_pre_deployment_tasks() {
    local app_dir="$1"
    
    log_info "Running pre-deployment tasks..."
    
    # Run database migrations if script exists
    if [ -f "$app_dir/scripts/migrate.sh" ]; then
        log_info "Running database migrations..."
        bash "$app_dir/scripts/migrate.sh"
    fi
    
    # Install dependencies if package.json exists
    if [ -f "$app_dir/package.json" ]; then
        log_info "Installing Node.js dependencies..."
        cd "$app_dir" && npm install --production
    fi
    
    # Build application if Makefile exists
    if [ -f "$app_dir/Makefile" ]; then
        log_info "Building application..."
        cd "$app_dir" && make build
    fi
}

swap_deployment() {
    local new_app_dir="$1"
    local old_app_dir="$APP_DIR"
    
    log_info "Swapping deployment directories..."
    
    if [ "$BLUE_GREEN_DEPLOYMENT" = "true" ]; then
        # Blue-green deployment
        local green_dir="${APP_DIR}-green"
        local blue_dir="${APP_DIR}-blue"
        
        if [ -L "$old_app_dir" ]; then
            local current_target=$(readlink "$old_app_dir")
            if [[ "$current_target" == *"blue"* ]]; then
                local target_dir="$green_dir"
            else
                local target_dir="$blue_dir"
            fi
        else
            local target_dir="$blue_dir"
        fi
        
        rm -rf "$target_dir"
        mv "$new_app_dir" "$target_dir"
        
        # Atomic swap
        ln -sfn "$target_dir" "$old_app_dir.new"
        mv "$old_app_dir.new" "$old_app_dir"
    else
        # Simple deployment
        local backup_dir="${APP_DIR}.old.$(date +%s)"
        
        if [ -d "$old_app_dir" ]; then
            mv "$old_app_dir" "$backup_dir"
        fi
        
        mv "$new_app_dir" "$old_app_dir"
    fi
}

restart_services() {
    log_info "Restarting application services..."
    
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        restart_service "$SERVICE_NAME"
        
        # Wait for service to be ready
        sleep 5
        
        if ! is_service_running "$SERVICE_NAME"; then
            error_exit "Service $SERVICE_NAME failed to start"
        fi
    fi
}

run_health_checks() {
    if [ "$SKIP_TESTS" = "true" ]; then
        log_info "Skipping health checks"
        return 0
    fi
    
    log_info "Running health checks..."
    
    # Wait for application to start
    if [ -n "$HEALTH_CHECK_URL" ]; then
        local retries=30
        local count=0
        
        while [ $count -lt $retries ]; do
            if curl -fsSL "$HEALTH_CHECK_URL" >/dev/null 2>&1; then
                log_info "Health check passed"
                return 0
            fi
            
            log_debug "Health check attempt $((count + 1))/$retries failed, retrying..."
            sleep 10
            count=$((count + 1))
        done
        
        error_exit "Health checks failed after $retries attempts"
    else
        log_warn "No health check URL configured"
    fi
}

rollback_deployment() {
    local backup_path="$1"
    
    if [ "$ROLLBACK_ON_FAILURE" != "true" ] || [ -z "$backup_path" ]; then
        log_error "Deployment failed and no rollback configured"
        return 1
    fi
    
    log_warn "Rolling back to previous version..."
    
    # Stop current version
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        stop_service "$SERVICE_NAME"
    fi
    
    # Restore backup
    rm -rf "$APP_DIR"
    restore_backup "$backup_path.tar.gz" "$APP_DIR"
    
    # Restart service
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        restart_service "$SERVICE_NAME"
    fi
    
    log_info "Rollback completed"
}

cleanup_deployment() {
    log_info "Cleaning up deployment artifacts..."
    
    # Remove temporary files
    rm -rf /tmp/deploy-*
    
    # Keep only last 5 backups
    find "$BACKUP_DIR" -name "backup-*" -type f | sort | head -n -5 | xargs rm -f
    
    # Clean up old blue-green directories
    if [ "$BLUE_GREEN_DEPLOYMENT" = "true" ]; then
        find "$(dirname "$APP_DIR")" -name "${APP_NAME}-*" -type d -mtime +7 -exec rm -rf {} \;
    fi
}

main() {
    parse_arguments "$@"
    
    log_info "Starting deployment of $APP_NAME"
    log_info "Artifact: $ARTIFACT_URL"
    log_info "Type: $ARTIFACT_TYPE"
    
    # Setup signal handlers and acquire lock
    setup_signal_handlers "$LOCK_FILE"
    acquire_lock "$LOCK_FILE"
    
    validate_environment
    
    # Create temporary directory for new version
    local temp_app_dir=$(mktemp -d "/tmp/deploy-${APP_NAME}-XXXXXX")
    local backup_path=""
    
    # Deployment process
    local artifact_file
    artifact_file=$(download_artifact)
    
    backup_path=$(backup_current_version)
    
    deploy_artifact "$artifact_file" "$temp_app_dir"
    run_pre_deployment_tasks "$temp_app_dir"
    
    # Stop services before swapping
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        stop_service "$SERVICE_NAME"
    fi
    
    swap_deployment "$temp_app_dir"
    restart_services
    
    # Run health checks and rollback if they fail
    if ! run_health_checks; then
        rollback_deployment "$backup_path"
        error_exit "Deployment failed health checks"
    fi
    
    cleanup_deployment
    release_lock "$LOCK_FILE"
    
    log_info "Deployment completed successfully"
}

# Execute main function
main "$@"
```

### deployment/rollback.sh - Rollback Script
```bash
#!/bin/bash
# rollback.sh - Application rollback script

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Configuration
readonly APP_NAME="${APP_NAME:-myapp}"
readonly APP_DIR="${APP_DIR:-/opt/$APP_NAME}"
readonly BACKUP_DIR="${BACKUP_DIR:-/backup/$APP_NAME}"
readonly SERVICE_NAME="${SERVICE_NAME:-$APP_NAME}"
readonly LOCK_FILE="/var/lock/${APP_NAME}-rollback.lock"

BACKUP_VERSION=""
LIST_BACKUPS="false"
FORCE_ROLLBACK="false"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -v, --version VERSION   Backup version to rollback to
    -l, --list             List available backup versions
    -f, --force            Force rollback without confirmation
    -h, --help             Show this help message

Examples:
    $0 --list
    $0 --version backup-20240115_143022
    $0 --version backup-20240115_143022 --force
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                BACKUP_VERSION="$2"
                shift 2
                ;;
            -l|--list)
                LIST_BACKUPS="true"
                shift
                ;;
            -f|--force)
                FORCE_ROLLBACK="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
}

list_backup_versions() {
    log_info "Available backup versions:"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log_warn "Backup directory not found: $BACKUP_DIR"
        return 1
    fi
    
    find "$BACKUP_DIR" -name "backup-*.tar.gz" -type f | sort -r | while read -r backup; do
        local version=$(basename "$backup" .tar.gz)
        local size=$(du -h "$backup" | cut -f1)
        local date=$(stat -c %y "$backup" | cut -d'.' -f1)
        
        echo "  $version ($size, created: $date)"
    done
}

validate_backup_version() {
    local version="$1"
    local backup_file="$BACKUP_DIR/$version.tar.gz"
    
    if [ ! -f "$backup_file" ]; then
        error_exit "Backup version not found: $version"
    fi
    
    # Validate backup integrity
    if ! tar -tzf "$backup_file" >/dev/null 2>&1; then
        error_exit "Backup file is corrupted: $backup_file"
    fi
    
    log_info "Backup version validated: $version"
}

confirm_rollback() {
    if [ "$FORCE_ROLLBACK" = "true" ]; then
        return 0
    fi
    
    echo
    log_warn "This will rollback $APP_NAME to version: $BACKUP_VERSION"
    log_warn "Current application data will be backed up before rollback"
    echo
    
    read -p "Are you sure you want to proceed? (yes/no): " -r
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Rollback cancelled by user"
        exit 0
    fi
}

create_pre_rollback_backup() {
    log_info "Creating backup of current version before rollback..."
    
    if [ -d "$APP_DIR" ] && [ "$(ls -A "$APP_DIR")" ]; then
        local backup_name="pre-rollback-$(date +%Y%m%d_%H%M%S)"
        create_backup "$APP_DIR" "$BACKUP_DIR/$backup_name"
        echo "$backup_name"
    else
        log_info "No current version to backup"
        echo ""
    fi
}

perform_rollback() {
    local version="$1"
    local backup_file="$BACKUP_DIR/$version.tar.gz"
    
    log_info "Rolling back to version: $version"
    
    # Stop application service
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        stop_service "$SERVICE_NAME"
    fi
    
    # Remove current application directory
    if [ -d "$APP_DIR" ]; then
        rm -rf "$APP_DIR"
    fi
    
    # Extract backup
    mkdir -p "$(dirname "$APP_DIR")"
    tar -xzf "$backup_file" -C "$(dirname "$APP_DIR")"
    
    # Set proper permissions
    chown -R deploy:deploy "$APP_DIR" 2>/dev/null || true
    
    # Start application service
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        start_service "$SERVICE_NAME"
        
        # Wait for service to be ready
        sleep 5
        
        if ! is_service_running "$SERVICE_NAME"; then
            error_exit "Service $SERVICE_NAME failed to start after rollback"
        fi
    fi
    
    log_info "Rollback completed successfully"
}

run_post_rollback_checks() {
    log_info "Running post-rollback checks..."
    
    # Check if application directory exists and has content
    if [ ! -d "$APP_DIR" ] || [ ! "$(ls -A "$APP_DIR")" ]; then
        error_exit "Application directory is empty after rollback"
    fi
    
    # Check service status
    if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
        if ! is_service_running "$SERVICE_NAME"; then
            error_exit "Service $SERVICE_NAME is not running after rollback"
        fi
    fi
    
    # Run health check if URL is configured
    local health_check_url="${HEALTH_CHECK_URL:-http://localhost:8080/health}"
    local retries=10
    local count=0
    
    while [ $count -lt $retries ]; do
        if curl -fsSL "$health_check_url" >/dev/null 2>&1; then
            log_info "Health check passed"
            return 0
        fi
        
        log_debug "Health check attempt $((count + 1))/$retries failed, retrying..."
        sleep 5
        count=$((count + 1))
    done
    
    log_warn "Health checks failed, but rollback completed"
}

main() {
    parse_arguments "$@"
    
    if [ "$LIST_BACKUPS" = "true" ]; then
        list_backup_versions
        exit 0
    fi
    
    [ -n "$BACKUP_VERSION" ] || error_exit "Backup version is required (use --list to see available versions)"
    
    log_info "Starting rollback of $APP_NAME to version: $BACKUP_VERSION"
    
    # Setup signal handlers and acquire lock
    setup_signal_handlers "$LOCK_FILE"
    acquire_lock "$LOCK_FILE"
    
    validate_backup_version "$BACKUP_VERSION"
    confirm_rollback
    
    # Create backup of current state
    local pre_rollback_backup
    pre_rollback_backup=$(create_pre_rollback_backup)
    
    if [ -n "$pre_rollback_backup" ]; then
        log_info "Pre-rollback backup created: $pre_rollback_backup"
    fi
    
    # Perform rollback
    perform_rollback "$BACKUP_VERSION"
    run_post_rollback_checks
    
    release_lock "$LOCK_FILE"
    
    log_info "Rollback completed successfully"
    echo
    log_info "Application has been rolled back to: $BACKUP_VERSION"
    
    if [ -n "$pre_rollback_backup" ]; then
        log_info "Previous version backed up as: $pre_rollback_backup"
    fi
}

# Execute main function
main "$@"
```

## Implementation Guide

### Setup Instructions:
1. **Create directory structure**:
   ```bash
   sudo mkdir -p /opt/devops-scripts/{deployment,monitoring,maintenance,utilities,lib}
   sudo mkdir -p /var/log/devops-scripts
   sudo mkdir -p /etc/devops-scripts
   ```

2. **Copy scripts and set permissions**:
   ```bash
   sudo chmod +x /opt/devops-scripts/**/*.sh
   sudo chown -R deploy:deploy /opt/devops-scripts
   ```

3. **Create configuration files**:
   ```bash
   # /etc/devops-scripts/default.conf
   APP_NAME="myapp"
   DEPLOY_USER="deploy"
   HEALTH_CHECK_URL="http://localhost:8080/health"
   BACKUP_RETENTION_DAYS=30
   LOG_LEVEL="INFO"
   ```

### Usage Examples:
```bash
# Deploy application
./deployment/deploy-app.sh -u https://releases.company.com/myapp-1.2.3.tar.gz

# Rollback to previous version
./deployment/rollback.sh --list
./deployment/rollback.sh --version backup-20240115_143022

# Monitor system with custom thresholds
DEBUG=true ./monitoring/system-monitor.sh
```

## Learning Outcomes
- Advanced shell scripting techniques
- Error handling and logging best practices
- Configuration management
- Service deployment automation
- Backup and rollback strategies
- Lock file management
- Signal handling
- Code organization and reusability
