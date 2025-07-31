# 3. Linux Fundamentals - Detailed Notes

## Introduction to Command-Line Interface (CLI)

### What is CLI?
The Command-Line Interface is a text-based interface where users interact with the system by typing commands. It's more powerful and efficient than GUI for many administrative tasks.

### Terminal vs Shell:
- **Terminal**: The program that displays the CLI
- **Shell**: The command interpreter (bash, zsh, fish)

### Shell Prompt Structure:
```
username@hostname:current_directory$ 
```
Example: `devops@web-server:/home/devops$ `

## Basic Linux Commands

### Navigation Commands:
```bash
pwd                    # Print working directory
ls                     # List directory contents
ls -la                 # List with details and hidden files
cd /path/to/directory  # Change directory
cd ~                   # Go to home directory
cd ..                  # Go to parent directory
cd -                   # Go to previous directory
```

### File and Directory Operations:
```bash
# Creating
mkdir directory_name           # Create directory
mkdir -p path/to/nested/dir   # Create nested directories
touch filename.txt            # Create empty file

# Copying
cp file.txt backup.txt        # Copy file
cp -r directory/ backup/      # Copy directory recursively

# Moving/Renaming
mv old_name.txt new_name.txt  # Rename file
mv file.txt /path/to/dest/    # Move file

# Removing
rm file.txt                   # Remove file
rm -rf directory/             # Remove directory recursively (force)
rmdir empty_directory         # Remove empty directory
```

### File Content Commands:
```bash
cat file.txt           # Display entire file content
less file.txt          # View file content page by page
head -n 10 file.txt    # Show first 10 lines
tail -n 10 file.txt    # Show last 10 lines
tail -f logfile.log    # Follow file changes (real-time)
wc file.txt            # Word, line, character count
wc -l file.txt         # Line count only
```

### Text Processing:
```bash
grep "pattern" file.txt              # Search for pattern
grep -r "pattern" directory/         # Recursive search
grep -i "pattern" file.txt           # Case-insensitive search
grep -v "pattern" file.txt           # Invert match (exclude)

sort file.txt                        # Sort lines
sort -r file.txt                     # Reverse sort
uniq file.txt                        # Remove duplicates
cut -d',' -f1,3 file.csv            # Extract columns
awk '{print $1}' file.txt           # Print first column
sed 's/old/new/g' file.txt          # Replace text
```

### System Information:
```bash
whoami                 # Current username
id                     # User and group IDs
who                    # Currently logged in users
w                      # Detailed user activity
uname -a               # System information
hostname               # System hostname
uptime                 # System uptime and load
```

## Advanced Linux Commands

### File Permissions and Ownership:
```bash
# View permissions
ls -l file.txt

# Change permissions
chmod 755 file.txt              # Octal notation
chmod u+x file.txt              # Add execute for user
chmod g-w file.txt              # Remove write for group
chmod o=r file.txt              # Set read-only for others

# Change ownership
chown user:group file.txt       # Change owner and group
chown user file.txt             # Change owner only
chgrp group file.txt            # Change group only
```

### Process Management:
```bash
ps aux                 # List all processes
ps aux | grep nginx    # Find specific process
top                    # Real-time process monitor
htop                   # Enhanced process monitor
jobs                   # List background jobs
kill PID               # Terminate process by PID
kill -9 PID            # Force kill process
killall process_name   # Kill all instances of process
nohup command &        # Run command in background
```

### Network Commands:
```bash
ping hostname          # Test connectivity
wget URL               # Download file
curl URL               # Transfer data from/to server
ssh user@hostname      # Secure shell connection
scp file user@host:    # Secure copy over network
rsync -av src/ dest/   # Synchronize directories

# Network information
netstat -tulpn         # Network connections
ss -tulpn              # Socket statistics
ip addr show           # Show IP addresses
ip route show          # Show routing table
```

### System Monitoring:
```bash
df -h                  # Disk space usage
du -sh directory/      # Directory size
free -h                # Memory usage
iostat                 # I/O statistics
vmstat                 # Virtual memory statistics
lscpu                  # CPU information
lsblk                  # Block devices
lsusb                  # USB devices
lspci                  # PCI devices
```

