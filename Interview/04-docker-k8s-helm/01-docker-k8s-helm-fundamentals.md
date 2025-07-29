# Docker, Kubernetes & Helm Fundamentals

## Table of Contents
1. [Docker Fundamentals](#docker-fundamentals)
2. [Docker Compose](#docker-compose)
3. [Kubernetes Core Concepts](#kubernetes-core-concepts)
4. [Kubernetes Objects](#kubernetes-objects)
5. [Helm Charts](#helm-charts)
6. [Container Debugging](#container-debugging)
7. [Scaling and Performance](#scaling-and-performance)
8. [Security Best Practices](#security-best-practices)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Interview Questions](#interview-questions)

## Docker Fundamentals

### Dockerfile Best Practices

```dockerfile
# Multi-stage build for Python application
FROM python:3.9-slim as builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY setup.py .

# Install application
RUN pip install -e .

# Production stage
FROM python:3.9-slim as production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app/src ./src

# Set ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Set labels
LABEL maintainer="your-email@example.com" \
      version="1.0.0" \
      description="Production-ready Python application"

# Environment variables
ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# Default command
CMD ["python", "-m", "src.main"]
```

### Advanced Docker Patterns

```dockerfile
# Development Dockerfile with debugging capabilities
FROM python:3.9-slim as development

# Install development dependencies
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    htop \
    strace \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt requirements-dev.txt ./
RUN pip install -r requirements-dev.txt

# Copy source code
COPY . .

# Install in development mode
RUN pip install -e .

# Debugging tools
RUN pip install pdb ipdb debugpy

# Expose debug port
EXPOSE 5678 8080

# Development command with auto-reload
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "src.main"]
```

### Docker Build Optimization

```bash
#!/bin/bash
# scripts/optimized-docker-build.sh

set -e

IMAGE_NAME="myapp"
VERSION="${1:-latest}"
REGISTRY="registry.example.com"

echo "🏗️  Building optimized Docker image..."

# Build with BuildKit for better performance
export DOCKER_BUILDKIT=1

# Build multi-platform image
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag "${REGISTRY}/${IMAGE_NAME}:${VERSION}" \
    --tag "${REGISTRY}/${IMAGE_NAME}:latest" \
    --cache-from type=registry,ref="${REGISTRY}/${IMAGE_NAME}:buildcache" \
    --cache-to type=registry,ref="${REGISTRY}/${IMAGE_NAME}:buildcache",mode=max \
    --push \
    .

echo "✅ Build completed successfully"

# Security scan
echo "🔒 Running security scan..."
trivy image "${REGISTRY}/${IMAGE_NAME}:${VERSION}"

# Size analysis
echo "📊 Image size analysis:"
docker images "${REGISTRY}/${IMAGE_NAME}:${VERSION}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Layer analysis
echo "📋 Layer analysis:"
dive "${REGISTRY}/${IMAGE_NAME}:${VERSION}"
```

## Docker Compose

### Production-Ready Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    image: myapp:latest
    container_name: myapp-web
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379/0
      - LOG_LEVEL=INFO
    volumes:
      - ./logs:/app/logs
      - app-data:/app/data
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  db:
    image: postgres:13-alpine
    container_name: myapp-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    secrets:
      - db_password

  redis:
    image: redis:6-alpine
    container_name: myapp-redis
    restart: unless-stopped
    command: redis-server --requirepass mypassword --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/ssl:ro
      - nginx-logs:/var/log/nginx
    depends_on:
      - web
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  prometheus:
    image: prom/prometheus:latest
    container_name: myapp-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    networks:
      - app-network

volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
  app-data:
    driver: local
  nginx-logs:
    driver: local
  prometheus-data:
    driver: local

networks:
  app-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Development Docker Compose

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
      target: development
    volumes:
      - .:/app
      - /app/__pycache__
      - /app/.pytest_cache
    environment:
      - DEBUG=true
      - LOG_LEVEL=DEBUG
      - FLASK_ENV=development
    ports:
      - "8080:8080"
      - "5678:5678"  # Debug port
    command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m src.main

  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: dev_user
      POSTGRES_PASSWORD: dev_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres-dev-data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"

  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI

volumes:
  postgres-dev-data:
```

## Kubernetes Core Concepts

### Basic Kubernetes Resources

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  labels:
    name: myapp
    environment: production
---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: myapp
data:
  database_host: "postgres-service"
  database_port: "5432"
  redis_host: "redis-service"
  redis_port: "6379"
  log_level: "INFO"
  app_name: "myapp"
---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
  namespace: myapp
type: Opaque
data:
  database_password: cGFzc3dvcmQxMjM=  # base64 encoded
  redis_password: cmVkaXNwYXNz
  jwt_secret: bXlqd3RzZWNyZXQ=
---
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  namespace: myapp
  labels:
    app: myapp
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      serviceAccountName: myapp-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      initContainers:
      - name: migration
        image: myapp:latest
        command: ['python', '-m', 'src.migrate']
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database_url
      containers:
      - name: myapp
        image: myapp:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: myapp-config
              key: database_host
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: myapp-secrets
              key: database_password
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: myapp-config
              key: log_level
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: app-logs
          mountPath: /app/logs
        - name: config-volume
          mountPath: /app/config
          readOnly: true
      volumes:
      - name: app-logs
        emptyDir: {}
      - name: config-volume
        configMap:
          name: myapp-config
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
      - key: "app"
        operator: "Equal"
        value: "myapp"
        effect: "NoSchedule"
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - myapp
              topologyKey: kubernetes.io/hostname
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: myapp
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: myapp
---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

### Advanced Kubernetes Resources

```yaml
# hpa.yaml - Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
  namespace: myapp
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp-deployment
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
---
# pdb.yaml - Pod Disruption Budget
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
  namespace: myapp
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
---
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  - from:
    - podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
  - to: []  # Allow all outbound for external APIs
    ports:
    - protocol: TCP
      port: 443
---
# cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: myapp-cleanup
  namespace: myapp
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: myapp:latest
            command: ['python', '-m', 'src.cleanup']
            env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database_url
            resources:
              requests:
                memory: "128Mi"
                cpu: "100m"
              limits:
                memory: "256Mi"
                cpu: "200m"
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
```

## Helm Charts

### Basic Helm Chart Structure

```yaml
# Chart.yaml
apiVersion: v2
name: myapp
description: A production-ready web application
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - web
  - api
  - microservice
home: https://example.com/myapp
sources:
  - https://github.com/example/myapp
maintainers:
  - name: DevOps Team
    email: devops@example.com
dependencies:
  - name: postgresql
    version: 11.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  - name: redis
    version: 16.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

```yaml
# values.yaml
# Default values for myapp
replicaCount: 3

image:
  repository: myapp
  pullPolicy: IfNotPresent
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext:
  fsGroup: 2000

securityContext:
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
    - ALL

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - myapp
        topologyKey: kubernetes.io/hostname

# Application configuration
config:
  logLevel: INFO
  debugMode: false
  database:
    host: ""
    port: 5432
    name: myapp
  redis:
    host: ""
    port: 6379

# External dependencies
postgresql:
  enabled: true
  auth:
    postgresPassword: ""
    username: myapp
    password: ""
    database: myapp

redis:
  enabled: true
  auth:
    enabled: true
    password: ""

# Monitoring
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    path: /metrics

# Backup
backup:
  enabled: false
  schedule: "0 2 * * *"
  retention: 7
```

### Advanced Helm Templates

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "myapp.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      
      {{- if .Values.postgresql.enabled }}
      initContainers:
        - name: wait-for-db
          image: postgres:13-alpine
          command: ['sh', '-c']
          args:
            - |
              until pg_isready -h {{ include "myapp.databaseHost" . }} -p {{ .Values.config.database.port }}; do
                echo "Waiting for database..."
                sleep 2
              done
      {{- end }}
      
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          env:
            - name: DATABASE_HOST
              value: {{ include "myapp.databaseHost" . }}
            - name: DATABASE_PORT
              value: {{ .Values.config.database.port | quote }}
            - name: DATABASE_NAME
              value: {{ .Values.config.database.name }}
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "myapp.fullname" . }}-secret
                  key: database-password
            - name: REDIS_HOST
              value: {{ include "myapp.redisHost" . }}
            - name: REDIS_PORT
              value: {{ .Values.config.redis.port | quote }}
            {{- if .Values.redis.auth.enabled }}
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "myapp.fullname" . }}-secret
                  key: redis-password
            {{- end }}
            - name: LOG_LEVEL
              value: {{ .Values.config.logLevel }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

```yaml
# templates/_helpers.tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "myapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "myapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "myapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "myapp.labels" -}}
helm.sh/chart: {{ include "myapp.chart" . }}
{{ include "myapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "myapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database host helper
*/}}
{{- define "myapp.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- include "postgresql.fullname" .Subcharts.postgresql }}
{{- else }}
{{- .Values.config.database.host }}
{{- end }}
{{- end }}

{{/*
Redis host helper
*/}}
{{- define "myapp.redisHost" -}}
{{- if .Values.redis.enabled }}
{{- include "redis.fullname" .Subcharts.redis }}-master
{{- else }}
{{- .Values.config.redis.host }}
{{- end }}
{{- end }}
```

### Helm Deployment Scripts

```bash
#!/bin/bash
# scripts/helm-deploy.sh

set -e

CHART_NAME="myapp"
NAMESPACE="myapp"
ENVIRONMENT="${1:-staging}"
VERSION="${2:-latest}"

echo "🚀 Deploying $CHART_NAME to $ENVIRONMENT environment"

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Validate chart
echo "🔍 Validating Helm chart..."
helm lint ./helm-chart

# Dry run deployment
echo "🧪 Running dry-run deployment..."
helm upgrade --install "$CHART_NAME" ./helm-chart \
    --namespace "$NAMESPACE" \
    --values "./helm-chart/values-$ENVIRONMENT.yaml" \
    --set image.tag="$VERSION" \
    --dry-run --debug

# Actual deployment
echo "📦 Deploying to $ENVIRONMENT..."
helm upgrade --install "$CHART_NAME" ./helm-chart \
    --namespace "$NAMESPACE" \
    --values "./helm-chart/values-$ENVIRONMENT.yaml" \
    --set image.tag="$VERSION" \
    --timeout 10m \
    --wait \
    --atomic

# Verify deployment
echo "✅ Verifying deployment..."
kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name="$CHART_NAME"

# Run smoke tests
echo "🧪 Running smoke tests..."
./scripts/smoke-tests.sh "$NAMESPACE"

echo "🎉 Deployment completed successfully!"
```

## Container Debugging

### Debugging Tools and Techniques

```bash
#!/bin/bash
# scripts/debug-container.sh

set -e

NAMESPACE="${1:-default}"
POD_NAME="${2}"

if [ -z "$POD_NAME" ]; then
    echo "Usage: $0 <namespace> <pod-name>"
    exit 1
fi

echo "🔍 Debugging pod $POD_NAME in namespace $NAMESPACE"

# Pod information
echo "📋 Pod Information:"
kubectl describe pod "$POD_NAME" -n "$NAMESPACE"

# Resource usage
echo "📊 Resource Usage:"
kubectl top pod "$POD_NAME" -n "$NAMESPACE"

# Logs
echo "📝 Recent Logs:"
kubectl logs "$POD_NAME" -n "$NAMESPACE" --tail=50

# Previous container logs (if crashed)
echo "📝 Previous Container Logs:"
kubectl logs "$POD_NAME" -n "$NAMESPACE" --previous || echo "No previous logs"

# Events
echo "📅 Recent Events:"
kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$POD_NAME" --sort-by='.lastTimestamp'

# Network debugging
echo "🌐 Network Information:"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- nslookup kubernetes.default.svc.cluster.local || echo "DNS resolution failed"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- netstat -tlnp || echo "Netstat not available"

# File system debugging
echo "💾 File System Information:"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- df -h || echo "Disk usage not available"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- find /tmp -type f -size +10M 2>/dev/null || echo "Large files not found"

# Process debugging
echo "⚙️  Process Information:"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- ps aux || echo "Process list not available"

# Interactive debugging session
read -p "Start interactive debug session? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- /bin/bash || \
    kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- /bin/sh
fi
```

### Debug Utilities Pod

```yaml
# debug-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug-utils
  namespace: default
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ['sleep', '3600']
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_PTRACE"]
    volumeMounts:
    - name: host-root
      mountPath: /host
      readOnly: true
  volumes:
  - name: host-root
    hostPath:
      path: /
  hostNetwork: true
  hostPID: true
  restartPolicy: Never
```

```bash
# Debug commands inside the pod
kubectl exec -it debug-utils -- bash

# Network debugging
nslookup kubernetes.default.svc.cluster.local
dig @kube-dns.kube-system.svc.cluster.local kubernetes.default.svc.cluster.local
nmap -p 80,443 service-name.namespace.svc.cluster.local

# DNS debugging
cat /etc/resolv.conf
ping 8.8.8.8
curl -I https://httpbin.org/status/200

# Process debugging
ps aux | grep my-app
lsof -p <pid>
strace -p <pid>

# Network traffic
tcpdump -i any port 80
ss -tulpn | grep :80
```

## Scaling and Performance

### Cluster Autoscaling

```yaml
# cluster-autoscaler.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  labels:
    app: cluster-autoscaler
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8085'
    spec:
      serviceAccountName: cluster-autoscaler
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        resources:
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 300Mi
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/myapp-cluster
        - --balance-similar-node-groups
        - --scale-down-enabled=true
        - --scale-down-delay-after-add=10m
        - --scale-down-unneeded-time=10m
        - --max-node-provision-time=15m
        env:
        - name: AWS_REGION
          value: us-west-2
```

### Vertical Pod Autoscaling

```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
  namespace: myapp
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp-deployment
  updatePolicy:
    updateMode: "Auto"  # Auto, Recreation, or Off
  resourcePolicy:
    containerPolicies:
    - containerName: myapp
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 1000m
        memory: 1Gi
      mode: Auto
```

### Performance Monitoring

```python
# scripts/k8s-performance-monitor.py
import subprocess
import json
import time
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd

class K8sPerformanceMonitor:
    def __init__(self, namespace="default"):
        self.namespace = namespace
        self.metrics = []
    
    def get_pod_metrics(self):
        """Get current pod resource usage"""
        cmd = f"kubectl top pods -n {self.namespace} --no-headers"
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        
        metrics = []
        for line in result.stdout.strip().split('\n'):
            if line:
                parts = line.split()
                pod_name = parts[0]
                cpu = parts[1].replace('m', '')
                memory = parts[2].replace('Mi', '')
                
                metrics.append({
                    'timestamp': datetime.now(),
                    'pod_name': pod_name,
                    'cpu_millicores': int(cpu),
                    'memory_mb': int(memory)
                })
        
        return metrics
    
    def get_cluster_metrics(self):
        """Get cluster-wide metrics"""
        # Node metrics
        cmd = "kubectl top nodes --no-headers"
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        
        node_metrics = []
        for line in result.stdout.strip().split('\n'):
            if line:
                parts = line.split()
                node_name = parts[0]
                cpu_percent = parts[1].replace('%', '')
                memory_percent = parts[3].replace('%', '')
                
                node_metrics.append({
                    'node_name': node_name,
                    'cpu_percent': float(cpu_percent),
                    'memory_percent': float(memory_percent)
                })
        
        return node_metrics
    
    def monitor_continuous(self, duration_minutes=60, interval_seconds=30):
        """Monitor performance continuously"""
        end_time = time.time() + (duration_minutes * 60)
        
        while time.time() < end_time:
            try:
                # Collect pod metrics
                pod_metrics = self.get_pod_metrics()
                cluster_metrics = self.get_cluster_metrics()
                
                # Store metrics
                self.metrics.extend(pod_metrics)
                
                # Print summary
                if pod_metrics:
                    avg_cpu = sum(m['cpu_millicores'] for m in pod_metrics) / len(pod_metrics)
                    avg_memory = sum(m['memory_mb'] for m in pod_metrics) / len(pod_metrics)
                    print(f"[{datetime.now()}] Avg CPU: {avg_cpu:.1f}m, Avg Memory: {avg_memory:.1f}Mi")
                
                time.sleep(interval_seconds)
                
            except KeyboardInterrupt:
                print("Monitoring stopped by user")
                break
            except Exception as e:
                print(f"Error collecting metrics: {e}")
                time.sleep(interval_seconds)
    
    def generate_report(self):
        """Generate performance report"""
        if not self.metrics:
            print("No metrics collected")
            return
        
        df = pd.DataFrame(self.metrics)
        
        # Create visualizations
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
        
        # CPU usage over time
        df.groupby('timestamp')['cpu_millicores'].mean().plot(ax=ax1)
        ax1.set_title('Average CPU Usage Over Time')
        ax1.set_ylabel('CPU (millicores)')
        
        # Memory usage over time
        df.groupby('timestamp')['memory_mb'].mean().plot(ax=ax2)
        ax2.set_title('Average Memory Usage Over Time')
        ax2.set_ylabel('Memory (MB)')
        
        # CPU distribution by pod
        df.groupby('pod_name')['cpu_millicores'].mean().plot(kind='bar', ax=ax3)
        ax3.set_title('Average CPU Usage by Pod')
        ax3.set_ylabel('CPU (millicores)')
        plt.setp(ax3.xaxis.get_majorticklabels(), rotation=45)
        
        # Memory distribution by pod
        df.groupby('pod_name')['memory_mb'].mean().plot(kind='bar', ax=ax4)
        ax4.set_title('Average Memory Usage by Pod')
        ax4.set_ylabel('Memory (MB)')
        plt.setp(ax4.xaxis.get_majorticklabels(), rotation=45)
        
        plt.tight_layout()
        plt.savefig('k8s_performance_report.png', dpi=300, bbox_inches='tight')
        plt.show()
        
        # Summary statistics
        summary = df.groupby('pod_name').agg({
            'cpu_millicores': ['mean', 'max', 'min'],
            'memory_mb': ['mean', 'max', 'min']
        }).round(2)
        
        print("\nPerformance Summary:")
        print(summary)

if __name__ == "__main__":
    monitor = K8sPerformanceMonitor("myapp")
    print("Starting performance monitoring...")
    monitor.monitor_continuous(duration_minutes=30, interval_seconds=30)
    monitor.generate_report()
```

## Interview Questions

### Common Docker/K8s Interview Questions

**Q1: What's the difference between Docker images and containers?**

**Answer:**
- **Image:** Read-only template with application code, dependencies, and OS. Blueprint for containers.
- **Container:** Running instance of an image. Writable layer on top of image layers.

```bash
# Image operations
docker build -t myapp:latest .
docker images
docker pull nginx:alpine

# Container operations
docker run -d --name myapp-container myapp:latest
docker ps
docker exec -it myapp-container bash
```

**Q2: How do you optimize Docker image size?**

**Answer:**
```dockerfile
# Multi-stage builds
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]

# Additional optimizations:
# - Use Alpine base images
# - Remove package managers after use
# - Combine RUN commands
# - Use .dockerignore
# - Minimize layers
```

**Q3: Explain Kubernetes networking concepts.**

**Answer:**
- **Pod Network:** Each pod gets unique IP, containers share network namespace
- **Service Network:** Stable IPs/DNS for pod groups
- **Ingress Network:** External access routing
- **CNI:** Container Network Interface for pod networking

```yaml
# Service example
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

**Q4: How do you handle secrets in Kubernetes?**

**Answer:**
```yaml
# Secret creation
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: dXNlcm5hbWU=  # base64 encoded
  password: cGFzc3dvcmQ=

# Using in pod
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: password

# Volume mount
volumeMounts:
- name: secret-volume
  mountPath: /etc/secrets
volumes:
- name: secret-volume
  secret:
    secretName: app-secrets
```

**Q5: What are Kubernetes probes and why are they important?**

**Answer:**
```yaml
# Liveness probe - restart container if fails
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

# Readiness probe - remove from service if fails
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

# Startup probe - during application startup
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  periodSeconds: 10
  failureThreshold: 30
```

**Q6: How do you troubleshoot a failing pod?**

**Answer:**
```bash
# Debug workflow
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl exec -it <pod-name> -- /bin/bash

# Common issues:
# - Image pull errors
# - Resource constraints
# - Mount failures
# - Network issues
# - Configuration errors
```

**Q7: Explain Helm and its benefits.**

**Answer:**
Helm is Kubernetes package manager providing:
- **Templating:** Parameterized YAML files
- **Versioning:** Release management
- **Rollback:** Easy version rollback
- **Dependencies:** Chart dependencies management
- **Reusability:** Shareable packages

```bash
# Helm commands
helm create myapp
helm install myapp ./myapp
helm upgrade myapp ./myapp --set image.tag=v2.0.0
helm rollback myapp 1
helm uninstall myapp
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is Docker? | Containerization platform that packages applications with dependencies into portable containers |
| 2 | Easy | What is a container? | Lightweight, standalone package containing application and all its dependencies |
| 3 | Easy | What is Dockerfile? | Text file with instructions to build Docker image |
| 4 | Easy | What is Docker image? | Read-only template used to create containers |
| 5 | Easy | What is the difference between image and container? | Image is template, container is running instance of image |
| 6 | Easy | What is Kubernetes? | Container orchestration platform for managing containerized applications |
| 7 | Easy | What is a Pod in Kubernetes? | Smallest deployable unit containing one or more containers |
| 8 | Easy | What is kubectl? | Command-line tool for interacting with Kubernetes clusters |
| 9 | Easy | What is Helm? | Package manager for Kubernetes applications using charts |
| 10 | Easy | What is Helm chart? | Collection of Kubernetes manifests and templates packaged together |
| 11 | Easy | What is Docker Compose? | Tool for defining and running multi-container Docker applications |
| 12 | Easy | What is container registry? | Repository for storing and distributing container images |
| 13 | Easy | What is namespace in Kubernetes? | Virtual cluster for organizing and isolating resources |
| 14 | Easy | What is Service in Kubernetes? | Abstract way to expose application running on Pods |
| 15 | Easy | What is Deployment in Kubernetes? | Describes desired state for Pods and ReplicaSets |
| 16 | Medium | How does Docker networking work? | Bridge, host, overlay networks for container communication |
| 17 | Medium | What is Docker volume? | Persistent storage mechanism for containers |
| 18 | Medium | What is multi-stage build? | Dockerfile technique using multiple FROM statements to optimize image size |
| 19 | Medium | What is ReplicaSet in Kubernetes? | Ensures specified number of Pod replicas are running |
| 20 | Medium | What is ConfigMap and Secret? | ConfigMap stores config data, Secret stores sensitive data |
| 21 | Medium | What is Ingress in Kubernetes? | Manages external access to services, typically HTTP/HTTPS |
| 22 | Medium | What is PersistentVolume and PersistentVolumeClaim? | PV is storage resource, PVC is request for storage |
| 23 | Medium | What is StatefulSet? | Manages stateful applications with stable identities and storage |
| 24 | Medium | What is DaemonSet? | Ensures copy of Pod runs on all or selected nodes |
| 25 | Medium | What is Job and CronJob? | Job runs Pods to completion, CronJob runs Jobs on schedule |
| 26 | Medium | What is Helm values? | Configuration values that customize chart behavior |
| 27 | Medium | What is Helm template? | Go template files that generate Kubernetes manifests |
| 28 | Medium | What is resource limit and request? | Request is guaranteed resources, limit is maximum allowed |
| 29 | Medium | What is health check in containers? | Liveness and readiness probes to monitor container health |
| 30 | Medium | What is horizontal vs vertical scaling? | Horizontal adds more instances, vertical adds more resources |
| 31 | Hard | How to optimize Docker image size? | Multi-stage builds, minimal base images, layer caching, .dockerignore |
| 32 | Hard | What is Kubernetes networking model? | Flat network where every Pod gets unique IP |
| 33 | Hard | What is CNI (Container Network Interface)? | Standard for configuring network interfaces in containers |
| 34 | Hard | What is RBAC in Kubernetes? | Role-Based Access Control for securing cluster access |
| 35 | Hard | What is Custom Resource Definition (CRD)? | Extension mechanism to add custom resources to Kubernetes |
| 36 | Hard | What is Operator pattern? | Method of packaging and managing complex applications |
| 37 | Hard | What is Pod Security Policy? | Cluster-level resource controlling security-sensitive aspects of Pods |
| 38 | Hard | What is Network Policy? | Specification of how groups of Pods communicate |
| 39 | Hard | What is Kubernetes scheduler? | Component that assigns Pods to nodes based on constraints |
| 40 | Hard | What is etcd in Kubernetes? | Distributed key-value store for cluster state |
| 41 | Hard | How to handle secrets management? | Use external secret managers, sealed secrets, encryption at rest |
| 42 | Hard | What is service mesh? | Infrastructure layer handling service-to-service communication |
| 43 | Hard | What is Istio? | Service mesh providing traffic management, security, observability |
| 44 | Hard | How to implement blue-green deployment in Kubernetes? | Use separate deployments with service selector updates |
| 45 | Hard | What is cluster autoscaling? | Automatically adjusting cluster size based on demand |
| 46 | Expert | What is Kubernetes control plane? | Master components managing cluster: API server, scheduler, controller manager |
| 47 | Expert | How to troubleshoot networking issues? | Check CNI, DNS, network policies, service endpoints |
| 48 | Expert | What is admission controller? | Plugin intercepting API requests before object persistence |
| 49 | Expert | How to implement disaster recovery? | Multi-region clusters, backup strategies, data replication |
| 50 | Expert | What is resource quotas and limits? | Mechanism to limit resource consumption per namespace |
| 51 | Expert | How to implement monitoring and logging? | Prometheus, Grafana, ELK stack, distributed tracing |
| 52 | Expert | What is GitOps with Kubernetes? | Using Git as source of truth for cluster configuration |
| 53 | Expert | How to handle database in Kubernetes? | StatefulSets, operators, external services, backup strategies |
| 54 | Expert | What is Kubernetes security best practices? | RBAC, network policies, security contexts, image scanning |
| 55 | Expert | How to optimize Kubernetes performance? | Resource tuning, node affinity, topology spreading |
