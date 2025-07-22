# DevOps Best Practices and Troubleshooting Guide

A comprehensive guide covering industry best practices, common issues, and proven solutions for DevOps practitioners.

## 📚 Table of Contents

1. [CI/CD Best Practices](#cicd-best-practices)
2. [Infrastructure as Code](#infrastructure-as-code)
3. [Container and Kubernetes](#container-and-kubernetes)
4. [Monitoring and Observability](#monitoring-and-observability)
5. [Security and Compliance](#security-and-compliance)
6. [Troubleshooting Guide](#troubleshooting-guide)
7. [Performance Optimization](#performance-optimization)
8. [Disaster Recovery](#disaster-recovery)

## 🚀 CI/CD Best Practices

### Pipeline Design Principles

#### 1. Fail Fast, Fail Often
```yaml
# Example: Early validation stage
stages:
  - validate
  - test
  - security-scan
  - build
  - deploy

validate:
  stage: validate
  script:
    - lint-code
    - validate-configs
    - check-dependencies
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"
```

#### 2. Pipeline as Code
- Version control all pipeline definitions
- Use templates and reusable components
- Environment-specific configurations
- Automated pipeline testing

#### 3. Artifact Management
```bash
# Semantic versioning for artifacts
VERSION=$(git describe --tags --always --dirty)
ARTIFACT_NAME="myapp-${VERSION}"

# Promote artifacts between environments
promote_artifact() {
    local from_env=$1
    local to_env=$2
    
    # Copy artifact with environment-specific configuration
    docker pull "${REGISTRY}/${ARTIFACT_NAME}:${from_env}"
    docker tag "${REGISTRY}/${ARTIFACT_NAME}:${from_env}" \
               "${REGISTRY}/${ARTIFACT_NAME}:${to_env}"
    docker push "${REGISTRY}/${ARTIFACT_NAME}:${to_env}"
}
```

### Testing Strategy

#### Test Pyramid Implementation
```yaml
# Testing stages in CI/CD
unit-tests:
  stage: test
  script:
    - npm run test:unit
    - npm run test:coverage
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'

integration-tests:
  stage: test
  script:
    - docker-compose up -d test-db
    - npm run test:integration
  after_script:
    - docker-compose down

e2e-tests:
  stage: test
  script:
    - npm run test:e2e
  only:
    - main
    - develop
```

#### Contract Testing
```javascript
// Example: API contract testing with Pact
const { Pact } = require('@pact-foundation/pact');

const provider = new Pact({
  consumer: 'Frontend',
  provider: 'UserService',
  port: 1234,
  log: path.resolve(process.cwd(), 'logs', 'pact.log'),
  dir: path.resolve(process.cwd(), 'pacts'),
});
```

### Deployment Strategies

#### Blue-Green Deployment
```bash
#!/bin/bash
# Blue-Green deployment script with health checks

deploy_blue_green() {
    local new_version=$1
    local environment=$2
    
    # Deploy to inactive environment
    kubectl set image deployment/app-green app=myapp:${new_version} -n ${environment}
    
    # Wait for rollout
    kubectl rollout status deployment/app-green -n ${environment} --timeout=300s
    
    # Health check
    if health_check "app-green.${environment}.svc.cluster.local"; then
        # Switch traffic
        kubectl patch service app -p '{"spec":{"selector":{"version":"green"}}}' -n ${environment}
        
        # Cleanup old version after delay
        sleep 300
        kubectl delete deployment app-blue -n ${environment}
    else
        echo "Health check failed, rolling back..."
        return 1
    fi
}
```

#### Canary Deployment with Istio
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: app-canary
spec:
  hosts:
  - app
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: app
        subset: v2
  - route:
    - destination:
        host: app
        subset: v1
      weight: 90
    - destination:
        host: app
        subset: v2
      weight: 10
```

## 🏗️ Infrastructure as Code

### Terraform Best Practices

#### Module Structure
```
terraform/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── eks/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── shared/
    ├── backend.tf
    └── provider.tf
```

#### State Management
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

#### Resource Tagging Strategy
```hcl
# Standard tags for all resources
locals {
  standard_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.team_name
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = merge(local.standard_tags, {
    Name = "${var.project_name}-web-${var.environment}"
    Type = "web-server"
  })
}
```

### Configuration Management

#### Ansible Playbook Structure
```yaml
# site.yml - Main playbook
---
- hosts: web_servers
  become: yes
  roles:
    - common
    - nginx
    - application
  vars:
    app_version: "{{ lookup('env', 'APP_VERSION') | default('latest') }}"
  
- hosts: db_servers
  become: yes
  roles:
    - common
    - postgresql
    - backup
```

#### Variable Management
```yaml
# group_vars/all.yml
common_packages:
  - curl
  - wget
  - git
  - htop

# group_vars/production.yml
environment: production
log_level: warn
backup_retention_days: 30

# host_vars/web01.yml
server_role: primary
custom_config:
  max_connections: 1000
```

## ☸️ Container and Kubernetes

### Container Best Practices

#### Dockerfile Optimization
```dockerfile
# Multi-stage build with security best practices
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

WORKDIR /app
COPY --from=builder --chown=nodeuser:nodejs /app/node_modules ./node_modules
COPY --chown=nodeuser:nodejs . .

USER nodeuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

#### Image Security Scanning
```bash
# Comprehensive image scanning
scan_image() {
    local image=$1
    
    # Vulnerability scanning
    trivy image --exit-code 1 --severity HIGH,CRITICAL $image
    
    # Configuration scanning
    dockle --exit-code 1 --exit-level WARN $image
    
    # Secret scanning
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        secretscanner/secret-scanner:latest $image
}
```

### Kubernetes Resource Management

#### Resource Quotas and Limits
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: 200Gi
    limits.cpu: "200"
    limits.memory: 400Gi
    persistentvolumeclaims: "10"
    services.loadbalancers: "5"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range
  namespace: production
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

#### Pod Security Standards
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
```

### Service Mesh Configuration

#### Istio Traffic Management
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: app-destination
spec:
  host: app
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
    circuitBreaker:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

## 📊 Monitoring and Observability

### Prometheus Configuration

#### Recording Rules
```yaml
groups:
- name: app_performance
  rules:
  - record: app:request_rate_5m
    expr: rate(http_requests_total[5m])
  
  - record: app:error_rate_5m
    expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
  
  - record: app:latency_p99_5m
    expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

#### Alert Rules
```yaml
groups:
- name: app_alerts
  rules:
  - alert: HighErrorRate
    expr: app:error_rate_5m > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} for service {{ $labels.service }}"
  
  - alert: HighLatency
    expr: app:latency_p99_5m > 0.5
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High latency detected"
      description: "99th percentile latency is {{ $value }}s"
```

### Grafana Dashboard Best Practices

#### Dashboard Design Principles
```json
{
  "dashboard": {
    "title": "Application Performance",
    "templating": {
      "list": [
        {
          "name": "service",
          "type": "query",
          "query": "label_values(http_requests_total, service)"
        },
        {
          "name": "environment",
          "type": "query",
          "query": "label_values(http_requests_total, environment)"
        }
      ]
    },
    "panels": [
      {
        "title": "Request Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{service=\"$service\",environment=\"$environment\"}[5m]))"
          }
        ]
      }
    ]
  }
}
```

### Log Management

#### Structured Logging Best Practices
```python
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'service': 'user-service',
            'version': '1.2.3',
            'trace_id': getattr(record, 'trace_id', None),
            'user_id': getattr(record, 'user_id', None)
        }
        
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
            
        return json.dumps(log_entry)

# Configure logger
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)
```

#### ELK Stack Configuration
```yaml
# Logstash configuration
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] {
    mutate {
      add_tag => ["service", "%{[fields][service]}"]
    }
  }
  
  if [message] =~ /^\{/ {
    json {
      source => "message"
    }
  }
  
  date {
    match => ["timestamp", "ISO8601"]
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{[fields][environment]}-%{+YYYY.MM.dd}"
  }
}
```

## 🔒 Security and Compliance

### Security Scanning Integration

#### SAST Integration
```yaml
# GitHub Actions security scanning
security-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Run Semgrep
      uses: returntocorp/semgrep-action@v1
      with:
        config: >-
          p/security-audit
          p/secrets
          p/owasp-top-ten
    
    - name: Run CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: javascript, python
    
    - name: Build
      run: npm run build
    
    - name: Run CodeQL Analysis
      uses: github/codeql-action/analyze@v3
```

#### Container Security
```bash
# Container security scanning script
scan_container_security() {
    local image=$1
    
    # Vulnerability scanning
    trivy image --exit-code 1 --severity HIGH,CRITICAL $image
    
    # Best practices scanning
    dockle --exit-code 1 $image
    
    # Runtime security policy
    cat > security-policy.yaml << EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: app-policy
spec:
  selector:
    matchLabels:
      app: myapp
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/frontend/sa/frontend"]
  - to:
    - operation:
        methods: ["GET", "POST"]
EOF
}
```

### Secrets Management

#### HashiCorp Vault Integration
```python
import hvac

class VaultSecretManager:
    def __init__(self, vault_url, token):
        self.client = hvac.Client(url=vault_url, token=token)
    
    def get_secret(self, path):
        """Retrieve secret from Vault"""
        try:
            response = self.client.secrets.kv.v2.read_secret_version(path=path)
            return response['data']['data']
        except Exception as e:
            logger.error(f"Failed to retrieve secret from {path}: {e}")
            raise
    
    def rotate_secret(self, path, new_value):
        """Rotate secret in Vault"""
        try:
            self.client.secrets.kv.v2.create_or_update_secret(
                path=path,
                secret=new_value
            )
            logger.info(f"Secret rotated successfully at {path}")
        except Exception as e:
            logger.error(f"Failed to rotate secret at {path}: {e}")
            raise

# Usage
vault = VaultSecretManager('https://vault.company.com', token)
db_credentials = vault.get_secret('database/prod/credentials')
```

## 🛠️ Troubleshooting Guide

### Common CI/CD Issues

#### Pipeline Failures
```bash
# Debug pipeline issues
debug_pipeline() {
    local pipeline_id=$1
    
    # Check pipeline logs
    echo "=== Pipeline Logs ==="
    gitlab-cli pipeline logs $pipeline_id
    
    # Check resource usage
    echo "=== Resource Usage ==="
    kubectl top pods -n gitlab-runner
    
    # Check runner capacity
    echo "=== Runner Status ==="
    gitlab-cli runners list --status online
    
    # Common fixes
    echo "=== Common Solutions ==="
    echo "1. Clear Docker image cache"
    echo "2. Increase runner memory/CPU"
    echo "3. Check network connectivity"
    echo "4. Verify secrets and credentials"
}
```

#### Build Performance Issues
```yaml
# Optimized build configuration
build:
  stage: build
  image: node:18-alpine
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
      - .npm/
  before_script:
    - npm ci --cache .npm --prefer-offline
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour
```

### Kubernetes Troubleshooting

#### Pod Issues
```bash
# Comprehensive pod debugging
debug_pod() {
    local pod_name=$1
    local namespace=${2:-default}
    
    echo "=== Pod Status ==="
    kubectl get pod $pod_name -n $namespace -o wide
    
    echo "=== Pod Events ==="
    kubectl get events --field-selector involvedObject.name=$pod_name -n $namespace
    
    echo "=== Pod Logs ==="
    kubectl logs $pod_name -n $namespace --previous --tail=100
    
    echo "=== Pod Description ==="
    kubectl describe pod $pod_name -n $namespace
    
    echo "=== Resource Usage ==="
    kubectl top pod $pod_name -n $namespace
    
    # Check node resources
    echo "=== Node Resources ==="
    node=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.spec.nodeName}')
    kubectl describe node $node | grep -A 5 "Allocated resources"
}
```

#### Network Issues
```bash
# Network connectivity debugging
debug_network() {
    local service_name=$1
    local namespace=${2:-default}
    
    echo "=== Service Status ==="
    kubectl get svc $service_name -n $namespace -o wide
    
    echo "=== Endpoints ==="
    kubectl get endpoints $service_name -n $namespace
    
    echo "=== Network Policies ==="
    kubectl get networkpolicy -n $namespace
    
    # Test connectivity
    echo "=== Connectivity Test ==="
    kubectl run debug-pod --image=nicolaka/netshoot --rm -it -- \
        curl -v http://$service_name.$namespace.svc.cluster.local
}
```

### Performance Issues

#### Application Performance
```bash
# Performance analysis script
analyze_performance() {
    local app_name=$1
    local namespace=${2:-default}
    
    echo "=== Resource Utilization ==="
    kubectl top pods -l app=$app_name -n $namespace
    
    echo "=== HPA Status ==="
    kubectl get hpa -l app=$app_name -n $namespace
    
    echo "=== Pod Distribution ==="
    kubectl get pods -l app=$app_name -n $namespace -o wide
    
    echo "=== Response Time Analysis ==="
    # Prometheus query for response times
    promtool query instant 'histogram_quantile(0.95, 
        rate(http_request_duration_seconds_bucket{app="'$app_name'"}[5m]))'
    
    echo "=== Error Rate Analysis ==="
    promtool query instant 'rate(http_requests_total{app="'$app_name'",status=~"5.."}[5m]) / 
        rate(http_requests_total{app="'$app_name'"}[5m])'
}
```

#### Database Performance
```sql
-- PostgreSQL performance analysis
-- Check slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;

-- Check table statistics
SELECT 
    schemaname,
    tablename,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_dead_tup
FROM pg_stat_user_tables 
ORDER BY n_dead_tup DESC;
```

## 🚀 Performance Optimization

### Application Optimization

#### Caching Strategies
```python
# Multi-level caching implementation
import redis
from functools import wraps
import json

class CacheManager:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def cache_result(self, ttl=300):
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                # Generate cache key
                cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
                
                # Try to get from cache
                cached_result = self.redis.get(cache_key)
                if cached_result:
                    return json.loads(cached_result)
                
                # Execute function and cache result
                result = func(*args, **kwargs)
                self.redis.setex(cache_key, ttl, json.dumps(result))
                return result
            return wrapper
        return decorator

# Usage
cache_manager = CacheManager(redis.Redis(host='redis'))

@cache_manager.cache_result(ttl=600)
def expensive_computation(param1, param2):
    # Expensive operation
    return result
```

#### Database Optimization
```python
# Database connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:password@host:port/database',
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=30,
    pool_pre_ping=True,
    pool_recycle=3600
)

# Query optimization with indexes
CREATE INDEX CONCURRENTLY idx_users_email_active 
ON users(email) WHERE active = true;

CREATE INDEX CONCURRENTLY idx_orders_created_status 
ON orders(created_at, status) 
WHERE status IN ('pending', 'processing');
```

### Infrastructure Optimization

#### Auto-scaling Configuration
```yaml
# Horizontal Pod Autoscaler with custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 3
  maxReplicas: 100
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
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
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
        value: 50
        periodSeconds: 60
```

#### Cluster Autoscaling
```yaml
# Cluster Autoscaler configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      containers:
      - image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0
        name: cluster-autoscaler
        command:
        - ./cluster-autoscaler
        - --v=4
        - --stderrthreshold=info
        - --cloud-provider=aws
        - --skip-nodes-with-local-storage=false
        - --expander=least-waste
        - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/production
        - --balance-similar-node-groups
        - --scale-down-enabled=true
        - --scale-down-delay-after-add=10m
        - --scale-down-unneeded-time=10m
```

## 🚨 Disaster Recovery

### Backup Strategies

#### Database Backup Automation
```bash
#!/bin/bash
# Automated database backup with rotation

backup_database() {
    local db_name=$1
    local retention_days=${2:-7}
    local backup_dir="/backups/postgresql"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/${db_name}_${timestamp}.sql.gz"
    
    # Create backup directory
    mkdir -p $backup_dir
    
    # Create backup
    echo "Creating backup of $db_name..."
    pg_dump $db_name | gzip > $backup_file
    
    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $backup_file"
        
        # Upload to S3
        aws s3 cp $backup_file s3://company-backups/postgresql/
        
        # Clean up old backups
        find $backup_dir -name "${db_name}_*.sql.gz" -type f -mtime +$retention_days -delete
        
        # Clean up old S3 backups
        aws s3 ls s3://company-backups/postgresql/ --recursive | \
        awk '{print $4}' | \
        grep "${db_name}_" | \
        head -n -$retention_days | \
        xargs -I {} aws s3 rm s3://company-backups/postgresql/{}
    else
        echo "Backup failed for $db_name"
        exit 1
    fi
}

# Schedule with cron
# 0 2 * * * /usr/local/bin/backup_database.sh production_db 30
```

#### Application State Backup
```yaml
# Velero backup configuration
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: production-backup
spec:
  includedNamespaces:
  - production
  - monitoring
  excludedResources:
  - events
  - events.events.k8s.io
  storageLocation: aws-s3
  ttl: 720h0m0s  # 30 days
  snapshotVolumes: true
  hooks:
    resources:
    - name: database-backup-hook
      includedNamespaces:
      - production
      includedResources:
      - pods
      labelSelector:
        matchLabels:
          app: database
      pre:
      - exec:
          command:
          - /bin/bash
          - -c
          - pg_dump production | gzip > /tmp/backup.sql.gz
      post:
      - exec:
          command:
          - rm
          - -f
          - /tmp/backup.sql.gz
```

### Recovery Procedures

#### Point-in-Time Recovery
```bash
# PostgreSQL point-in-time recovery
restore_database() {
    local target_time=$1
    local backup_file=$2
    local recovery_dir="/var/lib/postgresql/recovery"
    
    # Stop PostgreSQL service
    systemctl stop postgresql
    
    # Backup current data
    mv /var/lib/postgresql/data /var/lib/postgresql/data.backup
    
    # Create recovery directory
    mkdir -p $recovery_dir
    cd $recovery_dir
    
    # Restore base backup
    tar -xzf $backup_file
    
    # Configure recovery
    cat > recovery.conf << EOF
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
recovery_target_time = '$target_time'
recovery_target_action = 'promote'
EOF
    
    # Start PostgreSQL in recovery mode
    chown -R postgres:postgres $recovery_dir
    sudo -u postgres pg_ctl start -D $recovery_dir
    
    echo "Recovery initiated. Target time: $target_time"
}
```

#### Cross-Region Failover
```bash
# Automated cross-region failover
failover_to_dr() {
    local primary_region=$1
    local dr_region=$2
    local app_name=$3
    
    echo "Initiating failover from $primary_region to $dr_region"
    
    # Update DNS to point to DR region
    aws route53 change-resource-record-sets \
        --hosted-zone-id Z123456789 \
        --change-batch '{
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "api.company.com",
                    "Type": "CNAME",
                    "TTL": 60,
                    "ResourceRecords": [{"Value": "api-dr.company.com"}]
                }
            }]
        }'
    
    # Scale up DR environment
    kubectl config use-context dr-cluster
    kubectl scale deployment $app_name --replicas=10
    
    # Promote read replica to primary
    aws rds promote-read-replica \
        --db-instance-identifier ${app_name}-dr-replica
    
    # Update application configuration
    kubectl patch configmap app-config \
        -p '{"data":{"database_url":"postgresql://dr-host:5432/production"}}'
    
    # Restart application pods
    kubectl rollout restart deployment $app_name
    
    echo "Failover completed. Monitor application health."
}
```

---

This comprehensive guide provides practical, production-tested solutions for common DevOps challenges. Remember to adapt these practices to your specific environment and requirements.

For additional support, refer to:
- [Project Documentation](../docs/)
- [Community Forums](https://github.com/your-org/devops-repo/discussions)
- [Issue Tracker](https://github.com/your-org/devops-repo/issues)
