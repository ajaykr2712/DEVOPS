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