### Archive and Compression:
```bash
# tar (tape archive)
tar -czf archive.tar.gz directory/    # Create compressed archive
tar -xzf archive.tar.gz               # Extract archive
tar -tzf archive.tar.gz               # List archive contents

# zip/unzip
zip -r archive.zip directory/         # Create zip archive
unzip archive.zip                     # Extract zip archive
unzip -l archive.zip                  # List zip contents
```

## Package Manager

### APT (Advanced Package Tool) - Debian/Ubuntu:
```bash
# Update package lists
sudo apt update

# Upgrade packages
sudo apt upgrade
sudo apt full-upgrade

# Install packages
sudo apt install package_name
sudo apt install package1 package2 package3

# Remove packages
sudo apt remove package_name           # Remove package
sudo apt purge package_name            # Remove package and config
sudo apt autoremove                    # Remove unused dependencies

# Search packages
apt search keyword
apt show package_name                  # Show package information

# Package management
dpkg -l                               # List installed packages
dpkg -L package_name                  # List package files
dpkg -S /path/to/file                 # Find package owning file
```

### YUM/DNF - Red Hat/CentOS/Fedora:
```bash
# Update packages
sudo yum update                       # CentOS/RHEL
sudo dnf update                       # Fedora

# Install packages
sudo yum install package_name
sudo dnf install package_name

# Remove packages
sudo yum remove package_name
sudo dnf remove package_name

# Search packages
yum search keyword
dnf search keyword

# Package information
yum info package_name
rpm -qa                               # List all installed packages
rpm -ql package_name                  # List package files
```

## Installing Software on Linux

### Methods of Software Installation:

1. **Package Managers** (Recommended)
   - Pre-compiled, tested packages
   - Automatic dependency resolution
   - Easy updates and removal

2. **Source Compilation**
   ```bash
   # Download source code
   wget https://example.com/software.tar.gz
   tar -xzf software.tar.gz
   cd software/
   
   # Configure, compile, install
   ./configure
   make
   sudo make install
   ```

3. **Binary Downloads**
   ```bash
   # Download and install binary
   wget https://example.com/software.deb
   sudo dpkg -i software.deb
   sudo apt install -f  # Fix dependencies
   ```

4. **Snap Packages**
   ```bash
   sudo apt install snapd
   snap search package_name
   sudo snap install package_name
   ```

5. **AppImage**
   ```bash
   # Download AppImage
   wget https://example.com/software.AppImage
   chmod +x software.AppImage
   ./software.AppImage
   ```

### Software Repositories:
- **Official Repositories**: Maintained by distribution
- **PPA (Personal Package Archives)**: Third-party Ubuntu repositories
- **Third-party Repositories**: Vendor-specific repositories

## Working with the Vim Editor

### Vim Modes:
1. **Normal Mode**: Default mode for navigation and commands
2. **Insert Mode**: For text insertion
3. **Visual Mode**: For text selection
4. **Command Mode**: For executing commands

### Basic Vim Commands:
```vim
# Mode switching
i          # Enter insert mode
Esc        # Return to normal mode
:          # Enter command mode
v          # Enter visual mode

# Navigation
h, j, k, l # Left, down, up, right
w          # Next word
b          # Previous word
0          # Beginning of line
$          # End of line
gg         # Go to first line
G          # Go to last line

# Editing
dd         # Delete line
yy         # Copy line
p          # Paste
u          # Undo
Ctrl+r     # Redo

# Search and replace
/pattern   # Search forward
?pattern   # Search backward
n          # Next search result
N          # Previous search result
:%s/old/new/g  # Replace all occurrences

# File operations
:w         # Save
:q         # Quit
:wq        # Save and quit
:q!        # Quit without saving
```

### Vim Configuration (~/.vimrc):
```vim
" Enable syntax highlighting
syntax on

" Show line numbers
set number

" Enable auto-indentation
set autoindent
set smartindent

" Set tab width
set tabstop=4
set shiftwidth=4
set expandtab

" Enable search highlighting
set hlsearch
set incsearch

" Show matching brackets
set showmatch

" Enable mouse support
set mouse=a
```

## Linux Accounts and Groups

### User Account Types:
1. **Root User**: Superuser with all privileges (UID 0)
2. **System Users**: Service accounts (UID 1-999)
3. **Regular Users**: Human users (UID 1000+)

