# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_006

## Breaking down the assignmentof this Linux System Distribution Projectinto clear and manaeagable sections

```
# Linux System Administration Practice Guide

## PART I: EC2 Instance Setup
1. Launch Ubuntu EC2 instance with specifications:
   - Instance type: t2.micro (free tier)
   - Storage: 8GB gp2
   - Name: SSHServer
   - Enable SSH access and public IP
   - Create/use keypair

## PART II: User Management
```bash
# SSH into instance
ssh -i keypair.pem ubuntu@public-ip

# Set passwords
sudo passwd ubuntu
sudo passwd root

# Create users
sudo adduser user1
sudo adduser your_name

# Check user info
id user1
id your_name
cat /etc/passwd | tail

# Password aging
sudo chage -l user1
sudo chage -l your_name
sudo chage -M 60 user1
sudo chage -M 90 your_name

# Add user to sudoers
sudo visudo
# Add line: your_name ALL=(ALL:ALL) ALL

# Force password change
sudo passwd -e user1

```
# 2. PART III: SSH Key Generation
```
# Local machine commands
cd ~
ls -lah | grep .ssh
mkdir -p ~/.ssh && cd ~/.ssh

# Generate SSH key
ssh-keygen -t rsa

# Start SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# View public key
cat ~/.ssh/id_rsa.pub

```

# 3.SSH Key Configuration

```
# On remote server
mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
# Paste public key into authorized_keys

# Set permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

```

# 4.SSH Access Verification
```
# Test SSH access
ssh your_name@remote-ip
```
# 5.File Management

```
# Create directories
sudo mkdir /home/user1/shared_data
mkdir ~/private_data

# Set permissions
sudo chmod 660 /home/user1/shared_data
sudo chown user1:your_name /home/user1/shared_data

# Create and manage files
sudo touch /home/user1/shared_data/shared_file.txt
sudo chown user1 /home/user1/shared_data/shared_file.txt

# Archive and extract
tar -cvzf private_data.tar.gz private_data/
mkdir restored_files
tar -xvzf private_data.tar.gz -C restored_files/


```


## Key Concepts:
    File Permissions:
        r (read):  4
        w (write): 2
        x (execute): 1

    Command Structure:
        chmod: Change mode
        chown: Change owner
        chage:Change age (password aging)

    SSH Key Types:
        id_rsa: Private key (keep secure)
        id_rsa.pub: Public key (share)



# Happy Learning
