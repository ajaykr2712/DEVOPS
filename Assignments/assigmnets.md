# Context

This assignment focuses on **cloud computing** using **AWS EC2** services and basic server administration. The goal is to gain hands-on experience in the following areas:
- Launching and configuring EC2 instances.
- Connecting securely to servers using SSH.
- Setting up and managing a web server.
- Controlling access using network configurations.
- Modifying server content.
- Managing the lifecycle of cloud instances to avoid unnecessary costs.

By the end of this assignment, you will have the knowledge and confidence to deploy and manage a basic web server on AWS.

---

# Skills Required

## 1. AWS Basics
- Signing into the AWS Console.
- Navigating the EC2 dashboard.

## 2. Networking
- Understanding security groups and firewall rules.
- Configuring access for SSH, HTTP, and HTTPS.

## 3. Linux/Unix Commands
- Connecting to instances via SSH.
- Installing software using package managers (`apt-get`).
- Basic file manipulation commands.

## 4. Web Server Setup
- Installing and starting Apache web server.
- Customizing the default webpage.

## 5. Instance Lifecycle Management
- Launching and configuring EC2 instances.
- Terminating instances to manage costs.

## 6. Storage
- Configuring disk sizes for the instance (e.g., 8GB gp2).

## 7. Key Pair Management
- Creating and using key pairs for secure SSH access.

---

# Explanation (Part II: Web Server)

## **Connecting via SSH**
1. **What is SSH?**
   - SSH (Secure Shell) is a protocol used to securely connect to a remote computer or server.

2. **How to Connect:**
   - Use the following command:  
     ```bash
     ssh -i path-to-your-keypair ubuntu@your-instance-public-ip
     ```
     - `-i`: Specifies the key pair file to use.
     - `ubuntu`: The default username for Ubuntu instances.
     - `your-instance-public-ip`: Replace with your EC2 instance’s public IP address.

---

## **Installing Apache Web Server**
1. **What is Apache?**
   - Apache is a software application that makes your server capable of serving web pages to users.

2. **Installation Command:**
   - Run the following to install Apache:
     ```bash
     sudo apt-get install apache2 -y
     ```
     - `sudo`: Runs the command with administrator privileges.
     - `apt-get install`: Installs the specified software.
     - `-y`: Automatically confirms prompts during installation.

---

## **Starting the Web Server**
1. **Command to Start Apache:**
   - Use this command:
     ```bash
     sudo systemctl start apache2
     ```

2. **Test the Server:**
   - Open a web browser and enter the public IP of your instance. If successful, you’ll see the default Apache welcome page.

---

## **Customizing the Webpage**
1. **Switch to Root User:**
   - Run this command to gain root privileges:
     ```bash
     sudo -i
     ```

2. **Modify the Default Webpage:**
   - Update the content using the `echo` command:
     ```bash
     echo "my name is Ajay, and this is my first web server, congrats to me" > /var/www/html/index.html
     ```

3. **Verify the Update:**
   - Refresh your browser. The updated content should now appear instead of the default Apache page.

---

## **Sharing and Verification**
1. Share your instance’s public IP with colleagues.
2. They can view the webpage from their browsers to verify your web server configuration.

---

## **Important: Terminate the Instance**
1. Go to the AWS EC2 dashboard.
2. Select the instance and terminate it to avoid unnecessary charges.

---
