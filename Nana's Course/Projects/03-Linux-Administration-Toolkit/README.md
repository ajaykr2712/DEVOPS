# Project 3: Linux System Administration and Automation

## Project Overview
Build a comprehensive Linux administration toolkit with automated monitoring, user management, and system maintenance scripts.

## Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                 Linux Admin Toolkit                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Monitor   │  │User Mgmt    │  │ Maintenance │         │
│  │   Scripts   │  │ Scripts     │  │  Scripts    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Central Dashboard                      │   │
│  │           (Web-based Interface)                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Phase 1: System Monitoring Scripts

### 1. System Health Monitor
```bash
#!/bin/bash
# system-health.sh

LOG_FILE="/var/log/system-health.log"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=90

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_cpu_usage() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    CPU_USAGE=${CPU_USAGE%.*}  # Remove decimal
    
    if [ "$CPU_USAGE" -gt "$ALERT_THRESHOLD_CPU" ]; then
        log_message "ALERT: High CPU usage: ${CPU_USAGE}%"
        return 1
    else
        log_message "INFO: CPU usage normal: ${CPU_USAGE}%"
        return 0
    fi
}

check_memory_usage() {
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    
    if [ "$MEM_USAGE" -gt "$ALERT_THRESHOLD_MEM" ]; then
        log_message "ALERT: High memory usage: ${MEM_USAGE}%"
        return 1
    else
        log_message "INFO: Memory usage normal: ${MEM_USAGE}%"
        return 0
    fi
}

check_disk_usage() {
    while IFS= read -r line; do
        USAGE=$(echo "$line" | awk '{print $5}' | cut -d'%' -f1)
        MOUNT_POINT=$(echo "$line" | awk '{print $6}')
        
        if [ "$USAGE" -gt "$ALERT_THRESHOLD_DISK" ]; then
            log_message "ALERT: High disk usage on $MOUNT_POINT: ${USAGE}%"
            return 1
        fi
    done < <(df -h | grep -E '^/dev/')
    
    log_message "INFO: All disk usage normal"
    return 0
}

check_services() {
    SERVICES=("ssh" "cron" "systemd-resolved")
    
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_message "INFO: Service $service is running"
        else
            log_message "ALERT: Service $service is not running"
        fi
    done
}

main() {
    log_message "=== Starting System Health Check ==="
    
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_services
    
    log_message "=== System Health Check Complete ==="
}

main "$@"
```

### 2. Network Monitoring Script
```bash
#!/bin/bash
# network-monitor.sh

PING_HOSTS=("8.8.8.8" "1.1.1.1" "google.com")
LOG_FILE="/var/log/network-monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_connectivity() {
    for host in "${PING_HOSTS[@]}"; do
        if ping -c 3 "$host" > /dev/null 2>&1; then
            log_message "INFO: Connectivity to $host OK"
        else
            log_message "ALERT: Cannot reach $host"
        fi
    done
}

check_ports() {
    PORTS=("22:SSH" "80:HTTP" "443:HTTPS")
    
    for port_info in "${PORTS[@]}"; do
        port=$(echo "$port_info" | cut -d':' -f1)
        service=$(echo "$port_info" | cut -d':' -f2)
        
        if netstat -tuln | grep -q ":$port "; then
            log_message "INFO: Port $port ($service) is listening"
        else
            log_message "WARNING: Port $port ($service) is not listening"
        fi
    done
}

network_statistics() {
    log_message "=== Network Statistics ==="
    
    # Interface statistics
    for interface in $(ip link show | grep -E '^[0-9]+:' | cut -d':' -f2 | tr -d ' ' | grep -v lo); do
        RX_BYTES=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
        TX_BYTES=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
        
        RX_MB=$((RX_BYTES / 1024 / 1024))
        TX_MB=$((TX_BYTES / 1024 / 1024))
        
        log_message "INFO: $interface - RX: ${RX_MB}MB, TX: ${TX_MB}MB"
    done
}

main() {
    log_message "=== Starting Network Monitor ==="
    check_connectivity
    check_ports
    network_statistics
    log_message "=== Network Monitor Complete ==="
}

main "$@"
```