### User Management Commands:
```bash
# Create user
sudo useradd -m -s /bin/bash username
sudo useradd -m -s /bin/bash -c "Full Name" username

# Set password
sudo passwd username

# Modify user
sudo usermod -c "New Name" username       # Change full name
sudo usermod -s /bin/zsh username         # Change shell
sudo usermod -a -G group username         # Add to group

# Delete user
sudo userdel username                     # Delete user only
sudo userdel -r username                  # Delete user and home
```

### Group Management:
```bash
# Create group
sudo groupadd groupname

# Add user to group
sudo usermod -a -G groupname username
sudo gpasswd -a username groupname

# Remove user from group
sudo gpasswd -d username groupname

# Delete group
sudo groupdel groupname

# View groups
groups username                           # User's groups
getent group groupname                    # Group information
```

### Important Files:
- `/etc/passwd`: User account information
- `/etc/shadow`: Encrypted passwords
- `/etc/group`: Group information
- `/etc/gshadow`: Group passwords

## Users and Permissions

### Permission Types:
- **r (read)**: View file contents or list directory
- **w (write)**: Modify file or create/delete files in directory
- **x (execute)**: Run file or access directory

### Permission Categories:
- **User (u)**: File owner
- **Group (g)**: File group
- **Other (o)**: Everyone else

### Numeric Permissions:
```
4 = read (r)
2 = write (w)
1 = execute (x)

Common combinations:
755 = rwxr-xr-x (owner: rwx, group: r-x, other: r-x)
644 = rw-r--r-- (owner: rw-, group: r--, other: r--)
600 = rw------- (owner: rw-, group: ---, other: ---)
```

### Special Permissions:
```bash
# Setuid (SUID) - 4000
chmod u+s file                           # Run with owner's privileges

# Setgid (SGID) - 2000  
chmod g+s directory                      # Files inherit group ownership

# Sticky bit - 1000
chmod +t directory                       # Only owner can delete files
```

## File Ownership and Permissions

### Understanding ls -l Output:
```
-rw-r--r-- 1 user group 1024 Jan 1 12:00 file.txt
│││││││││  │ │    │     │    │          │
│││││││││  │ │    │     │    │          └─ filename
│││││││││  │ │    │     │    └─ modification time
│││││││││  │ │    │     └─ file size
│││││││││  │ │    └─ group owner
│││││││││  │ └─ user owner
│││││││││  └─ number of hard links
│││││││└─ other permissions (r--)
││││││└─ group permissions (r--)
│││││└─ user permissions (rw-)
││││└─ special permissions
│││└─ file type (- = file, d = directory, l = link)
```

### Default Permissions (umask):
```bash
umask                    # View current umask
umask 022               # Set umask (removes write for group/other)

# Default permissions calculation:
# Files: 666 - umask = default file permissions
# Directories: 777 - umask = default directory permissions
```

## Pipes and Redirects

### Redirection Operators:
```bash
# Output redirection
command > file.txt              # Redirect stdout to file (overwrite)
command >> file.txt             # Redirect stdout to file (append)
command 2> error.log            # Redirect stderr to file
command &> output.log           # Redirect both stdout and stderr
command > /dev/null             # Discard output

# Input redirection
command < input.txt             # Read input from file
command << EOF                  # Here document
This is input
EOF
```

### Pipes:
```bash
# Basic pipe
command1 | command2             # Send output of command1 to command2

# Multiple pipes
ps aux | grep nginx | grep -v grep

# Useful pipe combinations
ls -la | sort                   # Sort directory listing
cat /etc/passwd | cut -d: -f1   # Extract usernames
tail -f /var/log/syslog | grep ERROR  # Monitor errors

# tee command (split output)
command | tee file.txt          # Save output to file and display
command | tee -a file.txt       # Append to file and display
```

### Advanced Redirection:
```bash
# File descriptors
# 0 = stdin, 1 = stdout, 2 = stderr

exec 3< input.txt               # Open file descriptor 3 for reading
exec 4> output.txt              # Open file descriptor 4 for writing
exec 3<&-                       # Close file descriptor 3

# Process substitution
diff <(ls dir1) <(ls dir2)      # Compare directory contents
```
