
================================================
File: README.md
================================================



================================================
File: Devops.md
================================================
# How to Ace DevOps Skills

## 1. Understand the Basics 🌱
- Learn **Linux Fundamentals**: Command-line proficiency, shell scripting.
- Understand **Networking Concepts**: DNS, HTTP/HTTPS, load balancers.
- Study **Version Control Systems**: Git and GitHub.

## 2. Learn Core DevOps Practices ⚙️
- **Continuous Integration (CI)**: Automating code integration.
- **Continuous Deployment (CD)**: Delivering code to production frequently.
- **Infrastructure as Code (IaC)**: Managing infrastructure using code.
- **Monitoring and Logging**: Observability of systems.

## 3. Master Cloud Platforms ☁️
- Focus on providers like AWS, Azure, or Google Cloud.
- Understand key services like EC2, S3, and Kubernetes.

## 4. Get Hands-On Experience 🛠️
- Build pipelines, deploy applications, and configure monitoring tools.
- Work on real-world projects or contribute to open source.

## 5. Stay Updated 📚
- Follow DevOps blogs, forums, and attend webinars.
- Explore evolving concepts like GitOps and AIOps.

---

# Top DevOps Tools and Their Applications

## 1. **Version Control Systems** 🗂️
- **Git**: Tracks code changes and facilitates collaboration.
- **GitHub/GitLab**: Repository hosting services with CI/CD capabilities.

## 2. **CI/CD Tools** 🚀
- **Jenkins**: Automates builds and deployments.
- **GitLab CI/CD**: Integrated CI/CD pipelines.
- **CircleCI**: Cloud-based CI/CD for fast delivery.

## 3. **Configuration Management** 🛠️
- **Ansible**: Automates provisioning and configuration.
- **Chef**: Manages infrastructure using code.
- **Puppet**: Ensures system configurations are consistent..

## 4. **Containerization and Orchestration** 🐳
- **Docker**: Containerizes applications for portability.
- **Kubernetes**: Manages and scales containerized applications.
- **OpenShift**: Enterprise Kubernetes platform.

## 5. **Monitoring and Logging** 📈
- **Prometheus**: Metrics-based monitoring.
- **Grafana**: Visualizes metrics and logs.
- **ELK Stack**: Collects and analyzes logs (Elasticsearch, Logstash, Kibana).

## 6. **Infrastructure as Code (IaC)** 📜
- **Terraform**: Provisions and manages infrastructure.
- **CloudFormation**: AWS-specific IaC tool.
- **Pulumi**: Supports multiple cloud providers with modern programming languages.

## 7. **Cloud Platforms** ☁️
- **AWS**: Offers EC2, S3, Lambda, etc.
- **Azure**: Provides Virtual Machines, AKS, and App Services.
- **Google Cloud**: Features GKE, Cloud Functions, and BigQuery.

## 8. **Security Tools** 🔒
- **HashiCorp Vault**: Manages secrets and protects sensitive data.
- **SonarQube**: Performs static code analysis for vulnerabilities.
- **Aqua Security**: Secures containers and Kubernetes.

## 9. **Collaboration Tools** 🤝
- **Slack**: Enhances team communication.
- **Trello**: Manages project workflows.
- **Jira**: Tracks issues and project progress.

---

## Example DevOps Workflow 🌐
1. Developer pushes code to **Git**.
2. **Jenkins** triggers a build and runs tests.
3. Code is containerized using **Docker**.
4. **Kubernetes** deploys the containerized app.
5. Metrics are monitored with **Prometheus** and visualized in **Grafana**.
6. Logs are collected using **ELK Stack**.

---

By following this structured cycle and mastering the tools, you can excel in DevOps and build robust, scalable, and efficient systems



Building the real time solutions to the real world problems like
# Issue: Title: Set Up a CI/CD Pipeline Using GitHub Actions 
Use a sample application (e.g., Node.js or Python).
Install dependencies.
Run unit tests.
Build the application.
Trigger the workflow on push to the main branch.


================================================
File: Docker_practice.md
================================================
# The Best Practice of Using the Docker as part of mananging the Images and Containers


# BP 1: Use official and verified Docker Images as Base Image  
# BP 2: Use Specific Docker Image Versions  
# BP 3: Use Small-Sized Official Images  
# BP 4: Optimize Caching Image Layers  
# BP 5: Use .dockerignore file  
# BP 6: Make use of Multi-Stage Builds  
# BP 7: Use the Least Privileged User  
# BP 8: Scan your Images for Security Vulnerabilities  


================================================
File: Assignments/10th -Day.md
================================================
# ## DevOps Journey: Setting Up Maven and Tomcat on EC2 Instance for CI/CD, and implementig a simple maven generated web app project.

## PART I (Maven & Tomcat Server -2 in 1)

1. **Launch a new EC2 instance and name it CICD, with ssh access and port 8080 open in your inbound rules.**

2. **SSH into your instance**

3. **Change the hostname and switch to user ubuntu e.g.** 
```
sudo hostnamectl set-hostname cicd && sudo su - ubuntu

```

4. **Update your system e.g.** 
```
sudo apt-get upgrade -y && sudo apt-get update -y

```

5. **Install the default Java JDK e.g.** 
```
sudo apt-get install default-jdk -y

```

6. **Download Maven and Tomcat zipped files using ```wget```**
e.g. 
```
sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz

```

7. **Extract the zip files** 
e.g. 
```
sudo tar -xzvf apache-maven-3.9.6-bin.tar.gz && sudo tar -xzvf apache-tomcat-9.0.85.tar.gz

```

8. **Remove the zipped packages after extraction** 
e.g. 
```
sudo rm apache-maven-3.9.6-bin.tar.gz && sudo rm apache-tomcat-9.0.85.tar.gz

```

9. **Rename and move the extracted directories to the /opt directory**
e.g. 
```
sudo mv apache-maven-3.9.6/ /opt/maven && sudo mv apache-tomcat-9.0.85/ /opt/tomcat9

```

10. **Modify the environment variables by editing the .bashrc file**
e.g. sudo vi ~/.bashrc
```
export M2_HOME=/opt/maven/
export PATH=$PATH:$M2_HOME/bin
```

11. **Save and exit**

12. **Reload the .bashrc file** 
e.g. 
```
source ~/.bashrc

```

13. **Verify Maven is installed** 
e.g. 
```
mvn -version

```

14. **Enable all access to the Tomcat directory** 
e.g. 
```
sudo chmod 777 -R /opt/tomcat9

```

15. **Enable easy access to starting and stopping Tomcat by creating symbolic links**
e.g. 
```
sudo ln -s /opt/tomcat9/bin/startup.sh /usr/bin/starttomcat && sudo ln -s /opt/tomcat9/bin/shutdown.sh /usr/bin/stoptomcat

```

16. **Verify Tomcat is working**  
- Start Tomcat by calling the link you created earlier 
e.g. 
```
sudo starttomcat

```
- Visit `instance-ip-address:8080` from your browser

17. **Create a new directory called ```my-app``` in your home directory and move into it**

18. **Use Maven to generate a new web-app project**
e.g. 
```
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-webapp

```

- leave everyhting at deafult

19. **Verify the my-app directory has been generated by maven and cd into it.**

20. **Modify the contents of the `src/main/webapp/index.jsp file` and paste in the contents of [index.jsp](assignment_resources/index.jsp). Modify as you please**

21. **Clean and package your app by running ```mvn clean package``` in the root of your web app directory**
- notice the build success and also verify the creation of the web-app artifact inside the target directory.

22. **Copy the packaged WAR artifact in the target directory to the webapps directory of Tomcat9**
e.g. 
```
sudo cp target/my-app.war /opt/tomcat9/webapps/

```

23. **Stop and start tomcat by calling the links you created earlier** 
e.g. 
```
sudo stoptomcat
sudo starttomcat

```

24. **Modify Tomcat configurations to allow access to the manager app from any IP by editing the context.xml file**
e.g. 
```
sudo vi /opt/tomcat9/webapps/manager/META-INF/context.xml

```
-comment these 2 lines

```
- <Valve className="org.apache.catalina.valves.RemoteAddrValve" 

- allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />

```

25. **Create a new Tomcat user and add roles to enable accessing the manager app**
e.g. 
```
sudo vi /opt/tomcat9/conf/tomcat-users.xml

```
- under the users section, add a new user with password and specify roles in similar manner as commented.

26. **Stop and start tomcat`**

27. **Open ```instance-ip-address:8080```, navigate to the manager app, login with the user you created, scroll down and notice your web-app, open it**

28. **Did it work?**




## PART II (Tomcat Server)


1. Launch another Ubuntu Ec2 instance with ssh access

2. SSH into your instance

4. **Update your system e.g.** 
```
sudo apt-get upgrade -y && sudo apt-get update -y

```

5. **Install the default Java JDK e.g.** 
```
sudo apt-get install default-jdk -y

```

6. **Download Tomcat zipped file using ```wget```**
e.g. 
```
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz

```

7. **Extract the zip files** 
e.g. 
```
sudo tar -xzvf apache-tomcat-9.0.85.tar.gz

```

8. **Remove the zipped packages after extraction** 
e.g. 
```
    sudo rm apache-tomcat-9.0.85.tar.gz

```

9. **Rename and move the extracted directories to the /opt directory**
e.g. 
```
sudo mv apache-tomcat-9.0.85/ /opt/tomcat9
   
```

10. **Enable all access to the Tomcat directory** 
e.g. 
```
sudo chmod 777 -R /opt/tomcat9

```

11. **Enable easy access to starting and stopping Tomcat by creating symbolic links in your /usr/bin directory**
e.g. 
```
sudo ln -s /opt/tomcat9/bin/startup.sh /usr/bin/starttomcat && sudo ln -s /opt/tomcat9/bin/shutdown.sh /usr/bin/stoptomcat

```

12. **Verify Tomcat is working**  
- Start Tomcat by calling the link you created earlier 
e.g. 
```
sudo starttomcat

```
- Visit ```instance-ip-address:8080``` from your browser

13.  **Click on the manager app, and follow the instruction to modify Tomcat configurations to allow access to the manager app from any IP by editing the `context.xml` file**
e.g. 
```
sudo vi /opt/tomcat9/webapps/manager/META-INF/context.xml

```
- comment these 2 lines
```
<Valve className="org.apache.catalina.valves.RemoteAddrValve"   
allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />   

```

14. **Create a new Tomcat user and add roles to enable accessing the manager app**
e.g. 
```
sudo vi /opt/tomcat9/conf/tomcat-users.xml

```
- under the users section, add a new user with apssword and specify roles in similar manner as commented.

15. **On your CICD server, navigate to your web-app directory, and open the pom.xml file. Paste the contents of the [tomcat_plugin.xml](assignment_resources/tomcat_plugin.xml) file in the build code block.***

- change the values in the plugin as necesarry.

16. **Edit the contents of the settings.xml file in your maven home directory at ` ~/.m2/settings.xml ` and paste in the contents of this [dettings.xml](assignment_resources/settings.xml)**
- create the settings file if it doesn't exist
- modify as necessary.

17. **From the root of your web app directory, deploy the the web app to the remote tomcat server**
eg.
```
mvn tomcat7:deploy