## Phase 2: User Management Automation

### 1. Bulk User Creation Script
```bash
#!/bin/bash
# create-users.sh

USER_FILE="$1"
DEFAULT_SHELL="/bin/bash"
DEFAULT_GROUP="users"

usage() {
    echo "Usage: $0 <user_file>"
    echo "User file format: username,full_name,group,shell"
    echo "Example: jdoe,John Doe,developers,/bin/bash"
    exit 1
}

validate_input() {
    if [ $# -ne 1 ]; then
        usage
    fi
    
    if [ ! -f "$USER_FILE" ]; then
        echo "Error: User file '$USER_FILE' not found"
        exit 1
    fi
}

create_user() {
    local username="$1"
    local full_name="$2"
    local group="$3"
    local shell="$4"
    
    # Set defaults if empty
    [ -z "$group" ] && group="$DEFAULT_GROUP"
    [ -z "$shell" ] && shell="$DEFAULT_SHELL"
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists, skipping..."
        return 1
    fi
    
    # Create group if it doesn't exist
    if ! getent group "$group" &>/dev/null; then
        groupadd "$group"
        echo "Created group: $group"
    fi
    
    # Create user
    useradd -m -s "$shell" -g "$group" -c "$full_name" "$username"
    
    if [ $? -eq 0 ]; then
        echo "Created user: $username ($full_name)"
        
        # Set temporary password
        temp_password=$(openssl rand -base64 12)
        echo "$username:$temp_password" | chpasswd
        
        # Force password change on first login
        chage -d 0 "$username"
        
        echo "Temporary password for $username: $temp_password"
        echo "$username:$temp_password" >> /var/log/user-passwords.log
        chmod 600 /var/log/user-passwords.log
    else
        echo "Failed to create user: $username"
        return 1
    fi
}

main() {
    validate_input "$@"
    
    echo "Creating users from file: $USER_FILE"
    echo "=========================="
    
    while IFS=',' read -r username full_name group shell; do
        # Skip empty lines and comments
        [[ -z "$username" || "$username" =~ ^#.*$ ]] && continue
        
        create_user "$username" "$full_name" "$group" "$shell"
    done < "$USER_FILE"
    
    echo "=========================="
    echo "User creation complete"
}

main "$@"
```

### 2. User Audit Script
```bash
#!/bin/bash
# user-audit.sh

REPORT_FILE="/var/log/user-audit-$(date +%Y%m%d).log"

generate_report() {
    echo "=== User Audit Report - $(date) ===" > "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # System users vs regular users
    echo "=== User Categories ===" >> "$REPORT_FILE"
    echo "System users (UID < 1000):" >> "$REPORT_FILE"
    awk -F: '$3 < 1000 {print $1 " (UID: " $3 ")"}' /etc/passwd >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    echo "Regular users (UID >= 1000):" >> "$REPORT_FILE"
    awk -F: '$3 >= 1000 {print $1 " (UID: " $3 ")"}' /etc/passwd >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # Users with shell access
    echo "=== Users with Shell Access ===" >> "$REPORT_FILE"
    grep -E "(bash|zsh|fish|sh)$" /etc/passwd | cut -d: -f1 >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # Users without password
    echo "=== Users without Password ===" >> "$REPORT_FILE"
    awk -F: '$2 == "" {print $1}' /etc/shadow >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # Sudo users
    echo "=== Sudo Users ===" >> "$REPORT_FILE"
    grep -E "^sudo|^wheel" /etc/group | cut -d: -f4 | tr ',' '\n' >> "$REPORT_FILE"
    echo >> "$REPORT_FILE"
    
    # Last login information
    echo "=== Last Login Information ===" >> "$REPORT_FILE"
    lastlog | grep -v "Never" >> "$REPORT_FILE"
}

check_password_policies() {
    echo "=== Password Policy Check ===" >> "$REPORT_FILE"
    
    # Check for expired passwords
    awk -F: '$2 != "*" && $2 != "!" {print $1}' /etc/shadow | while read username; do
        chage -l "$username" | grep -E "(Password expires|Account expires)" >> "$REPORT_FILE"
    done
}

check_home_directories() {
    echo "=== Home Directory Check ===" >> "$REPORT_FILE"
    
    awk -F: '$3 >= 1000 {print $1 ":" $6}' /etc/passwd | while IFS=: read username homedir; do
        if [ ! -d "$homedir" ]; then
            echo "Missing home directory for user: $username ($homedir)" >> "$REPORT_FILE"
        fi
    done
}

main() {
    echo "Generating user audit report..."
    
    generate_report
    check_password_policies
    check_home_directories
    
    echo "Audit report generated: $REPORT_FILE"
    
    # Display summary
    echo "=== Audit Summary ==="
    echo "Total users: $(wc -l < /etc/passwd)"
    echo "Regular users: $(awk -F: '$3 >= 1000' /etc/passwd | wc -l)"
    echo "Users with shell: $(grep -E "(bash|zsh|fish|sh)$" /etc/passwd | wc -l)"
    echo "Report saved to: $REPORT_FILE"
}

main "$@"
```

