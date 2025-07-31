# Project 5: Enterprise Network Lab and SSH Infrastructure

## Project Overview
Build a comprehensive enterprise network lab with multiple subnets, security zones, and a complete SSH infrastructure including jump hosts, key management, and monitoring.

## Network Architecture
```
Internet Gateway (192.168.1.1)
│
├── DMZ Network (192.168.10.0/24)
│   ├── Load Balancer (192.168.10.10)
│   ├── Web Server 1 (192.168.10.11)
│   └── Web Server 2 (192.168.10.12)
│
├── Application Network (192.168.20.0/24)
│   ├── App Server 1 (192.168.20.21)
│   ├── App Server 2 (192.168.20.22)
│   └── Cache Server (192.168.20.25)
│
├── Database Network (192.168.30.0/24)
│   ├── DB Master (192.168.30.31)
│   ├── DB Slave (192.168.30.32)
│   └── Backup Server (192.168.30.35)
│
├── Management Network (192.168.40.0/24)
│   ├── Jump Host (192.168.40.41)
│   ├── Monitoring (192.168.40.42)
│   └── Log Server (192.168.40.43)
│
└── Developer Network (192.168.50.0/24)
    ├── Dev Server 1 (192.168.50.51)
    ├── Dev Server 2 (192.168.50.52)
    └── CI/CD Server (192.168.50.55)
```

## Phase 1: Network Infrastructure Setup

