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