```

18. **Visit `instance-ip-address:8080` (remote tomcat server) from your browser, click on the manager app and notice your web app. Click on your web app to open it.**

19. **Did it work?**


### HAPPY LEARNING.

================================================
File: Assignments/11th-Day.md
================================================
# Interview Questions (Beginner and Intermediate)

## Describe a real-world example of how you used Python to solve a DevOps challenge.
- Here you can talk about the projects that we did in this series:
  - GitHub Webhooks
  - JIRA integration
  - File Operations

## Discuss the challenges that you faced while using Python for DevOps and how you overcame them.
- Mention a challenge you faced while implementing a Python project for DevOps, as learned in this series.

## How can you secure your Python code and scripts?
- Handle sensitive information using:
  - Input variables
  - Command line arguments
  - Environment variables

## Explain the difference between mutable and immutable objects.
- **Mutable Objects**: Can be altered after creation.  
  Example:
  ```
  my_list = [1, 2, 3]
  my_list[0] = 0  # Modifying an element in the list
  print(my_list)  # Output: [0, 2, 3]
 ```

================================================
File: Assignments/1st-Day.md
================================================
# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_001
 1. pwd
 2. ls
 3. mkdir
 4. rm
 5. cp
 6. cd ~
 7. man
 8. What does the command chmod +x script.sh do?:  Changes ownership of script.sh
 9. What is the purpose of the grep command in Linux?: Search for a pattern in files
 10. How do you see the contents of a file names file.txt in the terminal?: cat file.txt

 ## HAPPY LEARNING

================================================
File: Assignments/2nd-Day.md
================================================

# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_002

 1. Displays the file system
 2. cd
 3. In Linux, what is the purpose of the chmod command?:  Change mode of a file
 4. find
 5. print file content
 6. df in linux: Display file content
 7. tail
 8. uname: Display system name
 9. Kill the process
 10. whoami: Display current username
 11. Root User vs Regular User: A root user has access to all files and system settings, while a regular user has restricted access.
 12. cd ->  Changes the current directory.
 13. SUDO: Temporarily allows a regular user to execute a command with root privileges.
 14. Basic File Permissions in Linux: Read permissions, Write permissions, Execute permissions
 15. Current Directory
 16.  Command vs Script:  Commands are single lines, scripts are multiple lines.
 17. Advantage of CLI against GUI: a) The command line is faster and more efficient for experienced users.
b) The command line offers more precise control over system actions.
c) The command line is less resource-intensive.

18. /  the symbol used to represent root in a Linux file path
19. mv -> Renames a file or directory
20. NANO -> A text editor

## HAPPY LEARNING

================================================
File: Assignments/3rd- Day.md
================================================
# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_003

1. Opening Terminal & Checking Current Directory : This command shows your absolute path location in the filesystem.
```
pwd    # Print Working Directory
```
2. Listing Directory Contents with Different Flags
Flag Explanations:
-a: Shows all files, including hidden ones (starting with .)
-h: Shows file sizes in human-readable format (KB, MB, GB)
-l: Long format, showing permissions, owner, size, date
-lah: Combines all above flags for most detailed view

```
ls        # Basic list
ls -a     # Show all files (including hidden)
ls -h     # Human readable file sizes
ls -l     # Long format (detailed)
ls -la    # Long format including hidden files
ls -lah   # Combines all above flags

```

3. Checking Username and Navigating to Home

```
whoami    # Shows current username
cd ~      # Navigate to home directory
# OR
cd        # Same as cd ~
# OR
cd /home/username    # Direct path to home

```

4. Creating Practice Directory

```
mkdir practice # Creates a directory

```

5. Navigating to Practice Directory

```
cd practice

```

6. Creating Empty File

```
touch mcsdwj.txt # Creates empty file 

```

7. Adding Text to File

```
echo "This is file1" > file1.txt    # Writes text to file
# > overwrites file
# >> appends to file

```

8. Using Nano Editor

```
nano file1.txt    # Opens nano editor
# Ctrl + O to save
# Ctrl + X to exit

```

9. Viewing File Contents

```
cat file1.txt #Display contents

```

10. Copying the files

```
cp file1.txt file2.txt    # Creates copy

```

11. Renaming the files

```
cp file1.txt file2.txt # Renames contents   

```

12. Deleting Files

```
rm file1.txt

```

13. Creating multiple directories

```
mkdir dir1 dir2 # Creates two directory   

```

14. Directory Navigation

```
cd dir1           # Move into dir1
ls                # List contents
cd ..             # Move up one level
cd ../dir2        # Move to sibling directory
pwd               # Check current location

```

15. Returning to Original Directory

```
cd ~ 

```
## Happy Learning


================================================
File: Assignments/4th-Day.md
================================================
# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_004


### The goal of this assignment is to get familiar with the Linux terminal by manipulating files using some common commands.


ALL these operations are implemented parallely in the the Terminal and being contemplated here

1. cd ..
 cd .. /home
2.  touch file.txt
3. nano file.txt (eidts)
4. To save and edit nano commands you need to follow the instructions
   To Save:
        Ctrl + O (letter O) - Write Out/Save
        Press Enter to confirm the filename
   To Edit:
        Just type to insert/edit textUse arrow keys to navigate
        Ctrl + K - Cut line
        Ctrl + U - Paste line
        Ctrl + W - Search text
        Backspace/Delete - Delete charactersTo Exit:
6. echo file.txt
7.  echo "My name is Echo" >> file.txt
8. sed -i 's/practice/manipulation/g' file.txt
9. cp command to copy  and create a backup file text:  cp example.txt example_backup.txt
10.   Remove second line from backup:  sed -i '2d' example_backup.txt
11. Count words in original file: wc -w file.txt, for the backup file use the same and add the path wc -w file_backup.txt
12. exit the terminal : exit


# Happy Learning




================================================
File: Assignments/5th-Day.md
================================================
# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_005


### The goal of this assignment is to give you hands-on practice with launching an instance, connecting via SSH, installing web server, controlling instance state, and using public IPs


ALL these operations are implemented parallely in the the Terminal and being contemplated here


Part I - Creating a new instance through EC2:
1. AWS Console login steps:
    . Go to AWS Console
    . Sign in with IAM credentials
    . Navigate to EC2 dashboard

2. Launch an instance steps:
    - Click "Launch Instance"
    - Name: webServer
    - AMI: Ubuntu Server (latest LTS)
    - Instance type: t2.micro
    - Key pair: Create new "webServer" or use existing

3. Network/Security settings:
    Security Group settings:
    - Allow SSH (port 22) from 0.0.0.0/0
    - Allow HTTP (port 80) from 0.0.0.0/0
    - Allow HTTPS (port 443) from 0.0.0.0/0

4. Storage:  
    - Volume type: gp2
    - Size: 8 GB



================================================
File: Assignments/6th-Day.md
================================================
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


================================================
File: Assignments/7th-Day.md
================================================
# Answers to the Assignments of Michael Kedey's repo https://github.com/michaelkedey/practice-devops-assignments

 ## assignment_007

 # Listing all the assignments in a seperate folder named Day-7

================================================
File: Assignments/8th_Day.md
================================================
# Create a new repo on GitHub called simple_logs, and select the option to include a README.md file

## Clone the repo to your local machine into a new directory called github101

## Cd into the local repo, create a new git branch and switch to the new branch.

## Copy the logs.txt file into the local repository, add, commit and push the new changes to to the remote GitHub repository.

## Notice the new changes in your remote GitHub repository, create and approve pull requests where necessary, also configure git credentails where necessary.

## Modify your script, and change the path of the logs.txt file to your local git repository.

## Modify the README.md file to offer a brief description of what you are doing.

## Add a copy of your script into the local git repo.

## Save, add, commit and push all local changes to the remote GitHub repository.

================================================
File: Assignments/9th- Day.md
================================================
# Learning about these topics so a detailed explanation

# 1. SSH (Secure Shell)

## Secure Remote Access
- SSH provides a secure channel to remotely access your EC2 instance's command line.
- Protects credentials and data in transit using encryption.

## Public-Key Cryptography
- Utilizes key pairs: a **public key** stored on the server and a **private key** kept by the user.
- Eliminates the need for passwords, enhancing security.

## Port 22 (Default, Can Be Changed)
- By default, SSH uses **port 22** for connections.
- Changing the port improves security but requires updates to AWS Security Groups and firewalls.

## `sshd_config` File
- The `sshd_config` file manages SSH server settings, including ports and authentication methods.
- It’s crucial for fine-tuning security.

## Importance of Firewalls (UFW)
- Firewalls like **UFW (Uncomplicated Firewall)** regulate incoming and outgoing traffic.
- Adjustments are necessary when modifying the SSH port.

---

# 2. AWS Security Groups

## Virtual Firewall for EC2
- Security Groups act as **virtual firewalls**, controlling traffic to and from your instance.

## Stateful Rules
- Automatically allows outbound traffic for any allowed inbound traffic and vice versa.

## Inbound/Outbound Rules
- You define specific rules for:
  - **Inbound traffic**: Controls incoming data to the instance.
  - **Outbound traffic**: Manages data leaving the instance.

## Rule Components
- A rule typically includes:
  - **Protocol** (e.g., TCP, UDP).
  - **Port range** (e.g., 22 for SSH, 80 for HTTP).
  - **Source** (IP address or Security Group).

## Essential for Security
- Always configure Security Groups to allow only **necessary traffic** for added protection.

---

# 3. Nginx Reverse Proxy

## Web Server and More
- Nginx is not just a web server—it can act as a **reverse proxy, load balancer, and HTTP cache**.

## Reverse Proxy Explained
- Nginx receives client requests and forwards them to backend servers.
- This shields backend servers from direct exposure.

## Benefits of a Reverse Proxy
- **Security**: Prevents direct access to backend servers.
- **Load Balancing**: Distributes incoming traffic efficiently among multiple servers.
- **Caching**: Stores static content to reduce backend workload.

## `proxy_pass` Directive
- A key directive in Nginx configuration, it specifies the backend server where requests should be forwarded.
- Example:
  ```nginx
  location / {
      proxy_pass http://backend_server:port;
  }


================================================
File: Assignments/assigmnets.md
================================================
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


================================================
File: Assignments/8th Day/instructions.md
================================================
# Removing Image Source Calls from a Markdown File

This guide explains how to remove image source calls (e.g., `![](image.jpg)`) from a Markdown file, specifically targeting the provided example of removing:

```html
<p align="center">
  <img src="https://github.com/Avik-Jain/100-Days-Of-ML-Code/blob/master/Info-graphs/Day%204.jpg">
</p> 
```
Tools and Techniques
    You can achieve this using various text editors or command-line tools. Here are a couple of approaches:

1. Manual Deletion using a Text Editor
    Open the 100days.md file: Use any text editor (VS Code, Atom, Sublime Text, Notepad++, etc.).

    Find the Image Calls: Locate the lines containing <img src= tags.
    
    Delete: Select and delete the entire block of HTML code associated with the image, including the <p> tags for alignment.

    Save: Save the 100days.md file.2. 
2. Automated Removal using sed (Command Line)
    Caution: This method is powerful but requires caution as it directly modifies the original file. Always back up your file before running such commands.
    
    1. Open your terminal/command prompt.
    2. Navigate to the directory containing the 100days.md file using the cd command.
    3. Run the following sed command:
    ```
    sed -i '' '/<p align="center">/,/<\/p>/d' 100days.md 

    ```

    

