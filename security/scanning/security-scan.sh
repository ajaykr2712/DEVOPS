#!/bin/bash

# Security Scanning Script
# Comprehensive security scanning for applications and infrastructure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCAN_DIR="${1:-$(pwd)}"
OUTPUT_DIR="./security-scan-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$OUTPUT_DIR/security-report-$TIMESTAMP.json"

# Tool versions
TRIVY_VERSION="0.46.0"
SEMGREP_VERSION="1.45.0"
CHECKOV_VERSION="3.0.0"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
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

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "scan_directory": "$SCAN_DIR",
  "scans": {}
}
EOF

# Function to check if tool is installed
check_tool() {
    local tool=$1
    local install_cmd=$2
    
    if ! command -v "$tool" &> /dev/null; then
        log_warning "$tool not found. Installing..."
        eval "$install_cmd"
    else
        log_success "$tool is installed"
    fi
}

# Install required tools
install_tools() {
    log "Installing security scanning tools..."
    
    # Install Trivy
    check_tool "trivy" "
        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v$TRIVY_VERSION
    "
    
    # Install Semgrep
    check_tool "semgrep" "
        python3 -m pip install semgrep==$SEMGREP_VERSION
    "
    
    # Install Checkov
    check_tool "checkov" "
        python3 -m pip install checkov==$CHECKOV_VERSION
    "
    
    # Install Grype
    check_tool "grype" "
        curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
    "
}

# Filesystem vulnerability scanning
scan_filesystem() {
    log "Running filesystem vulnerability scan with Trivy..."
    
    trivy fs "$SCAN_DIR" \
        --format json \
        --output "$OUTPUT_DIR/trivy-fs-$TIMESTAMP.json" \
        --severity HIGH,CRITICAL \
        --ignore-unfixed 2>/dev/null || log_warning "Trivy filesystem scan completed with warnings"
    
    # Update report
    jq --argjson trivy "$(cat "$OUTPUT_DIR/trivy-fs-$TIMESTAMP.json")" \
       '.scans.filesystem_vulnerabilities = $trivy' \
       "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
    
    log_success "Filesystem vulnerability scan completed"
}

# Static code analysis
scan_code() {
    log "Running static code analysis with Semgrep..."
    
    semgrep --config=auto \
        --json \
        --output="$OUTPUT_DIR/semgrep-$TIMESTAMP.json" \
        "$SCAN_DIR" 2>/dev/null || log_warning "Semgrep scan completed with warnings"
    
    # Update report
    jq --argjson semgrep "$(cat "$OUTPUT_DIR/semgrep-$TIMESTAMP.json")" \
       '.scans.static_analysis = $semgrep' \
       "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
    
    log_success "Static code analysis completed"
}