### 1. Network Configuration Script
```bash
#!/bin/bash
# setup-network.sh - Configure enterprise network infrastructure

set -euo pipefail

# Network configuration
declare -A NETWORKS=(
    ["dmz"]="192.168.10.0/24"
    ["app"]="192.168.20.0/24"
    ["db"]="192.168.30.0/24"
    ["mgmt"]="192.168.40.0/24"
    ["dev"]="192.168.50.0/24"
)

declare -A GATEWAYS=(
    ["dmz"]="192.168.10.1"
    ["app"]="192.168.20.1"
    ["db"]="192.168.30.1"
    ["mgmt"]="192.168.40.1"
    ["dev"]="192.168.50.1"
)

# DNS Configuration
PRIMARY_DNS="8.8.8.8"
SECONDARY_DNS="8.8.4.4"
DOMAIN="enterprise.local"

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

validate_network_config() {
    log_info "Validating network configuration..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    # Check required commands
    local required_commands=("ip" "iptables" "systemctl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
}

configure_interfaces() {
    log_info "Configuring network interfaces..."
    
    # Create netplan configuration for Ubuntu
    cat > /etc/netplan/01-enterprise-network.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      nameservers:
        addresses: [$PRIMARY_DNS, $SECONDARY_DNS]
        search: [$DOMAIN]
    eth1:
      addresses: [${GATEWAYS[dmz]}/24]
    eth2:
      addresses: [${GATEWAYS[app]}/24]
    eth3:
      addresses: [${GATEWAYS[db]}/24]
    eth4:
      addresses: [${GATEWAYS[mgmt]}/24]
    eth5:
      addresses: [${GATEWAYS[dev]}/24]
  bridges:
    br-dmz:
      interfaces: [eth1]
      addresses: [${GATEWAYS[dmz]}/24]
      parameters:
        stp: false
        forward-delay: 0
    br-app:
      interfaces: [eth2]
      addresses: [${GATEWAYS[app]}/24]
      parameters:
        stp: false
        forward-delay: 0
    br-db:
      interfaces: [eth3]
      addresses: [${GATEWAYS[db]}/24]
      parameters:
        stp: false
        forward-delay: 0
    br-mgmt:
      interfaces: [eth4]
      addresses: [${GATEWAYS[mgmt]}/24]
      parameters:
        stp: false
        forward-delay: 0
    br-dev:
      interfaces: [eth5]
      addresses: [${GATEWAYS[dev]}/24]
      parameters:
        stp: false
        forward-delay: 0
EOF
    
    # Apply network configuration
    netplan apply
    log_info "Network interfaces configured"
}

configure_routing() {
    log_info "Configuring routing..."
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
    sysctl -p
    
    # Add static routes
    for network in "${!NETWORKS[@]}"; do
        local net="${NETWORKS[$network]}"
        local gw="${GATEWAYS[$network]}"
        
        # Add route if not exists
        if ! ip route show | grep -q "$net"; then
            ip route add "$net" via "$gw" 2>/dev/null || true
        fi
    done
    
    log_info "Routing configured"
}

configure_firewall() {
    log_info "Configuring enterprise firewall rules..."
    
    # Flush existing rules
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    
    # Set default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    
    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    
    # Allow established connections
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # Management network rules
    iptables -A INPUT -s 192.168.40.0/24 -j ACCEPT
    iptables -A FORWARD -s 192.168.40.0/24 -j ACCEPT
    
    # DMZ to App network (HTTP/HTTPS only)
    iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -p tcp -m multiport --dports 80,443 -j ACCEPT
    
    # App to Database network (DB ports only)
    iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.30.0/24 -p tcp -m multiport --dports 3306,5432 -j ACCEPT
    
    # Developer network rules (limited access)
    iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.20.0/24 -p tcp --dport 8080 -j ACCEPT
    
    # SSH access from management network only
    iptables -A INPUT -s 192.168.40.0/24 -p tcp --dport 22 -j ACCEPT
    
    # Internet access for all networks (NAT)
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    
    # Save iptables rules
    iptables-save > /etc/iptables/rules.v4
    
    log_info "Firewall rules configured"
}

configure_dns() {
    log_info "Configuring DNS server..."
    
    # Install and configure dnsmasq
    apt update && apt install -y dnsmasq
    
    # Configure dnsmasq
    cat > /etc/dnsmasq.conf << EOF
# DNS Configuration
server=$PRIMARY_DNS
server=$SECONDARY_DNS
domain=$DOMAIN
local=/$DOMAIN/

# DHCP Configuration for networks
dhcp-range=tag:dmz,192.168.10.100,192.168.10.200,12h
dhcp-range=tag:app,192.168.20.100,192.168.20.200,12h
dhcp-range=tag:db,192.168.30.100,192.168.30.200,12h
dhcp-range=tag:mgmt,192.168.40.100,192.168.40.200,12h
dhcp-range=tag:dev,192.168.50.100,192.168.50.200,12h

# Static host entries
address=/jumphost.$DOMAIN/192.168.40.41
address=/monitoring.$DOMAIN/192.168.40.42
address=/logserver.$DOMAIN/192.168.40.43
address=/loadbalancer.$DOMAIN/192.168.10.10
address=/webserver1.$DOMAIN/192.168.10.11
address=/webserver2.$DOMAIN/192.168.10.12

# Logging
log-queries
log-dhcp
EOF
    
    systemctl enable dnsmasq
    systemctl restart dnsmasq
    
    log_info "DNS server configured"
}

setup_monitoring() {
    log_info "Setting up network monitoring..."
    
    # Install monitoring tools
    apt install -y nmap iperf3 tcpdump wireshark-common
    
    # Create network monitoring script
    cat > /usr/local/bin/network-monitor.sh << 'EOF'
#!/bin/bash
# network-monitor.sh - Monitor network connectivity and performance

LOG_FILE="/var/log/network-monitor.log"
NETWORKS=("192.168.10.0/24" "192.168.20.0/24" "192.168.30.0/24" "192.168.40.0/24" "192.168.50.0/24")

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_connectivity() {
    log_message "=== Network Connectivity Check ==="
    
    for network in "${NETWORKS[@]}"; do
        local gateway=$(echo "$network" | sed 's/0\/24/1/')
        
        if ping -c 3 "$gateway" >/dev/null 2>&1; then
            log_message "✓ Gateway $gateway is reachable"
        else
            log_message "✗ Gateway $gateway is unreachable"
        fi
    done
}

check_services() {
    log_message "=== Service Connectivity Check ==="
    
    local services=(
        "jumphost.enterprise.local:22"
        "webserver1.enterprise.local:80"
        "monitoring.enterprise.local:3000"
    )
    
    for service in "${services[@]}"; do
        local host=$(echo "$service" | cut -d':' -f1)
        local port=$(echo "$service" | cut -d':' -f2)
        
        if nc -z "$host" "$port" 2>/dev/null; then
            log_message "✓ Service $service is available"
        else
            log_message "✗ Service $service is unavailable"
        fi
    done
}

network_statistics() {
    log_message "=== Network Statistics ==="
    
    # Interface statistics
    for interface in $(ip link show | grep -E '^[0-9]+:' | cut -d':' -f2 | tr -d ' ' | grep -E '^(eth|br-)'); do
        local rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
        local tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
        
        local rx_mb=$((rx_bytes / 1024 / 1024))
        local tx_mb=$((tx_bytes / 1024 / 1024))
        
        log_message "Interface $interface: RX ${rx_mb}MB, TX ${tx_mb}MB"
    done
}

main() {
    check_connectivity
    check_services
    network_statistics
    log_message "=== Network Monitor Complete ==="
}

main "$@"
EOF
    
    chmod +x /usr/local/bin/network-monitor.sh
    
    # Add to cron for regular monitoring
    echo "*/5 * * * * root /usr/local/bin/network-monitor.sh" >> /etc/crontab
    
    log_info "Network monitoring configured"
}

main() {
    log_info "Starting enterprise network setup..."
    
    validate_network_config
    configure_interfaces
    configure_routing
    configure_firewall
    configure_dns
    setup_monitoring
    
    log_info "Enterprise network setup completed successfully"
    log_info "Network segments configured:"
    
    for network in "${!NETWORKS[@]}"; do
        echo "  $network: ${NETWORKS[$network]} (Gateway: ${GATEWAYS[$network]})"
    done
}

# Execute main function
main "$@"
```