================================================
File: Assignments/Day-7/8th_assignment_logs.md
================================================
# Simple Logging Script with Cronjob and Aliases

## **Script: `logs.sh`**

This script generates a log entry with the current date and time, appending it to `logs.txt` in your home directory.

### **Code**
```bash
#!/bin/bash

# Define the log file path
log_file="$HOME/logs.txt"

# Get the current timestamp
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

# Define the log message
log_message="Log entry at ${current_datetime}"

# Append the log message to the log file
echo "$log_message" >> "$log_file"

# Print success message
echo "Log entry added successfully to $log_file"


================================================
File: Assignments/Day-7/8th_assignment_logs.sh
================================================
#!/bin/bash

# Declare variables
log_file="$HOME/logs.txt"
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
log_message="This log was generated at ${current_datetime}"

# Add the new log to the logs.txt file
echo "$log_message" >> "$log_file"

# Print a message to the terminal
echo "Log entry added successfully to $log_file"


================================================
File: Assignments/Day-7/Shell.md
================================================
# A step-by-step guide on how to run these Bash scripts. Here's a general process that applies to all the scripts we've created:

1. Open a terminal window on your computer.

2. Navigate to the directory where you've saved the scripts. For example:
   ```bash
   cd /Users/aponduga/Desktop/Personal/Devops/Assignments/Day-7
   ```

3. Ensure the script has executable permissions. If it doesn't, you can add them using the chmod command:
   ```bash
   chmod +x search_replace.sh
   ```

4. Run the script by prefixing it with ./
   For the search_replace.sh script, you would run:
   ```bash
   ./search_replace.sh <filename> <search_word> <replace_word>
   ```
   Replace <filename>, <search_word>, and <replace_word> with actual values.

   For example:
   ```bash
   ./search_replace.sh myfile.txt old new
   ```

5. The script will execute and provide output based on its functionality.

For the specific search_replace.sh script:

1. Create a test file to work with:
   ```bash
   echo "This is a test file with some words to replace." > testfile.txt
   ```

2. Run the script:
   ```bash
   ./search_replace.sh testfile.txt words phrases
   ```

3. Check the output. It should tell you how many replacements were made.

4. Verify the changes in the file:
   ```bash
   cat testfile.txt
   ```

Remember, for scripts that require user input (like greet_user.sh or add_numbers.sh), you'll be prompted to enter information after running the script.

For scripts with menus (like menu_operations.sh), you'll interact with the script by entering numbers corresponding to menu options.

Always make sure you're in the correct directory when running the scripts, and that you provide the correct number and type of arguments for scripts that expect them.

================================================
File: Assignments/Day-7/add_numbers.sh
================================================
#!/bin/bash

# Declare variables
declare -i num1
declare -i num2
declare -i sum

# Prompt for input
echo "Enter the first number:"
read num1

echo "Enter the second number:"
read num2

# Calculate sum
sum=$((num1 + num2))

# Display result
echo "The sum of $num1 and $num2 is: $sum"

================================================
File: Assignments/Day-7/array_operations.sh
================================================
#!/bin/bash

# Declare an array of favorite fruits
fruits=("apple" "banana" "orange" "grape" "mango")

# Function to display fruits
display_fruits() {
    echo "Current fruits:"
    for i in "${!fruits[@]}"; do
        echo "$((i+1)). ${fruits[i]}"
    done
}

while true; do
    echo "1. Add a fruit"
    echo "2. Remove a fruit"
    echo "3. Display fruits"
    echo "4. Exit"
    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            read -p "Enter a fruit to add: " new_fruit
            fruits+=("$new_fruit")
            echo "Fruit added successfully."
            ;;
        2)
            display_fruits
            read -p "Enter the number of the fruit to remove: " remove_index
            if ((remove_index >= 1 && remove_index <= ${#fruits[@]})); then
                unset "fruits[$((remove_index-1))]"
                fruits=("${fruits[@]}")
                echo "Fruit removed successfully."
            else
                echo "Invalid index."
            fi
            ;;
        3)
            display_fruits
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done

================================================
File: Assignments/Day-7/calcualtor.sh
================================================
#!/bin/bash

add() {
    echo "$(($1 + $2))"
}

subtract() {
    echo "$(($1 - $2))"
}

multiply() {
    echo "$(($1 * $2))"
}

divide() {
    if [ $2 -eq 0 ]; then
        echo "Error: Division by zero"
    else
        echo "scale=2; $1 / $2" | bc
    fi
}

echo "Simple Calculator"
read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Enter operation (+, -, *, /): " op

case $op in
    +) result=$(add $num1 $num2) ;;
    -) result=$(subtract $num1 $num2) ;;
    *) result=$(multiply $num1 $num2) ;;
    /) result=$(divide $num1 $num2) ;;
    *) echo "Invalid operation"; exit 1 ;;
esac

echo "Result: $result"

================================================
File: Assignments/Day-7/greet_user.sh
================================================
#!/bin/bash

# Prompt for first name
echo "Enter your first name:"
read first_name

# Prompt for last name
echo "Enter your last name:"
read last_name

# Display greeting
echo "Hello, $first_name $last_name! Welcome to Bash scripting."

================================================
File: Assignments/Day-7/guessing.sh
================================================
#!/bin/bash

# Generate a random number between 1 and 10
target=$((RANDOM % 10 + 1))

echo "Welcome to the Number Guessing Game!"
echo "I'm thinking of a number between 1 and 10."

while true; do
    echo "Enter your guess:"
    read guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid number."
        continue
    fi

    if ((guess < target)); then
        echo "Too low! Try again."
    elif ((guess > target)); then
        echo "Too high! Try again."
    else
        echo "Congratulations! You guessed the correct number: $target"
        break
    fi
done

================================================
File: Assignments/Day-7/menu_op.sh
================================================
#!/bin/bash

while true; do
    echo "Menu:"
    echo "1. List files in current directory"
    echo "2. Create a new directory"
    echo "3. Remove a file"
    echo "4. Exit"
    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            echo "Files in current directory:"
            ls -l
            ;;
        2)
            read -p "Enter the name of the new directory: " dir_name
            mkdir "$dir_name"
            echo "Directory '$dir_name' created."
            ;;
        3)
            read -p "Enter the name of the file to remove: " file_name
            if [ -f "$file_name" ]; then
                rm "$file_name"
                echo "File '$file_name' removed."
            else
                echo "File '$file_name' does not exist."
            fi
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo
done

================================================
File: Assignments/Day-7/odd_even_check.sh
================================================
#!/bin/bash

# Function to validate integer input
validate_integer() {
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        echo "Error: '$1' is not a valid integer."
        return 1
    fi
}

# Prompt for a number
while true; do
    echo "Enter an integer:"
    read number
    if validate_integer "$number"; then
        break
    fi
done

# Check if odd or even
if ((number % 2 == 0)); then
    echo "The number you entered ($number) is even."
else
    echo "The number you entered ($number) is odd."
fi

================================================
File: Assignments/Day-7/search_replace.sh
================================================
#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <filename> <search_word> <replace_word>"
    exit 1
fi

filename="$1"
search_word="$2"
replace_word="$3"

if [ ! -f "$filename" ]; then
    echo "Error: File '$filename' does not exist."
    exit 1
fi

sed -i "s/$search_word/$replace_word/g" "$filename"
echo "Replacement complete. Words replaced: $(grep -c "$replace_word" "$filename")"

================================================
File: Assignments/Quiz/assignment.md
================================================
 1- Make another commit. Now you should have two commits in your repo.
2- Show the changes in the last 2 commits.
3- Show all commits made by yourself. Use the one-liner option.
4- Show all commits with GUI in their message.
5- Show all commits with changes to file1.txt. Include the number of lines added/
removed.
6- Compare the last two commits.
7- Check out the commit before the last commit. Note the detached HEAD in the
terminal. Check out the master branch.
8- Show the author of every line in file1.txt.
9- Create a tag (v1.0) for the last commit. Show the history using the one-liner
option and note the tag you just created.
10- Delete the tag.


================================================
File: Assignments/Quiz/solutions.md
================================================
 # Solutions  1- Make another commit. Now you should have two commits in your repo.
git add .
git commit -m “Update file1”
2- Show the changes in the last 2 commits.
git log --patch -2
3- Show all commits made by yourself. Use the one-liner option.
git log --author=“Your name” --oneline
4- Show all commits with GUI in their message.
git log --grep=“GUI”
5- Show all commits with changes to file1.txt. Include the number of lines added/
removed.
git log --stat file1.txt
6- Compare the last two commits.
git diff HEAD~1 HEAD
7- Check out the commit before the last commit. Note the detached HEAD in the
terminal. Check out the master branch.
git checkout HEAD~1
git checkout master
8- Show the author of every line in file1.txt.
git blame file1.txt
9- Create a tag (v1.0) for the last commit. Show the history using the one-liner
option and note the tag you just created.
git tag v1.0
git log --oneline
10- Delete the tag.
git tag -d v1.0


================================================
File: GO_Devops/1st_Go.go
================================================
package main

import "fmt"

func main() {
    fmt.Println("Hello, DevOps World!")
}


================================================
File: GO_Devops/APIs.go
================================================
# Example: Calling a REST API.

package main

import (
    "encoding/json"
    "fmt"
    "net/http"
)

type Response struct {
    Status string `json:"status"`
}

func main() {
    resp, err := http.Get("https://api.example.com/status")
    if err != nil {
        fmt.Println("Error:", err)
        return
    }
    defer resp.Body.Close()

    var result Response
    json.NewDecoder(resp.Body).Decode(&result)
    fmt.Println("API Status:", result.Status)
}


================================================
File: GO_Devops/Running.md
================================================
## Run the program:

```
go run main.go

```

## Setting Up a Go Module

### Initializing a Go Module

```
go mod init my-devops-tool

```

### Add Dependencies

```
go get github.com/spf13/cobra

```

================================================
File: GO_Devops/new.go
================================================

#### **`essential_concepts.md`**
```
# Essential Concepts for DevOps in Go