## Phase 3: System Maintenance Scripts

### 1. Automated Backup Script
```bash
#!/bin/bash
# backup-system.sh

BACKUP_ROOT="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$DATE"
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=7

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

create_backup_structure() {
    mkdir -p "$BACKUP_DIR"/{system,databases,applications,logs}
    log_message "Created backup directory: $BACKUP_DIR"
}

backup_system_configs() {
    log_message "Backing up system configurations..."
    
    SYSTEM_DIRS=("/etc" "/home" "/root" "/var/spool/cron")
    
    for dir in "${SYSTEM_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            tar -czf "$BACKUP_DIR/system/$(basename $dir).tar.gz" "$dir" 2>/dev/null
            log_message "Backed up: $dir"
        fi
    done
}

backup_databases() {
    log_message "Backing up databases..."
    
    # MySQL/MariaDB
    if systemctl is-active --quiet mysql || systemctl is-active --quiet mariadb; then
        mysqldump --all-databases --single-transaction > "$BACKUP_DIR/databases/mysql_all.sql" 2>/dev/null
        log_message "MySQL backup completed"
    fi
    
    # PostgreSQL
    if systemctl is-active --quiet postgresql; then
        sudo -u postgres pg_dumpall > "$BACKUP_DIR/databases/postgresql_all.sql" 2>/dev/null
        log_message "PostgreSQL backup completed"
    fi
}

backup_applications() {
    log_message "Backing up applications..."
    
    APP_DIRS=("/opt" "/usr/local" "/var/www")
    
    for dir in "${APP_DIRS[@]}"; do
        if [ -d "$dir" ] && [ "$(ls -A $dir)" ]; then
            tar -czf "$BACKUP_DIR/applications/$(basename $dir).tar.gz" "$dir" 2>/dev/null
            log_message "Backed up application directory: $dir"
        fi
    done
}

backup_logs() {
    log_message "Backing up system logs..."
    
    find /var/log -name "*.log" -type f -exec cp {} "$BACKUP_DIR/logs/" \; 2>/dev/null
    log_message "System logs backed up"
}

cleanup_old_backups() {
    log_message "Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null
    log_message "Old backup cleanup completed"
}

create_backup_summary() {
    SUMMARY_FILE="$BACKUP_DIR/backup_summary.txt"
    
    echo "Backup Summary - $(date)" > "$SUMMARY_FILE"
    echo "================================" >> "$SUMMARY_FILE"
    echo "Backup Location: $BACKUP_DIR" >> "$SUMMARY_FILE"
    echo "Backup Size: $(du -sh $BACKUP_DIR | cut -f1)" >> "$SUMMARY_FILE"
    echo "Files Count: $(find $BACKUP_DIR -type f | wc -l)" >> "$SUMMARY_FILE"
    echo >> "$SUMMARY_FILE"
    
    echo "Directory Structure:" >> "$SUMMARY_FILE"
    tree "$BACKUP_DIR" >> "$SUMMARY_FILE" 2>/dev/null || ls -la "$BACKUP_DIR" >> "$SUMMARY_FILE"
    
    log_message "Backup summary created: $SUMMARY_FILE"
}

main() {
    log_message "=== Starting System Backup ==="
    
    create_backup_structure
    backup_system_configs
    backup_databases
    backup_applications
    backup_logs
    create_backup_summary
    cleanup_old_backups
    
    log_message "=== Backup Complete ==="
    log_message "Total backup size: $(du -sh $BACKUP_DIR | cut -f1)"
}

main "$@"
```

