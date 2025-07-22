# Docker and Containerization

Production-ready containerization solutions, Docker best practices, and container orchestration examples.

## 📁 Directory Structure

```
containers/
├── README.md
├── docker/                 # Docker configurations and examples
├── kubernetes/             # Kubernetes manifests and configs
├── helm/                  # Helm charts and templates
├── compose/               # Docker Compose applications
├── security/              # Container security configurations
└── best-practices/        # Documentation and guidelines
```

## 🐳 Docker Best Practices

### Multi-stage Builds
```dockerfile
# Example: Optimized Node.js application
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --chown=nextjs:nodejs . .
USER nextjs
EXPOSE 3000
CMD ["npm", "start"]
```

### Security Hardening
- Non-root user execution
- Minimal base images (Alpine, Distroless)
- No unnecessary packages or tools
- Regular security updates
- Image scanning integration

### Image Optimization
- Layer caching strategies
- .dockerignore for build context
- Multi-stage builds for size reduction
- Dependency management
- Build-time variable handling

## ☸️ Kubernetes Resources

### Production Deployments
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: web-app
        image: ghcr.io/company/web-app:v1.2.3
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
```

### Service Mesh Integration
- Istio service mesh configuration
- Traffic management and routing
- Security policies and mTLS
- Observability and monitoring

## ⎈ Helm Charts

### Chart Structure
```
helm/
├── Chart.yaml
├── values.yaml
├── values-production.yaml
├── values-staging.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── hpa.yaml
└── charts/
```

### Advanced Features
- Dependency management
- Conditional resource creation
- Environment-specific values
- Hook and test integration
- Chart versioning and releases

## 🔐 Container Security

### Runtime Security
```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-netpol
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8080
```

### Image Security Scanning
- Trivy integration in CI/CD
- Harbor registry scanning
- Policy enforcement with OPA Gatekeeper
- Runtime security monitoring

## 🏗️ Container Orchestration

### Docker Swarm
- Swarm mode configuration
- Service definitions and scaling
- Secrets and config management
- Load balancing and networking

### Kubernetes Operators
- Custom Resource Definitions (CRDs)
- Controller patterns
- Operator development best practices
- Lifecycle management automation

## 📊 Monitoring and Observability

### Container Metrics
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-metrics
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
spec:
  selector:
    app: web-app
  ports:
  - port: 8080
    targetPort: 8080
```

### Logging Strategy
- Centralized log aggregation
- Structured logging practices
- Log retention policies
- Error tracking and alerting

### Distributed Tracing
- Jaeger integration
- Trace correlation across services
- Performance monitoring
- Debugging distributed systems

## 🚀 Deployment Strategies

### Blue-Green Deployment
```bash
#!/bin/bash
# Blue-Green deployment script
NAMESPACE="production"
NEW_VERSION="v1.2.3"

# Deploy green version
kubectl set image deployment/web-app-green web-app=myapp:$NEW_VERSION -n $NAMESPACE
kubectl rollout status deployment/web-app-green -n $NAMESPACE

# Switch traffic
kubectl patch service web-app -p '{"spec":{"selector":{"version":"green"}}}' -n $NAMESPACE

# Cleanup blue version after verification
sleep 300
kubectl delete deployment web-app-blue -n $NAMESPACE
```

### Canary Deployment
- Traffic splitting with Istio/Linkerd
- Automated rollback on errors
- Metrics-based promotion
- A/B testing integration

## 🛠️ Development Workflow

### Local Development
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    depends_on:
      - database
      - redis
```

### Testing Strategies
- Unit testing in containers
- Integration testing with test containers
- Contract testing between services
- End-to-end testing automation

## 📚 Documentation and Guides

- [Container Security Best Practices](security/README.md)
- [Kubernetes Production Checklist](best-practices/k8s-production.md)
- [Helm Chart Development Guide](helm/DEVELOPMENT.md)
- [Docker Optimization Techniques](docker/OPTIMIZATION.md)
- [Container Troubleshooting Guide](best-practices/troubleshooting.md)

## 🎯 Performance Optimization

### Resource Management
- CPU and memory optimization
- JVM tuning for Java applications
- Node.js performance tuning
- Database connection pooling

### Scaling Strategies
- Horizontal Pod Autoscaling (HPA)
- Vertical Pod Autoscaling (VPA)
- Cluster autoscaling
- Custom metrics scaling

## 🤝 Contributing

We welcome contributions to improve our containerization practices! Please see our [Contributing Guide](../.github/CONTRIBUTING.md) for:
- Adding new Docker examples
- Improving Kubernetes manifests
- Contributing Helm charts
- Sharing optimization techniques
- Updating security practices
