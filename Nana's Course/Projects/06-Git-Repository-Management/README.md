# Git Repository Management & Collaboration Project

## Project Overview
This project implements a comprehensive Git repository management system with advanced workflows, automated processes, and collaboration tools for enterprise DevOps environments.

## Architecture

```
Git Management Platform
├── Repository Templates
├── Workflow Automation
├── Code Quality Gates
├── Security Scanning
├── Collaboration Tools
└── Analytics Dashboard
```

## Project Structure

```
git-management-project/
├── templates/
│   ├── repository-templates/
│   ├── workflow-templates/
│   └── hook-templates/
├── automation/
│   ├── git-hooks/
│   ├── scripts/
│   └── ci-cd/
├── security/
│   ├── scanning/
│   ├── secrets-detection/
│   └── access-control/
├── monitoring/
│   ├── analytics/
│   ├── reporting/
│   └── alerts/
└── docs/
    ├── guidelines/
    ├── procedures/
    └── training/
```

## Implementation

### 1. Repository Templates

#### Standard Repository Template
```bash
#!/bin/bash
# scripts/create-repo-template.sh

create_repository_template() {
    local repo_name=$1
    local repo_type=$2
    
    echo "Creating repository template: $repo_name"
    
    # Initialize repository
    git init $repo_name
    cd $repo_name
    
    # Create standard structure
    mkdir -p {src,tests,docs,scripts,config}
    
    # Create standard files
    create_gitignore $repo_type
    create_readme $repo_name
    create_contributing_guidelines
    create_code_of_conduct
    create_license
    
    # Setup Git hooks
    setup_git_hooks
    
    # Initial commit
    git add .
    git commit -m "chore: initial repository setup"
    
    echo "Repository template created successfully"
}

create_gitignore() {
    local repo_type=$1
    
    cat > .gitignore << EOF
# Dependencies
node_modules/
vendor/
*.egg-info/

# Build outputs
dist/
build/
target/
*.jar
*.war

# Environment files
.env
.env.local
.env.production
*.key

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/
npm-debug.log*

# Runtime data
pids/
*.pid
*.seed

# Coverage directory used by tools like istanbul
coverage/
*.coverage

# Temporary files
tmp/
temp/
EOF

    # Add language-specific ignores
    case $repo_type in
        "python")
            echo "__pycache__/" >> .gitignore
            echo "*.pyc" >> .gitignore
            echo ".pytest_cache/" >> .gitignore
            ;;
        "nodejs")
            echo "npm-debug.log*" >> .gitignore
            echo ".npm" >> .gitignore
            ;;
        "java")
            echo "*.class" >> .gitignore
            echo ".gradle/" >> .gitignore
            ;;
    esac
}

create_readme() {
    local repo_name=$1
    
    cat > README.md << EOF
# $repo_name

## Description
Brief description of the project.

## Getting Started

### Prerequisites
- List prerequisites here

### Installation
\`\`\`bash
# Installation commands
\`\`\`

### Usage
\`\`\`bash
# Usage examples
\`\`\`

## Development

### Setup Development Environment
\`\`\`bash
# Development setup commands
\`\`\`

### Running Tests
\`\`\`bash
# Test commands
\`\`\`

## Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
EOF
}

create_contributing_guidelines() {
    cat > CONTRIBUTING.md << EOF
# Contributing Guidelines

## Getting Started
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Submit a pull request

## Code Style
- Follow the established coding standards
- Use meaningful commit messages
- Write clear documentation

## Pull Request Process
1. Ensure all tests pass
2. Update documentation as needed
3. Request review from maintainers
4. Address review feedback

## Commit Message Format
\`\`\`
type(scope): description

[optional body]

[optional footer]
\`\`\`

### Types
- feat: A new feature
- fix: A bug fix
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code
- refactor: A code change that neither fixes a bug nor adds a feature
- test: Adding missing tests
- chore: Changes to the build process or auxiliary tools
EOF
}
```

### 2. Git Hooks Implementation