## Phase 2: SSH Infrastructure Setup

### 1. SSH Jump Host Configuration
```bash
#!/bin/bash
# setup-jumphost.sh - Configure SSH jump host

set -euo pipefail

JUMPHOST_IP="192.168.40.41"
SSH_PORT="2222"
LOG_FILE="/var/log/jumphost-setup.log"

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

install_requirements() {
    log_info "Installing required packages..."
    
    apt update
    apt install -y openssh-server fail2ban ufw auditd
    
    log_info "Required packages installed"
}

configure_ssh_server() {
    log_info "Configuring SSH server..."
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Create hardened SSH configuration
    cat > /etc/ssh/sshd_config << EOF
# SSH Server Configuration - Jump Host
Protocol 2
Port $SSH_PORT

# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Connection settings
MaxAuthTries 3
MaxSessions 10
MaxStartups 10:30:60
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2

# User/Group restrictions
AllowGroups ssh-users admins
DenyUsers root guest

# Security features
StrictModes yes
IgnoreRhosts yes
HostbasedAuthentication no
PermitUserEnvironment no

# Logging
LogLevel VERBOSE
SyslogFacility AUTHPRIV

# Disable unused features
X11Forwarding no
AllowTcpForwarding yes
GatewayPorts no
PermitTunnel no
AllowAgentForwarding yes

# Crypto settings
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512

# Banner
Banner /etc/ssh/banner
EOF
    
    # Create SSH banner
    cat > /etc/ssh/banner << 'EOF'
**************************************************************************
*                                                                        *
*                         AUTHORIZED ACCESS ONLY                        *
*                                                                        *
*  This system is for authorized users only. All activities are         *
*  monitored and logged. Unauthorized access is strictly prohibited.    *
*                                                                        *
**************************************************************************
EOF
    
    # Test SSH configuration
    sshd -t || {
        log_error "SSH configuration test failed"
        exit 1
    }
    
    systemctl restart ssh
    log_info "SSH server configured"
}

setup_user_management() {
    log_info "Setting up user management..."
    
    # Create groups
    groupadd -f ssh-users
    groupadd -f admins
    
    # Create jump host users
    local users=("admin" "operator" "developer")
    
    for user in "${users[@]}"; do
        if ! id "$user" &>/dev/null; then
            useradd -m -s /bin/bash -G ssh-users "$user"
            log_info "Created user: $user"
        fi
        
        # Create SSH directory
        sudo -u "$user" mkdir -p "/home/$user/.ssh"
        sudo -u "$user" chmod 700 "/home/$user/.ssh"
        sudo -u "$user" touch "/home/$user/.ssh/authorized_keys"
        sudo -u "$user" chmod 600 "/home/$user/.ssh/authorized_keys"
    done
    
    # Add admin to admins group
    usermod -a -G admins admin
    
    log_info "User management configured"
}

configure_firewall() {
    log_info "Configuring firewall..."
    
    # Enable UFW
    ufw --force enable
    
    # Default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH from management network
    ufw allow from 192.168.40.0/24 to any port "$SSH_PORT"
    
    # Allow SSH from external networks (for jump host functionality)
    ufw allow "$SSH_PORT"/tcp
    
    # Allow monitoring
    ufw allow from 192.168.40.42 to any port 9100  # Node exporter
    
    log_info "Firewall configured"
}

setup_fail2ban() {
    log_info "Setting up Fail2Ban..."
    
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    log_info "Fail2Ban configured"
}

setup_auditing() {
    log_info "Setting up system auditing..."
    
    # Configure auditd rules
    cat > /etc/audit/rules.d/ssh.rules << EOF
# SSH monitoring rules
-w /etc/ssh/sshd_config -p wa -k ssh_config
-w /etc/ssh/ -p wa -k ssh_config
-w /home/ -p wa -k home_dirs
-a always,exit -F arch=b64 -S execve -k commands
-a always,exit -F arch=b32 -S execve -k commands
EOF
    
    systemctl restart auditd
    
    log_info "System auditing configured"
}

create_ssh_management_scripts() {
    log_info "Creating SSH management scripts..."
    
    # SSH user management script
    cat > /usr/local/bin/manage-ssh-users.sh << 'EOF'
#!/bin/bash
# manage-ssh-users.sh - Manage SSH users and keys

set -euo pipefail

ACTION="$1"
USERNAME="${2:-}"
KEY_FILE="${3:-}"

usage() {
    echo "Usage: $0 {add-user|remove-user|add-key|remove-key|list-users} [username] [key-file]"
    exit 1
}

add_user() {
    local user="$1"
    
    if id "$user" &>/dev/null; then
        echo "User $user already exists"
        return 1
    fi
    
    useradd -m -s /bin/bash -G ssh-users "$user"
    sudo -u "$user" mkdir -p "/home/$user/.ssh"
    sudo -u "$user" chmod 700 "/home/$user/.ssh"
    sudo -u "$user" touch "/home/$user/.ssh/authorized_keys"
    sudo -u "$user" chmod 600 "/home/$user/.ssh/authorized_keys"
    
    echo "User $user created successfully"
}

remove_user() {
    local user="$1"
    
    if ! id "$user" &>/dev/null; then
        echo "User $user does not exist"
        return 1
    fi
    
    userdel -r "$user"
    echo "User $user removed successfully"
}

add_key() {
    local user="$1"
    local key_file="$2"
    
    if ! id "$user" &>/dev/null; then
        echo "User $user does not exist"
        return 1
    fi
    
    if [ ! -f "$key_file" ]; then
        echo "Key file $key_file not found"
        return 1
    fi
    
    cat "$key_file" >> "/home/$user/.ssh/authorized_keys"
    chown "$user:$user" "/home/$user/.ssh/authorized_keys"
    
    echo "Key added for user $user"
}

list_users() {
    echo "SSH Users:"
    getent group ssh-users | cut -d: -f4 | tr ',' '\n' | sort
}

case "$ACTION" in
    add-user)
        [ -n "$USERNAME" ] || usage
        add_user "$USERNAME"
        ;;
    remove-user)
        [ -n "$USERNAME" ] || usage
        remove_user "$USERNAME"
        ;;
    add-key)
        [ -n "$USERNAME" ] && [ -n "$KEY_FILE" ] || usage
        add_key "$USERNAME" "$KEY_FILE"
        ;;
    list-users)
        list_users
        ;;
    *)
        usage
        ;;
esac
EOF
    
    chmod +x /usr/local/bin/manage-ssh-users.sh
    
    # SSH monitoring script
    cat > /usr/local/bin/ssh-monitor.sh << 'EOF'
#!/bin/bash
# ssh-monitor.sh - Monitor SSH connections and activities

LOG_FILE="/var/log/ssh-monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

show_active_sessions() {
    log_message "=== Active SSH Sessions ==="
    who | grep pts | while read line; do
        log_message "Active: $line"
    done
}

show_recent_logins() {
    log_message "=== Recent SSH Logins ==="
    last -n 10 | grep -E "(pts|ssh)" | while read line; do
        log_message "Recent: $line"
    done
}

show_failed_attempts() {
    log_message "=== Recent Failed Attempts ==="
    grep "Failed password" /var/log/auth.log | tail -10 | while read line; do
        log_message "Failed: $line"
    done
}

show_connection_stats() {
    log_message "=== Connection Statistics ==="
    
    local total_connections=$(grep "Accepted publickey" /var/log/auth.log | wc -l)
    local unique_users=$(grep "Accepted publickey" /var/log/auth.log | awk '{print $9}' | sort | uniq | wc -l)
    local unique_ips=$(grep "Accepted publickey" /var/log/auth.log | awk '{print $11}' | sort | uniq | wc -l)
    
    log_message "Total successful connections: $total_connections"
    log_message "Unique users: $unique_users"
    log_message "Unique source IPs: $unique_ips"
}

main() {
    show_active_sessions
    show_recent_logins
    show_failed_attempts
    show_connection_stats
    log_message "=== SSH Monitor Complete ==="
}

main "$@"
EOF
    
    chmod +x /usr/local/bin/ssh-monitor.sh
    
    # Add to cron
    echo "*/15 * * * * root /usr/local/bin/ssh-monitor.sh" >> /etc/crontab
    
    log_info "SSH management scripts created"
}

main() {
    log_info "Setting up SSH jump host..."
    
    install_requirements
    configure_ssh_server
    setup_user_management
    configure_firewall
    setup_fail2ban
    setup_auditing
    create_ssh_management_scripts
    
    log_info "SSH jump host setup completed"
    log_info "SSH server listening on port: $SSH_PORT"
    log_info "Management scripts available:"
    log_info "  - /usr/local/bin/manage-ssh-users.sh"
    log_info "  - /usr/local/bin/ssh-monitor.sh"
}

# Execute main function
main "$@"
```

