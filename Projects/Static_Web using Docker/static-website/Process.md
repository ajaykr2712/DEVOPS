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