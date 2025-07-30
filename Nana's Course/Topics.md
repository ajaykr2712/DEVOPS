# 🚀 DevOps Learning Roadmap

---

## 1. Introduction to DevOps
- What is DevOps?
- DevOps Lifecycle
- DevOps Culture and Principles

---

## 2. Operating Systems & Linux
- OS and Linux Model Overview
- Introduction to Operating Systems
- Introduction to Virtualization and Virtual Machines
- Setting Up a Linux Virtual Machine
- Linux File System

---

## 3. Linux Fundamentals
- Introduction to Command-Line Interface (CLI)
- Basic Linux Commands
- Advanced Linux Commands
- Package Manager
- Installing Software on Linux
- Working with the Vim Editor
- Linux Accounts and Groups
- Users and Permissions
- File Ownership and Permissions
- Pipes and Redirects

---

## 4. Shell Scripting
- Introduction to Shell Scripting
- Shell Scripting Concepts and Syntax
- Environment Variables

---

## 5. Networking and Remote Access
- Networking Basics
- Secure Shell (SSH)

---

## 6. Version Control with Git
- What is Version Control?
- Introduction to Git
- Git Concepts: Init, Clone, Commit, Push, Pull
- `.gitignore` Usage
- Git Stash
- Undoing Git Commands

---

## 7. Databases and Development Process
- Types of Databases (SQL, NoSQL)
- Integrating Databases in DevOps Pipelines

---

## 8. Build Tools and Package Managers
- Introduction to Build Tools and Package Managers
- Installing Build Tools
- Building Artifacts
- Running the Application
- Building JavaScript Applications
- Common Build Concepts Across Languages
- Publishing Artifacts to Repositories
- Build Tools with Docker
- Build Tools for DevOps

---

## 9. Cloud and IaaS Basics
- Cloud and Infrastructure as a Service (IaaS)
- Setting Up Servers on DigitalOcean
- Deploying Artifacts to Cloud Droplets
- Create and Configure Linux Users on Cloud Servers

---

## 10. Artifact Repository Manager (Nexus)
- Introduction to Artifact Repositories
- Installing and Running Nexus
- Nexus Repository Types
- Publishing Artifacts to Nexus
- Using Nexus REST API
- Blob Store Management
- Component vs Asset
- Cleanup Policies and Scheduled Tasks

---

## 11. Containers with Docker
- What is a Container?
- Container vs Image
- Docker vs Virtual Machine
- Docker Architecture and Components
- Essential Docker Commands
- Docker Debugging Commands
- Docker Demo Project Overview
- Developing with Docker
- Docker Compose: Multi-Container Setup
- Building Custom Docker Images
- Using Private Docker Repositories
- Deploying Docker Apps to Servers
- Docker Volumes and Data Persistence
- Creating a Docker Repository on Nexus (Push/Pull)
- Deploying Nexus as a Docker Container
- Docker Best Practices

---

## 12. Build Automation & CI with Jenkins
- Introduction to Build Automation
- Installing Jenkins
- Jenkins UI Overview
- Jenkins Basics & Plugin Management
- Jenkins Credentials (Security Best Practices)
- Jenkins Freestyle Jobs
- Introduction to Jenkins Pipeline Jobs
- Jenkinsfile Syntax & Structure
- Full CI/CD Pipeline with Jenkins
- Multi-Branch Pipelines
- Jenkins Shared Libraries
- Triggering Pipelines Automatically
- Dynamic Versioning in Pipelines

---

## 13. Amazon Web Services (AWS)
- Introduction to AWS
- Creating an AWS Account
- Identity and Access Management (IAM)
  - Users, Roles, and Permissions
- Regions and Availability Zones
- Virtual Private Cloud (VPC)
  - Private Networking
  - CIDR (Classless Inter-Domain Routing)
- EC2 (Elastic Compute Cloud)
  - Launch and Connect to Instances
  - Deploy from Jenkins to EC2
  - Health Check and Monitoring
  - Backup EC2 Volumes Automatically (Snapshot Creation)
  - Automate Cleanup of Old Snapshots
  - Automate Restoration of EC2 Volume from Snapshots
  - Error Handling in Backup Processes