### 2. SSH Key Management System
```bash
#!/bin/bash
# ssh-key-manager.sh - Centralized SSH key management system

set -euo pipefail

# Configuration
KEY_STORE="/etc/ssh-keys"
AUTHORIZED_KEYS_DIR="/etc/ssh-keys/authorized"
BACKUP_DIR="/etc/ssh-keys/backup"
LOG_FILE="/var/log/ssh-key-manager.log"

# Key types and their properties
declare -A KEY_TYPES=(
    ["rsa"]="4096"
    ["ed25519"]=""
    ["ecdsa"]="521"
)

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE" >&2
}

usage() {
    cat << EOF
SSH Key Manager - Centralized key management system

Usage: $0 COMMAND [OPTIONS]

Commands:
    generate-key    Generate new SSH key pair
    deploy-key      Deploy public key to servers
    revoke-key      Revoke and remove key from servers
    rotate-keys     Rotate keys for specified user/servers
    list-keys       List all managed keys
    backup-keys     Backup all keys
    restore-keys    Restore keys from backup

Options:
    -u, --user USER         Username for key operations
    -t, --type TYPE         Key type (rsa, ed25519, ecdsa)
    -s, --servers SERVERS   Comma-separated list of servers
    -k, --key-id ID         Key identifier
    -f, --force             Force operation without confirmation
    -h, --help              Show this help

Examples:
    $0 generate-key -u admin -t ed25519
    $0 deploy-key -u admin -k admin_ed25519 -s server1,server2
    $0 rotate-keys -u admin -s server1,server2
    $0 revoke-key -k admin_rsa_old
EOF
}

initialize_key_store() {
    log_info "Initializing SSH key store..."
    
    mkdir -p "$KEY_STORE"/{private,public,config,backup}
    mkdir -p "$AUTHORIZED_KEYS_DIR"
    mkdir -p "$BACKUP_DIR"
    
    chmod 700 "$KEY_STORE"
    chmod 700 "$KEY_STORE/private"
    chmod 755 "$KEY_STORE/public"
    
    # Create key registry
    if [ ! -f "$KEY_STORE/registry.json" ]; then
        cat > "$KEY_STORE/registry.json" << 'EOF'
{
    "keys": {},
    "deployments": {},
    "metadata": {
        "created": "TIMESTAMP",
        "version": "1.0"
    }
}
EOF
        sed -i "s/TIMESTAMP/$(date -Iseconds)/" "$KEY_STORE/registry.json"
    fi
    
    log_info "Key store initialized"
}

generate_ssh_key() {
    local user="$1"
    local key_type="$2"
    local comment="${3:-$user@$(hostname)-$(date +%Y%m%d)}"
    
    log_info "Generating $key_type key for user: $user"
    
    local key_id="${user}_${key_type}_$(date +%Y%m%d)"
    local private_key="$KEY_STORE/private/$key_id"
    local public_key="$KEY_STORE/public/$key_id.pub"
    
    # Generate key based on type
    case "$key_type" in
        "rsa")
            ssh-keygen -t rsa -b "${KEY_TYPES[rsa]}" -f "$private_key" -C "$comment" -N ""
            ;;
        "ed25519")
            ssh-keygen -t ed25519 -f "$private_key" -C "$comment" -N ""
            ;;
        "ecdsa")
            ssh-keygen -t ecdsa -b "${KEY_TYPES[ecdsa]}" -f "$private_key" -C "$comment" -N ""
            ;;
        *)
            log_error "Unsupported key type: $key_type"
            return 1
            ;;
    esac
    
    chmod 600 "$private_key"
    chmod 644 "$public_key"
    
    # Update registry
    update_key_registry "$key_id" "$user" "$key_type" "generated" ""
    
    log_info "Key generated: $key_id"
    echo "$key_id"
}

deploy_key_to_servers() {
    local user="$1"
    local key_id="$2"
    local servers="$3"
    
    log_info "Deploying key $key_id to servers: $servers"
    
    local public_key="$KEY_STORE/public/$key_id.pub"
    
    if [ ! -f "$public_key" ]; then
        log_error "Public key not found: $public_key"
        return 1
    fi
    
    IFS=',' read -ra SERVER_LIST <<< "$servers"
    local deployed_servers=()
    
    for server in "${SERVER_LIST[@]}"; do
        log_info "Deploying to server: $server"
        
        if ssh-copy-id -i "$public_key" "$user@$server" 2>/dev/null; then
            log_info "Successfully deployed to $server"
            deployed_servers+=("$server")
        else
            log_error "Failed to deploy to $server"
        fi
    done
    
    # Update registry with deployment info
    local deployed_list=$(IFS=','; echo "${deployed_servers[*]}")
    update_key_registry "$key_id" "$user" "" "deployed" "$deployed_list"
    
    log_info "Key deployment completed"
}

revoke_key() {
    local key_id="$1"
    local servers="${2:-}"
    
    log_info "Revoking key: $key_id"
    
    local public_key="$KEY_STORE/public/$key_id.pub"
    
    if [ ! -f "$public_key" ]; then
        log_error "Public key not found: $public_key"
        return 1
    fi
    
    # Get key content for removal
    local key_content=$(cat "$public_key")
    local key_fingerprint=$(ssh-keygen -lf "$public_key" | awk '{print $2}')
    
    # If no servers specified, get from registry
    if [ -z "$servers" ]; then
        servers=$(get_deployed_servers "$key_id")
    fi
    
    if [ -n "$servers" ]; then
        IFS=',' read -ra SERVER_LIST <<< "$servers"
        
        for server in "${SERVER_LIST[@]}"; do
            log_info "Removing key from server: $server"
            
            # Remove key from authorized_keys
            ssh "$server" "sed -i '/$key_fingerprint/d' ~/.ssh/authorized_keys" 2>/dev/null || true
        done
    fi
    
    # Move keys to backup
    mv "$KEY_STORE/private/$key_id" "$BACKUP_DIR/" 2>/dev/null || true
    mv "$KEY_STORE/public/$key_id.pub" "$BACKUP_DIR/" 2>/dev/null || true
    
    # Update registry
    update_key_registry "$key_id" "" "" "revoked" ""
    
    log_info "Key revoked: $key_id"
}

rotate_user_keys() {
    local user="$1"
    local servers="$2"
    local key_type="${3:-ed25519}"
    
    log_info "Rotating keys for user: $user on servers: $servers"
    
    # Generate new key
    local new_key_id
    new_key_id=$(generate_ssh_key "$user" "$key_type")
    
    # Deploy new key
    deploy_key_to_servers "$user" "$new_key_id" "$servers"
    
    # Get old keys for this user
    local old_keys
    old_keys=$(get_user_keys "$user" | grep -v "$new_key_id" || true)
    
    if [ -n "$old_keys" ]; then
        log_info "Revoking old keys..."
        
        while read -r old_key; do
            [ -n "$old_key" ] && revoke_key "$old_key" "$servers"
        done <<< "$old_keys"
    fi
    
    log_info "Key rotation completed for user: $user"
}

update_key_registry() {
    local key_id="$1"
    local user="$2"
    local key_type="$3"
    local status="$4"
    local servers="$5"
    
    local registry="$KEY_STORE/registry.json"
    local temp_file=$(mktemp)
    
    # Create entry if it doesn't exist
    if ! jq -e ".keys[\"$key_id\"]" "$registry" >/dev/null 2>&1; then
        jq ".keys[\"$key_id\"] = {}" "$registry" > "$temp_file"
        mv "$temp_file" "$registry"
    fi
    
    # Update fields
    [ -n "$user" ] && jq ".keys[\"$key_id\"].user = \"$user\"" "$registry" > "$temp_file" && mv "$temp_file" "$registry"
    [ -n "$key_type" ] && jq ".keys[\"$key_id\"].type = \"$key_type\"" "$registry" > "$temp_file" && mv "$temp_file" "$registry"
    [ -n "$status" ] && jq ".keys[\"$key_id\"].status = \"$status\"" "$registry" > "$temp_file" && mv "$temp_file" "$registry"
    [ -n "$servers" ] && jq ".keys[\"$key_id\"].servers = \"$servers\"" "$registry" > "$temp_file" && mv "$temp_file" "$registry"
    
    # Update timestamp
    jq ".keys[\"$key_id\"].updated = \"$(date -Iseconds)\"" "$registry" > "$temp_file"
    mv "$temp_file" "$registry"
}

get_deployed_servers() {
    local key_id="$1"
    jq -r ".keys[\"$key_id\"].servers // \"\"" "$KEY_STORE/registry.json"
}

get_user_keys() {
    local user="$1"
    jq -r ".keys | to_entries[] | select(.value.user == \"$user\") | .key" "$KEY_STORE/registry.json"
}

list_keys() {
    log_info "Listing all managed SSH keys:"
    
    echo "Key Management Registry"
    echo "======================"
    printf "%-20s %-10s %-10s %-15s %-20s %s\n" "KEY_ID" "USER" "TYPE" "STATUS" "UPDATED" "SERVERS"
    echo "-------------------------------------------------------------------------------------"
    
    jq -r '.keys | to_entries[] | "\(.key)|\(.value.user // "")|\(.value.type // "")|\(.value.status // "")|\(.value.updated // "")|\(.value.servers // "")"' "$KEY_STORE/registry.json" | \
    while IFS='|' read -r key_id user type status updated servers; do
        printf "%-20s %-10s %-10s %-15s %-20s %s\n" "$key_id" "$user" "$type" "$status" "${updated:0:19}" "$servers"
    done
}

backup_keys() {
    local backup_name="ssh-keys-backup-$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name.tar.gz"
    
    log_info "Creating backup: $backup_name"
    
    tar -czf "$backup_path" -C "$KEY_STORE" . --exclude="backup/*"
    
    log_info "Backup created: $backup_path"
    echo "$backup_path"
}

main() {
    local command=""
    local user=""
    local key_type="ed25519"
    local servers=""
    local key_id=""
    local force="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            generate-key|deploy-key|revoke-key|rotate-keys|list-keys|backup-keys)
                command="$1"
                shift
                ;;
            -u|--user)
                user="$2"
                shift 2
                ;;
            -t|--type)
                key_type="$2"
                shift 2
                ;;
            -s|--servers)
                servers="$2"
                shift 2
                ;;
            -k|--key-id)
                key_id="$2"
                shift 2
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Validate command
    if [ -z "$command" ]; then
        usage
        exit 1
    fi
    
    # Check dependencies
    for cmd in ssh-keygen ssh-copy-id jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    # Initialize key store
    initialize_key_store
    
    # Execute command
    case "$command" in
        generate-key)
            [ -n "$user" ] || { log_error "User required for key generation"; exit 1; }
            generate_ssh_key "$user" "$key_type"
            ;;
        deploy-key)
            [ -n "$user" ] && [ -n "$key_id" ] && [ -n "$servers" ] || {
                log_error "User, key-id, and servers required for deployment"
                exit 1
            }
            deploy_key_to_servers "$user" "$key_id" "$servers"
            ;;
        revoke-key)
            [ -n "$key_id" ] || { log_error "Key-id required for revocation"; exit 1; }
            revoke_key "$key_id" "$servers"
            ;;
        rotate-keys)
            [ -n "$user" ] && [ -n "$servers" ] || {
                log_error "User and servers required for key rotation"
                exit 1
            }
            rotate_user_keys "$user" "$servers" "$key_type"
            ;;
        list-keys)
            list_keys
            ;;
        backup-keys)
            backup_keys
            ;;
    esac
}

# Execute main function
main "$@"
```

## Learning Outcomes
- Enterprise network design and implementation
- Advanced SSH configuration and security
- Network security with firewalls and monitoring
- Centralized key management systems
- Jump host architecture and administration
- Network troubleshooting and monitoring
- DNS and DHCP configuration
- Security auditing and compliance
