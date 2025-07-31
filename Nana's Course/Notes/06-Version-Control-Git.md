# Version Control & Git - Comprehensive Notes

## Table of Contents
1. [Introduction to Version Control](#introduction)
2. [Git Fundamentals](#git-fundamentals)
3. [Git Workflow](#git-workflow)
4. [Branching Strategies](#branching-strategies)
5. [Collaboration & Remote Repositories](#collaboration)
6. [Advanced Git Operations](#advanced-operations)
7. [Best Practices](#best-practices)
8. [Git in DevOps](#git-in-devops)

## Introduction to Version Control {#introduction}

### What is Version Control?
Version control is a system that records changes to files over time so that you can recall specific versions later. It's essential for:
- Tracking changes in code
- Collaboration among team members
- Backup and recovery
- Release management
- Code integrity

### Types of Version Control Systems
1. **Local VCS**: RCS (Revision Control System)
2. **Centralized VCS**: SVN, Perforce
3. **Distributed VCS**: Git, Mercurial, Bazaar

### Why Git?
- Distributed architecture
- Speed and performance
- Data integrity
- Branching and merging capabilities
- Large community support
- Integration with CI/CD tools

## Git Fundamentals {#git-fundamentals}

### Git Architecture
```
Working Directory → Staging Area → Local Repository → Remote Repository
     (add)           (commit)         (push)
```

### Core Concepts
- **Repository**: Storage location for your project
- **Commit**: Snapshot of your project at a specific time
- **Branch**: Lightweight movable pointer to a commit
- **HEAD**: Pointer to the current branch
- **Index/Staging Area**: Intermediate area before committing

### Essential Git Commands

#### Configuration
```bash
# Global configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main

# Check configuration
git config --list
```

#### Repository Operations
```bash
# Initialize repository
git init

# Clone repository
git clone <url>
git clone <url> <directory-name>

# Check status
git status
git status -s  # Short format
```

#### Basic Workflow
```bash
# Add files to staging
git add <file>
git add .
git add -A

# Commit changes
git commit -m "Commit message"
git commit -am "Add and commit"

# View history
git log
git log --oneline
git log --graph --oneline --all
```

## Git Workflow {#git-workflow}

### Standard Workflow
1. **Modify** files in working directory
2. **Stage** changes you want to include
3. **Commit** staged changes
4. **Push** to remote repository

### File States in Git
- **Untracked**: New files not yet tracked
- **Modified**: Changed files in working directory
- **Staged**: Files added to staging area
- **Committed**: Files stored in Git database

### Working with Remote Repositories
```bash
# Add remote
git remote add origin <url>

# List remotes
git remote -v

# Fetch changes
git fetch origin

# Pull changes
git pull origin main

# Push changes
git push origin main
git push -u origin main  # Set upstream
```

## Branching Strategies {#branching-strategies}

### Branch Operations
```bash
# Create branch
git branch <branch-name>
git checkout -b <branch-name>  # Create and switch
git switch -c <branch-name>    # Modern syntax

# Switch branches
git checkout <branch-name>
git switch <branch-name>

# List branches
git branch
git branch -a  # All branches
git branch -r  # Remote branches

# Delete branch
git branch -d <branch-name>
git branch -D <branch-name>  # Force delete
```

### Merging Strategies

#### Fast-Forward Merge
```bash
git checkout main
git merge feature-branch
```

#### Three-Way Merge
```bash
git checkout main
git merge feature-branch --no-ff
```

#### Rebase
```bash
git checkout feature-branch
git rebase main
```

### Popular Branching Models

#### Git Flow
- **main**: Production-ready code
- **develop**: Integration branch
- **feature/**: Feature branches
- **release/**: Release preparation
- **hotfix/**: Production fixes

#### GitHub Flow
- **main**: Deployable code
- **feature**: Feature branches
- Direct deployment from feature branches

#### GitLab Flow
- **main**: Latest code
- **production**: Production deployment
- **environment**: Environment-specific branches

## Collaboration & Remote Repositories {#collaboration}

### Pull Requests/Merge Requests
1. Create feature branch
2. Make changes and commit
3. Push to remote repository
4. Create pull/merge request
5. Code review process
6. Merge after approval

### Handling Conflicts
```bash
# During merge conflicts
git status  # See conflicted files
# Edit files to resolve conflicts
git add <resolved-files>
git commit
```

### Collaborative Workflows
```bash
# Update local repository
git fetch origin
git pull origin main

# Create feature branch
git checkout -b feature/new-feature

# Work and commit
git add .
git commit -m "Add new feature"

# Push feature branch
git push origin feature/new-feature

# After PR merge, cleanup
git checkout main
git pull origin main
git branch -d feature/new-feature
```

## Advanced Git Operations {#advanced-operations}

### Stashing
```bash
# Stash changes
git stash
git stash save "Work in progress"

# List stashes
git stash list

# Apply stash
git stash apply
git stash pop  # Apply and remove

# Drop stash
git stash drop
```

### Reset and Revert
```bash
# Reset (dangerous)
git reset --soft HEAD~1   # Keep changes staged
git reset --mixed HEAD~1  # Keep changes unstaged
git reset --hard HEAD~1   # Discard changes

# Revert (safe)
git revert <commit-hash>
```

### Interactive Rebase
```bash
# Interactive rebase
git rebase -i HEAD~3

# Commands in interactive mode:
# p, pick = use commit
# r, reword = use commit, but edit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# d, drop = remove commit
```

### Cherry-picking
```bash
# Apply specific commit to current branch
git cherry-pick <commit-hash>
```

### Submodules
```bash
# Add submodule
git submodule add <url> <path>

# Clone with submodules
git clone --recursive <url>

# Update submodules
git submodule update --init --recursive
```

## Best Practices {#best-practices}

### Commit Messages
```
feat: add user authentication system
fix: resolve database connection timeout
docs: update API documentation
style: format code according to style guide
refactor: simplify user validation logic
test: add unit tests for user service
chore: update dependencies
```

### Branch Naming Conventions
```
feature/user-authentication
bugfix/login-error
hotfix/security-patch
release/v1.2.0
```

### Git Hooks
```bash
# Pre-commit hook example
#!/bin/sh
# Run linting before commit
npm run lint
if [ $? -ne 0 ]; then
    echo "Linting failed. Commit aborted."
    exit 1
fi
```

### .gitignore Best Practices
```gitignore
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.o
*.so

# Environment files
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/
```

## Git in DevOps {#git-in-devops}

### Integration with CI/CD
```yaml
# GitHub Actions example
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
```

### Git for Infrastructure as Code
```bash
# Terraform workflow
git checkout -b infrastructure/vpc-update
# Make infrastructure changes
terraform plan
git add terraform/
git commit -m "feat: update VPC configuration"
git push origin infrastructure/vpc-update
# Create PR for review
```

### Semantic Versioning with Git Tags
```bash
# Create tags
git tag v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tags
git push origin v1.0.0
git push origin --tags

# List tags
git tag -l
```

### Git Workflows in Different Environments

#### Development Environment
```bash
# Feature development
git checkout develop
git pull origin develop
git checkout -b feature/new-feature
# Development work
git commit -m "feat: implement new feature"
git push origin feature/new-feature
```

#### Staging Environment
```bash
# Release preparation
git checkout develop
git checkout -b release/v1.1.0
# Bug fixes and testing
git commit -m "fix: resolve staging issues"
git checkout develop
git merge release/v1.1.0
```

#### Production Environment
```bash
# Production release
git checkout main
git merge release/v1.1.0
git tag v1.1.0
git push origin main --tags
```

## Troubleshooting Common Issues

### Merge Conflicts
```bash
# Identify conflicts
git status
git diff

# Resolve manually or use merge tools
git mergetool

# Abort merge if needed
git merge --abort
```

### Undo Operations
```bash
# Undo last commit (keep changes)
git reset HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo specific file changes
git checkout -- <file>
git restore <file>
```

### Performance Optimization
```bash
# Garbage collection
git gc

# Prune remote branches
git remote prune origin

# Large file handling with LFS
git lfs track "*.psd"
git add .gitattributes
```

## Security Considerations

### SSH Keys
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
```

### GPG Signing
```bash
# Configure GPG signing
git config --global user.signingkey <gpg-key-id>
git config --global commit.gpgSign true

# Sign commits
git commit -S -m "Signed commit"
```

### Secrets Management
- Never commit secrets to Git
- Use environment variables
- Implement pre-commit hooks
- Use tools like git-secrets
- Regular security audits

## Conclusion

Git is fundamental to modern DevOps practices. Mastering Git workflows, branching strategies, and collaboration patterns is essential for:
- Efficient team collaboration
- Code quality maintenance
- Release management
- CI/CD integration
- Infrastructure as Code practices

Continue practicing these concepts and integrate them into your daily DevOps workflows for maximum effectiveness.
