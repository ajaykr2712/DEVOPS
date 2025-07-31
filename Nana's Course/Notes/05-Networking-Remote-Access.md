# 5. Networking and Remote Access - Detailed Notes

## Networking Basics

### OSI Model Overview
The Open Systems Interconnection (OSI) model is a conceptual framework that describes how network protocols interact and work together to provide network services.

```
Layer 7: Application  (HTTP, HTTPS, FTP, SSH, DNS)
Layer 6: Presentation (SSL/TLS, Encryption, Compression)
Layer 5: Session      (NetBIOS, RPC, SQL sessions)
Layer 4: Transport    (TCP, UDP)
Layer 3: Network      (IP, ICMP, ARP, Routing)
Layer 2: Data Link    (Ethernet, WiFi, MAC addresses)
Layer 1: Physical     (Cables, Hubs, Repeaters)
```

### TCP/IP Model
A simplified 4-layer model used in real-world networking:

```
Application Layer    (HTTP, HTTPS, SSH, FTP, DNS, SMTP)
Transport Layer      (TCP, UDP)
Internet Layer       (IP, ICMP, ARP)
Network Access Layer (Ethernet, WiFi)
```

### IP Addressing

#### IPv4 Addressing
- **Format**: 32-bit address written as four octets (e.g., 192.168.1.1)
- **Classes**:
  - Class A: 1.0.0.0 to 126.255.255.255 (Large networks)
  - Class B: 128.0.0.0 to 191.255.255.255 (Medium networks)
  - Class C: 192.0.0.0 to 223.255.255.255 (Small networks)

#### Private IP Ranges (RFC 1918)
```
10.0.0.0/8        (10.0.0.0 to 10.255.255.255)      - Class A
172.16.0.0/12     (172.16.0.0 to 172.31.255.255)    - Class B
192.168.0.0/16    (192.168.0.0 to 192.168.255.255)  - Class C
```

#### Special IP Addresses
```
127.0.0.1         - Loopback (localhost)
0.0.0.0           - Default route or "any address"
255.255.255.255   - Broadcast address
169.254.0.0/16    - Link-local (APIPA)
```

### Subnetting and CIDR

#### CIDR Notation
Classless Inter-Domain Routing (CIDR) uses a suffix to indicate the number of network bits:

```
192.168.1.0/24    - Network: 192.168.1.0, Subnet mask: 255.255.255.0
192.168.1.0/25    - Network: 192.168.1.0, Subnet mask: 255.255.255.128
192.168.1.128/25  - Network: 192.168.1.128, Subnet mask: 255.255.255.128
```

#### Subnet Calculation Examples
```bash
# /24 network (256 addresses, 254 usable)
Network: 192.168.1.0/24
Range: 192.168.1.1 - 192.168.1.254
Broadcast: 192.168.1.255

# /25 network (128 addresses, 126 usable)
Network: 192.168.1.0/25
Range: 192.168.1.1 - 192.168.1.126
Broadcast: 192.168.1.127
```

### Common Network Protocols

#### HTTP/HTTPS (Hypertext Transfer Protocol)
- **Port**: 80 (HTTP), 443 (HTTPS)
- **Purpose**: Web communication
- **Methods**: GET, POST, PUT, DELETE, PATCH

#### DNS (Domain Name System)
- **Port**: 53
- **Purpose**: Translate domain names to IP addresses
- **Types**: A, AAAA, CNAME, MX, TXT, NS

#### DHCP (Dynamic Host Configuration Protocol)
- **Ports**: 67 (server), 68 (client)
- **Purpose**: Automatic IP address assignment
- **Lease process**: Discover → Offer → Request → Acknowledge

#### TCP vs UDP
```
TCP (Transmission Control Protocol):
- Connection-oriented
- Reliable delivery
- Error correction
- Flow control
- Examples: HTTP, HTTPS, SSH, FTP

UDP (User Datagram Protocol):
- Connectionless
- Fast but unreliable
- No error correction
- Examples: DNS, DHCP, Video streaming
```

### Network Commands

#### Basic Connectivity
```bash
# Test connectivity
ping google.com
ping -c 4 8.8.8.8          # Send 4 packets
ping6 google.com           # IPv6 ping

# Trace route to destination
traceroute google.com
tracepath google.com       # Alternative to traceroute

# Test specific ports
telnet google.com 80
nc -zv google.com 80       # Netcat port scan
```

#### Network Configuration
```bash
# Show network interfaces
ip addr show
ip a                       # Short form
ifconfig                   # Legacy command

# Show routing table
ip route show
route -n                   # Legacy command

# Show ARP table
ip neigh show
arp -a                     # Legacy command

# Network statistics
netstat -tuln              # Show listening ports
ss -tuln                   # Modern replacement for netstat
netstat -rn                # Routing table
```