#### Pre-commit Hook
```bash
#!/bin/bash
# hooks/pre-commit

echo "Running pre-commit checks..."

# Check for secrets
if command -v git-secrets >/dev/null 2>&1; then
    echo "Checking for secrets..."
    git secrets --scan
    if [ $? -ne 0 ]; then
        echo "❌ Secrets detected! Commit aborted."
        exit 1
    fi
    echo "✅ No secrets detected"
fi

# Run linting
if [ -f "package.json" ]; then
    echo "Running JavaScript/TypeScript linting..."
    npm run lint
    if [ $? -ne 0 ]; then
        echo "❌ Linting failed! Commit aborted."
        exit 1
    fi
    echo "✅ Linting passed"
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "Running Python linting..."
    if command -v black >/dev/null 2>&1; then
        black --check .
        if [ $? -ne 0 ]; then
            echo "❌ Python formatting check failed! Run 'black .' to fix."
            exit 1
        fi
    fi
    
    if command -v flake8 >/dev/null 2>&1; then
        flake8 .
        if [ $? -ne 0 ]; then
            echo "❌ Python linting failed!"
            exit 1
        fi
    fi
    echo "✅ Python checks passed"
fi

# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'
commit_message=$(cat .git/COMMIT_EDITMSG)

if ! echo "$commit_message" | grep -qE "$commit_regex"; then
    echo "❌ Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Example: feat(auth): add user authentication"
    exit 1
fi

echo "✅ All pre-commit checks passed"
exit 0
```

#### Pre-push Hook
```bash
#!/bin/bash
# hooks/pre-push

echo "Running pre-push checks..."

# Run tests
if [ -f "package.json" ]; then
    echo "Running JavaScript/TypeScript tests..."
    npm test
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed! Push aborted."
        exit 1
    fi
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "Running Python tests..."
    if command -v pytest >/dev/null 2>&1; then
        pytest
        if [ $? -ne 0 ]; then
            echo "❌ Python tests failed! Push aborted."
            exit 1
        fi
    fi
fi

# Security scan
if command -v safety >/dev/null 2>&1; then
    echo "Running security scan..."
    safety check
    if [ $? -ne 0 ]; then
        echo "❌ Security vulnerabilities detected! Push aborted."
        exit 1
    fi
fi

echo "✅ All pre-push checks passed"
exit 0
```

### 3. Workflow Automation

#### GitHub Actions Workflow
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.9'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run linting
        run: npm run lint
        
      - name: Run prettier check
        run: npm run prettier:check

  test:
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info

  security:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Run security audit
        run: npm audit --audit-level=moderate
        
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  build:
    runs-on: ubuntu-latest
    needs: [lint, test, security]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build application
        run: npm run build
        
      - name: Build Docker image
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker tag myapp:${{ github.sha }} myapp:latest
          
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
          docker push myapp:latest

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
          # Deployment commands here
```

### 4. Branch Protection Rules

#### Setup Script
```bash
#!/bin/bash
# scripts/setup-branch-protection.sh

setup_branch_protection() {
    local repo_owner=$1
    local repo_name=$2
    local token=$3
    
    echo "Setting up branch protection for $repo_owner/$repo_name"
    
    # Main branch protection
    curl -X PUT \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$repo_owner/$repo_name/branches/main/protection" \
        -d '{
            "required_status_checks": {
                "strict": true,
                "contexts": ["ci/lint", "ci/test", "ci/security"]
            },
            "enforce_admins": true,
            "required_pull_request_reviews": {
                "required_approving_review_count": 2,
                "dismiss_stale_reviews": true,
                "require_code_owner_reviews": true
            },
            "restrictions": null,
            "allow_force_pushes": false,
            "allow_deletions": false
        }'
    
    echo "Branch protection rules applied"
}

# Usage: ./setup-branch-protection.sh owner repo-name github-token
setup_branch_protection $1 $2 $3
```

### 5. Code Quality Gates

#### Quality Gate Script
```bash
#!/bin/bash
# scripts/quality-gate.sh