### 2. System Cleanup Script
```bash
#!/bin/bash
# system-cleanup.sh

LOG_FILE="/var/log/system-cleanup.log"
DRY_RUN=false

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage: $0 [--dry-run]"
    echo "  --dry-run    Show what would be done without actually doing it"
    exit 1
}

cleanup_package_cache() {
    log_message "Cleaning package cache..."
    
    if $DRY_RUN; then
        apt list --upgradable 2>/dev/null | wc -l | xargs echo "Packages that could be upgraded:"
        echo "Would run: apt clean && apt autoremove"
    else
        apt clean
        apt autoremove -y
        log_message "Package cache cleaned"
    fi
}

cleanup_log_files() {
    log_message "Cleaning old log files..."
    
    # Find log files older than 30 days
    OLD_LOGS=$(find /var/log -name "*.log" -type f -mtime +30 2>/dev/null)
    
    if [ -n "$OLD_LOGS" ]; then
        if $DRY_RUN; then
            echo "Log files that would be compressed:"
            echo "$OLD_LOGS"
        else
            echo "$OLD_LOGS" | xargs gzip
            log_message "Old log files compressed"
        fi
    fi
}

cleanup_tmp_files() {
    log_message "Cleaning temporary files..."
    
    TMP_DIRS=("/tmp" "/var/tmp")
    
    for tmp_dir in "${TMP_DIRS[@]}"; do
        OLD_TMP=$(find "$tmp_dir" -type f -atime +7 2>/dev/null)
        
        if [ -n "$OLD_TMP" ]; then
            if $DRY_RUN; then
                echo "Temporary files in $tmp_dir that would be removed:"
                echo "$OLD_TMP" | wc -l | xargs echo "Count:"
            else
                find "$tmp_dir" -type f -atime +7 -delete 2>/dev/null
                log_message "Cleaned temporary files in $tmp_dir"
            fi
        fi
    done
}

cleanup_user_cache() {
    log_message "Cleaning user cache directories..."
    
    for user_home in /home/*; do
        [ -d "$user_home" ] || continue
        
        CACHE_DIRS=("$user_home/.cache" "$user_home/.thumbnails")
        
        for cache_dir in "${CACHE_DIRS[@]}"; do
            if [ -d "$cache_dir" ]; then
                CACHE_SIZE=$(du -sh "$cache_dir" 2>/dev/null | cut -f1)
                
                if $DRY_RUN; then
                    echo "Would clean cache: $cache_dir ($CACHE_SIZE)"
                else
                    find "$cache_dir" -type f -atime +30 -delete 2>/dev/null
                    log_message "Cleaned cache: $cache_dir"
                fi
            fi
        done
    done
}

cleanup_journal_logs() {
    log_message "Cleaning systemd journal logs..."
    
    if $DRY_RUN; then
        journalctl --disk-usage | xargs echo "Current journal size:"
        echo "Would run: journalctl --vacuum-time=30d"
    else
        journalctl --vacuum-time=30d
        log_message "Journal logs cleaned"
    fi
}

system_summary() {
    log_message "=== System Summary ==="
    
    echo "Disk Usage:" | tee -a "$LOG_FILE"
    df -h | tee -a "$LOG_FILE"
    
    echo | tee -a "$LOG_FILE"
    echo "Memory Usage:" | tee -a "$LOG_FILE"
    free -h | tee -a "$LOG_FILE"
    
    echo | tee -a "$LOG_FILE"
    echo "Largest Directories:" | tee -a "$LOG_FILE"
    du -h /var /usr /opt 2>/dev/null | sort -hr | head -10 | tee -a "$LOG_FILE"
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                usage
                ;;
        esac
    done
    
    if $DRY_RUN; then
        log_message "=== DRY RUN - System Cleanup ==="
    else
        log_message "=== Starting System Cleanup ==="
    fi
    
    cleanup_package_cache
    cleanup_log_files
    cleanup_tmp_files
    cleanup_user_cache
    cleanup_journal_logs
    system_summary
    
    if $DRY_RUN; then
        log_message "=== DRY RUN Complete ==="
    else
        log_message "=== System Cleanup Complete ==="
    fi
}

main "$@"
```