- AWS Command-Line Interface (CLI)
- AWS and Terraform Integration (Preview)
- AWS and IaaS (Infrastructure as Code)
- Container Services on AWS

---

## 14. Kubernetes & Container Orchestration
- Introduction to Kubernetes
- Kubernetes Components & Architecture
- Minikube and `kubectl` (Local Clusters)
- `kubectl` Commands and Use Cases
- YAML Configuration Files
- Demo Project: Application Deployment on Kubernetes
- Namespaces and Component Organization
- Kubernetes Services
  - Internal & External Access (Ingress)
- Volumes for Persistent Storage
  - Volume Types, ConfigMaps, Secrets
  - StatefulSets for Stateful Applications
- Managed Kubernetes (EKS, GKE, AKS)
- Helm (Kubernetes Package Manager)
  - Helm Demo
  - Helm Chart for Microservices
  - Deploy with Helm
- Microservices on Kubernetes
  - Secure RBAC Authorization
  - Production-Grade Deployment
- Kubernetes on AWS (EKS)
  - Create EKS Cluster via Console & CLI (eksctl)
  - Configure Auto Scaling
  - Create and Use Fargate Profiles
  - Deploy from Jenkins to EKS & LKE
- CI/CD with EKS and Docker Hub or ECR

---

## 15. Infrastructure as Code (IaC) with Terraform
- Introduction to Terraform
- Install and Configure Terraform
- Providers, Resources, and Data Sources
- Create and Destroy Resources
- Terraform Core Commands
- Terraform State Management
- Output Values and Variables
- Environment Variables in Terraform
- Git Integration for Terraform Projects
- EC2 Provisioning with Terraform (Demo)
- EKS Cluster Automation with Terraform
- Terraform Provisioners and Modules
- Remote State Management
- Terraform vs Python: When to Use What
- Terraform Best Practices

---

## 16. Python for DevOps & Automation
- Introduction to Python for DevOps
- Python IDE Setup and Tools
- PyPI and pip Package Management
- Python for Automation Projects
- Working with Spreadsheets
- OOP: Classes and Objects
- API Integration Project (e.g. GitLab)
- Introduction to Boto3 (AWS SDK for Python)
  - Install and Connect to AWS via Boto3
- Scheduled Python Tasks for Monitoring
- Server Configuration Scripts
- Tagging AWS Resources with Python
- EKS Cluster Info Retrieval

---

## 17. Website Monitoring & Alerts
- Scheduled Task for Application Health Monitoring
- Automated Email Notifications
- Application Restart and Server Reboot Scripts
- Error Detection and Recovery Workflows

---

## 18. Configuration Management with Ansible
- Introduction to Ansible
- Installing Ansible on Control Node
- Setting Up Ansible Inventory
- Ad-Hoc Commands in Ansible
- SSH Key and Host Key Management
- Ansible Playbooks
- Using Ansible Modules
- Collections in Ansible
- Ansible Variables for Custom Playbooks
- Ansible Roles for Modularity
- Projects:
  - Deploy Node.js Application
  - Deploy Nexus with Ansible
  - Run Docker Apps
  - Use Terraform with Ansible
  - Dynamic Inventory for AWS EC2
  - Deploy Kubernetes Applications
  - Trigger Ansible from Jenkins Pipelines

---

## 19. Monitoring and Observability
- Introduction to Prometheus
- Install Prometheus Stack on Kubernetes
- Data Collection and Visualization
- Introduction to Grafana
- Prometheus Alert Rules
  - Custom Alert Rules
- Alertmanager:
  - Configuration and Email Receiver Setup
  - Trigger Alerts with Email Notifications
- Monitoring Third-Party Applications
- Redis Monitoring with Grafana Dashboard
- Collect Exposure Metrics with Prometheus Client Library
- Monitor Your Own Application
- Deploy Redis Explorer
- Final Monitoring Configurations and Wrap-Up

---

## ✅ Capstone Projects
- Complete CI/CD Pipeline with:
  - Jenkins + DockerHub + EKS
  - Jenkins + ECR + Terraform + EKS
- End-to-End DevOps Project (Infra + Code + Monitoring)