run_quality_gate() {
    local threshold_coverage=80
    local max_complexity=10
    
    echo "Running quality gate checks..."
    
    # Code coverage check
    coverage=$(npm run coverage:report | grep "All files" | awk '{print $4}' | sed 's/%//')
    if (( $(echo "$coverage < $threshold_coverage" | bc -l) )); then
        echo "❌ Code coverage ($coverage%) below threshold ($threshold_coverage%)"
        exit 1
    fi
    echo "✅ Code coverage: $coverage%"
    
    # Complexity check
    complexity=$(npm run complexity:report | grep "Average complexity" | awk '{print $3}')
    if (( $(echo "$complexity > $max_complexity" | bc -l) )); then
        echo "❌ Code complexity ($complexity) above threshold ($max_complexity)"
        exit 1
    fi
    echo "✅ Code complexity: $complexity"
    
    # Security vulnerabilities
    vulnerabilities=$(npm audit --json | jq '.metadata.vulnerabilities.total')
    if [ "$vulnerabilities" -gt 0 ]; then
        echo "❌ Security vulnerabilities found: $vulnerabilities"
        exit 1
    fi
    echo "✅ No security vulnerabilities"
    
    # Technical debt
    debt_ratio=$(sonar-scanner | grep "Technical Debt Ratio" | awk '{print $4}' | sed 's/%//')
    if (( $(echo "$debt_ratio > 5" | bc -l) )); then
        echo "❌ Technical debt ratio ($debt_ratio%) above threshold (5%)"
        exit 1
    fi
    echo "✅ Technical debt ratio: $debt_ratio%"
    
    echo "✅ All quality gates passed"
}

run_quality_gate
```

### 6. Automated Release Management

#### Release Script
```bash
#!/bin/bash
# scripts/release.sh

create_release() {
    local version_type=$1  # major, minor, patch
    
    echo "Creating release..."
    
    # Ensure we're on main branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        echo "❌ Must be on main branch for release"
        exit 1
    fi
    
    # Ensure clean working directory
    if [ -n "$(git status --porcelain)" ]; then
        echo "❌ Working directory must be clean"
        exit 1
    fi
    
    # Pull latest changes
    git pull origin main
    
    # Run tests
    npm test
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed"
        exit 1
    fi
    
    # Bump version
    npm version $version_type --no-git-tag-version
    new_version=$(node -p "require('./package.json').version")
    
    # Update changelog
    generate_changelog $new_version
    
    # Commit changes
    git add .
    git commit -m "chore: release v$new_version"
    
    # Create tag
    git tag -a "v$new_version" -m "Release v$new_version"
    
    # Push changes and tag
    git push origin main
    git push origin "v$new_version"
    
    # Create GitHub release
    create_github_release $new_version
    
    echo "✅ Release v$new_version created successfully"
}

generate_changelog() {
    local version=$1
    local date=$(date +%Y-%m-%d)
    
    echo "## [$version] - $date" > CHANGELOG.tmp
    echo "" >> CHANGELOG.tmp
    
    # Get commits since last tag
    last_tag=$(git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "")
    if [ -n "$last_tag" ]; then
        git log --pretty=format:"- %s" $last_tag..HEAD >> CHANGELOG.tmp
    else
        git log --pretty=format:"- %s" >> CHANGELOG.tmp
    fi
    
    echo "" >> CHANGELOG.tmp
    echo "" >> CHANGELOG.tmp
    
    # Prepend to existing changelog
    if [ -f CHANGELOG.md ]; then
        cat CHANGELOG.md >> CHANGELOG.tmp
    fi
    
    mv CHANGELOG.tmp CHANGELOG.md
}

create_github_release() {
    local version=$1
    local token=$GITHUB_TOKEN
    
    if [ -z "$token" ]; then
        echo "⚠️  GITHUB_TOKEN not set, skipping GitHub release"
        return
    fi
    
    # Extract changelog for this version
    changelog=$(sed -n "/## \[$version\]/,/## \[/p" CHANGELOG.md | head -n -1)
    
    curl -X POST \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/releases" \
        -d "{
            \"tag_name\": \"v$version\",
            \"target_commitish\": \"main\",
            \"name\": \"Release v$version\",
            \"body\": \"$changelog\",
            \"draft\": false,
            \"prerelease\": false
        }"
}

# Usage: ./release.sh [major|minor|patch]
create_release ${1:-patch}
```

### 7. Monitoring and Analytics

#### Git Analytics Script
```python
#!/usr/bin/env python3
# scripts/git-analytics.py

import subprocess
import json
import datetime
from collections import defaultdict

