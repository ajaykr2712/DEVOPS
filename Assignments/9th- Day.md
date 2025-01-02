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
