# 2. Operating Systems & Linux - Detailed Notes

## OS and Linux Model Overview

### What is an Operating System?
An Operating System (OS) is system software that manages computer hardware, software resources, and provides common services for computer programs.

### Key Functions of an OS:
1. **Process Management**: Creating, scheduling, and terminating processes
2. **Memory Management**: Allocating and deallocating memory space
3. **File System Management**: Organizing and managing files and directories
4. **Device Management**: Managing hardware devices and drivers
5. **Network Management**: Handling network communication
6. **Security**: User authentication and access control

### Linux Architecture:
```
┌─────────────────────────────────────┐
│          User Applications          │
├─────────────────────────────────────┤
│            System Libraries         │
├─────────────────────────────────────┤
│             System Calls            │
├─────────────────────────────────────┤
│            Linux Kernel             │
├─────────────────────────────────────┤
│              Hardware               │
└─────────────────────────────────────┘
```

## Introduction to Operating Systems

### Types of Operating Systems:
1. **Batch OS**: Processes jobs in batches without user interaction
2. **Time-Sharing OS**: Multiple users can use the system simultaneously
3. **Distributed OS**: Manages a group of independent computers
4. **Real-Time OS**: Provides immediate response to inputs
5. **Network OS**: Manages network resources

### Linux Distributions:
- **Red Hat Family**: RHEL, CentOS, Fedora
- **Debian Family**: Debian, Ubuntu, Linux Mint
- **SUSE Family**: openSUSE, SLES
- **Arch Family**: Arch Linux, Manjaro
- **Container-Optimized**: Alpine Linux, CoreOS

## Introduction to Virtualization and Virtual Machines

### What is Virtualization?
Virtualization is the creation of virtual versions of computer hardware platforms, operating systems, storage devices, and network resources.

### Types of Virtualization:
1. **Hardware Virtualization**: Full virtualization of hardware
2. **OS-level Virtualization**: Containers (Docker, LXC)
3. **Application Virtualization**: Running applications in isolated environments
4. **Network Virtualization**: Creating virtual networks

### Hypervisors:
- **Type 1 (Bare Metal)**: VMware vSphere, Microsoft Hyper-V, Xen
- **Type 2 (Hosted)**: VMware Workstation, VirtualBox, Parallels

### Benefits of Virtualization:
- Resource optimization
- Cost reduction
- Improved disaster recovery
- Enhanced security isolation
- Easier testing and development

## Setting Up a Linux Virtual Machine

### Prerequisites:
- Host machine with sufficient resources (8GB+ RAM recommended)
- Virtualization software (VirtualBox, VMware)
- Linux distribution ISO file

### Step-by-Step Setup:
1. **Download and Install VirtualBox**
2. **Create New Virtual Machine**
   - Name: DevOps-Lab
   - Type: Linux
   - Version: Ubuntu (64-bit)
   - Memory: 4GB (4096 MB)
   - Hard Disk: 50GB (dynamically allocated)

3. **Configure VM Settings**
   - Processors: 2 cores
   - Enable VT-x/AMD-V
   - Network: NAT or Bridged
   - Enable clipboard sharing

4. **Install Ubuntu Server**
   - Boot from ISO
   - Follow installation wizard
   - Create user account
   - Install OpenSSH server

5. **Post-Installation Setup**
   - Update system: `sudo apt update && sudo apt upgrade`
   - Install essential tools: `sudo apt install curl wget git vim`
   - Configure SSH keys

## Linux File System

### File System Hierarchy Standard (FHS):
```
/
├── bin/          # Essential command binaries
├── boot/         # Boot loader files
├── dev/          # Device files
├── etc/          # Configuration files
├── home/         # User home directories
├── lib/          # Shared libraries
├── media/        # Removable media mount points
├── mnt/          # Temporary mount points
├── opt/          # Optional software packages
├── proc/         # Process information
├── root/         # Root user home directory
├── run/          # Runtime data
├── sbin/         # System administration binaries
├── srv/          # Service data
├── sys/          # System information
├── tmp/          # Temporary files
├── usr/          # User utilities and applications
└── var/          # Variable data files
```

### File System Types:
- **ext4**: Default Linux file system
- **xfs**: High-performance file system
- **btrfs**: Advanced file system with snapshots
- **zfs**: Enterprise-grade file system
- **tmpfs**: Memory-based file system

### File Permissions:
- **Read (r)**: Permission to read file contents
- **Write (w)**: Permission to modify file contents
- **Execute (x)**: Permission to execute file

### Permission Notation:
- **Symbolic**: rwxrwxrwx (owner, group, others)
- **Octal**: 755 (4=read, 2=write, 1=execute)

### Inodes and Links:
- **Inode**: Data structure storing file metadata
- **Hard Link**: Multiple names for the same inode
- **Soft Link**: Pointer to another file path

### Mount Points:
- Process of making a file system accessible
- Common mount points: `/`, `/home`, `/var`, `/tmp`
- Mount options: rw, ro, noexec, nosuid

### File System Commands:
- `df -h`: Display disk space usage
- `du -sh`: Show directory size
- `mount`: Display mounted file systems
- `lsblk`: List block devices
- `fdisk -l`: List disk partitions