class GitAnalytics:
    def __init__(self, repo_path="."):
        self.repo_path = repo_path
        
    def get_commit_stats(self, since_days=30):
        """Get commit statistics for the last N days"""
        since_date = (datetime.datetime.now() - datetime.timedelta(days=since_days)).strftime("%Y-%m-%d")
        
        cmd = f'git log --since="{since_date}" --pretty=format:"%an|%ad|%s" --date=short'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        commits = []
        authors = defaultdict(int)
        daily_commits = defaultdict(int)
        
        for line in result.stdout.strip().split('\n'):
            if line:
                author, date, message = line.split('|', 2)
                commits.append({
                    'author': author,
                    'date': date,
                    'message': message
                })
                authors[author] += 1
                daily_commits[date] += 1
        
        return {
            'total_commits': len(commits),
            'commits_by_author': dict(authors),
            'daily_commits': dict(daily_commits),
            'commits': commits
        }
    
    def get_branch_stats(self):
        """Get branch statistics"""
        # Active branches
        cmd = "git branch -r --format='%(refname:short)|%(committerdate:short)'"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        branches = []
        for line in result.stdout.strip().split('\n'):
            if line and 'origin/HEAD' not in line:
                branch, last_commit = line.split('|', 1)
                branches.append({
                    'name': branch.replace('origin/', ''),
                    'last_commit_date': last_commit
                })
        
        return {
            'total_branches': len(branches),
            'branches': branches
        }
    
    def get_file_stats(self):
        """Get file change statistics"""
        cmd = "git log --name-only --pretty=format: | sort | uniq -c | sort -rn"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        files = []
        for line in result.stdout.strip().split('\n')[:20]:  # Top 20
            if line.strip():
                count, filename = line.strip().split(None, 1)
                files.append({
                    'filename': filename,
                    'changes': int(count)
                })
        
        return {
            'most_changed_files': files
        }
    
    def generate_report(self):
        """Generate comprehensive analytics report"""
        commit_stats = self.get_commit_stats()
        branch_stats = self.get_branch_stats()
        file_stats = self.get_file_stats()
        
        report = {
            'generated_at': datetime.datetime.now().isoformat(),
            'commit_statistics': commit_stats,
            'branch_statistics': branch_stats,
            'file_statistics': file_stats
        }
        
        return report
    
    def save_report(self, filename='git-analytics.json'):
        """Save analytics report to file"""
        report = self.generate_report()
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"Analytics report saved to {filename}")

if __name__ == "__main__":
    analytics = GitAnalytics()
    analytics.save_report()
    
    # Print summary
    report = analytics.generate_report()
    print("\n=== Git Analytics Summary ===")
    print(f"Total commits (last 30 days): {report['commit_statistics']['total_commits']}")
    print(f"Total branches: {report['branch_statistics']['total_branches']}")
    print(f"Top contributors: {list(report['commit_statistics']['commits_by_author'].keys())[:5]}")
```

## Deployment Instructions

### 1. Environment Setup
```bash
# Clone the project
git clone <repository-url>
cd git-management-project

# Install dependencies
npm install

# Setup Git hooks
./scripts/setup-hooks.sh

# Configure environment
cp .env.example .env
# Edit .env with your settings
```

### 2. Repository Template Usage
```bash
# Create new repository from template
./scripts/create-repo-template.sh my-new-project nodejs

# Setup branch protection
./scripts/setup-branch-protection.sh myorg my-new-project $GITHUB_TOKEN
```

### 3. CI/CD Integration
```bash
# Setup GitHub Actions
mkdir -p .github/workflows
cp templates/workflow-templates/ci-cd.yml .github/workflows/

# Configure secrets in GitHub:
# - DOCKER_USERNAME
# - DOCKER_PASSWORD
# - SNYK_TOKEN
```

## Expected Outcomes

1. **Standardized Repository Structure**: All repositories follow consistent patterns
2. **Automated Quality Gates**: Code quality maintained through automated checks
3. **Enhanced Security**: Secrets detection and security scanning integrated
4. **Streamlined Collaboration**: Standardized workflows for all team members
5. **Comprehensive Monitoring**: Analytics and insights into development patterns
6. **Automated Releases**: Consistent and reliable release management

## Technologies Used

- **Git**: Version control system
- **GitHub Actions**: CI/CD automation
- **Node.js**: Scripting and automation
- **Python**: Analytics and reporting
- **Docker**: Containerization
- **Bash**: Shell scripting
- **JSON/YAML**: Configuration management

This project provides a complete Git management platform that can be adapted for any organization's needs while maintaining best practices and security standards.
