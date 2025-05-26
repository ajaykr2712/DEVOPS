# Basic Network Information
ifconfig                              # Display network interface configuration
ip addr show                          # Show IP addresses (Linux)
ip link show                          # Show network interfaces (Linux)
hostname                              # Display system hostname
hostname -I                           # Display all IP addresses
whoami                                # Display current username
id                                    # Display user and group IDs

# Network Connectivity Testing
ping google.com                       # Test connectivity to Google
ping -c 4 8.8.8.8                   # Ping with count limit
ping6 google.com                      # IPv6 ping
ping -i 2 192.168.1.1                # Ping with interval
ping -s 1000 google.com              # Ping with packet size
ping -t 5 google.com                 # Ping with TTL
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
ip neigh show                         # Show neighbor table (Linux)
ip neigh flush all                    # Flush neighbor table (Linux)

# Route Commands
route -n                              # Display routing table
route add default gw 192.168.1.1     # Add default gateway
route add -net 192.168.2.0/24 gw 192.168.1.1  # Add network route
route del default                     # Delete default route
ip route show                         # Show routes (Linux)
ip route add default via 192.168.1.1 # Add default route (Linux)
ip route add 192.168.2.0/24 via 192.168.1.1   # Add network route (Linux)
ip route del 192.168.2.0/24          # Delete route (Linux)

# Network Interface Management
ifconfig eth0 up                      # Bring interface up
ifconfig eth0 down                    # Bring interface down
ifconfig eth0 192.168.1.100          # Set IP address
ifconfig eth0 192.168.1.100 netmask 255.255.255.0  # Set IP and netmask
ip link set eth0 up                   # Bring interface up (Linux)
ip link set eth0 down                 # Bring interface down (Linux)
ip addr add 192.168.1.100/24 dev eth0  # Add IP address (Linux)
ip addr del 192.168.1.100/24 dev eth0  # Delete IP address (Linux)

# Network Scanning and Discovery
nmap 192.168.1.0/24                  # Network scan
nmap -sP 192.168.1.0/24              # Ping scan
nmap -sS 192.168.1.1                 # SYN scan
nmap -sT 192.168.1.1                 # TCP connect scan
nmap -sU 192.168.1.1                 # UDP scan
nmap -O 192.168.1.1                  # OS detection
nmap -sV 192.168.1.1                 # Service version detection
nmap -A 192.168.1.1                  # Aggressive scan
nmap -p 80,443 192.168.1.1           # Specific ports
nmap -p 1-1000 192.168.1.1           # Port range
nmap -F 192.168.1.1                  # Fast scan
nmap -v 192.168.1.1                  # Verbose output

# Port and Service Testing
telnet google.com 80                  # Test port connectivity
nc -zv google.com 80                 # Netcat port test
nc -l 8080                            # Listen on port
nc -u google.com 53                  # UDP connection
nc -w 5 google.com 80                # Timeout connection
echo "GET / HTTP/1.0\r\n\r\n" | nc google.com 80  # HTTP request
curl -I google.com                    # HTTP headers
curl -v google.com                    # Verbose HTTP
wget google.com                       # Download webpage
wget -O - google.com                  # Output to stdout

# Bandwidth and Performance Testing
iperf3 -s                             # iPerf server
iperf3 -c server_ip                   # iPerf client
iperf3 -c server_ip -t 30             # 30-second test
iperf3 -c server_ip -P 4              # 4 parallel streams
iperf3 -c server_ip -u                # UDP test
iperf3 -c server_ip -R                # Reverse test
speedtest-cli                         # Internet speed test

# Network Configuration Files
cat /etc/hosts                        # View hosts file
cat /etc/resolv.conf                  # View DNS configuration
cat /etc/network/interfaces           # Network interfaces (Debian/Ubuntu)
cat /etc/sysconfig/network-scripts/   # Network scripts (RedHat/CentOS)
cat /proc/net/dev                     # Network device statistics
cat /proc/net/route                   # Kernel routing table
cat /proc/net/arp                     # ARP table

# Firewall Commands (iptables)
iptables -L                           # List firewall rules
iptables -L -n                        # Numeric output
iptables -L -v                        # Verbose output
iptables -F                           # Flush all rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # Allow SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # Allow HTTP
iptables -A INPUT -j DROP             # Drop all other input

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
tcpdump -i eth0                       # Packet capture
tcpdump -i eth0 port 80               # Capture HTTP traffic
tcpdump -i eth0 host 192.168.1.1      # Capture specific host
tcpdump -w capture.pcap -i eth0       # Save to file
wireshark                             # GUI packet analyzer
tshark -i eth0                        # Command-line Wireshark
ettercap -T -M arp /192.168.1.1//     # ARP poisoning
ngrep -d eth0 "GET" port 80           # Network grep

# Network Time and Synchronization
ntpdate pool.ntp.org                  # Sync time with NTP
ntpq -p                               # NTP peer status
chronyc sources                       # Chrony time sources
timedatectl status                    # System time status
date                                  # Current date and time
hwclock                               # Hardware clock

# Network File Transfer
scp file.txt user@host:/path/         # Secure copy
rsync -av /local/ user@host:/remote/  # Remote sync
sftp user@host                        # Secure FTP
ftp host                              # FTP connection
wget http://example.com/file.txt      # Download file
curl -O http://example.com/file.txt   # Download with curl
curl -T file.txt ftp://host/          # Upload with curl

# Network Troubleshooting
dmesg | grep network                  # Kernel network messages
journalctl -u networking              # Systemd network logs
tail -f /var/log/syslog | grep network  # Live network logs
strace -e network command             # Trace network system calls
ldd /usr/bin/ping                     # Library dependencies
which ping                            # Command location
type ping                             # Command type
command -v ping                       # Command verification