#### DNS Tools
```bash
# DNS lookup
nslookup google.com
dig google.com
dig @8.8.8.8 google.com    # Query specific DNS server

# Reverse DNS lookup
dig -x 8.8.8.8
nslookup 8.8.8.8

# DNS record types
dig google.com MX          # Mail exchange records
dig google.com TXT         # Text records
dig google.com NS          # Name server records
```

#### Network Monitoring
```bash
# Monitor network traffic
tcpdump -i eth0            # Capture packets on interface
tcpdump -i eth0 port 80    # Capture HTTP traffic
wireshark                  # GUI packet analyzer

# Bandwidth monitoring
iftop                      # Interface bandwidth
nethogs                    # Process bandwidth usage
vnstat                     # Network statistics
```

### Firewalls and Security

#### iptables (Traditional Linux Firewall)
```bash
# View current rules
iptables -L -n -v

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Block specific IP
iptables -A INPUT -s 192.168.1.100 -j DROP

# Allow related and established connections
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save rules (Ubuntu/Debian)
iptables-save > /etc/iptables/rules.v4
```

#### UFW (Uncomplicated Firewall)
```bash
# Enable/disable UFW
sudo ufw enable
sudo ufw disable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow services
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 192.168.1.0/24

# View status
sudo ufw status verbose
sudo ufw status numbered

# Delete rules
sudo ufw delete 2         # Delete rule number 2
sudo ufw delete allow ssh
```

#### firewalld (Red Hat/CentOS)
```bash
# Zone management
firewall-cmd --get-default-zone
firewall-cmd --list-all
firewall-cmd --list-all-zones

# Add services
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --add-port=8080/tcp --permanent

# Reload configuration
firewall-cmd --reload

# Rich rules
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" accept' --permanent
```

## Secure Shell (SSH)

### SSH Overview
SSH (Secure Shell) is a cryptographic network protocol for operating network services securely over an unsecured network.

#### SSH Components
- **SSH Client**: Initiates connections (ssh command)
- **SSH Server**: Accepts connections (sshd daemon)
- **SSH Keys**: Public/private key pairs for authentication
- **SSH Agent**: Manages private keys in memory

### SSH Configuration

#### Client Configuration (~/.ssh/config)
```bash
# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes

# Specific host configuration
Host webserver
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/webserver_key

Host jumphost
    HostName jump.company.com
    User jumpuser
    ProxyJump bastion.company.com

# Connection through proxy
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyCommand ssh -W %h:%p jumphost
```

#### Server Configuration (/etc/ssh/sshd_config)
```bash
# Security settings
Protocol 2
Port 2222                          # Change default port
PermitRootLogin no                 # Disable root login
PasswordAuthentication no          # Disable password auth
PubkeyAuthentication yes           # Enable key-based auth
AuthorizedKeysFile .ssh/authorized_keys

# Connection settings
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2

# Restrictions
AllowUsers admin deploy
AllowGroups ssh-users
DenyUsers guest

# Logging
LogLevel INFO
SyslogFacility AUTHPRIV

# Disable unused features
X11Forwarding no
AllowTcpForwarding no
GatewayPorts no
```

### SSH Key Management

#### Generate SSH Keys
```bash
# Generate RSA key (4096 bits)
ssh-keygen -t rsa -b 4096 -C "user@company.com"

# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "user@company.com"

# Generate key with custom filename
ssh-keygen -t ed25519 -f ~/.ssh/production_key -C "production-access"

# Generate key without passphrase (not recommended)
ssh-keygen -t ed25519 -N "" -f ~/.ssh/automation_key
```

#### Deploy SSH Keys
```bash
# Copy public key to server
ssh-copy-id user@server
ssh-copy-id -i ~/.ssh/custom_key.pub user@server

# Manual key deployment
cat ~/.ssh/id_ed25519.pub | ssh user@server 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

#### SSH Agent
```bash
# Start SSH agent
eval $(ssh-agent)

# Add keys to agent
ssh-add ~/.ssh/id_ed25519
ssh-add ~/.ssh/production_key

# List loaded keys
ssh-add -l

# Remove keys from agent
ssh-add -d ~/.ssh/id_ed25519
ssh-add -D                      # Remove all keys

# Forward agent to remote server
ssh -A user@server
```

### Advanced SSH Features

#### SSH Tunneling

##### Local Port Forwarding
```bash
# Forward local port 8080 to remote server's port 80
ssh -L 8080:localhost:80 user@server

# Access database through SSH tunnel
ssh -L 3306:db.internal.com:3306 user@jumphost

