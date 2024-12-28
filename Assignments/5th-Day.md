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

