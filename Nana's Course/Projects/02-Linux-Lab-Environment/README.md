# Project 2: Linux Lab Environment Setup and System Administration

## Project Overview
Set up a comprehensive Linux lab environment with multiple VMs to simulate a real-world infrastructure setup.

## Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Host Machine                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Web VM    │  │   DB VM     │  │  Monitor VM │         │
│  │ Ubuntu 22.04│  │ Ubuntu 22.04│  │ Ubuntu 22.04│         │
│  │ 192.168.1.10│  │ 192.168.1.11│  │ 192.168.1.12│         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## Phase 1: Infrastructure Setup

### VM Specifications:
1. **Web Server VM**
   - OS: Ubuntu 22.04 LTS
   - RAM: 2GB
   - Storage: 20GB
   - Purpose: Web application hosting

2. **Database VM**
   - OS: Ubuntu 22.04 LTS
   - RAM: 4GB
   - Storage: 30GB
   - Purpose: Database server

3. **Monitoring VM**
   - OS: Ubuntu 22.04 LTS
   - RAM: 2GB
   - Storage: 20GB
   - Purpose: System monitoring

### Network Configuration:
- **Network Type**: Internal Network
- **IP Range**: 192.168.1.0/24
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 8.8.4.4

## Phase 2: System Administration Tasks

### 1. User and Group Management
```bash
# Create system users
sudo useradd -m -s /bin/bash devops
sudo useradd -m -s /bin/bash webapp
sudo useradd -m -s /bin/bash dbadmin

# Create groups
sudo groupadd developers
sudo groupadd sysadmins
sudo groupadd dbusers

# Add users to groups
sudo usermod -a -G developers devops
sudo usermod -a -G sysadmins devops
sudo usermod -a -G dbusers dbadmin
```

### 2. File System Management
```bash
# Create project directories
sudo mkdir -p /opt/webapps
sudo mkdir -p /var/log/applications
sudo mkdir -p /backup/databases

# Set permissions
sudo chown -R webapp:developers /opt/webapps
sudo chmod -R 755 /opt/webapps
sudo chmod -R 664 /var/log/applications
```

### 3. Storage Management
```bash
# Add new disk for data
sudo fdisk /dev/sdb
# Create partition
# Format with ext4
sudo mkfs.ext4 /dev/sdb1
# Create mount point
sudo mkdir /data
# Mount the partition
sudo mount /dev/sdb1 /data
# Add to fstab for persistent mounting
echo '/dev/sdb1 /data ext4 defaults 0 2' | sudo tee -a /etc/fstab
```

## Phase 3: Security Hardening

### 1. SSH Configuration
```bash
# Edit SSH config
sudo vim /etc/ssh/sshd_config

# Key configurations:
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers devops webapp
```

### 2. Firewall Setup
```bash
# Enable UFW
sudo ufw enable

# Allow SSH on custom port
sudo ufw allow 2222/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow database port (internal only)
sudo ufw allow from 192.168.1.0/24 to any port 3306
```

### 3. System Updates and Package Management
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget vim git htop tree unzip

# Set up automatic updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Phase 4: Monitoring and Logging

### 1. System Monitoring Setup
```bash
# Install monitoring tools
sudo apt install -y htop iotop nethogs

# Create monitoring script
cat > /usr/local/bin/system-monitor.sh << 'EOF'
#!/bin/bash
echo "=== System Monitor Report ===" > /var/log/system-monitor.log
echo "Date: $(date)" >> /var/log/system-monitor.log
echo "CPU Usage:" >> /var/log/system-monitor.log
top -bn1 | grep "Cpu(s)" >> /var/log/system-monitor.log
echo "Memory Usage:" >> /var/log/system-monitor.log
free -h >> /var/log/system-monitor.log
echo "Disk Usage:" >> /var/log/system-monitor.log
df -h >> /var/log/system-monitor.log
EOF

chmod +x /usr/local/bin/system-monitor.sh
```

### 2. Log Management
```bash
# Configure logrotate
sudo vim /etc/logrotate.d/application
```

## Phase 5: Automation Scripts

### 1. Backup Script
```bash
#!/bin/bash
# backup-system.sh

BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup important directories
tar -czf $BACKUP_DIR/home-backup.tar.gz /home
tar -czf $BACKUP_DIR/etc-backup.tar.gz /etc
tar -czf $BACKUP_DIR/var-log-backup.tar.gz /var/log

# Database backup (if running)
if systemctl is-active --quiet mysql; then
    mysqldump --all-databases > $BACKUP_DIR/mysql-backup.sql
fi

echo "Backup completed: $BACKUP_DIR"
```

### 2. Health Check Script
```bash
#!/bin/bash
# health-check.sh

echo "=== System Health Check ==="
echo "Date: $(date)"
echo

# Check disk space
echo "Disk Usage:"
df -h | awk '$5 > 80 { print $0 " - WARNING: High disk usage" }'

# Check memory usage
echo "Memory Usage:"
free -h

# Check system load
echo "System Load:"
uptime

# Check running services
echo "Critical Services Status:"
systemctl is-active --quiet ssh && echo "SSH: Running" || echo "SSH: FAILED"
systemctl is-active --quiet nginx && echo "Nginx: Running" || echo "Nginx: FAILED"
```

## Deliverables

1. **Documentation**
   - VM setup guide
   - Network configuration document
   - Security hardening checklist
   - Backup and recovery procedures

2. **Scripts**
   - System monitoring scripts
   - Backup automation scripts
   - Health check scripts
   - User management scripts

3. **Configuration Files**
   - SSH configuration
   - Firewall rules
   - System service configurations
   - Cron job schedules

## Learning Outcomes
- Linux system administration skills
- Virtualization concepts
- Security best practices
- Automation scripting
- System monitoring and logging
- Network configuration
- File system management
