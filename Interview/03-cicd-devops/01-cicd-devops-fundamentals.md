# CI/CD & DevOps Fundamentals

## Table of Contents
1. [GitHub Actions](#github-actions)
2. [Jenkins](#jenkins)
3. [Git Best Practices](#git-best-practices)
4. [Pipeline Automation](#pipeline-automation)
5. [Rollback Strategies](#rollback-strategies)
6. [Release Strategies](#release-strategies)
7. [Infrastructure as Code](#infrastructure-as-code)
8. [Monitoring and Alerting](#monitoring-and-alerting)
9. [Security in CI/CD](#security-in-cicd)
10. [Interview Questions](#interview-questions)

## GitHub Actions

### Basic Workflow Structure

```yaml
# .github/workflows/ci.yml
name: Continuous Integration

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

env:
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.9'

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Full history for better diff analysis
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
        cache: 'pip'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    
    - name: Type checking with mypy
      run: mypy src/
    
    - name: Run tests with pytest
      run: |
        pytest tests/ \
          --cov=src \
          --cov-report=xml \
          --cov-report=html \
          --cov-fail-under=80 \
          --junitxml=test-results.xml
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results-${{ matrix.python-version }}
        path: |
          test-results.xml
          htmlcov/
```

### Advanced GitHub Actions Patterns

```yaml
# .github/workflows/deployment.yml
name: Build and Deploy

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ghcr.io/${{ github.repository }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha,prefix={{branch}}-
    
    - name: Build and push
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          VERSION=${{ steps.meta.outputs.version }}
          BUILD_DATE=${{ steps.meta.outputs.created }}

  security-scan:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
    - name: Security scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ needs.build.outputs.image-tag }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  deploy-staging:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - name: Deploy to staging
      run: |
        echo "Deploying ${{ needs.build.outputs.image-tag }} to staging"
        # Deployment logic here
    
    - name: Run smoke tests
      run: |
        ./scripts/smoke-tests.sh staging
    
    - name: Notify deployment
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    if: startsWith(github.ref, 'refs/tags/v')
    
    steps:
    - name: Deploy to production
      run: |
        echo "Deploying ${{ needs.build.outputs.image-tag }} to production"
        # Blue-green deployment logic
```

### Reusable Workflows and Actions

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: true
        type: string
      test-path:
        required: false
        type: string
        default: 'tests/'
      coverage-threshold:
        required: false
        type: number
        default: 80
    outputs:
      coverage-percentage:
        description: "Test coverage percentage"
        value: ${{ jobs.test.outputs.coverage }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      coverage: ${{ steps.coverage.outputs.percentage }}
    
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v4
      with:
        python-version: ${{ inputs.python-version }}
    
    - name: Install and test
      run: |
        pip install -r requirements.txt
        pytest ${{ inputs.test-path }} --cov --cov-report=json
    
    - name: Extract coverage
      id: coverage
      run: |
        COVERAGE=$(jq '.totals.percent_covered' coverage.json)
        echo "percentage=$COVERAGE" >> $GITHUB_OUTPUT
        
        if (( $(echo "$COVERAGE < ${{ inputs.coverage-threshold }}" | bc -l) )); then
          echo "Coverage $COVERAGE% below threshold ${{ inputs.coverage-threshold }}%"
          exit 1
        fi
```

## Jenkins

### Declarative Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent {
        kubernetes {
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: docker
                    image: docker:latest
                    command:
                    - cat
                    tty: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-sock
                  - name: python
                    image: python:3.9
                    command:
                    - cat
                    tty: true
                  volumes:
                  - name: docker-sock
                    hostPath:
                      path: /var/run/docker.sock
            """
        }
    }
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'myapp'
        SLACK_CHANNEL = '#ci-cd'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                    env.BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        container('python') {
                            sh '''
                                pip install -r requirements.txt
                                pip install pytest pytest-cov
                                pytest tests/unit/ --cov=src --cov-report=xml --junitxml=unit-test-results.xml
                            '''
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'unit-test-results.xml'
                            publishCoverage adapters: [coberturaAdapter('coverage.xml')], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        container('python') {
                            sh '''
                                pip install -r requirements.txt
                                pytest tests/integration/ --junitxml=integration-test-results.xml
                            '''
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'integration-test-results.xml'
                        }
                    }
                }
                
                stage('Linting') {
                    steps {
                        container('python') {
                            sh '''
                                pip install flake8 black mypy
                                flake8 src/
                                black --check src/
                                mypy src/
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    tag pattern: 'v\\d+\\.\\d+\\.\\d+', comparator: 'REGEXP'
                }
            }
            steps {
                container('docker') {
                    sh '''
                        docker build \
                            --build-arg VERSION=${BUILD_VERSION} \
                            --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                            -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VERSION} \
                            -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest \
                            .
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                container('docker') {
                    sh '''
                        # Install Trivy
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                        
                        # Scan image
                        trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VERSION}
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }
        
        stage('Push Image') {
            when {
                anyOf {
                    branch 'main'
                    tag pattern: 'v\\d+\\.\\d+\\.\\d+', comparator: 'REGEXP'
                }
            }
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-registry', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                            echo $PASSWORD | docker login ${DOCKER_REGISTRY} -u $USERNAME --password-stdin
                            docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VERSION}
                            docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                        '''
                    }
                }
            }
        }
        
        stage('Deploy') {
            parallel {
                stage('Deploy to Staging') {
                    when {
                        branch 'develop'
                    }
                    steps {
                        build job: 'deploy-to-staging',
                              parameters: [
                                  string(name: 'IMAGE_TAG', value: env.BUILD_VERSION),
                                  string(name: 'ENVIRONMENT', value: 'staging')
                              ],
                              wait: true
                    }
                }
                
                stage('Deploy to Production') {
                    when {
                        tag pattern: 'v\\d+\\.\\d+\\.\\d+', comparator: 'REGEXP'
                    }
                    steps {
                        timeout(time: 5, unit: 'MINUTES') {
                            input message: 'Deploy to production?', ok: 'Deploy',
                                  submitterParameter: 'DEPLOYER'
                        }
                        
                        build job: 'deploy-to-production',
                              parameters: [
                                  string(name: 'IMAGE_TAG', value: env.BUILD_VERSION),
                                  string(name: 'ENVIRONMENT', value: 'production'),
                                  string(name: 'DEPLOYER', value: env.DEPLOYER)
                              ],
                              wait: true
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend channel: env.SLACK_CHANNEL,
                     color: 'good',
                     message: """
                         ✅ Build Successful
                         Job: ${env.JOB_NAME}
                         Build: ${env.BUILD_NUMBER}
                         Version: ${env.BUILD_VERSION}
                     """
        }
        failure {
            slackSend channel: env.SLACK_CHANNEL,
                     color: 'danger',
                     message: """
                         ❌ Build Failed
                         Job: ${env.JOB_NAME}
                         Build: ${env.BUILD_NUMBER}
                         Version: ${env.BUILD_VERSION}
                         Logs: ${env.BUILD_URL}console
                     """
        }
    }
}
```

### Jenkins Shared Libraries

```groovy
// vars/deployApplication.groovy
def call(Map config) {
    pipeline {
        agent any
        
        stages {
            stage('Validate Config') {
                steps {
                    script {
                        validateDeploymentConfig(config)
                    }
                }
            }
            
            stage('Pre-deployment Health Check') {
                steps {
                    script {
                        def healthStatus = checkEnvironmentHealth(config.environment)
                        if (!healthStatus.healthy) {
                            error("Environment ${config.environment} is not healthy: ${healthStatus.message}")
                        }
                    }
                }
            }
            
            stage('Deploy') {
                steps {
                    script {
                        deployToEnvironment(config)
                    }
                }
            }
            
            stage('Post-deployment Tests') {
                steps {
                    script {
                        runSmokeTests(config)
                    }
                }
            }
        }
        
        post {
            success {
                script {
                    notifyDeploymentSuccess(config)
                }
            }
            failure {
                script {
                    notifyDeploymentFailure(config)
                    if (config.autoRollback) {
                        rollbackDeployment(config)
                    }
                }
            }
        }
    }
}

def validateDeploymentConfig(config) {
    def requiredFields = ['application', 'version', 'environment']
    requiredFields.each { field ->
        if (!config.containsKey(field)) {
            error("Missing required configuration field: ${field}")
        }
    }
}

def deployToEnvironment(config) {
    sh """
        helm upgrade --install ${config.application} ./helm-chart \
            --namespace ${config.environment} \
            --set image.tag=${config.version} \
            --set environment=${config.environment} \
            --timeout 10m \
            --wait
    """
}
```

## Git Best Practices

### Branching Strategy (GitFlow)

```bash
# Main branches
git checkout main          # Production-ready code
git checkout develop       # Integration branch

# Feature development
git checkout develop
git checkout -b feature/user-authentication
# ... make changes ...
git add .
git commit -m "feat: add user authentication with JWT"
git push origin feature/user-authentication

# Create pull request to develop

# Release preparation
git checkout develop
git checkout -b release/v1.2.0
# ... version bumps, minor fixes ...
git commit -m "chore: bump version to 1.2.0"

# Merge to main and tag
git checkout main
git merge release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge release/v1.2.0

# Hotfixes
git checkout main
git checkout -b hotfix/critical-security-fix
# ... fix ...
git commit -m "fix: resolve critical security vulnerability"
git checkout main
git merge hotfix/critical-security-fix
git tag -a v1.2.1 -m "Hotfix version 1.2.1"
git checkout develop
git merge hotfix/critical-security-fix
```

### Conventional Commits

```bash
# Commit message format: <type>(<scope>): <description>

# Types:
git commit -m "feat(auth): add OAuth2 integration"        # New feature
git commit -m "fix(api): resolve null pointer exception"  # Bug fix
git commit -m "docs(readme): update installation guide"   # Documentation
git commit -m "style(css): fix button alignment"          # Code style
git commit -m "refactor(db): optimize query performance"  # Refactoring
git commit -m "test(unit): add user service tests"        # Tests
git commit -m "chore(deps): update dependencies"          # Maintenance

# Breaking changes
git commit -m "feat(api)!: change user endpoint structure

BREAKING CHANGE: User endpoint now returns different JSON structure.
Migration guide available in docs/migration.md"

# Multi-line commits
git commit -m "feat(payment): integrate Stripe payment processing

- Add Stripe SDK integration
- Implement payment webhooks
- Add payment status tracking
- Update database schema for transactions

Closes #123"
```

### Git Hooks

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Run linting
if ! flake8 .; then
    echo "❌ Linting failed"
    exit 1
fi

# Run type checking
if ! mypy src/; then
    echo "❌ Type checking failed"
    exit 1
fi

# Run tests
if ! pytest tests/unit/ -q; then
    echo "❌ Unit tests failed"
    exit 1
fi

# Check for secrets
if grep -r "api_key\|password\|secret" --include="*.py" --include="*.js" .; then
    echo "❌ Potential secrets found in code"
    exit 1
fi

echo "✅ All pre-commit checks passed"
exit 0
```

```bash
#!/bin/sh
# .git/hooks/commit-msg

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format"
    echo "Format: <type>(<scope>): <description>"
    echo "Example: feat(auth): add user login"
    exit 1
fi

echo "✅ Commit message format is valid"
exit 0
```

## Pipeline Automation

### Multi-Environment Pipeline

```yaml
# .github/workflows/multi-env-pipeline.yml
name: Multi-Environment Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-type: [unit, integration, e2e]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup test environment
      run: |
        if [ "${{ matrix.test-type }}" = "integration" ]; then
          docker-compose -f docker-compose.test.yml up -d
          sleep 30  # Wait for services to start
        elif [ "${{ matrix.test-type }}" = "e2e" ]; then
          docker-compose -f docker-compose.e2e.yml up -d
          sleep 60  # Wait for full stack
        fi
    
    - name: Run ${{ matrix.test-type }} tests
      run: |
        case "${{ matrix.test-type }}" in
          unit)
            pytest tests/unit/ --cov --cov-report=xml
            ;;
          integration)
            pytest tests/integration/ --timeout=300
            ;;
          e2e)
            pytest tests/e2e/ --browser=chrome --headless
            ;;
        esac
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results-${{ matrix.test-type }}
        path: |
          test-results.xml
          coverage.xml
          screenshots/

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
    
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  deploy-dev:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
    - name: Deploy to development
      run: |
        echo "Deploying to development environment"
        # kubectl apply -f k8s/development/
        # helm upgrade --install myapp ./chart --namespace dev

  deploy-staging:
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment"
        # deployment commands
    
    - name: Run staging tests
      run: |
        ./scripts/staging-tests.sh
    
    - name: Performance tests
      run: |
        # Run load tests against staging
        artillery run tests/performance/load-test.yml

  deploy-production:
    needs: [build-and-push, deploy-staging]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Manual approval required
      uses: trstringer/manual-approval@v1
      with:
        secret: ${{ github.TOKEN }}
        approvers: team-leads
        minimum-approvals: 2
    
    - name: Blue-Green deployment
      run: |
        ./scripts/blue-green-deploy.sh ${{ needs.build-and-push.outputs.image-tag }}
```

### Automated Testing Pipeline

```python
# scripts/test-automation-pipeline.py
import subprocess
import sys
import json
import time
from typing import Dict, List, Any

class TestPipeline:
    def __init__(self):
        self.results = {
            "unit_tests": None,
            "integration_tests": None,
            "security_scan": None,
            "performance_tests": None,
            "e2e_tests": None
        }
    
    def run_unit_tests(self) -> Dict[str, Any]:
        """Run unit tests with coverage"""
        print("🧪 Running unit tests...")
        
        cmd = [
            "pytest", "tests/unit/",
            "--cov=src",
            "--cov-report=json",
            "--cov-fail-under=80",
            "--junitxml=unit-test-results.xml"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Parse coverage report
        try:
            with open("coverage.json", "r") as f:
                coverage_data = json.load(f)
                coverage_percent = coverage_data["totals"]["percent_covered"]
        except FileNotFoundError:
            coverage_percent = 0
        
        return {
            "passed": result.returncode == 0,
            "coverage": coverage_percent,
            "output": result.stdout,
            "errors": result.stderr
        }
    
    def run_integration_tests(self) -> Dict[str, Any]:
        """Run integration tests"""
        print("🔗 Running integration tests...")
        
        # Start test dependencies
        subprocess.run(["docker-compose", "-f", "docker-compose.test.yml", "up", "-d"])
        time.sleep(30)  # Wait for services
        
        try:
            cmd = ["pytest", "tests/integration/", "--timeout=300"]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            return {
                "passed": result.returncode == 0,
                "output": result.stdout,
                "errors": result.stderr
            }
        finally:
            # Cleanup
            subprocess.run(["docker-compose", "-f", "docker-compose.test.yml", "down"])
    
    def run_security_scan(self) -> Dict[str, Any]:
        """Run security vulnerability scan"""
        print("🔒 Running security scan...")
        
        # SAST (Static Application Security Testing)
        bandit_cmd = ["bandit", "-r", "src/", "-f", "json"]
        bandit_result = subprocess.run(bandit_cmd, capture_output=True, text=True)
        
        # Dependency vulnerability scan
        safety_cmd = ["safety", "check", "--json"]
        safety_result = subprocess.run(safety_cmd, capture_output=True, text=True)
        
        vulnerabilities = []
        if bandit_result.stdout:
            bandit_data = json.loads(bandit_result.stdout)
            vulnerabilities.extend(bandit_data.get("results", []))
        
        return {
            "passed": len(vulnerabilities) == 0,
            "vulnerabilities": vulnerabilities,
            "bandit_output": bandit_result.stdout,
            "safety_output": safety_result.stdout
        }
    
    def run_performance_tests(self) -> Dict[str, Any]:
        """Run performance tests"""
        print("⚡ Running performance tests...")
        
        cmd = ["locust", "-f", "tests/performance/locustfile.py", "--headless", 
               "-u", "100", "-r", "10", "-t", "60s", "--html", "performance-report.html"]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        return {
            "passed": result.returncode == 0,
            "output": result.stdout,
            "errors": result.stderr
        }
    
    def run_e2e_tests(self) -> Dict[str, Any]:
        """Run end-to-end tests"""
        print("🌐 Running E2E tests...")
        
        cmd = ["pytest", "tests/e2e/", "--browser=chrome", "--headless"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        return {
            "passed": result.returncode == 0,
            "output": result.stdout,
            "errors": result.stderr
        }
    
    def generate_report(self) -> str:
        """Generate test pipeline report"""
        total_tests = len(self.results)
        passed_tests = sum(1 for result in self.results.values() 
                          if result and result.get("passed", False))
        
        report = f"""
# Test Pipeline Report

## Summary
- **Total Test Suites:** {total_tests}
- **Passed:** {passed_tests}
- **Failed:** {total_tests - passed_tests}
- **Success Rate:** {(passed_tests/total_tests)*100:.1f}%

## Detailed Results
"""
        
        for test_type, result in self.results.items():
            status = "✅ PASSED" if result and result.get("passed") else "❌ FAILED"
            report += f"\n### {test_type.replace('_', ' ').title()}\n"
            report += f"**Status:** {status}\n"
            
            if test_type == "unit_tests" and result:
                report += f"**Coverage:** {result.get('coverage', 0):.1f}%\n"
            
            if test_type == "security_scan" and result:
                vuln_count = len(result.get("vulnerabilities", []))
                report += f"**Vulnerabilities Found:** {vuln_count}\n"
        
        return report
    
    def run_pipeline(self) -> bool:
        """Run complete test pipeline"""
        print("🚀 Starting test pipeline...")
        
        # Run all test suites
        self.results["unit_tests"] = self.run_unit_tests()
        self.results["integration_tests"] = self.run_integration_tests()
        self.results["security_scan"] = self.run_security_scan()
        self.results["performance_tests"] = self.run_performance_tests()
        self.results["e2e_tests"] = self.run_e2e_tests()
        
        # Generate report
        report = self.generate_report()
        with open("test-pipeline-report.md", "w") as f:
            f.write(report)
        
        print(report)
        
        # Return overall success
        return all(result and result.get("passed", False) 
                  for result in self.results.values())

if __name__ == "__main__":
    pipeline = TestPipeline()
    success = pipeline.run_pipeline()
    sys.exit(0 if success else 1)
```

## Rollback Strategies

### Blue-Green Deployment with Rollback

```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

set -e

APP_NAME="myapp"
NAMESPACE="production"
NEW_VERSION="$1"

if [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

echo "🚀 Starting blue-green deployment for $APP_NAME:$NEW_VERSION"

# Determine current active environment
CURRENT_ACTIVE=$(kubectl get service "$APP_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.selector.version}')
echo "Current active version: $CURRENT_ACTIVE"

# Determine target environment
if [ "$CURRENT_ACTIVE" = "blue" ]; then
    TARGET_ENV="green"
    INACTIVE_ENV="blue"
else
    TARGET_ENV="blue"
    INACTIVE_ENV="green"
fi

echo "Deploying to $TARGET_ENV environment"

# Deploy new version to inactive environment
helm upgrade --install "$APP_NAME-$TARGET_ENV" ./helm-chart \
    --namespace "$NAMESPACE" \
    --set environment="$TARGET_ENV" \
    --set image.tag="$NEW_VERSION" \
    --set service.selector.version="$TARGET_ENV" \
    --wait --timeout=10m

echo "✅ Deployed $NEW_VERSION to $TARGET_ENV environment"

# Health check
echo "🔍 Running health checks..."
TARGET_SERVICE="$APP_NAME-$TARGET_ENV"
HEALTH_URL="http://$TARGET_SERVICE.$NAMESPACE.svc.cluster.local/health"

for i in {1..30}; do
    if kubectl run health-check-$i --rm -i --restart=Never --image=curlimages/curl -- \
        curl -f "$HEALTH_URL" > /dev/null 2>&1; then
        echo "✅ Health check passed"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo "❌ Health check failed after 30 attempts"
        echo "🔄 Rolling back..."
        helm uninstall "$APP_NAME-$TARGET_ENV" -n "$NAMESPACE"
        exit 1
    fi
    
    echo "Health check attempt $i failed, retrying in 10s..."
    sleep 10
done

# Smoke tests
echo "🧪 Running smoke tests..."
if ! ./scripts/smoke-tests.sh "$TARGET_SERVICE.$NAMESPACE.svc.cluster.local"; then
    echo "❌ Smoke tests failed"
    echo "🔄 Rolling back..."
    helm uninstall "$APP_NAME-$TARGET_ENV" -n "$NAMESPACE"
    exit 1
fi

echo "✅ Smoke tests passed"

# Switch traffic to new environment
echo "🔄 Switching traffic to $TARGET_ENV"
kubectl patch service "$APP_NAME" -n "$NAMESPACE" -p \
    "{\"spec\":{\"selector\":{\"version\":\"$TARGET_ENV\"}}}"

# Wait for traffic switch
sleep 30

# Final verification
echo "🔍 Final verification..."
if ! ./scripts/production-health-check.sh; then
    echo "❌ Production health check failed"
    echo "🔄 Rolling back traffic..."
    kubectl patch service "$APP_NAME" -n "$NAMESPACE" -p \
        "{\"spec\":{\"selector\":{\"version\":\"$INACTIVE_ENV\"}}}"
    exit 1
fi

echo "✅ Traffic switched successfully"

# Cleanup old environment (optional)
read -p "Remove old $INACTIVE_ENV environment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    helm uninstall "$APP_NAME-$INACTIVE_ENV" -n "$NAMESPACE"
    echo "✅ Cleaned up $INACTIVE_ENV environment"
fi

echo "🎉 Blue-green deployment completed successfully!"
```

### Database Migration Rollback

```python
# scripts/database_migration_rollback.py
import psycopg2
import logging
from typing import List, Dict
import json
from datetime import datetime

class DatabaseMigrationManager:
    def __init__(self, connection_string: str):
        self.conn = psycopg2.connect(connection_string)
        self.conn.autocommit = False
        self.logger = logging.getLogger(__name__)
    
    def create_backup(self, backup_name: str) -> str:
        """Create database backup before migration"""
        cursor = self.conn.cursor()
        
        backup_file = f"backup_{backup_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.sql"
        
        # Create backup using pg_dump
        import subprocess
        cmd = f"pg_dump {self.connection_string} > {backup_file}"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode != 0:
            raise Exception(f"Backup failed: {result.stderr}")
        
        self.logger.info(f"Backup created: {backup_file}")
        return backup_file
    
    def record_migration(self, migration_id: str, description: str, rollback_sql: str):
        """Record migration in migration log"""
        cursor = self.conn.cursor()
        
        cursor.execute("""
            INSERT INTO migration_log (migration_id, description, rollback_sql, applied_at)
            VALUES (%s, %s, %s, %s)
        """, (migration_id, description, rollback_sql, datetime.now()))
        
        self.conn.commit()
    
    def rollback_migration(self, migration_id: str) -> bool:
        """Rollback specific migration"""
        cursor = self.conn.cursor()
        
        try:
            # Get rollback SQL
            cursor.execute("""
                SELECT rollback_sql FROM migration_log 
                WHERE migration_id = %s AND rolled_back = FALSE
                ORDER BY applied_at DESC LIMIT 1
            """, (migration_id,))
            
            result = cursor.fetchone()
            if not result:
                self.logger.error(f"No migration found with ID: {migration_id}")
                return False
            
            rollback_sql = result[0]
            
            # Execute rollback
            cursor.execute(rollback_sql)
            
            # Mark as rolled back
            cursor.execute("""
                UPDATE migration_log 
                SET rolled_back = TRUE, rolled_back_at = %s
                WHERE migration_id = %s
            """, (datetime.now(), migration_id))
            
            self.conn.commit()
            self.logger.info(f"Successfully rolled back migration: {migration_id}")
            return True
            
        except Exception as e:
            self.conn.rollback()
            self.logger.error(f"Rollback failed: {str(e)}")
            return False
    
    def rollback_to_version(self, target_version: str) -> bool:
        """Rollback all migrations after target version"""
        cursor = self.conn.cursor()
        
        try:
            # Get migrations to rollback (in reverse order)
            cursor.execute("""
                SELECT migration_id, rollback_sql FROM migration_log 
                WHERE version > %s AND rolled_back = FALSE
                ORDER BY applied_at DESC
            """, (target_version,))
            
            migrations = cursor.fetchall()
            
            for migration_id, rollback_sql in migrations:
                cursor.execute(rollback_sql)
                cursor.execute("""
                    UPDATE migration_log 
                    SET rolled_back = TRUE, rolled_back_at = %s
                    WHERE migration_id = %s
                """, (datetime.now(), migration_id))
                
                self.logger.info(f"Rolled back migration: {migration_id}")
            
            self.conn.commit()
            return True
            
        except Exception as e:
            self.conn.rollback()
            self.logger.error(f"Rollback to version {target_version} failed: {str(e)}")
            return False
```

## Interview Questions

### Common CI/CD Interview Questions

**Q1: What's the difference between CI, CD (Continuous Delivery), and CD (Continuous Deployment)?**

**Answer:**
- **Continuous Integration (CI):** Automatically building, testing, and integrating code changes frequently
- **Continuous Delivery:** Automatically deploying to staging/pre-production environments; production deployment requires manual approval
- **Continuous Deployment:** Automatically deploying to production after all automated tests pass

**Q2: How do you handle secrets in CI/CD pipelines?**

**Answer:**
```yaml
# GitHub Actions example
- name: Deploy application
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    # Never log secrets
    echo "Deploying application..."
    
# Best practices:
# 1. Use secret management systems (HashiCorp Vault, AWS Secrets Manager)
# 2. Rotate secrets regularly
# 3. Use environment-specific secrets
# 4. Never commit secrets to code
# 5. Use least privilege principle
```

**Q3: How do you implement zero-downtime deployments?**

**Answer:**
Strategies include:
1. **Blue-Green Deployment:** Maintain two identical environments, switch traffic
2. **Rolling Updates:** Gradually replace instances
3. **Canary Deployments:** Route small percentage of traffic to new version
4. **Feature Flags:** Control feature rollout without redeployment

**Q4: How do you handle database migrations in CI/CD?**

**Answer:**
```python
# Migration strategy:
# 1. Backward-compatible migrations
# 2. Multi-phase approach for breaking changes
# 3. Always create backups before migrations
# 4. Test migrations on production-like data

def safe_migration_strategy():
    # Phase 1: Add new column (nullable)
    # Phase 2: Populate data in new column
    # Phase 3: Make column non-nullable
    # Phase 4: Remove old column (separate deployment)
    pass
```

**Q5: How do you monitor and alert on pipeline failures?**

**Answer:**
```yaml
# Multi-channel alerting
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    channel: '#alerts'
    
# Metrics to monitor:
# - Build success rate
# - Build duration trends
# - Test failure patterns
# - Deployment frequency
# - Lead time for changes
# - Mean time to recovery (MTTR)
```

**Q6: How do you handle flaky tests in CI/CD?**

**Answer:**
```python
# Strategies:
# 1. Test retries with backoff
@pytest.mark.flaky(reruns=3, reruns_delay=2)
def test_api_endpoint():
    pass

# 2. Better test isolation
# 3. Quarantine flaky tests
# 4. Regular flaky test analysis
# 5. Environment stability improvements
```

**Q7: What's your approach to testing in CI/CD pipelines?**

**Answer:**
```yaml
# Test pyramid in CI/CD:
# 1. Unit tests (fast, many)
# 2. Integration tests (medium, some)
# 3. E2E tests (slow, few)

# Parallel testing:
strategy:
  matrix:
    test-type: [unit, integration, contract, e2e]
    
# Fail-fast principle:
# Stop pipeline early on critical test failures
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is CI/CD? | Continuous Integration/Continuous Deployment - automated building, testing, and deployment |
| 2 | Easy | What is DevOps? | Culture and practices bridging development and operations for faster, reliable delivery |
| 3 | Easy | What is version control? | System tracking changes to files over time, enabling collaboration and history |
| 4 | Easy | What is Git? | Distributed version control system for tracking changes in source code |
| 5 | Easy | What is a Git commit? | Snapshot of changes saved to repository with message describing changes |
| 6 | Easy | What is a Git branch? | Parallel line of development allowing isolated work on features |
| 7 | Easy | What is Git merge? | Combining changes from different branches into single branch |
| 8 | Easy | What is pull request? | Request to merge changes from one branch to another with review process |
| 9 | Easy | What is pipeline? | Automated sequence of stages for building, testing, and deploying code |
| 10 | Easy | What is build automation? | Automatically compiling, testing, and packaging code without manual intervention |
| 11 | Easy | What is Jenkins? | Open-source automation server for building CI/CD pipelines |
| 12 | Easy | What is GitHub Actions? | CI/CD platform integrated with GitHub for automating workflows |
| 13 | Easy | What is artifact? | Deployable unit produced by build process (JAR, Docker image, etc.) |
| 14 | Easy | What is deployment? | Process of releasing application to target environment |
| 15 | Easy | What is rollback? | Reverting to previous version after deployment issues |
| 16 | Medium | What is blue-green deployment? | Deployment strategy using two identical environments for zero-downtime releases |
| 17 | Medium | What is canary deployment? | Gradual rollout to small subset of users before full deployment |
| 18 | Medium | What is rolling deployment? | Gradually replacing instances one at a time |
| 19 | Medium | What is feature flag? | Toggle mechanism to enable/disable features without code deployment |
| 20 | Medium | What is GitFlow? | Branching model with specific branches for features, releases, hotfixes |
| 21 | Medium | What is trunk-based development? | Practice where developers integrate small changes frequently to main branch |
| 22 | Medium | What is Git rebase? | Reapplying commits on top of another base tip, creating linear history |
| 23 | Medium | What is Git cherry-pick? | Applying specific commit from one branch to another |
| 24 | Medium | What is webhook? | HTTP callback triggered by events in external system |
| 25 | Medium | What is pipeline as code? | Defining CI/CD pipelines using code files versioned with application |
| 26 | Medium | What is infrastructure as code? | Managing infrastructure through code rather than manual processes |
| 27 | Medium | What is configuration management? | Automating system configuration using tools like Ansible, Puppet |
| 28 | Medium | What is environment promotion? | Moving code through environments: dev → test → staging → production |
| 29 | Medium | What is automated testing in CI/CD? | Running tests automatically as part of pipeline to catch issues early |
| 30 | Medium | What is build matrix? | Testing across multiple configurations (OS, language versions, etc.) |
| 31 | Hard | How to handle secrets in CI/CD? | Use secret management tools, encrypted variables, separate secret stores |
| 32 | Hard | What is drift detection? | Identifying differences between desired and actual infrastructure state |
| 33 | Hard | How to implement approval workflows? | Use manual approval gates, required reviewers, environment-specific approvals |
| 34 | Hard | What is multi-stage pipeline? | Pipeline with distinct stages like build, test, security scan, deploy |
| 35 | Hard | How to handle database migrations in CI/CD? | Version migrations, rollback scripts, testing with data copies |
| 36 | Hard | What is parallel vs serial pipeline execution? | Running stages simultaneously vs sequentially based on dependencies |
| 37 | Hard | How to implement chaos engineering in CI/CD? | Automated failure injection to test system resilience |
| 38 | Hard | What is pipeline optimization? | Reducing build times through caching, parallelization, efficient resource usage |
| 39 | Hard | How to handle cross-service dependencies? | Dependency management, service contracts, integration testing |
| 40 | Hard | What is progressive delivery? | Advanced deployment with feature flags, monitoring, automated rollback |
| 41 | Hard | How to implement compliance in CI/CD? | Audit trails, security scanning, policy enforcement, documentation |
| 42 | Hard | What is GitOps? | Operational paradigm using Git as single source of truth for declarative infrastructure |
| 43 | Hard | How to handle monorepo CI/CD? | Path-based triggers, selective builds, dependency management |
| 44 | Hard | What is pipeline security? | Securing build process, scanning dependencies, protecting secrets |
| 45 | Hard | How to implement disaster recovery for CI/CD? | Backup strategies, multi-region setup, recovery procedures |
| 46 | Expert | What is continuous compliance? | Automated compliance checking throughout development lifecycle |
| 47 | Expert | How to implement advanced monitoring in CI/CD? | Pipeline metrics, build health monitoring, predictive analytics |
| 48 | Expert | What is value stream mapping? | Analyzing flow from code commit to production delivery |
| 49 | Expert | How to handle enterprise CI/CD at scale? | Federated models, standardization, governance, self-service |
| 50 | Expert | What is continuous security? | Integrating security practices throughout CI/CD pipeline |
| 51 | Expert | How to implement AI/ML in CI/CD? | Intelligent test selection, predictive failure analysis, automated optimization |
| 52 | Expert | What is immutable infrastructure? | Infrastructure components never modified after deployment |
| 53 | Expert | How to handle legacy system integration? | Gradual modernization, API wrappers, strangler fig pattern |
| 54 | Expert | What is pipeline orchestration? | Coordinating complex workflows across multiple systems and teams |
| 55 | Expert | How to measure DevOps success? | DORA metrics: deployment frequency, lead time, MTTR, change failure rate |
