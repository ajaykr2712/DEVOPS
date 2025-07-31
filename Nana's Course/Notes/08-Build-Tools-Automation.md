# Advanced Build Tools & Automation

## Table of Contents
1. [Introduction to Build Tools](#introduction)
2. [Build Tool Categories](#categories)
3. [Modern Build Systems](#modern-builds)
4. [Language-Specific Tools](#language-tools)
5. [CI/CD Integration](#cicd-integration)
6. [Build Optimization](#optimization)
7. [Artifact Management](#artifacts)
8. [Best Practices](#best-practices)

## Introduction to Build Tools {#introduction}

### What are Build Tools?
Build tools are programs that automate the creation of executable applications from source code. They compile, link, package, test, and deploy software artifacts.

### Why Build Tools Matter in DevOps
- **Automation**: Eliminate manual build processes
- **Consistency**: Ensure reproducible builds across environments
- **Efficiency**: Optimize build times and resource usage
- **Integration**: Seamless CI/CD pipeline integration
- **Quality**: Automated testing and code analysis

### Build Tool Evolution
```
Traditional → Modern → Cloud-Native
Make/Ant   → Maven    → Bazel/Buck
           → Gradle   → BuildKit
           → npm      → GitHub Actions
```

## Build Tool Categories {#categories}

### 1. Compiled Languages

#### C/C++ Build Tools
```makefile
# Makefile example
CC=gcc
CFLAGS=-Wall -Wextra -std=c99
SRCDIR=src
OBJDIR=obj
BINDIR=bin

SOURCES=$(wildcard $(SRCDIR)/*.c)
OBJECTS=$(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
TARGET=$(BINDIR)/myapp

.PHONY: all clean install

all: $(TARGET)

$(TARGET): $(OBJECTS) | $(BINDIR)
	$(CC) $(OBJECTS) -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

clean:
	rm -rf $(OBJDIR) $(BINDIR)

install: $(TARGET)
	cp $(TARGET) /usr/local/bin/
```

#### CMake Build System
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(MyApp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find dependencies
find_package(Boost REQUIRED COMPONENTS system filesystem)
find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp)

# Add executable
add_executable(myapp
    src/main.cpp
    src/config.cpp
    src/logger.cpp
)

# Include directories
target_include_directories(myapp PRIVATE
    include
    ${Boost_INCLUDE_DIRS}
    ${JSONCPP_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(myapp PRIVATE
    ${Boost_LIBRARIES}
    ${JSONCPP_LIBRARIES}
)

# Compiler flags
target_compile_options(myapp PRIVATE
    -Wall -Wextra -pedantic
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)

# Testing
enable_testing()
add_subdirectory(tests)

# Installation
install(TARGETS myapp DESTINATION bin)
install(FILES config/app.conf DESTINATION etc/myapp)
```

### 2. Java Build Tools

#### Maven Build Configuration
```xml
<!-- pom.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <spring.boot.version>3.1.0</spring.boot.version>
        <junit.version>5.9.3</junit.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>${spring.boot.version}</version>
        </dependency>
        
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring.boot.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.1.2</version>
                <configuration>
                    <includes>
                        <include>**/*Test.java</include>
                        <include>**/*Tests.java</include>
                    </includes>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.10</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
    
    <profiles>
        <profile>
            <id>production</id>
            <properties>
                <spring.profiles.active>prod</spring.profiles.active>
            </properties>
            <build>
                <plugins>
                    <plugin>
                        <groupId>com.spotify</groupId>
                        <artifactId>docker-maven-plugin</artifactId>
                        <version>1.2.2</version>
                        <configuration>
                            <imageName>${project.artifactId}</imageName>
                            <dockerDirectory>src/main/docker</dockerDirectory>
                            <resources>
                                <resource>
                                    <targetPath>/</targetPath>
                                    <directory>${project.build.directory}</directory>
                                    <include>${project.build.finalName}.jar</include>
                                </resource>
                            </resources>
                        </configuration>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
</project>
```

#### Gradle Build Configuration
```groovy
// build.gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
    id 'io.spring.dependency-management' version '1.1.0'
    id 'jacoco'
    id 'com.palantir.docker' version '0.35.0'
}

group = 'com.example'
version = '1.0.0-SNAPSHOT'
sourceCompatibility = '17'

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    runtimeOnly 'com.h2database:h2'
    
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

tasks.named('test') {
    useJUnitPlatform()
    finalizedBy jacocoTestReport
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}

docker {
    name "${project.group}/${project.name}:${project.version}"
    dockerfile file('Dockerfile')
    files jar.archiveFile.get()
}

// Custom tasks
task buildInfo {
    doLast {
        def buildInfoFile = file("$buildDir/resources/main/build-info.properties")
        buildInfoFile.parentFile.mkdirs()
        buildInfoFile.text = """
build.version=${version}
build.time=${new Date().format('yyyy-MM-dd HH:mm:ss')}
build.user=${System.getProperty('user.name')}
"""
    }
}

processResources.dependsOn buildInfo

// Environment-specific configurations
if (project.hasProperty('prod')) {
    bootJar {
        archiveClassifier = 'prod'
    }
}
```

### 3. JavaScript/Node.js Build Tools

#### Modern npm Configuration
```json
{
  "name": "myapp",
  "version": "1.0.0",
  "description": "Modern web application",
  "main": "dist/index.js",
  "scripts": {
    "build": "webpack --mode=production",
    "build:dev": "webpack --mode=development",
    "dev": "webpack serve --mode=development",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.{js,ts,tsx}",
    "lint:fix": "eslint src/**/*.{js,ts,tsx} --fix",
    "format": "prettier --write src/**/*.{js,ts,tsx,css,json}",
    "type-check": "tsc --noEmit",
    "clean": "rimraf dist",
    "start": "node dist/index.js",
    "docker:build": "docker build -t myapp .",
    "docker:run": "docker run -p 3000:3000 myapp"
  },
  "dependencies": {
    "express": "^4.18.2",
    "helmet": "^7.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.3",
    "@types/node": "^20.4.5",
    "@typescript-eslint/eslint-plugin": "^6.2.1",
    "@typescript-eslint/parser": "^6.2.1",
    "eslint": "^8.45.0",
    "eslint-config-prettier": "^8.8.0",
    "jest": "^29.6.1",
    "prettier": "^3.0.0",
    "rimraf": "^5.0.1",
    "ts-jest": "^29.1.1",
    "ts-loader": "^9.4.4",
    "typescript": "^5.1.6",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "collectCoverageFrom": [
      "src/**/*.{ts,js}",
      "!src/**/*.d.ts"
    ],
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

#### Webpack Configuration
```javascript
// webpack.config.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');

module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  
  return {
    entry: './src/index.ts',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProduction ? '[name].[contenthash].js' : '[name].js',
      clean: true,
    },
    
    resolve: {
      extensions: ['.ts', '.tsx', '.js', '.jsx'],
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
    
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
        {
          test: /\.css$/,
          use: [
            isProduction ? MiniCssExtractPlugin.loader : 'style-loader',
            'css-loader',
            'postcss-loader',
          ],
        },
        {
          test: /\.(png|jpg|jpeg|gif|svg)$/,
          type: 'asset/resource',
        },
      ],
    },
    
    plugins: [
      new HtmlWebpackPlugin({
        template: './src/index.html',
        minify: isProduction,
      }),
      ...(isProduction ? [
        new MiniCssExtractPlugin({
          filename: '[name].[contenthash].css',
        }),
      ] : []),
    ],
    
    optimization: {
      minimize: isProduction,
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            compress: {
              drop_console: true,
            },
          },
        }),
        new CssMinimizerPlugin(),
      ],
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all',
          },
        },
      },
    },
    
    devServer: {
      static: path.join(__dirname, 'dist'),
      port: 3000,
      hot: true,
      open: true,
    },
    
    devtool: isProduction ? 'source-map' : 'eval-source-map',
  };
};
```

## Modern Build Systems {#modern-builds}

### Bazel (Google's Build System)
```python
# WORKSPACE
workspace(name = "myapp")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Rules for different languages
http_archive(
    name = "rules_nodejs",
    sha256 = "...",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/..."],
)

load("@rules_nodejs//:index.bzl", "node_repositories")
node_repositories()

# BUILD file
load("@rules_nodejs//:index.bzl", "nodejs_binary")

nodejs_binary(
    name = "server",
    data = [
        "package.json",
        "//src:app_lib",
    ],
    entry_point = "src/server.js",
)

cc_binary(
    name = "myapp",
    srcs = [
        "main.cc",
        "//lib:mylib",
    ],
    deps = [
        "@boost//:system",
        "@boost//:filesystem",
    ],
)
```

### GitHub Actions Build Workflows
```yaml
# .github/workflows/build.yml
name: Build and Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  JAVA_VERSION: '17'
  PYTHON_VERSION: '3.11'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      infrastructure: ${{ steps.changes.outputs.infrastructure }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'package*.json'
            backend:
              - 'backend/**'
              - 'pom.xml'
              - 'build.gradle'
            infrastructure:
              - 'terraform/**'
              - 'ansible/**'

  build-frontend:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: 'frontend/package-lock.json'
          
      - name: Install dependencies
        working-directory: frontend
        run: npm ci
        
      - name: Run linting
        working-directory: frontend
        run: npm run lint
        
      - name: Run type checking
        working-directory: frontend
        run: npm run type-check
        
      - name: Run tests
        working-directory: frontend
        run: npm run test:coverage
        
      - name: Build application
        working-directory: frontend
        run: npm run build
        
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: frontend-build
          path: frontend/dist/
          
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: frontend/coverage/lcov.info
          flags: frontend

  build-backend:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
          cache: 'maven'
          
      - name: Run tests
        working-directory: backend
        run: mvn test
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/postgres
          SPRING_DATASOURCE_USERNAME: postgres
          SPRING_DATASOURCE_PASSWORD: postgres
          
      - name: Build application
        working-directory: backend
        run: mvn package -DskipTests
        
      - name: Build Docker image
        working-directory: backend
        run: |
          docker build -t myapp-backend:${{ github.sha }} .
          docker tag myapp-backend:${{ github.sha }} myapp-backend:latest
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: backend-jar
          path: backend/target/*.jar

  security-scan:
    runs-on: ubuntu-latest
    needs: [build-frontend, build-backend]
    if: always() && (needs.build-frontend.result == 'success' || needs.build-backend.result == 'success')
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  build-matrix:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

## Language-Specific Tools {#language-tools}

### Python Build Tools

#### Poetry Configuration
```toml
# pyproject.toml
[tool.poetry]
name = "myapp"
version = "1.0.0"
description = "Modern Python application"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
packages = [{include = "myapp", from = "src"}]

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.100.0"
uvicorn = {extras = ["standard"], version = "^0.23.0"}
pydantic = "^2.0.0"
sqlalchemy = "^2.0.0"
alembic = "^1.11.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-cov = "^4.1.0"
pytest-asyncio = "^0.21.0"
black = "^23.7.0"
isort = "^5.12.0"
flake8 = "^6.0.0"
mypy = "^1.4.0"
pre-commit = "^3.3.0"

[tool.poetry.scripts]
myapp = "myapp.main:app"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = "--cov=src/myapp --cov-report=term-missing --cov-report=html"

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

### Go Build Tools
```go
// go.mod
module github.com/example/myapp

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/lib/pq v1.10.9
    github.com/golang-migrate/migrate/v4 v4.16.2
)

require (
    github.com/bytedance/sonic v1.9.1 // indirect
    github.com/chenzhuoyu/base64x v0.0.0-20221115062448-fe3a3abad311 // indirect
    // ... other dependencies
)
```

```makefile
# Makefile for Go project
.PHONY: build test clean install docker-build docker-run

APP_NAME=myapp
VERSION=$(shell git describe --tags --always --dirty)
BUILD_TIME=$(shell date +%FT%T%z)
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

build:
	go build ${LDFLAGS} -o bin/${APP_NAME} ./cmd/${APP_NAME}

test:
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

clean:
	rm -rf bin/
	rm -f coverage.out coverage.html

install: build
	cp bin/${APP_NAME} ${GOPATH}/bin/

lint:
	golangci-lint run

format:
	go fmt ./...
	goimports -w .

docker-build:
	docker build -t ${APP_NAME}:${VERSION} .
	docker tag ${APP_NAME}:${VERSION} ${APP_NAME}:latest

docker-run:
	docker run -p 8080:8080 ${APP_NAME}:latest

deps:
	go mod download
	go mod verify

vendor:
	go mod vendor

release: test
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o bin/${APP_NAME}-linux-amd64 ./cmd/${APP_NAME}
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o bin/${APP_NAME}-windows-amd64.exe ./cmd/${APP_NAME}
	GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o bin/${APP_NAME}-darwin-amd64 ./cmd/${APP_NAME}
	GOOS=darwin GOARCH=arm64 go build ${LDFLAGS} -o bin/${APP_NAME}-darwin-arm64 ./cmd/${APP_NAME}
```

## CI/CD Integration {#cicd-integration}

### Jenkins Pipeline
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        IMAGE_NAME = 'myapp'
        KUBECONFIG = credentials('kubeconfig')
    }
    
    tools {
        nodejs '18'
        maven '3.9.0'
        go '1.21'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Build Matrix') {
            parallel {
                stage('Frontend') {
                    when {
                        changeset "frontend/**"
                    }
                    steps {
                        dir('frontend') {
                            sh 'npm ci'
                            sh 'npm run lint'
                            sh 'npm run test:coverage'
                            sh 'npm run build'
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'frontend/coverage',
                                reportFiles: 'index.html',
                                reportName: 'Frontend Coverage Report'
                            ])
                        }
                    }
                }
                
                stage('Backend') {
                    when {
                        changeset "backend/**"
                    }
                    steps {
                        dir('backend') {
                            sh 'mvn clean compile'
                            sh 'mvn test'
                            sh 'mvn package -DskipTests'
                        }
                    }
                    post {
                        always {
                            junit 'backend/target/surefire-reports/*.xml'
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'backend/target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'Backend Coverage Report'
                            ])
                        }
                    }
                }
                
                stage('Go Service') {
                    when {
                        changeset "services/go-service/**"
                    }
                    steps {
                        dir('services/go-service') {
                            sh 'go mod download'
                            sh 'go test -v -race -coverprofile=coverage.out ./...'
                            sh 'go build -o bin/service ./cmd/service'
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('SAST') {
                    steps {
                        sh 'sonar-scanner'
                    }
                }
                
                stage('Dependency Check') {
                    steps {
                        sh 'npm audit --audit-level moderate'
                        sh 'mvn dependency-check:check'
                    }
                }
                
                stage('Secret Scan') {
                    steps {
                        sh 'trufflehog git file://. --since-commit HEAD~1'
                    }
                }
            }
        }
        
        stage('Build Images') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    def services = ['frontend', 'backend', 'go-service']
                    def builds = [:]
                    
                    services.each { service ->
                        builds[service] = {
                            dir(service) {
                                def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}-${service}:${BUILD_VERSION}")
                                image.push()
                                image.push('latest')
                            }
                        }
                    }
                    
                    parallel builds
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh """
                    helm upgrade --install myapp-staging ./helm/myapp \\
                        --namespace staging \\
                        --set image.tag=${BUILD_VERSION} \\
                        --set environment=staging
                """
            }
        }
        
        stage('Integration Tests') {
            when {
                branch 'develop'
            }
            steps {
                sh 'npm run test:integration'
                sh 'npm run test:e2e'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh """
                    helm upgrade --install myapp-prod ./helm/myapp \\
                        --namespace production \\
                        --set image.tag=${BUILD_VERSION} \\
                        --set environment=production
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: "✅ Build succeeded: ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "❌ Build failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            )
        }
    }
}
```

## Build Optimization {#optimization}

### Caching Strategies
```dockerfile
# Multi-stage Dockerfile with caching
FROM node:18-alpine AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY frontend/ .
RUN npm run build

FROM maven:3.9-openjdk-17 AS backend-builder
WORKDIR /app
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn dependency:go-offline -B
RUN mvn package -DskipTests

FROM openjdk:17-jre-slim AS runtime
RUN addgroup --system app && adduser --system --group app
WORKDIR /app
COPY --from=backend-builder /app/target/*.jar app.jar
COPY --from=frontend-builder /app/dist ./static
USER app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Build Performance Monitoring
```yaml
# build-performance.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: build-metrics
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'jenkins'
        static_configs:
          - targets: ['jenkins:8080']
        metrics_path: '/prometheus'
      - job_name: 'build-agents'
        static_configs:
          - targets: ['agent1:9100', 'agent2:9100']
```

## Artifact Management {#artifacts}

### Nexus Repository Configuration
```groovy
// nexus-setup.groovy
repository.createMavenHosted('maven-releases')
repository.createMavenHosted('maven-snapshots')
repository.createNpmHosted('npm-private')
repository.createDockerHosted('docker-private', 8082)

// Create group repositories
repository.createMavenGroup('maven-public', [
    'maven-central',
    'maven-releases',
    'maven-snapshots'
])

repository.createNpmGroup('npm-public', [
    'npm-registry',
    'npm-private'
])
```

### JFrog Artifactory Pipeline
```yaml
# artifactory-pipeline.yml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: artifactory-publish
spec:
  params:
    - name: image-url
    - name: version
  tasks:
    - name: build-and-publish
      taskSpec:
        steps:
          - name: build
            image: maven:3.9-openjdk-17
            script: |
              mvn clean package
              
          - name: publish-maven
            image: maven:3.9-openjdk-17
            script: |
              mvn deploy -DskipTests
              
          - name: publish-docker
            image: gcr.io/kaniko-project/executor:latest
            args:
              - --dockerfile=Dockerfile
              - --destination=$(params.image-url):$(params.version)
              - --destination=$(params.image-url):latest
```

## Best Practices {#best-practices}

### Build Tool Selection Matrix

| Project Type | Recommended Tool | Alternative | Reason |
|--------------|------------------|-------------|---------|
| Java Enterprise | Maven | Gradle | Mature ecosystem, standard structure |
| Android/Modern Java | Gradle | Maven | Flexible, better for complex builds |
| Node.js/JavaScript | npm/pnpm | Yarn | Package management, script running |
| Python | Poetry | pip + setuptools | Dependency resolution, virtual envs |
| Go | go build | Mage | Built-in, simple, efficient |
| C/C++ | CMake | Make/Ninja | Cross-platform, modern |
| Rust | Cargo | - | Built-in, excellent design |
| .NET | dotnet CLI | MSBuild | Cross-platform, integrated |

### Performance Optimization Guidelines
1. **Parallel Builds**: Use multi-core compilation
2. **Incremental Builds**: Only rebuild changed components
3. **Caching**: Cache dependencies and intermediate artifacts
4. **Distributed Builds**: Use build farms for large projects
5. **Build Profiling**: Monitor and optimize bottlenecks

### Security Best Practices
```yaml
# security-scan.yml
name: Security Scan
on: [push]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Dependency vulnerability scan
        run: |
          npm audit --audit-level high
          mvn dependency-check:check
          
      - name: Secret scanning
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          
      - name: SAST analysis
        uses: github/codeql-action/analyze@v2
        
      - name: Container security scan
        run: |
          docker build -t temp-image .
          trivy image temp-image
```

### Build Reproducibility
```dockerfile
# Reproducible builds
FROM node:18.17.0@sha256:abc123... AS builder
WORKDIR /app
COPY package-lock.json package.json ./
RUN npm ci --frozen-lockfile
COPY . .
RUN npm run build

# Use specific versions and checksums
FROM nginx:1.25.1@sha256:def456...
COPY --from=builder /app/dist /usr/share/nginx/html
```

## Conclusion

Modern build tools are essential for DevOps success. Key considerations:
- **Automation**: Minimize manual intervention
- **Consistency**: Ensure reproducible builds
- **Speed**: Optimize for developer productivity
- **Security**: Integrate security scanning
- **Observability**: Monitor build performance
- **Scalability**: Support growing codebases

Choose tools that fit your technology stack, team size, and complexity requirements while maintaining flexibility for future growth.
