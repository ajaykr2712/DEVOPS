# YAML Configuration Guide

## Overview
Best practices for YAML configuration files.

## Syntax Rules
- Indentation with spaces
- No tabs allowed
- Case sensitive
- Data types support

## Kubernetes Examples
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
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
        image: nginx:1.21
        ports:
        - containerPort: 80
```

## Best Practices
- Consistent indentation
- Use comments
- Validate syntax
- Version control
- Environment specific configs

## Tools
- YAML linters
- Schema validation
- Template engines
- Configuration management