## Phase 4: Web Dashboard (Simple HTML/JavaScript)

### dashboard.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Linux Admin Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px; padding: 15px; background: #e3f2fd; border-radius: 5px; min-width: 150px; }
        .alert { background: #ffebee; border-left: 4px solid #f44336; }
        .success { background: #e8f5e8; border-left: 4px solid #4caf50; }
        .button { padding: 10px 20px; background: #2196f3; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .log-output { background: #f5f5f5; padding: 10px; border-radius: 4px; font-family: monospace; max-height: 300px; overflow-y: auto; }
        .status-good { color: #4caf50; }
        .status-warning { color: #ff9800; }
        .status-critical { color: #f44336; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Linux System Administration Dashboard</h1>
        
        <div class="card">
            <h2>System Metrics</h2>
            <div class="metric">
                <strong>CPU Usage:</strong><br>
                <span id="cpu-usage">Loading...</span>
            </div>
            <div class="metric">
                <strong>Memory Usage:</strong><br>
                <span id="memory-usage">Loading...</span>
            </div>
            <div class="metric">
                <strong>Disk Usage:</strong><br>
                <span id="disk-usage">Loading...</span>
            </div>
            <div class="metric">
                <strong>System Load:</strong><br>
                <span id="system-load">Loading...</span>
            </div>
        </div>
        
        <div class="card">
            <h2>Service Status</h2>
            <div id="service-status">Loading...</div>
        </div>
        
        <div class="card">
            <h2>System Operations</h2>
            <button class="button" onclick="runHealthCheck()">Run Health Check</button>
            <button class="button" onclick="runBackup()">Start Backup</button>
            <button class="button" onclick="runCleanup()">System Cleanup</button>
            <button class="button" onclick="viewLogs()">View Logs</button>
        </div>
        
        <div class="card">
            <h2>Recent Activity</h2>
            <div id="recent-logs" class="log-output">Loading recent logs...</div>
        </div>
        
        <div class="card">
            <h2>User Management</h2>
            <button class="button" onclick="listUsers()">List Users</button>
            <button class="button" onclick="userAudit()">User Audit</button>
            <div id="user-info" class="log-output" style="display: none;"></div>
        </div>
    </div>

    <script>
        // Simulate system metrics (in real implementation, these would come from backend API)
        function updateMetrics() {
            // Simulate CPU usage
            const cpuUsage = Math.floor(Math.random() * 100);
            document.getElementById('cpu-usage').innerHTML = 
                `<span class="${cpuUsage > 80 ? 'status-critical' : cpuUsage > 60 ? 'status-warning' : 'status-good'}">${cpuUsage}%</span>`;
            
            // Simulate memory usage
            const memUsage = Math.floor(Math.random() * 100);
            document.getElementById('memory-usage').innerHTML = 
                `<span class="${memUsage > 85 ? 'status-critical' : memUsage > 70 ? 'status-warning' : 'status-good'}">${memUsage}%</span>`;
            
            // Simulate disk usage
            const diskUsage = Math.floor(Math.random() * 100);
            document.getElementById('disk-usage').innerHTML = 
                `<span class="${diskUsage > 90 ? 'status-critical' : diskUsage > 75 ? 'status-warning' : 'status-good'}">${diskUsage}%</span>`;
            
            // Simulate system load
            const load = (Math.random() * 4).toFixed(2);
            document.getElementById('system-load').innerHTML = 
                `<span class="${load > 3 ? 'status-critical' : load > 2 ? 'status-warning' : 'status-good'}">${load}</span>`;
        }
        
        function updateServiceStatus() {
            const services = ['SSH', 'Nginx', 'MySQL', 'Cron', 'UFW'];
            const statusHtml = services.map(service => {
                const isRunning = Math.random() > 0.1; // 90% chance of running
                return `<div style="margin: 5px 0;">
                    <strong>${service}:</strong> 
                    <span class="${isRunning ? 'status-good' : 'status-critical'}">
                        ${isRunning ? '✓ Running' : '✗ Stopped'}
                    </span>
                </div>`;
            }).join('');
            
            document.getElementById('service-status').innerHTML = statusHtml;
        }
        
        function updateRecentLogs() {
            const sampleLogs = [
                '2024-01-15 10:30:15 - INFO: System health check completed successfully',
                '2024-01-15 10:25:43 - INFO: Backup process started',
                '2024-01-15 10:20:12 - WARNING: High memory usage detected (82%)',
                '2024-01-15 10:15:08 - INFO: User john.doe logged in via SSH',
                '2024-01-15 10:10:22 - INFO: System cleanup completed',
                '2024-01-15 10:05:17 - INFO: Package update available: nginx',
                '2024-01-15 10:00:01 - INFO: Cron job executed: system-monitor'
            ];
            
            document.getElementById('recent-logs').innerHTML = sampleLogs.join('\n');
        }
        
        function runHealthCheck() {
            alert('Health check initiated. Results will appear in the logs.');
            // In real implementation, this would trigger the health check script
            setTimeout(() => {
                const logElement = document.getElementById('recent-logs');
                logElement.innerHTML = new Date().toISOString() + ' - INFO: Health check completed\n' + logElement.innerHTML;
            }, 2000);
        }
        
        function runBackup() {
            if (confirm('Start system backup? This may take several minutes.')) {
                alert('Backup process started. Check logs for progress.');
                // In real implementation, this would trigger the backup script
            }
        }
        
        function runCleanup() {
            if (confirm('Run system cleanup? This will remove temporary files and clean caches.')) {
                alert('Cleanup process started. Check logs for details.');
                // In real implementation, this would trigger the cleanup script
            }
        }
        
        function viewLogs() {
            window.open('/var/log/system-health.log', '_blank');
        }
        
        function listUsers() {
            const userInfo = document.getElementById('user-info');
            userInfo.style.display = 'block';
            userInfo.innerHTML = 'Loading user information...';
            
            // Simulate user list
            setTimeout(() => {
                userInfo.innerHTML = `Regular Users:
john.doe (UID: 1001) - Last login: 2024-01-15 09:30
jane.smith (UID: 1002) - Last login: 2024-01-14 16:45
admin.user (UID: 1000) - Last login: 2024-01-15 08:15

System Users:
www-data (UID: 33)
mysql (UID: 999)
systemd-network (UID: 998)`;
            }, 1000);
        }
        
        function userAudit() {
            alert('User audit initiated. Report will be generated in /var/log/');
        }
        
        // Initialize dashboard
        document.addEventListener('DOMContentLoaded', function() {
            updateMetrics();
            updateServiceStatus();
            updateRecentLogs();
            
            // Update metrics every 30 seconds
            setInterval(updateMetrics, 30000);
            setInterval(updateServiceStatus, 60000);
        });
    </script>
</body>
</html>
```

## Implementation Guide

### Setup Instructions:
1. **Create script directory**: `sudo mkdir -p /opt/admin-scripts`
2. **Copy all scripts**: Place scripts in `/opt/admin-scripts/`
3. **Set permissions**: `sudo chmod +x /opt/admin-scripts/*.sh`
4. **Create log directory**: `sudo mkdir -p /var/log/admin-scripts`
5. **Install web server**: `sudo apt install nginx`
6. **Deploy dashboard**: Copy HTML to `/var/www/html/`

### Cron Jobs:
```bash
# Add to /etc/crontab
0 */4 * * * root /opt/admin-scripts/system-health.sh
0 2 * * * root /opt/admin-scripts/backup-system.sh
0 6 * * 0 root /opt/admin-scripts/system-cleanup.sh
*/15 * * * * root /opt/admin-scripts/network-monitor.sh
```

## Learning Outcomes
- Advanced Linux command line usage
- System administration automation
- Script development and debugging
- User and permission management
- System monitoring and alerting
- Web-based administration interfaces
- Log analysis and management
- Security best practices
