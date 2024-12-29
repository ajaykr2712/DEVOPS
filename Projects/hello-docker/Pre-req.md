# This File is part of letting the user know that pre requirements of starting the project

## 1_install_docker

```
# Step 1: Install Docker on Your System

Docker is a platform for developing, shipping, and running applications in containers. Follow the steps below to install Docker:

## For Ubuntu
1. Update the package list:
   ```bash
   sudo apt-get update

```

## Install Docker:
```
sudo apt-get install -y docker.io
```
## Start the Docker service:
```
sudo systemctl start docker

```

## Add your user to the Docker group (optional, to avoid using sudo):

```
sudo usermod -aG docker $USER

```

### Verify Installation

```
docker --version

```