## Goroutines and Channels
- **Concurrency with goroutines:**
```
  
  package main

  import (
      "fmt"
      "time"
  )

  func worker(id int) {
      fmt.Printf("Worker %d starting\n", id)
      time.Sleep(time.Second)
      fmt.Printf("Worker %d done\n", id)
  }

  func main() {
      for i := 1; i <= 3; i++ {
          go worker(i)
      }
      time.Sleep(time.Second * 3)
  }
 

================================================
File: GO_Devops/practice.go
================================================
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// PipelineStatus represents the status of a CI/CD pipeline
type PipelineStatus struct {
	ID     string `json:"id"`
	Status string `json:"status"`
	Logs   string `json:"logs,omitempty"`
}

// Mock pipeline data
var pipelineData = map[string]*PipelineStatus{}

func main() {
	http.HandleFunc("/trigger", triggerPipeline)
	http.HandleFunc("/status", getPipelineStatus)
	http.HandleFunc("/logs", getPipelineLogs)

	port := 8080
	fmt.Printf("Starting server on port %d...\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

// triggerPipeline triggers a new CI/CD pipeline
func triggerPipeline(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	pipelineID := fmt.Sprintf("pipeline-%d", time.Now().UnixNano())
	pipelineData[pipelineID] = &PipelineStatus{
		ID:     pipelineID,
		Status: "In Progress",
	}

	go func(id string) {
		time.Sleep(10 * time.Second) // Simulate build process
		pipelineData[id].Status = "Success"
		pipelineData[id].Logs = "Build completed successfully."
	}(pipelineID)

	response := map[string]string{"message": "Pipeline triggered", "id": pipelineID}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// getPipelineStatus retrieves the status of a given pipeline
func getPipelineStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "Pipeline ID is required", http.StatusBadRequest)
		return
	}

	pipeline, exists := pipelineData[id]
	if !exists {
		http.Error(w, "Pipeline not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(pipeline)
}

// getPipelineLogs retrieves the logs of a completed pipeline
func getPipelineLogs(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	id := r.URL.Query().Get("id")
	if id == "" {
		http.Error(w, "Pipeline ID is required", http.StatusBadRequest)
		return
	}

	pipeline, exists := pipelineData[id]
	if !exists {
		http.Error(w, "Pipeline not found", http.StatusNotFound)
		return
	}

	if pipeline.Status != "Success" {
		http.Error(w, "Logs not available for in-progress or failed pipelines", http.StatusBadRequest)
		return
	}

	response := map[string]string{"logs": pipeline.Logs}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}


================================================
File: GO_Devops/Basics/getting_started.md
================================================
 # Getting Started with Go for DevOps

## Installing Go
- Download from [https://golang.org/dl/](https://golang.org/dl/).
- Verify installation:
   ```
   go version
   ```
   


================================================
File: GO_Devops/Basics/mastering_go_devops.md
================================================
# Mastering Go for DevOps

## Why Go for DevOps?
- **Performance:** Compiles to machine code, offering near-C performance.
- **Concurrency:** Built-in goroutines and channels for handling multiple tasks.
- **Lightweight:** Ideal for building small, fast binaries.
- **Cloud-Native:** First-class support in Docker, Kubernetes, and Terraform.

---

## Basic Go Commands
- go run main.go - Run a program.
- go build - Compile a binary.
- go test - Run tests.
- go mod init <module> - Initialize a Go module.

---

For detailed topics, refer to the individual markdown files.


================================================
File: Linux Resources/Commands For Windows.md
================================================
| ZSH Commands | PowerShell Commmands |
| --- | --- |
| where | where.exe  |
| open | Use Shortcut- Win + R|
| $PATH | $Env:Path |
| ls -a </br> [To see all files[hidden and visible]] | dir -Force |
| vi | vim </br> [need to download] |
| ls -l </br> [To see all files & directories] | Get-ChildItem |
| cat > </br> [To edit] | vim |
| cat file.txt two.txt > total.txt | cat file.txt, two.txt > total.txt |
| cat file.txt \| tr a-z A-Z > upper.txt | (cat 'file.txt').ToUpper() > upper.txt |
| \ </br> [For new line] | ` |
| mkdir random </br> mkdir random/hello </br> [we need to create random first here] | mkdir random/hello </br> [only one line to execute, no need to create random first, it can be created together] |
| touch | [you need to define touch] </br> function touch { </br> Param( </br> [Parameter(Mandatory=$true)] </br> [string]$Path </br> ) </br> if (Test-Path -LiteralPath $Path) { </br> (Get-Item -Path $Path).LastWriteTime = Get-Date </br> } </br> else { </br> New-Item -Type File -Path $Path </br> } </br> } |
| sudo | runas |
| df | gdr |
| du | [need to define du] </br> function du($path=".") { </br> Get-ChildItem $path \| </br> ForEach-Object { </br> $file = $_ </br> Get-ChildItem -File -Recurse $_.FullName \| Measure-Object -Property length -Sum \| </br> Select-Object -Property @{Name="Name";Expression={$file}}, </br> @{Name="Size(MB)";Expression={[math]::round(($_.Sum / 1MB),2)}} # round 2 decimal places </br> } </br>} |


================================================
File: Linux Resources/linux.md
================================================
Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Practical Linux Commands Guide  ## 1. File and Directory Commands  ### Create Files  ```bash  touch Ajay.py  touch ajay.txt   `

### List Files

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codels  ls -l  # Long listing format  ls -a  # Show hidden files   `

### Display Current Directory

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codepwd   `

2\. View File Contents
----------------------

### View the Content of ajay.txt

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codecat ajay.txt   `

### View Line Numbers

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codenl ajay.txt   `

### Display File Content Page-by-Page

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeless ajay.txt   `

### Display the First and Last 5 Lines

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codehead -n 5 ajay.txt  tail -n 5 ajay.txt   `

3\. Edit Files
--------------

### Add Text to ajay.txt

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeecho "Hello, this is Ajay." > ajay.txt   `

### Append Text to ajay.txt

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeecho "Adding a new line to ajay.txt" >> ajay.txt   `

### Edit ajay.txt with Nano

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codenano ajay.txt   `

4\. Copy, Move, Rename, and Delete Files
----------------------------------------

### Copy Ajay.py to Ajay\_copy.py

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codecp Ajay.py Ajay_copy.py   `

### Move Ajay\_copy.py to a New Directory

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codemkdir backup  mv Ajay_copy.py backup/   `

### Rename ajay.txt to ajay-renamed.txt

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codemv ajay.txt ajay-renamed.txt   `

### Remove a File

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy coderm ajay-renamed.txt   `

5\. Search and Find
-------------------

### Find Files by Name

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codefind . -name "Ajay.py"   `

### Search for a String in ajay.txt

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codegrep "Ajay" ajay.txt   `

### Search Recursively in a Directory

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codegrep -r "Ajay" .   `

6\. Permissions and Ownership
-----------------------------

### View File Permissions

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codels -l Ajay.py   `

### Change File Permissions

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codechmod 644 Ajay.py  # Read and write for owner, read-only for others   `

### Change Ownership (requires sudo)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codesudo chown username Ajay.py   `

7\. Compression
---------------

### Compress Files into a .tar.gz Archive

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codetar -czvf ajay_backup.tar.gz Ajay.py ajay.txt   `

### Extract the Archive

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codetar -xzvf ajay_backup.tar.gz   `

8\. Disk Usage and Processes
----------------------------

### Check Disk Usage

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codedu -h Ajay.py   `

### Check Free Disk Space

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codedf -h   `

### View Running Processes

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codetop   `

9\. Networking
--------------

### Check Network Configuration

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeifconfig   `

### Ping a Website

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeping -c 4 google.com   `

10\. Miscellaneous
------------------

### Check System Information

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeuname -a   `

### Check Last 10 Commands

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codehistory | tail -n 10   `

Example Workflow
----------------

### Create Files

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codetouch Ajay.py ajay.txt   `

### Edit and Add Content

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codeecho "print('Hello, Ajay!')" > Ajay.py  echo "Welcome to Linux!" > ajay.txt   `

### Display Content

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codecat ajay.txt   `

### Copy and Rename

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codecp Ajay.py Ajay_copy.py  mv ajay.txt ajay-renamed.txt   `

### Compress

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   bashCopy codetar -czvf ajay_backup.tar.gz Ajay.py ajay-renamed.txt   `

================================================
File: Pre-requisites/OS.md
================================================
# Mastering DevOps: Comprehensive Guide to OS and Kernel Systems

## I. What is an Operating System?
An Operating System (OS) is the software layer between hardware and applications, managing resources like CPU, memory, and I/O devices. Common OSes in DevOps include:
- **Linux (most popular for DevOps)**: Ubuntu, CentOS, RHEL
- **Windows Server**
- **macOS (for development environments)**

---

## II. Key OS Concepts for DevOps

### 1. Kernel
The kernel is the core of an OS, managing hardware and system resources.
- **Types of Kernels**:
  - **Monolithic Kernel**: Linux, where the entire OS runs in a single memory space.
  - **Microkernel**: Minimalist, focusing on critical functions; e.g., Minix.
  - **Hybrid Kernel**: Combines features; e.g., Windows NT.
- **Responsibilities**:
  - Process Management
  - Memory Management
  - Device Drivers
  - System Calls (interface for apps to use kernel services)

### 2. Processes and Threads
- **Processes**: Instances of running programs.
- **Threads**: Lighter-weight processes sharing resources.
- **Tools to monitor**: `ps`, `top`, `htop`, `task manager`.

### 3. File Systems
Understanding file systems helps manage storage efficiently.
- **Linux File System Structure**:
  - `/` (root): Base directory.
  - `/var`: Logs and variable data.
  - `/etc`: Configuration files.
  - `/usr`: User binaries and programs.
- **File system types**: ext4, NTFS, FAT32, XFS.

### 4. Networking
- **Concepts**: TCP/IP, UDP, DNS, SSH, FTP.
- **Commands**:
  - `ping`, `traceroute`, `netstat`, `curl`, `nc`.

### 5. Security
- **User Permissions**:
  - `chmod`, `chown`.
- **User Roles**:
  - Superuser (`root`), Groups.
- **Network Security**: Firewalls (`iptables`, `ufw`), SELinux.

---

## III. Advanced Kernel Systems

### 1. Namespaces and Cgroups (Linux)
Key for containers (e.g., Docker):
- **Namespaces**: Isolate processes (PID, network, etc.).
- **Cgroups**: Limit resources (CPU, memory).

### 2. Kernel Modules
- Dynamic pieces of code (drivers, filesystems).
- **Commands**: `lsmod`, `modprobe`, `rmmod`.

### 3. System Calls
- Interface between user applications and the kernel.
- **Examples**: `open()`, `read()`, `write()`.

---

## IV. Practical DevOps OS Skills

### 1. Linux Command Line Mastery
- **Navigation**: `ls`, `cd`, `pwd`, `find`.
- **File Manipulation**: `cat`, `less`, `vi`, `nano`, `touch`, `rm`.
- **Package Management**:
  - `apt`, `yum`, `dnf`, `snap` (Debian/RedHat-based systems).
  - `brew` for macOS.

### 2. Automation with Shell Scripting
- Writing Bash scripts for:
  - Automating tasks.
  - Configuring servers.

### 3. System Monitoring
- **Tools**:
  - `top`, `htop`, `vmstat`, `iotop`.
  - Logs: `journalctl`, `/var/log`.

### 4. Virtualization and Containers
- **Virtualization**: Hypervisors (e.g., VirtualBox, VMware).
- **Containers**: Docker, Kubernetes.
- **Kernel Features for Containers**:
  - Control groups (cgroups).
  - UnionFS (OverlayFS, AUFS).

---

## V. Best Practices for DevOps OS Mastery

1. **Get Hands-On Experience**
   - Set up a Linux server (Ubuntu or CentOS) on a VM (e.g., VirtualBox, VMware) or cloud (AWS, Azure, GCP).

2. **Learn Advanced Networking**
   - Build simple networks using `iptables`, `nginx`, `haproxy`.

3. **Master Configuration Management**
   - Tools: Ansible, Chef, Puppet.

4. **Explore Monitoring Tools**
   - Tools: Prometheus, Grafana, ELK stack.

5. **Practice Troubleshooting**
   - System logs, debugging tools (`strace`, `dmesg`).

---

## VI. Broader Insights into OS Kernel Development

### 1. Kernel Development
- Study Linux kernel source code (open source).

### 2. Compiling a Custom Kernel
- **Steps**:
  - Get the source: `https://www.kernel.org/`.
  - Configure: `make menuconfig`.
  - Compile: `make` and `make install`.

### 3. Advanced Tools
- **eBPF** for tracing kernel activities.
- `kprobes`, `perf`.

---

## VII. Roadmap to OS and Kernel Expertise for DevOps

### Beginner
- Linux basics, file systems, networking.
- **Commands**: `ls`, `cd`, `chmod`, `ping`.

### Intermediate
- Scripting, log analysis, Docker basics.
- **Commands**: `grep`, `awk`, `sed`, `journalctl`.

### Advanced
- Kubernetes, CI/CD pipelines, kernel modules.
- **Tools**: Jenkins, Terraform, Helm.

---



================================================
File: Pre-requisites/file_backup.md
================================================
# Strategy for Learning from Kunal Kushwaha Devops  course
...

## Introduction to networking
Networking fundamentals, OSI layer protocols, port forwarding, how the internet works, command line tools, and more.

## Command line tools
Various command line tools, bash scripting, regex, introduction to git, and more.

## Kubernetes
Introduction, architecture, set-up, objects, networking, storage, HA, monitoring, logging, production-ready applications.

## Servers
Introduction to web-servers, Nginx, and more.

## Infrastructure as code
Infrastructure provisioning, Terraform, Pulumi, configuration management, and more.

## Service mesh
Istio, Envoy, Linkerd, and more.

## Working with cloud providers
Learn about cloud providers, design patterns, and more.

## Chaos engineering
The next step in testing.

## Introduction to Linux
Learn about the essentials of working with Linux, including some important commands.

## Docker
Introduction to containers, hands-on demos, concepts, architecture, images, networking, best practices, development profiles, Docker Compose, Docker Swarm.

================================================
File: Pre-requisites/network.md
================================================
| **Category**               | **Command**   | **Description**                                           |
|----------------------------|---------------|-----------------------------------------------------------|
| **Network Configuration**  | ifconfig      | Display or configure network interfaces                   |
|                            | ip addr       | More versatile replacement for ifconfig                  |
| **Network Troubleshooting**| ping          | Send ICMP echo requests to a host                        |
|                            | traceroute    | Trace the route packets take to reach a host             |
|                            | netstat       | Display network statistics and active connections        |
|                            | ss            | Socket statistics, modern replacement for netstat        |
| **DNS Utilities**          | dig           | Query DNS servers for information                        |
|                            | nslookup      | Query DNS to lookup IP addresses or domain names         |
|                            | host          | Simple utility for performing DNS lookups                |
| **Network Connectivity**   | telnet        | Test connectivity to a host on a specific port           |
|                            | curl          | Transfer data with URLs                                  |
|                            | wget          | Retrieve files from the web using HTTP, HTTPS, FTP       |
| **Firewall and Security**  | iptables      | Configure IP packet filtering and NAT                    |
|                            | ufw           | Uncomplicated Firewall for managing iptables             |
|                            | nmap          | Network exploration and security auditing                |
| **Remote Access and File Transfer** | ssh  | Secure shell remote access                               |
|                            | scp           | Securely copy files between hosts                        |
|                            | rsync         | Efficiently sync files and directories                   |


================================================
File: Projects/Proj1.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 1: Microservices Orchestration Platform

**Complexity Level: Expert**

### Description

- Kubernetes cluster management
- Service mesh implementation
- Automated scaling
- Distributed tracing
- Chaos engineering integration

```
# Sample Kubernetes Configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: microservice-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: microservice
```



### Key Learning Objectives

- Kubernetes cluster management
- Service mesh implementation
- Automated scaling
- Distributed tracing
- Chaos engineering integration
- High availability patterns
- Security best practices
- CI/CD integration
- Monitoring and logging
- Performance optimization
- Cost optimization
- Scalability and fault tolerance
- Disaster recovery and backup strategies
- Containerization and virtualization
- Cloud native architecture
- DevOps culture and practices


================================================
File: Projects/proj2.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 2: CI/CD Pipeline Automation Framework

**Complexity Level: Advanced**

### Description


Create an enterprise-grade CI/CD framework:
- Multi-cloud deployment
- Infrastructure as Code
- Security scanning
- Automated testing
- Release management
- Monitoring and logging
- Performance optimization
- Cost optimization
- Scalability and fault tolerance
- Disaster recovery and backup strategies
- Containerization and virtualization
- Cloud native architecture
- DevOps culture and practices

```
// Sample Jenkins Pipeline
pipeline {
    agent any
    stages {
        stage('Security Scan') {
            steps {
                script {
                    def scanResults = securityScan()
                    if (scanResults.vulnerabilities > 0) {
                        error 'Security vulnerabilities found'
                    }
                }
            }
        }
    }
}
```


### Key Learning Objectives

- Multi-cloud deployment
- Infrastructure as Code
- Security scanning
- Automated testing
- Release management
- Monitoring and logging
- Performance optimization
- Cost optimization
- Scalability and fault tolerance
- Disaster recovery and backup strategies
- Containerization and virtualization
- Cloud native architecture
- DevOps culture and practices

================================================
File: Projects/proj3.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 3: Cloud-Native Monitoring System

**Complexity Level: Expert**

### Description


Develop a comprehensive monitoring solution:
- Multi-cloud monitoring
- Infrastructure as Code
- Security scanning
- Automated testing
- Release management
- Monitoring and logging
- Performance optimization
- Cost optimization
- Scalability and fault tolerance
- Disaster recovery and backup strategies
- Containerization and virtualization
- Cloud native architecture
- DevOps culture and practices

```
# Prometheus Alert Rule
groups:
- name: example
  rules:
  - alert: HighLatency
    expr: http_request_duration_seconds > 0.5
    for: 5m
    labels:
      severity: critical
```

### Key Learning Objectives

- Metrics collection
- Alert correlation
- Log analysis
- Performance optimization
- Automated incident response

================================================
File: Projects/proj4.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 4: Infrastructure Automation Platform

**Complexity Level: Expert**

### Description



Build an infrastructure management platform:

- Multi-cloud deployment
- Infrastructure as Code
- Security scanning
- Automated testing
- Release management
- Monitoring and logging
- Performance optimization
- Cost optimization
- Scalability and fault tolerance
- Disaster recovery and backup strategies
- Containerization and virtualization
- Cloud native architecture
- DevOps culture and practices

```
# Terraform Multi-Cloud Example
provider "aws" {
  region = "us-west-2"
}

provider "google" {
  project = "my-project"
  region  = "us-central1"
}
```

### Key Learning Objectives

- Multi-cloud deployment
- Infrastructure as Code
- Security scanning
- Automated testing
- Release management
- Monitoring and logging

================================================
File: Projects/proj5.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 5: Security Automation Framework

**Complexity Level: Expert**

### Description



Create a security automation system:
- Vulnerability scanning
- Compliance monitoring
- Threat detection
- Incident response
- Security posture management
- Automated policy enforcement
- Security event monitoring
- Automated remediation
- Security reporting and analytics
- Security automation framework
- DevOps culture and practices

```
# Security Policy as Code
apiVersion: security.policy/v1
kind: SecurityPolicy
metadata:
  name: container-security
spec:
  rules:
    - name: no-privileged
      deny: true
      match:
        privileged: true
```

### Key Learning Objectives

- Security automation
- Compliance frameworks
- Secret management
- Access control
- Threat detection

================================================
File: Projects/proj6.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 6: GitOps Platform

**Complexity Level: Expert**

### Description

- Declarative infrastructure
- Automated reconciliation
- Policy enforcement
- Drift detection
- Rollback capabilities

```
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    path: k8s
    repoURL: https://github.com/org/repo
    targetRevision: HEAD
```

### Key Learning Objectives

- GitOps principles
- Declarative infrastructure
- Automated reconciliation
- Policy enforcement
- Drift detection
- Rollback capabilities

================================================
File: Projects/proj7.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 7: Container Registry and Security Platform

**Complexity Level: Expert**

### Description


- Image scanning
- Policy enforcement
- Image signing
- Registry management
- Vulnerability tracking

```
# Secure Dockerfile Example
FROM alpine:3.14
RUN adduser -D -u 1000 appuser
USER appuser
COPY --chown=appuser:appuser app /app
ENTRYPOINT ["/app/start.sh"]
```

### Key Learning Objectives

- Container security
- Image management
- Policy enforcement
- Vulnerability management
- Access control

================================================
File: Projects/proj8.md
================================================
# Advanced DevOps Engineering Projects Portfolio

## Project 8: Service Mesh Implementation

**Complexity Level: Expert**

### Description



Deploy a comprehensive service mesh:

- Service discovery
- Traffic management
- Security policies
- Observability
- Fault tolerance
- Resilience and reliability
- Service mesh architecture
- DevOps culture and practices

```
# Istio Virtual Service
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: my-service
spec:
  hosts:
  - my-service
  http:
  - route:
    - destination:
        host: my-service
        subset: v1

```

### Key Learning Objectives

- Service discovery
- Traffic management
- Security policies
- Observability
- Fault tolerance
- Resilience and reliability
- Service mesh architecture
- DevOps culture and practices

================================================
File: Projects/Static_Web using Docker/static-website/Dockerfile
================================================
# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy static website files to the Nginx default content directory
COPY . /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80



================================================
File: Projects/Static_Web using Docker/static-website/Process.md
================================================
# The step by step process of Whats being done and implemented

# Deploy a Static Website Using Docker

This guide walks you through the process of deploying a simple static website using Docker and serving it with Nginx.

---

## **Overview**
Docker makes it easy to package, distribute, and deploy applications in containers. In this tutorial, we will:
1. Create a static website with HTML and CSS.
2. Write a `Dockerfile` to serve the site using the Nginx web server.
3. Build and run the Docker container locally.

---

## **Step 1: Prepare Your Static Website**
We start by creating a simple HTML/CSS website.

1. **Create the Project Directory**:
   ```bash
   mkdir static-website
   cd static-website
    ```
    2. Create a static website using HTML

```
      <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Static Website</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        p {
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Static Website</h1>
    <p>This site is served using Docker and Nginx!</p>
</body>
</html>

 ```

 ## Start Writing the Docker file

 ```
# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy the website files to the Nginx default content directory
COPY . /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

 ```

 ## Build the Docker Image
 ```
docker build -t static-website .

 ```

 ##  verify the Docker image
 ```
docker images

 ```

================================================
File: Projects/hello-docker/3_build_and_run.md
================================================
# 3_build_and_run

```
# Step 3: Build and Run the Docker Image

Once the `Dockerfile` is ready, follow these steps to build the image and run the container.

## Build the Docker Image
1. Build the image using the `docker build` command:
   ```bash
   docker build -t hello-world-python .

```

Here:

-t specifies the image name (hello-world-python).
. indicates the current directory contains the Dockerfile.

## Verify the image exists

```
docker images

```

### The  triggered Output must contain
REPOSITORY           TAG       IMAGE ID       CREATED       SIZE
hello-world-python   latest    <image-id>     <timestamp>   <size>



## Run The Docker Image Container

```
docker run hello-world-python

```

O/P: Hello, World!

================================================
File: Projects/hello-docker/Dockerfile
================================================
# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . .

# Command to run the Python application
CMD ["python", "-c", "print('Hello, World!')"]



================================================
File: Projects/hello-docker/Pre-req.md
================================================
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

================================================
File: Projects/hello-docker/Push Docker.md
================================================
#  Step 4: Push the Docker Image to Docker Hub

Docker Hub is a cloud-based repository where you can store and share Docker images.

## Log in to Docker Hub
1. Log in to your Docker Hub account:
```
   docker login
```


Some of the Best Practices of having the Docker Hub

```
# Best Practices for Docker

Follow these best practices to create efficient, secure, and optimized Docker images.

## Use Official and Verified Images
Always start with a verified base image from [Docker Hub](https://hub.docker.com/).

## Use Specific Image Versions
Specify the exact version of the base image (e.g., `python:3.9-slim`) to avoid unexpected changes.

## Optimize Image Size
1. Use minimal base images like `slim` or `alpine`.
2. Remove unnecessary files in the final image.

## Use Multi-Stage Builds
Leverage multi-stage builds to create lightweight production-ready images:
```dockerfile
FROM python:3.9 AS builder
# Install dependencies

FROM python:3.9-slim
# Copy only what is necessary

```

================================================
File: Projects/hello-docker/file_create.md
================================================
# Create a new docker file

## Step 2: Create a Dockerfile

A `Dockerfile` is a script that contains a series of commands to define a Docker image.

## Steps to Create a Dockerfile
1. Create a new directory for your project:
```
   mkdir hello-docker
   cd hello-docker
```
2.  Create a Nano Text Editor

```
nano Dockerfile
```

3. Add the contents to the Docker file
```
# Use an official Python runtime as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . .

# Command to run the Python application
CMD ["python", "-c", "print('Hello, World!')"]

```
4. Save and Close the File and Acknowledge the File through cat Dockerfile

================================================
File: Resources/Linux_Users.md
================================================
# Linux Accounts, Groups, Users, and Permissions Cheat Sheet

| **Command**                    | **Description**                                                                                  |
|---------------------------------|--------------------------------------------------------------------------------------------------|
| `whoami`                       | Displays the current logged-in user.                                                            |
| `id`                           | Displays the user ID (UID) and group ID (GID) of the current or specified user.                 |
| `groups`                       | Lists the groups a user belongs to.                                                             |
| `adduser username`             | Adds a new user with the specified `username`.                                                  |
| `useradd username`             | Adds a new user (requires manual configuration of home directory, password, etc.).              |
| `passwd username`              | Changes the password for the specified user.                                                    |
| `usermod -aG groupname username` | Adds a user to a specified group (`-a` for append, `-G` for group).                            |
| `deluser username`             | Deletes the specified user.                                                                     |
| `userdel username`             | Deletes the specified user (similar to `deluser`).                                              |
| `groupadd groupname`           | Creates a new group.                                                                            |
| `groupdel groupname`           | Deletes a group.                                                                                |
| `chown owner:group filename`   | Changes the ownership of a file to the specified `owner` and `group`.                           |
| `chmod permissions filename`   | Changes the file permissions (e.g., `chmod 755 filename`).                                      |
| `ls -l`                        | Lists files with their permissions, ownership, and other details.                               |
| `getfacl filename`             | Displays the access control list (ACL) for a file or directory.                                 |
| `setfacl -m u:username:rw filename` | Modifies the ACL to grant read and write permissions to a specific user.                   |
| `chmod u+r filename`           | Adds read permission for the user to the specified file.                                        |
| `chmod g-w filename`           | Removes write permission for the group from the specified file.                                 |
| `chmod o+x filename`           | Adds execute permission for others to the specified file.                                       |
| `chmod 777 filename`           | Grants read, write, and execute permissions to everyone.                                        |
| `chmod 000 filename`           | Removes all permissions from everyone.                                                         |
| `umask`                        | Displays or sets the default permissions for new files and directories.                        |
| `su - username`                | Switches to another user account with their environment.                                        |
| `sudo command`                 | Executes a command with superuser privileges.                                                  |
| `visudo`                       | Edits the sudoers file securely.                                                               |
| `find / -user username`        | Finds all files owned by the specified user.                                                   |
| `find / -group groupname`      | Finds all files belonging to the specified group.                                              |
| `touch filename`               | Creates a new empty file.                                                                      |
| `mkdir dirname`                | Creates a new directory.                                                                       |
| `rm -rf dirname`               | Deletes a directory and its contents recursively.                                              |
| `lsattr filename`              | Lists the attributes of a file (e.g., immutable files).                                        |
| `chattr +i filename`           | Makes a file immutable (cannot be modified, deleted, or renamed).                              |
| `chattr -i filename`           | Removes the immutable attribute from a file.                                                  |
| `who`                          | Displays all users currently logged into the system.                                           |
| `w`                            | Shows who is logged in and what they are doing.                                                |
| `last`                         | Displays the login history of users.                                                           |
| `finger username`              | Shows detailed information about a user, including home directory, shell, and more.            |
| `ssh username@hostname`        | Connects to a remote machine using SSH with the specified username.                            |
| `scp file username@hostname:/path` | Copies a file to a remote machine using SSH.                                               |
| `rsync -av source destination` | Synchronizes files between source and destination.                                             |

Feel free to copy and use this in your Markdown file!


================================================
File: Resources/Shell vs Python.md
================================================
Certainly! The choice between using shell scripting and Python in DevOps depends on the specific task or problem you're trying to solve. Both have their strengths and are suitable for different scenarios. Here are some guidelines to help you decide when to use each:

**Use Shell Scripting When:**

1. **System Administration Tasks:** Shell scripting is excellent for automating routine system administration tasks like managing files, directories, and processes. You can use shell scripts for tasks like starting/stopping services, managing users, and basic file manipulation.

2. **Command Line Interactions:** If your task primarily involves running command line tools and utilities, shell scripting can be more efficient. It's easy to call and control these utilities from a shell script.

3. **Rapid Prototyping:** If you need to quickly prototype a solution or perform one-off tasks, shell scripting is usually faster to write and execute. It's great for ad-hoc tasks.

4. **Text Processing:** Shell scripting is well-suited for tasks that involve text manipulation, such as parsing log files, searching and replacing text, or extracting data from text-based sources.

5. **Environment Variables and Configuration:** Shell scripts are useful for managing environment variables and configuring your system.

**Use Python When:**

1. **Complex Logic:** Python is a full-fledged programming language and is well-suited for tasks that involve complex logic, data structures, and algorithms. If your task requires extensive data manipulation, Python can be a more powerful choice.

2. **Cross-Platform Compatibility:** Python is more platform-independent than shell scripting, making it a better choice for tasks that need to run on different operating systems.

3. **API Integration:** Python has extensive libraries and modules for interacting with APIs, databases, and web services. If your task involves working with APIs, Python may be a better choice.

4. **Reusable Code:** If you plan to reuse your code or build larger applications, Python's structure and modularity make it easier to manage and maintain.

5. **Error Handling:** Python provides better error handling and debugging capabilities, which can be valuable in DevOps where reliability is crucial.

6. **Advanced Data Processing:** If your task involves advanced data processing, data analysis, or machine learning, Python's rich ecosystem of libraries (e.g., Pandas, NumPy, SciPy) makes it a more suitable choice.

================================================
File: Resources/keywords.md
================================================
### Python Keywords: An Overview

Keywords in Python are reserved words with predefined meanings and specific purposes. These words cannot be used as variable names or identifiers because they play a crucial role in defining the structure and logic of Python programs. Being case-sensitive, they must be written exactly as specified.

Here’s an explanation of some key Python keywords:

1. **`and`**: A logical operator that returns `True` only if both operands are true.  
2. **`or`**: A logical operator that returns `True` if at least one operand is true.  
3. **`not`**: A logical operator that inverts the truth value of its operand.  
4. **`if`**: Marks the start of a conditional statement, followed by a condition to determine if the code block should execute.  
5. **`else`**: Used with `if` to define an alternative code block when the condition is `False`.  
6. **`elif`**: Stands for "else if," enabling additional conditions after an initial `if`.  
7. **`while`**: Creates a loop that runs as long as a specified condition remains true.  
8. **`for`**: Defines a loop that iterates over a sequence (e.g., list, tuple, or string).  
9. **`in`**: Checks for membership in a sequence, often used with `for` loops.  
10. **`try`**: Starts a block of code for exception handling.  
11. **`except`**: Defines a block of code to execute when an exception is raised in the `try` block.  
12. **`finally`**: Specifies a block of code that will always execute, whether or not an exception occurs.  
13. **`def`**: Used to define a function in Python.  
14. **`return`**: Specifies the value to be returned by a function.  
15. **`class`**: Used to define a class, the blueprint for creating objects.  
16. **`import`**: Allows importing modules or libraries into the program.  
17. **`from`**: Used with `import` to bring specific components from a module.  
18. **`as`**: Assigns an alias to a module or component for easier reference.  
19. **`True`**: Represents a boolean value of "true."  
20. **`False`**: Represents a boolean value of "false."  
21. **`None`**: Indicates a special null value or absence of value.  
22. **`is`**: Compares the identity of two objects, checking if they refer to the same memory location.  
23. **`lambda`**: Defines small, anonymous functions.  
24. **`with`**: Used for context management to ensure certain operations are performed before and after a block of code.  
25. **`global`**: Declares a variable as global, allowing its modification within a function.  
26. **`nonlocal`**: Declares a variable as nonlocal, enabling its modification in an enclosing (non-global) scope.


================================================
File: Resources/listsvssets.md
================================================

# Keywords in Python

Keywords are reserved words in Python with predefined meanings. They cannot be used as variable names or identifiers. Keywords form the structural and logical framework of a Python program. These words are case-sensitive and must be used exactly as defined.

Here is a list of some essential Python keywords:

1. **and**: Logical operator; returns `True` if both operands are true.
   ```python
   x = True and False  # Output: False
   ```

2. **or**: Logical operator; returns `True` if at least one operand is true.
   ```python
   x = True or False  # Output: True
   ```

3. **not**: Logical operator; returns the opposite truth value of the operand.
   ```python
   x = not True  # Output: False
   ```

4. **if**: Starts a conditional statement.
   ```python
   if x > 0:
       print("Positive")
   ```

5. **else**: Defines a block of code executed if the `if` condition is false.
   ```python
   if x > 0:
       print("Positive")
   else:
       print("Non-positive")
   ```

6. **elif**: Stands for "else if," used for additional conditions.
   ```python
   if x > 0:
       print("Positive")
   elif x == 0:
       print("Zero")
   else:
       print("Negative")
   ```

7. **while**: Creates a loop that executes as long as the condition is true.
   ```python
   while x < 5:
       x += 1
   ```

8. **for**: Creates a loop to iterate over a sequence.
   ```python
   for item in [1, 2, 3]:
       print(item)
   ```

9. **in**: Checks if a value exists in a sequence.
   ```python
   if 2 in [1, 2, 3]:
       print("Found")
   ```

10. **try/except/finally**: Exception handling blocks.
    ```python
    try:
        x = 1 / 0
    except ZeroDivisionError:
        print("Division by zero")
    finally:
        print("Executed regardless")
    ```

11. **def**: Defines a function.
    ```python
    def add(a, b):
        return a + b
    ```

12. **class**: Defines a class.
    ```python
    class Person:
        pass
    ```

13. **import/from/as**: Imports modules or specific components, with optional aliasing.
    ```python
    import math
    from math import pi as circle_constant
    ```

14. **True/False/None**: Boolean values and null equivalent.
    ```python
    x = True
    y = False
    z = None
    ```

15. **is**: Checks identity of two objects.
    ```python
    x = y = [1, 2, 3]
    print(x is y)  # Output: True
    ```

16. **lambda**: Creates small anonymous functions.
    ```python
    square = lambda x: x ** 2
    print(square(3))  # Output: 9
    ```

17. **with**: Used for context management.
    ```python
    with open("file.txt", "r") as file:
        content = file.read()
    ```

18. **global/nonlocal**: Modifies variables in different scopes.
    ```python
    def example():
        global x
        x = 10
    ```

---

# Lists vs. Sets in Python

## Lists

- **Ordered Collection:**
  - Lists maintain the order of elements as they are added.
  - Elements can be accessed using their index.

  ```python
  my_list = [1, 2, 3, 4, 5]
  print(my_list[0])  # Output: 1
  ```

- **Mutable:**
  - Lists allow modification of elements after creation.

  ```python
  my_list[1] = 10
  ```

- **Allows Duplicate Elements:**
  - Lists can contain duplicate values.

  ```python
  my_list = [1, 2, 2, 3, 4]
  ```

- **Use Cases:**
  - Ideal when an ordered collection with modifiable elements is required.

## Sets

- **Unordered Collection:**
  - Sets do not maintain the order of elements.
  - Index-based access is not possible.

  ```python
  my_set = {1, 2, 3, 4, 5}
  ```

- **Mutable:**
  - Sets allow adding and removing elements after creation.

  ```python
  my_set.add(6)
  ```

- **No Duplicate Elements:**
  - Sets automatically eliminate duplicate values.

  ```python
  my_set = {1, 2, 2, 3, 4}  # Results in {1, 2, 3, 4}
  ```

- **Use Cases:**
  - Suitable when unique elements and set operations like union, intersection, or difference are needed.

---

## Common Operations

### Adding Elements:
- **Lists:** Use `append()` or `insert()`.  
- **Sets:** Use `add()`.

### Removing Elements:
- **Lists:** Use `remove()`, `pop()`, or the `del` statement.  
- **Sets:** Use `remove()` or `discard()`.

### Checking Membership:
- Both lists and sets use the `in` operator, but it is more efficient for sets.

```python
# Lists
if 3 in my_list:
    print("3 is in the list")

# Sets
if 3 in my_set:
    print("3 is in the set")
```

---

## Choosing Between Lists and Sets

### Use **Lists** When:
- Maintaining the order of elements is necessary.
- Duplicate values are acceptable.
- You need to access elements by index.

### Use **Sets** When:
- The order of elements does not matter.
- Unique values are required.
- Set operations like union, intersection, or difference are needed.


================================================
File: Resources/numericdata.md
================================================
# Numberic Data Type

**1. Numeric Data Types in Python (int, float):**

- Python supports two primary numeric data types: `int` for integers and `float` for floating-point numbers.
- Integers are whole numbers, and floats can represent both whole and fractional numbers.
- You can perform arithmetic operations on these types, including addition, subtraction, multiplication, division, and more.
- Be aware of potential issues with floating-point precision, which can lead to small inaccuracies in calculations.
- Python also provides built-in functions for mathematical operations, such as `abs()`, `round()`, and `math` module for advanced functions.

================================================
File: Resources/regex.md
================================================
# Regex

**1. Regular Expressions for Text Processing:**

- Regular expressions (regex or regexp) are a powerful tool for pattern matching and text processing.
- The `re` module in Python is used for working with regular expressions.
- Common metacharacters: `.` (any character), `*` (zero or more), `+` (one or more), `?` (zero or one), `[]` (character class), `|` (OR), `^` (start of a line), `$` (end of a line), etc.
- Examples of regex usage: matching emails, phone numbers, or extracting data from text.
- `re` module functions include `re.match()`, `re.search()`, `re.findall()`, and `re.sub()` for pattern matching and replacement.


A Basic Usage of Regex in a python file


================================================
File: Resources/regex.py
================================================
import re

# 1. Basic Pattern Matching
text = "Hello, my email is john@example.com"
email_pattern = r'\b[\w.-]+@[\w.-]+\.\w+\b'  # Simplified \.- to .-
email_match = re.search(email_pattern, text)
if email_match:
    print(email_match.group())  # Output: john@example.com

# 2. Phone Number Matching
phone_text = "Call me at 123-456-7890 or (987) 654-3210"
phone_pattern = r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}'
phones = re.findall(phone_pattern, phone_text)
print(phones)  # Output: ['123-456-7890', '(987) 654-3210']

# 3. Text Replacement
text = "I love cats, cats are great"
new_text = re.sub(r'cats', 'dogs', text, flags=re.IGNORECASE)  # Added flags for case insensitivity
print(new_text)  # Output: I love dogs, dogs are great

# 4. Validating Username
def is_valid_username(username):
    return bool(re.match(r'^[a-zA-Z0-9_]{3,16}$', username))

print(is_valid_username("john_doe123"))  # Output: True
print(is_valid_username("jo"))          # Output: False

# 5. Extracting URLs
text = "Visit https://www.example.com and http://test.com"
url_pattern = r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[^\s]*'
urls = re.findall(url_pattern, text)
print(urls)  # Output: ['https://www.example.com', 'http://test.com']

# 6. Split String by Multiple Delimiters
text = "apple,banana;orange|grape"
items = re.split(r'[,\|;]', text)  # Adjusted pattern for clarity
print(items)  # Output: ['apple', 'banana', 'orange', 'grape']

# 7. Password Validation
def is_valid_password(password):
    pattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
    return bool(re.match(pattern, password))

print(is_valid_password("Password123!"))  # Output: True
print(is_valid_password("weak"))          # Output: False

# 8. Date Format Validation
def is_valid_date(date):
    pattern = r'^(0[1-9]|1[0-2])/(0[1-9]|[12]\d|3[01])/([12]\d{3})$'
    return bool(re.match(pattern, date))

print(is_valid_date("12/25/2023"))  # Output: True
print(is_valid_date("13/45/2023"))  # Output: False

# 9. Extracting Words with Specific Pattern
text = "Python3 is great123 for coding456"
pattern = r'\b\w+\d+\b'  # Matches words ending with digits
words = re.findall(pattern, text)
print(words)  # Output: ['Python3', 'great123', 'coding456']

# 10. HTML Tag Removal
html = "<p>This is <b>bold</b> text</p>"
clean_text = re.sub(r'<[^>]+>', '', html)  # Removes all HTML tags
print(clean_text)  # Output: This is bold text


================================================
File: Resources/retrievalconfig.py
================================================
# Dictionary containing server configurations
server_config = {
    'server1': {'ip': '192.168.1.1', 'port': 8080, 'status': 'active'},
    'server2': {'ip': '192.168.1.2', 'port': 8000, 'status': 'inactive'},
    'server3': {'ip': '192.168.1.3', 'port': 9000, 'status': 'active'}
}

def get_server_status(server_name):
    """
    Retrieve the status of a specified server from the server configuration.
    
    Parameters:
        server_name (str): The name of the server (e.g., 'server1').
        
    Returns:
        str: The status of the server ('active', 'inactive', or 'Server not found').
    """
    return server_config.get(server_name, {}).get('status', 'Server not found')

# Example usage
print("Server Status:", get_server_status('server1'))  # Output: active


================================================
File: Resources/retrival.md
================================================
# Optimizations
Meaningful Function Name: Renamed the function to get_server_status for clarity, as the function retrieves the server's status specifically.

Improved Documentation: Added a detailed docstring to describe the function's purpose, parameters, and return value.

Simplified Print Statement: Updated the print statement for a clearer output message.

This version is more readable, maintainable, and informative for anyone using or reviewing the code.

================================================
File: Resources/variables.md
================================================
# Understanding Variables in Python:

In Python, a variable is a named storage location used to store data. Variables are essential for programming as they allow us to work with data, manipulate it, and make our code more flexible and reusable. 

#### Example:

```python
# Assigning a value to a variable
my_variable = 42

# Accessing the value of a variable
print(my_variable)  # Output: 42
```

### Variable Scope and Lifetime:

**Variable Scope:** In Python, variables have different scopes, which determine where in the code the variable can be accessed. There are mainly two types of variable scopes:

1. **Local Scope:** Variables defined within a function have local scope and are only accessible inside that function.
   
   ```python
   def my_function():
       x = 10  # Local variable
       print(x)
   
   my_function()
   print(x)  # This will raise an error since 'x' is not defined outside the function.
   ```

2. **Global Scope:** Variables defined outside of any function have global scope and can be accessed throughout the entire code.

   ```python
   y = 20  # Global variable

   def another_function():
       print(y)  # This will access the global variable 'y'

   another_function()
   print(y)  # This will print 20
   ```

**Variable Lifetime:** The lifetime of a variable is determined by when it is created and when it is destroyed or goes out of scope. Local variables exist only while the function is being executed, while global variables exist for the entire duration of the program.

### Variable Naming Conventions and Best Practices:

It's important to follow naming conventions and best practices for variables to write clean and maintainable code:

- Variable names should be descriptive and indicate their purpose.
- Use lowercase letters and separate words with underscores (snake_case) for variable names.
- Avoid using reserved words (keywords) for variable names.
- Choose meaningful names for variables.

#### Example:

```python
# Good variable naming
user_name = "John"
total_items = 42

# Avoid using reserved words
class = "Python"  # Not recommended

# Use meaningful names
a = 10  # Less clear
num_of_students = 10  # More descriptive
```

### Practice Exercises and Examples:

#### Example: Using Variables to Store and Manipulate Configuration Data in a DevOps Context

In a DevOps context, you often need to manage configuration data for various services or environments. Variables are essential for this purpose. Let's consider a scenario where we need to store and manipulate configuration data for a web server.

```python
# Define configuration variables for a web server
server_name = "my_server"
port = 80
is_https_enabled = True
max_connections = 1000

# Print the configuration
print(f"Server Name: {server_name}")
print(f"Port: {port}")
print(f"HTTPS Enabled: {is_https_enabled}")
print(f"Max Connections: {max_connections}")

# Update configuration values
port = 443
is_https_enabled = False

# Print the updated configuration
print(f"Updated Port: {port}")
print(f"Updated HTTPS Enabled: {is_https_enabled}")
```

In this example, we use variables to store and manipulate configuration data for a web server. This allows us to easily update and manage the server's configuration in a DevOps context.

================================================
File: Vim/Concepts.md
================================================
# Vim Concepts Cheat Sheet

## Basics
- **Open a file**: `vim filename`
- **Exit Vim**:
  - Save and exit: `:wq` or `ZZ`
  - Exit without saving: `:q!`
- **Insert Mode**: Press `i` to enter, `<Esc>` to exit.
- **Command Mode**: Default mode; navigate and execute commands.

---

## Navigation
- **Move cursor**:
  - Characters: `h` (left), `l` (right)
  - Lines: `j` (down), `k` (up)
- **Word navigation**:
  - Start of next word: `w`
  - End of next word: `e`
  - Start of previous word: `b`
- **Paragraph navigation**:
  - Next: `}` 
  - Previous: `{`
- **Screen navigation**:
  - Half-screen down: `Ctrl+d`
  - Half-screen up: `Ctrl+u`

---

## Editing
- **Delete**:
  - Character: `x`
  - Line: `dd`
  - Word: `dw`
  - From cursor to end of line: `D`
- **Undo/Redo**:
  - Undo: `u`
  - Redo: `Ctrl+r`
- **Copy/Paste**:
  - Copy (yank) line: `yy`
  - Paste: `p`
- **Replace**:
  - Replace a single character: `r<char>`
  - Replace from the cursor: `R` (overwrite mode)

---

## Search and Replace
- **Search**:
  - Forward: `/pattern`
  - Backward: `?pattern`
  - Next occurrence: `n`
  - Previous occurrence: `N`
- **Replace**:
  - Current line: `:s/old/new/g`
  - Entire file: `:%s/old/new/g`

---

## Visual Mode
- **Activate**:
  - Character selection: `v`
  - Line selection: `V`
  - Block selection: `Ctrl+v`
- **Edit selection**:
  - Delete: `d`
  - Yank: `y`
  - Replace: `r`

---

## Split Windows
- **Horizontal split**: `:split filename` or `Ctrl+w s`
- **Vertical split**: `:vsplit filename` or `Ctrl+w v`
- **Navigate splits**: `Ctrl+w <direction>` (`h`, `j`, `k`, `l`)
- **Resize splits**:
  - Increase: `Ctrl+w +`
  - Decrease: `Ctrl+w -`

---

## Buffers and Tabs
- **Buffers**:
  - List buffers: `:ls`
  - Switch buffer: `:b<number>`
  - Close buffer: `:bd`
- **Tabs**:
  - New tab: `:tabnew filename`
  - Next tab: `:tabn`
  - Previous tab: `:tabp`
  - Close tab: `:tabclose`

---

## Macros
- **Record macro**: `q<register>`
- **Stop recording**: `q`
- **Play macro**: `@<register>`
- **Repeat macro**: `@@`

---

## Advanced
- **Indentation**:
  - Indent: `>>`
  - Outdent: `<<`
- **Marks**:
  - Set mark: `m<char>`
  - Jump to mark: `'char`
- **Folding**:
  - Create fold: `zf`
  - Open fold: `zo`
  - Close fold: `zc`

---

## Customization
- **Edit settings**: `:e ~/.vimrc`
- **Set options**:
  - Line numbers: `:set number`
  - Syntax highlighting: `:syntax on`
- **Plugins**: Use a plugin manager like `vim-plug` for additional features.

---

## Useful Commands
- **Jump to line**: `:<line_number>`
- **Repeat last command**: `.`
- **Show current file info**: `Ctrl+g`

---

Mastering Vim takes practice. Start with these concepts and gradually explore more advanced features.


================================================
File: Vim/vim_editor_commands.md
================================================
# Vim Editor Commands Cheat Sheet

| **Command**         | **Description**                                                                 |
|----------------------|---------------------------------------------------------------------------------|
| `i`                 | Switch to insert mode from normal mode.                                        |
| `Esc`               | Switch to normal mode from insert mode.                                        |
| `:w`                | Save the current file.                                                        |
| `:q`                | Quit Vim.                                                                     |
| `:wq`               | Save and quit Vim.                                                            |
| `:q!`               | Quit without saving.                                                          |
| `:x`                | Save and exit (same as `:wq`).                                                |
| `u`                 | Undo the last change.                                                         |
| `Ctrl + r`          | Redo the undone changes.                                                      |
| `dd`                | Delete the current line.                                                      |
| `yy`                | Copy (yank) the current line.                                                 |
| `p`                 | Paste the yanked or deleted content after the cursor.                         |
| `P`                 | Paste the yanked or deleted content before the cursor.                        |
| `/text`             | Search for `text` in the file.                                                |
| `n`                 | Repeat the last search in the same direction.                                 |
| `N`                 | Repeat the last search in the opposite direction.                             |
| `:%s/old/new/g`     | Replace all occurrences of `old` with `new` in the file.                      |
| `:s


================================================
File: YAML/YAML_in_devops.md
================================================
# YAML in DevOps: The Ultimate Guide

## What is YAML?
- **YAML** stands for "YAML Ain't Markup Language."
- It is a human-readable data serialization standard, often used for configuration files.
- YAML uses a clean and minimal syntax, making it easier for humans to write and understand.

## Key Features of YAML
1. **Human-Readable**: Simple structure with minimal syntax.
2. **Hierarchical Data Representation**: Supports nested structures using indentation.
3. **Compatibility**: Works seamlessly with JSON and other formats.
4. **No Closing Tags**: Unlike XML, YAML avoids verbose tags.

## Why YAML is Essential in DevOps
- **Configuration Management**: YAML is widely used in tools like Ansible, Kubernetes, and GitHub Actions for defining configurations.
- **Declarative Syntax**: Ideal for describing infrastructure as code (IaC).
- **Interoperability**: Compatible with most DevOps tools, enabling smooth automation workflows.

## How YAML is Used in DevOps
### 1. **Kubernetes**
- YAML is the primary format for defining Kubernetes objects such as Pods, Deployments, and Services.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx


================================================
File: YAML/ansible.yaml
================================================
# YAML defines playbooks for automation.

- name: Install packages
  hosts: all
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present


================================================
File: YAML/ci-cd.yaml
================================================
name: CI Workflow
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Install dependencies
        run: npm install



================================================
File: YAML/file.md
================================================
| ZSH Commands | PowerShell Commmands |
| --- | --- |
| where | where.exe  |
| open | Use Shortcut- Win + R|
| $PATH | $Env:Path |
| ls -a </br> [To see all files[hidden and visible]] | dir -Force |
| vi | vim </br> [need to download] |
| ls -l </br> [To see all files & directories] | Get-ChildItem |
| cat > </br> [To edit] | vim |
| cat file.txt two.txt > total.txt | cat file.txt, two.txt > total.txt |
| cat file.txt \| tr a-z A-Z > upper.txt | (cat 'file.txt').ToUpper() > upper.txt |
| \ </br> [For new line] | ` |
| mkdir random </br> mkdir random/hello </br> [we need to create random first here] | mkdir random/hello </br> [only one line to execute, no need to create random first, it can be created together] |
| touch | [you need to define touch] </br> function touch { </br> Param( </br> [Parameter(Mandatory=$true)] </br> [string]$Path </br> ) </br> if (Test-Path -LiteralPath $Path) { </br> (Get-Item -Path $Path).LastWriteTime = Get-Date </br> } </br> else { </br> New-Item -Type File -Path $Path </br> } </br> } |
| sudo | runas |
| df | gdr |
| du | [need to define du] </br> function du($path=".") { </br> Get-ChildItem $path \| </br> ForEach-Object { </br> $file = $_ </br> Get-ChildItem -File -Recurse $_.FullName \| Measure-Object -Property length -Sum \| </br> Select-Object -Property @{Name="Name";Expression={$file}}, </br> @{Name="Size(MB)";Expression={[math]::round(($_.Sum / 1MB),2)}} # round 2 decimal places </br> } </br>} |


# Strategy for Learning from Kunal Kushwaha Devops  course
...

## Introduction to networking
Networking fundamentals, OSI layer protocols, port forwarding, how the internet works, command line tools, and more.

## Command line tools
Various command line tools, bash scripting, regex, introduction to git, and more.

## Kubernetes
Introduction, architecture, set-up, objects, networking, storage, HA, monitoring, logging, production-ready applications.

## Servers
Introduction to web-servers, Nginx, and more.

## Infrastructure as code
Infrastructure provisioning, Terraform, Pulumi, configuration management, and more.

## Service mesh
Istio, Envoy, Linkerd, and more.

## Working with cloud providers
Learn about cloud providers, design patterns, and more.

## Chaos engineering
The next step in testing.

## Introduction to Linux
Learn about the essentials of working with Linux, including some important commands.

## Docker
Introduction to containers, hands-on demos, concepts, architecture, images, networking, best practices, development profiles, Docker Compose, Docker Swarm.

================================================
File: YAML/yaaml.yml
================================================
jay: &likes
  fav_subject: "Quant"
  hated_subject: "Math"
  favorite_books:
    - "To Kill a Mockingbird"
    - "1984"

Ajar:
  << * likes
      

================================================
File: YAML/Assignments/Quest.yaml
================================================

---

### **Markdown File 2: YAML Assignment Questions**

``` 
# YAML Assignment Questions

## Question 1: Kubernetes Deployment
Write a YAML configuration for a Kubernetes Deployment with:
- 3 replicas.
- An Nginx container with the `latest` tag.
- Port 80 exposed.

---

## Question 2: Ansible Playbook
Create an Ansible playbook to:
- Install Apache.
- Start and enable the Apache service.

---

## Question 3: GitHub Actions Workflow
Design a GitHub Actions workflow to:
- Run on `push` events.
- Use Node.js 16.
- Install dependencies and run tests.
```

================================================
File: YAML/Assignments/Solution.yaml
================================================
# Solution 1: Kubernetes Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80

# Solution 2: Ansible Playbook
- name: Manage Apache
  hosts: all
  tasks:
    - name: Install Apache
      apt:
        name: apache2
        state: present
    - name: Start Apache service
      service:
        name: apache2
        state: started
        enabled: true

# Solution 3: GitHub Actions Workflow
name: Node.js CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test



================================================
File: YAML/Assignments/explained.md
================================================
# Assignment Solutions Explained

## Solution 1: Kubernetes Deployment
### Steps:
1. **Define the API Version**:
   - Use  for Deployment objects.
2. **Set Metadata**:
   - Name the deployment .
3. **Specify the Spec Section**:
   - Define  for three instances.
   - Use  as the container image.
   - Expose port 80 via .

---

## Solution 2: Ansible Playbook
### Steps:
1. **Define the Playbook Name**:
   - Use  for clarity.
2. **Set Hosts**:
   - Apply the tasks to all hosts in the inventory.
3. **Install Apache**:
   - Use the  module to ensure Apache is installed.
4. **Start and Enable Apache**:
   - Use the  module to manage the service state.

---

## Solution 3: GitHub Actions Workflow
### Steps:
1. **Define the Workflow Name**:
   - Name it  for clarity.
2. **Set the Trigger**:
   - Run on  events targeting the  branch.
3. **Define Jobs**:
   - Use  to specify the runner.
   - Include steps for:
     - Checking out code.
     - Setting up Node.js 16.
     - Installing dependencies.
     - Running tests.



================================================
File: YAML/Practices/Best_Practices_Yaml.md
================================================
Consistent Indentation: Use spaces, not tabs.
Avoid Trailing Spaces: They can cause parsing errors.
Comment Your Code: Use # to add context.
Validate Syntax: Use online validators or CLI tools like yamllint.
Reuse with Anchors and Aliases:


================================================
File: YAML/Practices/practice.yml
================================================
default_settings: &defaults
  retries: 3
  timeout: 30

server1:
  <<: *defaults
  url: http://server1.example.com



================================================
File: .github/workflows/docker-image.yml
================================================
name: Docker Image CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Build the Docker image
      run: docker build . --file Dockerfile --tag my-image-name:$(date +%s)


