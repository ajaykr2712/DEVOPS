# CI/CD Pipeline Templates

## Overview
Reusable pipeline templates for different project types.

## Template Categories
- Node.js applications
- Python applications
- Go applications
- Docker images

## GitHub Actions Template
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
    - run: npm install
    - run: npm test
```

## Pipeline Stages
- Code checkout
- Dependency installation
- Testing
- Security scanning
- Build
- Deploy

## Best Practices
- Parallel execution
- Artifact caching
- Environment promotion
- Rollback strategy