# Infrastructure as Code scanning
scan_iac() {
    log "Running Infrastructure as Code security scan with Checkov..."
    
    # Find IaC files
    iac_files=$(find "$SCAN_DIR" -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" | grep -E "(terraform|cloudformation|kubernetes|helm)" || true)
    
    if [[ -n "$iac_files" ]]; then
        checkov -d "$SCAN_DIR" \
            --framework terraform,cloudformation,kubernetes,helm \
            --output json \
            --output-file "$OUTPUT_DIR/checkov-$TIMESTAMP.json" \
            --quiet 2>/dev/null || log_warning "Checkov scan completed with warnings"
        
        # Update report
        if [[ -f "$OUTPUT_DIR/checkov-$TIMESTAMP.json" ]]; then
            jq --argjson checkov "$(cat "$OUTPUT_DIR/checkov-$TIMESTAMP.json")" \
               '.scans.infrastructure_security = $checkov' \
               "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
        fi
        
        log_success "Infrastructure security scan completed"
    else
        log_warning "No Infrastructure as Code files found"
    fi
}

# Container image scanning
scan_containers() {
    log "Scanning for container images..."
    
    # Find Dockerfiles
    dockerfiles=$(find "$SCAN_DIR" -name "Dockerfile*" || true)
    
    if [[ -n "$dockerfiles" ]]; then
        log "Found Dockerfiles, scanning with Trivy..."
        
        container_results="[]"
        while IFS= read -r dockerfile; do
            if [[ -n "$dockerfile" ]]; then
                log "Scanning $dockerfile"
                
                # Build temporary image for scanning
                temp_tag="security-scan:$(basename "$dockerfile")-$TIMESTAMP"
                docker build -t "$temp_tag" -f "$dockerfile" "$(dirname "$dockerfile")" &>/dev/null || continue
                
                # Scan the image
                trivy image "$temp_tag" \
                    --format json \
                    --output "$OUTPUT_DIR/trivy-image-$(basename "$dockerfile")-$TIMESTAMP.json" \
                    --severity HIGH,CRITICAL 2>/dev/null || true
                
                # Clean up temporary image
                docker rmi "$temp_tag" &>/dev/null || true
                
                # Collect results
                if [[ -f "$OUTPUT_DIR/trivy-image-$(basename "$dockerfile")-$TIMESTAMP.json" ]]; then
                    container_results=$(jq --argjson result "$(cat "$OUTPUT_DIR/trivy-image-$(basename "$dockerfile")-$TIMESTAMP.json")" \
                                         '. + [$result]' <<< "$container_results")
                fi
            fi
        done <<< "$dockerfiles"
        
        # Update report
        jq --argjson containers "$container_results" \
           '.scans.container_vulnerabilities = $containers' \
           "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
        
        log_success "Container image scanning completed"
    else
        log_warning "No Dockerfiles found"
    fi
}

# Secret scanning
scan_secrets() {
    log "Scanning for secrets and sensitive information..."
    
    # Use Semgrep for secret detection
    semgrep --config=p/secrets \
        --json \
        --output="$OUTPUT_DIR/secrets-$TIMESTAMP.json" \
        "$SCAN_DIR" 2>/dev/null || log_warning "Secret scan completed with warnings"
    
    # Update report
    jq --argjson secrets "$(cat "$OUTPUT_DIR/secrets-$TIMESTAMP.json")" \
       '.scans.secret_detection = $secrets' \
       "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
    
    log_success "Secret scanning completed"
}

# Generate summary report
generate_summary() {
    log "Generating security scan summary..."
    
    # Create HTML report
    cat > "$OUTPUT_DIR/security-report-$TIMESTAMP.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
        .critical { color: #dc3545; font-weight: bold; }
        .high { color: #fd7e14; font-weight: bold; }
        .medium { color: #ffc107; font-weight: bold; }
        .low { color: #28a745; font-weight: bold; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #dee2e6; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Security Scan Report</h1>
        <p><strong>Scan Date:</strong> <span id="scan-date"></span></p>
        <p><strong>Directory:</strong> <span id="scan-dir"></span></p>
    </div>
    
    <div class="section">
        <h2>Executive Summary</h2>
        <div id="summary"></div>
    </div>
    
    <div class="section">
        <h2>Vulnerability Breakdown</h2>
        <div id="vulnerabilities"></div>
    </div>
    
    <div class="section">
        <h2>Code Quality Issues</h2>
        <div id="code-issues"></div>
    </div>
    
    <div class="section">
        <h2>Infrastructure Security</h2>
        <div id="infrastructure"></div>
    </div>
    
    <script>
        // Load and display scan results
        fetch('./security-report-TIMESTAMP.json')
            .then(response => response.json())
            .then(data => {
                document.getElementById('scan-date').textContent = data.scan_timestamp;
                document.getElementById('scan-dir').textContent = data.scan_directory;
                
                // Process and display results
                // (This would be expanded with actual data processing)
            });
    </script>
</body>
</html>
EOF
    
    # Replace placeholder with actual timestamp
    sed -i.bak "s/TIMESTAMP/$TIMESTAMP/g" "$OUTPUT_DIR/security-report-$TIMESTAMP.html"
    rm "$OUTPUT_DIR/security-report-$TIMESTAMP.html.bak"
    
    # Generate text summary
    cat > "$OUTPUT_DIR/summary-$TIMESTAMP.txt" << EOF
Security Scan Summary
====================
Scan Date: $(date)
Directory: $SCAN_DIR

Results:
- Detailed JSON report: $REPORT_FILE
- HTML report: $OUTPUT_DIR/security-report-$TIMESTAMP.html
- Individual scan results in: $OUTPUT_DIR/

Next Steps:
1. Review critical and high severity vulnerabilities
2. Address infrastructure security issues
3. Fix any hardcoded secrets or sensitive information
4. Implement recommended security controls
EOF

    log_success "Security scan summary generated"
}

# Main execution
main() {
    log "Starting comprehensive security scan..."
    log "Scan directory: $SCAN_DIR"
    log "Output directory: $OUTPUT_DIR"
    
    # Check dependencies
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Please install jq first."
        exit 1
    fi
    
    # Install tools
    install_tools
    
    # Run scans
    scan_filesystem
    scan_code
    scan_iac
    scan_containers
    scan_secrets
    
    # Generate reports
    generate_summary
    
    log_success "Security scan completed successfully!"
    log "Results available in: $OUTPUT_DIR"
    log "Summary report: $OUTPUT_DIR/summary-$TIMESTAMP.txt"
    log "HTML report: $OUTPUT_DIR/security-report-$TIMESTAMP.html"
    log "JSON report: $REPORT_FILE"
}

# Help function
show_help() {
    cat << EOF
Security Scanning Script

Usage: $0 [DIRECTORY]

Arguments:
  DIRECTORY    Directory to scan (defaults to current directory)

Examples:
  $0                    # Scan current directory
  $0 /path/to/project   # Scan specific directory

This script performs comprehensive security scanning including:
- Filesystem vulnerability scanning
- Static code analysis
- Infrastructure as Code security
- Container image scanning
- Secret detection

Results are saved in ./security-scan-results/
EOF
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
