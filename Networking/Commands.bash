# Basic Network Information
ifconfig                              # Display network interface configuration
ip addr show                          # Show IP addresses (Linux)
ip link show                          # Show network interfaces (Linux)
hostname                              # Display system hostname
hostname -I                           # Display all IP addresses (Note: Use 'ifconfig | grep inet' on macOS)
whoami                                # Display current username
id                                    # Display user and group IDs

# Network Connectivity Testing
ping google.com                       # Test connectivity to Google
ping -c 4 8.8.8.8                   # Ping with count limit
ping6 google.com                      # IPv6 ping
ping -i 2 192.168.1.1                # Ping with interval
ping -s 1000 google.com              # Ping with packet size
ping -t 5 google.com                 # Ping with TTL (Note: Use -m on macOS)
ping -f google.com                    # Flood ping (requires root)
ping -a google.com                    # Audible ping
ping -v google.com                    # Verbose ping
ping -q google.com                    # Quiet ping

# Traceroute Commands
traceroute google.com                 # Trace route to destination
traceroute6 google.com               # IPv6 traceroute
traceroute -n google.com             # Numeric output only
traceroute -m 15 google.com          # Max hops
traceroute -p 80 google.com          # Specific port
traceroute -I google.com             # ICMP traceroute
traceroute -T google.com             # TCP traceroute
mtr google.com                        # My traceroute (continuous)
mtr -c 10 google.com                 # MTR with count
mtr -r google.com                     # MTR report mode

# DNS Commands
nslookup google.com                   # DNS lookup
nslookup google.com 8.8.8.8          # DNS lookup with specific server
dig google.com                        # DNS lookup with dig
dig @8.8.8.8 google.com             # Dig with specific DNS server
dig google.com MX                     # Mail exchange records
dig google.com NS                     # Name server records
dig google.com TXT                    # Text records
dig google.com AAAA                   # IPv6 records
dig -x 8.8.8.8                       # Reverse DNS lookup
dig +short google.com                 # Short output
dig +trace google.com                 # Trace DNS resolution
host google.com                       # Simple DNS lookup
host -t MX google.com                # Specific record type
host -a google.com                    # All records
whois google.com                      # Domain registration info

# Network Statistics and Monitoring
netstat -a                            # All connections
netstat -l                            # Listening ports
netstat -t                            # TCP connections
netstat -u                            # UDP connections
netstat -n                            # Numeric addresses
netstat -p                            # Process IDs
netstat -r                            # Routing table
netstat -i                            # Interface statistics
netstat -s                            # Protocol statistics
netstat -c                            # Continuous monitoring
ss -a                                 # Socket statistics (modern netstat)
ss -l                                 # Listening sockets
ss -t                                 # TCP sockets
ss -u                                 # UDP sockets
ss -p                                 # Show processes
ss -n                                 # Numeric output
lsof -i                               # List open network files
lsof -i :80                           # Specific port
lsof -i tcp                           # TCP connections only
lsof -i udp                           # UDP connections only

# ARP Commands
arp -a                                # Display ARP table
arp -n                                # Numeric output
arp 192.168.1.1                      # Specific IP ARP entry
arp -d 192.168.1.1                   # Delete ARP entry
arp -s 192.168.1.1 aa:bb:cc:dd:ee:ff # Static ARP entry
# Remove Linux-specific ip neigh commands

# Route Commands
route -n get default                  # Display routing table (macOS syntax)
route add default 192.168.1.1         # Add default gateway (macOS syntax)
route add -net 192.168.2.0/24 192.168.1.1  # Add network route (macOS syntax)
route delete default                   # Delete default route (macOS syntax)
# Remove Linux-specific ip route commands

# Network Interface Management
# Use actual interface names like en0, en1 instead of eth0
sudo ifconfig en0 up                   # Bring interface up
sudo ifconfig en0 down                 # Bring interface down
sudo ifconfig en0 192.168.1.100       # Set IP address
sudo ifconfig en0 192.168.1.100 netmask 255.255.255.0  # Set IP and netmask
# Remove Linux-specific ip link commands

# Network Statistics and Monitoring
netstat -a                            # All connections
netstat -l                            # Listening ports
netstat -t                            # TCP connections
netstat -u                            # UDP connections
netstat -n                            # Numeric addresses
netstat -p                            # Process IDs
netstat -r                            # Routing table
netstat -i                            # Interface statistics
netstat -s                            # Protocol statistics
netstat -c                            # Continuous monitoring
ss -a                                 # Socket statistics (modern netstat)
ss -l                                 # Listening sockets
ss -t                                 # TCP sockets
ss -u                                 # UDP sockets
ss -p                                 # Show processes
ss -n                                 # Numeric output
lsof -i                               # List open network files
lsof -i :80                           # Specific port
lsof -i tcp                           # TCP connections only
lsof -i udp                           # UDP connections only

# Network Configuration Files
cat /etc/hosts                        # View hosts file
cat /etc/resolv.conf                  # View DNS configuration
# Remove Linux-specific paths:
# /etc/network/interfaces (Debian/Ubuntu)
# /etc/sysconfig/network-scripts/ (RedHat/CentOS)
# /proc/net/* paths (Linux-specific)

# Firewall Commands (pfctl for macOS)
sudo pfctl -sr                        # Show firewall rules
sudo pfctl -f /etc/pf.conf            # Load firewall rules
sudo pfctl -e                         # Enable firewall
sudo pfctl -d                         # Disable firewall
# Remove iptables commands (Linux-specific)

# System Network Information
uname -a                              # System information
uptime                                # System uptime
w                                     # Who is logged in
who                                   # Currently logged users
last                                  # Last login information
ps aux | grep network                 # Network-related processes
top                                   # System processes
htop                                  # Enhanced process viewer
iotop                                 # I/O monitoring
nload                                 # Network load monitoring
iftop                                 # Interface bandwidth monitoring
vnstat                                # Network statistics
vnstat -d                             # Daily statistics
vnstat -m                             # Monthly statistics

# Advanced Network Tools
tcpdump -i en0                       # Packet capture (use en0 instead of eth0)
tcpdump -i en0 port 80               # Capture HTTP traffic
tcpdump -i en0 host 192.168.1.1      # Capture specific host
tcpdump -w capture.pcap -i en0       # Save to file
wireshark                             # GUI packet analyzer
tshark -i eth0                        # Command-line Wireshark
ettercap -T -M arp /192.168.1.1//     # ARP poisoning
ngrep -d en0 "GET" port 80           # Network grep (use en0 instead of eth0)

# Network Time and Synchronization
sntp -sS pool.ntp.org                # Sync time with NTP (macOS)
# Remove ntpdate, ntpq, chronyc, timedatectl (Linux-specific)
date                                  # Current date and time
# Remove hwclock (Linux-specific)

# Network Troubleshooting
dmesg | grep -i network               # Kernel network messages
# Remove journalctl (systemd-specific)
log show --predicate 'eventMessage contains "network"' --last 1h  # macOS system logs
# Remove /var/log/syslog (Linux path)
strace -e network command             # Note: Use dtruss on macOS instead
ldd /usr/bin/ping                     # Note: Use otool -L on macOS
which ping                            # Command location
type ping                             # Command type
command -v ping                       # Command verification
# These are some of the best commands That I have shortlisted for now and the list goes on, till i have some of the on practice hands on labs on this