# Keep tunnel open without shell
ssh -N -L 8080:localhost:80 user@server
```

##### Remote Port Forwarding
```bash
# Forward server's port 8080 to local port 80
ssh -R 8080:localhost:80 user@server

# Make local service available on remote server
ssh -R 9000:localhost:3000 user@server
```

##### Dynamic Port Forwarding (SOCKS Proxy)
```bash
# Create SOCKS proxy on port 1080
ssh -D 1080 user@server

# Use with applications
curl --socks5 localhost:1080 http://internal.site.com
```

#### SSH Jump Hosts
```bash
# Connect through jump host
ssh -J jumpuser@jumphost user@target

# Multiple jump hosts
ssh -J user1@jump1,user2@jump2 user@target

# ProxyJump in config file
Host target
    HostName target.internal.com
    User admin
    ProxyJump jumphost
```

#### SSH File Transfer

##### SCP (Secure Copy)
```bash
# Copy file to remote server
scp file.txt user@server:/path/to/destination/

# Copy directory recursively
scp -r directory/ user@server:/path/to/destination/

# Copy from remote to local
scp user@server:/path/to/file.txt ./

# Copy through jump host
scp -o ProxyJump=jumphost file.txt user@target:/path/
```

##### SFTP (SSH File Transfer Protocol)
```bash
# Interactive SFTP session
sftp user@server

# SFTP commands
put file.txt                    # Upload file
get remotefile.txt              # Download file
put -r directory/               # Upload directory
get -r remotedirectory/         # Download directory
ls                              # List remote files
lls                             # List local files
cd /path                        # Change remote directory
lcd /localpath                  # Change local directory
```

##### rsync over SSH
```bash
# Sync directories
rsync -avz source/ user@server:destination/

# Sync with progress and compression
rsync -avz --progress source/ user@server:destination/

# Exclude files
rsync -avz --exclude='*.log' source/ user@server:destination/

# Dry run (test without changes)
rsync -avz --dry-run source/ user@server:destination/
```

### SSH Security Best Practices

#### Server Hardening
```bash
# Change default port
Port 2222

# Disable root login
PermitRootLogin no

# Use key-based authentication only
PasswordAuthentication no
PubkeyAuthentication yes

# Limit users
AllowUsers admin deploy
DenyUsers root guest

# Set login grace time
LoginGraceTime 30

# Limit authentication attempts
MaxAuthTries 3

# Use strong ciphers
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
```

#### Client Security
```bash
# Use specific keys for specific hosts
Host production
    HostName prod.company.com
    IdentityFile ~/.ssh/production_key
    IdentitiesOnly yes

# Verify host keys
StrictHostKeyChecking yes
UserKnownHostsFile ~/.ssh/known_hosts

# Connection timeout
ConnectTimeout 30

# Keep connections alive
ServerAliveInterval 60
ServerAliveCountMax 3
```

#### Monitoring and Logging
```bash
# SSH log locations
/var/log/auth.log              # Ubuntu/Debian
/var/log/secure                # Red Hat/CentOS

# Monitor SSH connections
tail -f /var/log/auth.log | grep ssh

# Check failed login attempts
grep "Failed password" /var/log/auth.log

# SSH connection analysis
last                           # Show login history
w                              # Current logged in users
who                            # Currently logged in users
```

### Network Troubleshooting

#### Common Network Issues

##### Connectivity Problems
```bash
# Test basic connectivity
ping 8.8.8.8                   # Test internet connectivity
ping gateway_ip                # Test gateway connectivity
ping internal_server           # Test internal connectivity

# DNS resolution issues
nslookup domain.com
dig domain.com
cat /etc/resolv.conf           # Check DNS servers
```

##### Port Connectivity
```bash
# Test port connectivity
telnet server 80
nc -zv server 80
curl -I http://server          # HTTP connectivity

# Scan ports
nmap -p 80,443 server
nmap -sT server                # TCP scan
```

##### Performance Issues
```bash
# Network latency
ping -i 0.1 server             # High frequency ping
mtr server                     # Continuous traceroute

# Bandwidth testing
iperf3 -s                      # Server mode
iperf3 -c server               # Client mode

# Interface statistics
cat /proc/net/dev
ip -s link show eth0
```

#### Network Debugging Tools
```bash
# Packet capture
tcpdump -i any -w capture.pcap
tcpdump -r capture.pcap        # Read capture file

# Monitor network connections
netstat -tuln                  # Listening ports
ss -tuln                       # Socket statistics
lsof -i                        # Files opened by network processes

# ARP table issues
arp -a                         # Show ARP table
ip neigh flush all             # Clear ARP cache
```
