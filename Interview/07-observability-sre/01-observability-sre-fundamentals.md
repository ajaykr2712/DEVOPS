# Observability & SRE Fundamentals

## Table of Contents
1. [Overview](#overview)
2. [Logging](#logging)
3. [Metrics & Monitoring](#metrics--monitoring)
4. [Alerting](#alerting)
5. [Distributed Tracing](#distributed-tracing)
6. [Incident Response](#incident-response)
7. [SLIs, SLOs, and Error Budgets](#slis-slos-and-error-budgets)
8. [Blackbox Monitoring](#chaos-engineering)
9. [Chaos Engineering](#chaos-engineering)
10. [Tools and Platforms](#tools-and-platforms)
11. [Interview Questions & Answers](#interview-questions--answers)

## Overview

Observability is the ability to understand the internal state of a system based on its external outputs. The three pillars of observability are:

1. **Logs** - Discrete events with timestamps
2. **Metrics** - Numerical data points over time
3. **Traces** - Request flows through distributed systems

SRE (Site Reliability Engineering) focuses on maintaining system reliability through automation, monitoring, and incident management.

## Logging

### Structured Logging Implementation

```python
import json
import logging
import sys
from datetime import datetime
from typing import Any, Dict

class StructuredLogger:
    def __init__(self, service_name: str, version: str):
        self.service_name = service_name
        self.version = version
        self.logger = logging.getLogger(service_name)
        self.logger.setLevel(logging.INFO)
        
        # Create structured formatter
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(self._get_formatter())
        self.logger.addHandler(handler)
    
    def _get_formatter(self):
        return logging.Formatter('%(message)s')
    
    def _create_log_entry(self, level: str, message: str, **kwargs) -> str:
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": level,
            "service": self.service_name,
            "version": self.version,
            "message": message,
            **kwargs
        }
        return json.dumps(log_entry)
    
    def info(self, message: str, **kwargs):
        self.logger.info(self._create_log_entry("INFO", message, **kwargs))
    
    def error(self, message: str, **kwargs):
        self.logger.error(self._create_log_entry("ERROR", message, **kwargs))
    
    def warning(self, message: str, **kwargs):
        self.logger.warning(self._create_log_entry("WARNING", message, **kwargs))

# Usage example
logger = StructuredLogger("user-service", "1.2.3")

def process_user_request(user_id: str, action: str):
    try:
        logger.info(
            "Processing user request",
            user_id=user_id,
            action=action,
            request_id="req-12345"
        )
        
        # Simulate processing
        if action == "delete" and user_id == "admin":
            raise ValueError("Cannot delete admin user")
        
        logger.info(
            "Request processed successfully",
            user_id=user_id,
            action=action,
            duration_ms=150
        )
        
    except Exception as e:
        logger.error(
            "Request processing failed",
            user_id=user_id,
            action=action,
            error=str(e),
            error_type=type(e).__name__
        )
        raise
```

### Log Aggregation with ELK Stack

```yaml
# docker-compose.yml for ELK stack
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.8.0
    ports:
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "user-service" {
    json {
      source => "message"
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    # Add custom fields
    mutate {
      add_field => { "environment" => "production" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

## Metrics & Monitoring

### Prometheus Metrics Implementation

```python
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import random
from functools import wraps

# Define metrics
request_count = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('app_request_duration_seconds', 'Request duration')
active_users = Gauge('app_active_users', 'Number of active users')
db_connection_pool = Gauge('app_db_connections', 'Database connections', ['state'])

def track_metrics(endpoint: str):
    """Decorator to track request metrics"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            method = kwargs.get('method', 'GET')
            
            try:
                result = func(*args, **kwargs)
                status = '200'
                return result
            except Exception as e:
                status = '500'
                raise
            finally:
                # Record metrics
                request_count.labels(method=method, endpoint=endpoint, status=status).inc()
                request_duration.observe(time.time() - start_time)
        
        return wrapper
    return decorator

class UserService:
    def __init__(self):
        self.active_user_count = 0
    
    @track_metrics('/users')
    def get_users(self, method='GET'):
        # Simulate database query
        time.sleep(random.uniform(0.1, 0.5))
        return {"users": ["alice", "bob"]}
    
    @track_metrics('/users')
    def create_user(self, method='POST'):
        # Simulate user creation
        time.sleep(random.uniform(0.2, 0.8))
        self.active_user_count += 1
        active_users.set(self.active_user_count)
        return {"status": "created"}
    
    def update_db_metrics(self):
        """Update database connection metrics"""
        # Simulate connection pool stats
        db_connection_pool.labels(state='active').set(random.randint(5, 20))
        db_connection_pool.labels(state='idle').set(random.randint(0, 10))

# Start metrics server
if __name__ == "__main__":
    start_http_server(8000)
    service = UserService()
    
    # Simulate traffic
    while True:
        service.get_users()
        if random.random() > 0.7:
            service.create_user(method='POST')
        service.update_db_metrics()
        time.sleep(1)
```

### Grafana Dashboard Configuration

```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(app_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Request Duration",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Active Users",
        "type": "singlestat",
        "targets": [
          {
            "expr": "app_active_users"
          }
        ]
      }
    ]
  }
}
```

## Alerting

### Prometheus Alerting Rules

```yaml
# alerting_rules.yml
groups:
- name: application_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(app_requests_total{status="500"}[5m]) > 0.1
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} requests/sec for the last 5 minutes"

  - alert: HighResponseTime
    expr: histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m])) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High response time detected"
      description: "95th percentile response time is {{ $value }}s"

  - alert: LowActiveUsers
    expr: app_active_users < 10
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Low user activity"
      description: "Only {{ $value }} active users"

  - alert: DatabaseConnectionsHigh
    expr: app_db_connections{state="active"} > 50
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High database connection usage"
      description: "{{ $value }} active database connections"
```

### PagerDuty Integration

```python
import requests
import json
from typing import Dict, Any

class PagerDutyClient:
    def __init__(self, routing_key: str):
        self.routing_key = routing_key
        self.url = "https://events.pagerduty.com/v2/enqueue"
    
    def trigger_incident(self, summary: str, severity: str, source: str, 
                        custom_details: Dict[str, Any] = None):
        """Trigger a PagerDuty incident"""
        payload = {
            "routing_key": self.routing_key,
            "event_action": "trigger",
            "payload": {
                "summary": summary,
                "severity": severity,
                "source": source,
                "custom_details": custom_details or {}
            }
        }
        
        response = requests.post(
            self.url,
            headers={"Content-Type": "application/json"},
            data=json.dumps(payload)
        )
        
        return response.json()
    
    def resolve_incident(self, dedup_key: str):
        """Resolve a PagerDuty incident"""
        payload = {
            "routing_key": self.routing_key,
            "event_action": "resolve",
            "dedup_key": dedup_key
        }
        
        response = requests.post(
            self.url,
            headers={"Content-Type": "application/json"},
            data=json.dumps(payload)
        )
        
        return response.json()

# Alert handler
class AlertHandler:
    def __init__(self, pagerduty_client: PagerDutyClient):
        self.pd_client = pagerduty_client
        self.active_incidents = {}
    
    def handle_alert(self, alert_name: str, status: str, labels: Dict[str, str],
                    annotations: Dict[str, str]):
        """Handle incoming alert from Prometheus"""
        
        if status == "firing":
            incident = self.pd_client.trigger_incident(
                summary=annotations.get("summary", alert_name),
                severity=labels.get("severity", "warning"),
                source=labels.get("instance", "unknown"),
                custom_details={
                    "alert_name": alert_name,
                    "labels": labels,
                    "annotations": annotations
                }
            )
            
            if "dedup_key" in incident:
                self.active_incidents[alert_name] = incident["dedup_key"]
        
        elif status == "resolved" and alert_name in self.active_incidents:
            self.pd_client.resolve_incident(self.active_incidents[alert_name])
            del self.active_incidents[alert_name]
```

## Distributed Tracing

### OpenTelemetry Implementation

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
import requests
import time

# Configure tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configure Jaeger exporter
jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)

span_processor = BatchSpanProcessor(jaeger_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Auto-instrument libraries
RequestsInstrumentor().instrument()

class UserService:
    def __init__(self):
        self.tracer = trace.get_tracer(__name__)
    
    def get_user(self, user_id: str) -> dict:
        with self.tracer.start_as_current_span("get_user") as span:
            span.set_attribute("user.id", user_id)
            
            # Simulate database call
            user_data = self._fetch_from_database(user_id)
            
            # Fetch additional data from external service
            profile_data = self._fetch_user_profile(user_id)
            
            span.set_attribute("user.found", user_data is not None)
            
            return {
                "user": user_data,
                "profile": profile_data
            }
    
    def _fetch_from_database(self, user_id: str) -> dict:
        with self.tracer.start_as_current_span("database_query") as span:
            span.set_attribute("db.operation", "SELECT")
            span.set_attribute("db.table", "users")
            span.set_attribute("user.id", user_id)
            
            # Simulate DB latency
            time.sleep(0.1)
            
            return {"id": user_id, "name": f"User {user_id}"}
    
    def _fetch_user_profile(self, user_id: str) -> dict:
        with self.tracer.start_as_current_span("external_api_call") as span:
            span.set_attribute("http.method", "GET")
            span.set_attribute("http.url", f"https://api.example.com/profiles/{user_id}")
            
            try:
                # Simulate external API call
                time.sleep(0.2)
                response_data = {"profile_id": f"prof_{user_id}", "preferences": {}}
                
                span.set_attribute("http.status_code", 200)
                return response_data
                
            except Exception as e:
                span.set_attribute("error", True)
                span.set_attribute("error.message", str(e))
                raise

# Custom span decorator
def trace_function(operation_name: str):
    def decorator(func):
        def wrapper(*args, **kwargs):
            with tracer.start_as_current_span(operation_name) as span:
                span.set_attribute("function.name", func.__name__)
                try:
                    result = func(*args, **kwargs)
                    span.set_attribute("success", True)
                    return result
                except Exception as e:
                    span.set_attribute("error", True)
                    span.set_attribute("error.message", str(e))
                    raise
        return wrapper
    return decorator

@trace_function("process_order")
def process_order(order_id: str, user_id: str):
    # Business logic here
    time.sleep(0.3)
    return {"order_id": order_id, "status": "processed"}
```

## Incident Response

### Incident Management Framework

```python
from enum import Enum
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import json

class IncidentSeverity(Enum):
    SEV1 = "sev1"  # Critical - System down
    SEV2 = "sev2"  # High - Major functionality impaired
    SEV3 = "sev3"  # Medium - Minor functionality impaired
    SEV4 = "sev4"  # Low - Cosmetic issues

class IncidentStatus(Enum):
    INVESTIGATING = "investigating"
    IDENTIFIED = "identified"
    MONITORING = "monitoring"
    RESOLVED = "resolved"

class Incident:
    def __init__(self, title: str, severity: IncidentSeverity, 
                 description: str, affected_systems: List[str]):
        self.id = self._generate_id()
        self.title = title
        self.severity = severity
        self.description = description
        self.affected_systems = affected_systems
        self.status = IncidentStatus.INVESTIGATING
        self.created_at = datetime.utcnow()
        self.updates = []
        self.commander = None
        self.responders = []
        self.resolved_at = None
    
    def _generate_id(self) -> str:
        return f"INC-{datetime.utcnow().strftime('%Y%m%d')}-{id(self) % 10000:04d}"
    
    def add_update(self, message: str, author: str):
        update = {
            "timestamp": datetime.utcnow().isoformat(),
            "message": message,
            "author": author
        }
        self.updates.append(update)
    
    def assign_commander(self, commander: str):
        self.commander = commander
        self.add_update(f"Incident commander assigned: {commander}", "system")
    
    def add_responder(self, responder: str):
        if responder not in self.responders:
            self.responders.append(responder)
            self.add_update(f"Responder added: {responder}", "system")
    
    def update_status(self, status: IncidentStatus, message: str, author: str):
        self.status = status
        self.add_update(f"Status changed to {status.value}: {message}", author)
        
        if status == IncidentStatus.RESOLVED:
            self.resolved_at = datetime.utcnow()
    
    def get_duration(self) -> Optional[timedelta]:
        if self.resolved_at:
            return self.resolved_at - self.created_at
        return datetime.utcnow() - self.created_at
    
    def to_dict(self) -> Dict:
        return {
            "id": self.id,
            "title": self.title,
            "severity": self.severity.value,
            "description": self.description,
            "affected_systems": self.affected_systems,
            "status": self.status.value,
            "created_at": self.created_at.isoformat(),
            "resolved_at": self.resolved_at.isoformat() if self.resolved_at else None,
            "duration_minutes": int(self.get_duration().total_seconds() / 60),
            "commander": self.commander,
            "responders": self.responders,
            "updates": self.updates
        }

class IncidentResponse:
    def __init__(self):
        self.incidents = {}
        self.escalation_matrix = {
            IncidentSeverity.SEV1: ["oncall-engineer", "engineering-manager", "cto"],
            IncidentSeverity.SEV2: ["oncall-engineer", "engineering-manager"],
            IncidentSeverity.SEV3: ["oncall-engineer"],
            IncidentSeverity.SEV4: ["oncall-engineer"]
        }
    
    def create_incident(self, title: str, severity: IncidentSeverity,
                       description: str, affected_systems: List[str]) -> Incident:
        incident = Incident(title, severity, description, affected_systems)
        self.incidents[incident.id] = incident
        
        # Auto-escalate based on severity
        self._escalate_incident(incident)
        
        return incident
    
    def _escalate_incident(self, incident: Incident):
        """Automatically escalate incident based on severity"""
        responders = self.escalation_matrix.get(incident.severity, [])
        
        for responder in responders:
            incident.add_responder(responder)
        
        # Auto-assign commander for SEV1/SEV2
        if incident.severity in [IncidentSeverity.SEV1, IncidentSeverity.SEV2]:
            if responders:
                incident.assign_commander(responders[0])
    
    def get_active_incidents(self) -> List[Incident]:
        return [inc for inc in self.incidents.values() 
                if inc.status != IncidentStatus.RESOLVED]
    
    def generate_post_mortem_template(self, incident_id: str) -> str:
        incident = self.incidents.get(incident_id)
        if not incident:
            return "Incident not found"
        
        template = f"""
# Post-Mortem: {incident.title}

## Incident Summary
- **Incident ID**: {incident.id}
- **Severity**: {incident.severity.value.upper()}
- **Duration**: {incident.get_duration()}
- **Affected Systems**: {', '.join(incident.affected_systems)}
- **Incident Commander**: {incident.commander}

## Timeline
"""
        for update in incident.updates:
            template += f"- **{update['timestamp']}**: {update['message']} (by {update['author']})\n"
        
        template += """
## Root Cause Analysis
<!-- Fill in the root cause of the incident -->

## Contributing Factors
<!-- List factors that contributed to the incident -->

## Resolution
<!-- Describe how the incident was resolved -->

## Action Items
<!-- List specific action items to prevent similar incidents -->
- [ ] Action item 1
- [ ] Action item 2

## Lessons Learned
<!-- Key takeaways and improvements -->
"""
        return template

# Example usage
def simulate_incident_response():
    ir = IncidentResponse()
    
    # Create a critical incident
    incident = ir.create_incident(
        title="Database connection pool exhausted",
        severity=IncidentSeverity.SEV1,
        description="All database connections are in use, causing API timeouts",
        affected_systems=["user-service", "order-service", "payment-service"]
    )
    
    # Add updates as investigation progresses
    incident.add_update("Investigation started, checking connection pool metrics", "alice")
    incident.add_update("Found connection leak in user-service", "bob")
    incident.add_update("Deployed hotfix to release connections", "alice")
    incident.update_status(IncidentStatus.RESOLVED, "Connection pool normalized", "alice")
    
    # Generate post-mortem
    post_mortem = ir.generate_post_mortem_template(incident.id)
    print(post_mortem)
```

## SLIs, SLOs, and Error Budgets

### Service Level Management

```python
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import math

class SLI:
    """Service Level Indicator"""
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.measurements = []
    
    def record_measurement(self, value: float, timestamp: Optional[datetime] = None):
        if timestamp is None:
            timestamp = datetime.utcnow()
        self.measurements.append({"value": value, "timestamp": timestamp})
    
    def get_current_value(self, window_minutes: int = 60) -> float:
        """Get current SLI value over specified window"""
        cutoff = datetime.utcnow() - timedelta(minutes=window_minutes)
        recent_measurements = [
            m for m in self.measurements 
            if m["timestamp"] > cutoff
        ]
        
        if not recent_measurements:
            return 0.0
        
        return sum(m["value"] for m in recent_measurements) / len(recent_measurements)

class SLO:
    """Service Level Objective"""
    def __init__(self, sli: SLI, target: float, window_days: int = 30):
        self.sli = sli
        self.target = target  # e.g., 99.9 for 99.9% availability
        self.window_days = window_days
    
    def get_compliance(self) -> Dict:
        """Calculate SLO compliance"""
        cutoff = datetime.utcnow() - timedelta(days=self.window_days)
        measurements = [
            m for m in self.sli.measurements 
            if m["timestamp"] > cutoff
        ]
        
        if not measurements:
            return {"compliance": 0.0, "error_budget_remaining": 1.0}
        
        # Calculate average performance
        avg_performance = sum(m["value"] for m in measurements) / len(measurements)
        compliance = min(avg_performance / self.target * 100, 100.0)
        
        # Calculate error budget consumption
        error_budget_consumed = max(0, (self.target - avg_performance) / (100 - self.target))
        error_budget_remaining = max(0, 1 - error_budget_consumed)
        
        return {
            "compliance": compliance,
            "current_performance": avg_performance,
            "target": self.target,
            "error_budget_consumed": error_budget_consumed,
            "error_budget_remaining": error_budget_remaining,
            "window_days": self.window_days
        }

class ErrorBudgetPolicy:
    """Error budget policy for controlling releases"""
    def __init__(self, slo: SLO):
        self.slo = slo
    
    def can_release(self, risk_level: str = "medium") -> Dict:
        """Determine if release is allowed based on error budget"""
        compliance = self.slo.get_compliance()
        error_budget_remaining = compliance["error_budget_remaining"]
        
        # Risk thresholds
        thresholds = {
            "low": 0.1,      # Allow release if 10%+ error budget remains
            "medium": 0.25,  # Allow release if 25%+ error budget remains
            "high": 0.5      # Allow release if 50%+ error budget remains
        }
        
        threshold = thresholds.get(risk_level, 0.25)
        can_release = error_budget_remaining >= threshold
        
        return {
            "can_release": can_release,
            "risk_level": risk_level,
            "error_budget_remaining": error_budget_remaining,
            "threshold": threshold,
            "reason": self._get_reason(can_release, error_budget_remaining, threshold)
        }
    
    def _get_reason(self, can_release: bool, remaining: float, threshold: float) -> str:
        if can_release:
            return f"Release approved: {remaining:.1%} error budget remaining (>{threshold:.1%} required)"
        else:
            return f"Release blocked: Only {remaining:.1%} error budget remaining (<{threshold:.1%} required)"

# Example SLI/SLO setup
class ServiceReliability:
    def __init__(self):
        # Define SLIs
        self.availability_sli = SLI("availability", "Percentage of successful requests")
        self.latency_sli = SLI("latency", "Percentage of requests under 100ms")
        self.error_rate_sli = SLI("error_rate", "Percentage of requests without errors")
        
        # Define SLOs
        self.availability_slo = SLO(self.availability_sli, 99.9)  # 99.9% availability
        self.latency_slo = SLO(self.latency_sli, 95.0)           # 95% under 100ms
        self.error_rate_slo = SLO(self.error_rate_sli, 99.5)     # 99.5% success rate
        
        # Define error budget policies
        self.availability_policy = ErrorBudgetPolicy(self.availability_slo)
        self.latency_policy = ErrorBudgetPolicy(self.latency_slo)
        self.error_rate_policy = ErrorBudgetPolicy(self.error_rate_slo)
    
    def record_metrics(self, successful_requests: int, total_requests: int,
                      fast_requests: int, errors: int):
        """Record SLI measurements"""
        availability = (successful_requests / total_requests) * 100
        latency_performance = (fast_requests / total_requests) * 100
        error_rate_performance = ((total_requests - errors) / total_requests) * 100
        
        self.availability_sli.record_measurement(availability)
        self.latency_sli.record_measurement(latency_performance)
        self.error_rate_sli.record_measurement(error_rate_performance)
    
    def get_release_status(self, risk_level: str = "medium") -> Dict:
        """Check if release is allowed based on all SLOs"""
        availability_status = self.availability_policy.can_release(risk_level)
        latency_status = self.latency_policy.can_release(risk_level)
        error_rate_status = self.error_rate_policy.can_release(risk_level)
        
        can_release = all([
            availability_status["can_release"],
            latency_status["can_release"],
            error_rate_status["can_release"]
        ])
        
        return {
            "can_release": can_release,
            "availability": availability_status,
            "latency": latency_status,
            "error_rate": error_rate_status,
            "overall_reason": "All SLOs meet requirements" if can_release else "One or more SLOs below threshold"
        }

# Usage example
reliability = ServiceReliability()

# Simulate metrics over time
import random
for day in range(30):
    for hour in range(24):
        total_requests = random.randint(1000, 2000)
        successful_requests = int(total_requests * random.uniform(0.995, 1.0))
        fast_requests = int(total_requests * random.uniform(0.92, 0.98))
        errors = total_requests - successful_requests
        
        reliability.record_metrics(successful_requests, total_requests, fast_requests, errors)

# Check release status
release_status = reliability.get_release_status("medium")
print(f"Can release: {release_status['can_release']}")
print(f"Reason: {release_status['overall_reason']}")
```

## Blackbox Monitoring

### External Service Monitoring

```python
import requests
import time
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Optional
import ssl
import socket
from urllib.parse import urlparse

class HealthCheck:
    def __init__(self, name: str, url: str, method: str = "GET", 
                 expected_status: int = 200, timeout: int = 30,
                 headers: Optional[Dict] = None, body: Optional[str] = None):
        self.name = name
        self.url = url
        self.method = method
        self.expected_status = expected_status
        self.timeout = timeout
        self.headers = headers or {}
        self.body = body
    
    def execute(self) -> Dict:
        """Execute health check"""
        start_time = time.time()
        
        try:
            response = requests.request(
                method=self.method,
                url=self.url,
                headers=self.headers,
                data=self.body,
                timeout=self.timeout,
                verify=True
            )
            
            duration = time.time() - start_time
            
            success = response.status_code == self.expected_status
            
            return {
                "name": self.name,
                "success": success,
                "status_code": response.status_code,
                "expected_status": self.expected_status,
                "response_time": duration,
                "error": None if success else f"Expected {self.expected_status}, got {response.status_code}",
                "timestamp": time.time()
            }
            
        except Exception as e:
            duration = time.time() - start_time
            return {
                "name": self.name,
                "success": False,
                "status_code": None,
                "expected_status": self.expected_status,
                "response_time": duration,
                "error": str(e),
                "timestamp": time.time()
            }

class SSLCheck:
    def __init__(self, hostname: str, port: int = 443):
        self.hostname = hostname
        self.port = port
    
    def execute(self) -> Dict:
        """Check SSL certificate validity"""
        try:
            context = ssl.create_default_context()
            with socket.create_connection((self.hostname, self.port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=self.hostname) as ssock:
                    cert = ssock.getpeercert()
                    
                    # Parse expiry date
                    expiry_str = cert['notAfter']
                    expiry_date = time.strptime(expiry_str, '%b %d %H:%M:%S %Y %Z')
                    expiry_timestamp = time.mktime(expiry_date)
                    
                    days_until_expiry = (expiry_timestamp - time.time()) / (24 * 3600)
                    
                    return {
                        "hostname": self.hostname,
                        "success": True,
                        "days_until_expiry": int(days_until_expiry),
                        "expiry_date": expiry_str,
                        "issuer": cert.get('issuer', [{}])[0].get('organizationName', 'Unknown'),
                        "error": None,
                        "timestamp": time.time()
                    }
                    
        except Exception as e:
            return {
                "hostname": self.hostname,
                "success": False,
                "days_until_expiry": None,
                "expiry_date": None,
                "issuer": None,
                "error": str(e),
                "timestamp": time.time()
            }

class DNSCheck:
    def __init__(self, domain: str, expected_ips: List[str] = None):
        self.domain = domain
        self.expected_ips = expected_ips or []
    
    def execute(self) -> Dict:
        """Check DNS resolution"""
        try:
            start_time = time.time()
            resolved_ips = socket.gethostbyname_ex(self.domain)[2]
            resolution_time = time.time() - start_time
            
            success = True
            error = None
            
            if self.expected_ips:
                missing_ips = set(self.expected_ips) - set(resolved_ips)
                if missing_ips:
                    success = False
                    error = f"Missing expected IPs: {list(missing_ips)}"
            
            return {
                "domain": self.domain,
                "success": success,
                "resolved_ips": resolved_ips,
                "expected_ips": self.expected_ips,
                "resolution_time": resolution_time,
                "error": error,
                "timestamp": time.time()
            }
            
        except Exception as e:
            return {
                "domain": self.domain,
                "success": False,
                "resolved_ips": [],
                "expected_ips": self.expected_ips,
                "resolution_time": None,
                "error": str(e),
                "timestamp": time.time()
            }

class BlackboxMonitor:
    def __init__(self):
        self.health_checks = []
        self.ssl_checks = []
        self.dns_checks = []
    
    def add_health_check(self, check: HealthCheck):
        self.health_checks.append(check)
    
    def add_ssl_check(self, check: SSLCheck):
        self.ssl_checks.append(check)
    
    def add_dns_check(self, check: DNSCheck):
        self.dns_checks.append(check)
    
    def run_all_checks(self) -> Dict:
        """Run all configured checks"""
        results = {
            "health_checks": [],
            "ssl_checks": [],
            "dns_checks": [],
            "summary": {}
        }
        
        # Run health checks in parallel
        with ThreadPoolExecutor(max_workers=10) as executor:
            health_futures = [executor.submit(check.execute) for check in self.health_checks]
            ssl_futures = [executor.submit(check.execute) for check in self.ssl_checks]
            dns_futures = [executor.submit(check.execute) for check in self.dns_checks]
            
            # Collect health check results
            for future in as_completed(health_futures):
                results["health_checks"].append(future.result())
            
            # Collect SSL check results
            for future in as_completed(ssl_futures):
                results["ssl_checks"].append(future.result())
            
            # Collect DNS check results
            for future in as_completed(dns_futures):
                results["dns_checks"].append(future.result())
        
        # Generate summary
        results["summary"] = self._generate_summary(results)
        
        return results
    
    def _generate_summary(self, results: Dict) -> Dict:
        """Generate summary of all checks"""
        total_checks = 0
        successful_checks = 0
        
        for check_type in ["health_checks", "ssl_checks", "dns_checks"]:
            for check in results[check_type]:
                total_checks += 1
                if check["success"]:
                    successful_checks += 1
        
        success_rate = (successful_checks / total_checks * 100) if total_checks > 0 else 0
        
        return {
            "total_checks": total_checks,
            "successful_checks": successful_checks,
            "failed_checks": total_checks - successful_checks,
            "success_rate": success_rate,
            "timestamp": time.time()
        }

# Example usage
def setup_monitoring():
    monitor = BlackboxMonitor()
    
    # Add health checks
    monitor.add_health_check(HealthCheck("API Health", "https://api.example.com/health"))
    monitor.add_health_check(HealthCheck("User Service", "https://api.example.com/users/health"))
    monitor.add_health_check(HealthCheck("Payment Service", "https://payments.example.com/health"))
    
    # Add SSL checks
    monitor.add_ssl_check(SSLCheck("api.example.com"))
    monitor.add_ssl_check(SSLCheck("payments.example.com"))
    
    # Add DNS checks
    monitor.add_dns_check(DNSCheck("api.example.com"))
    monitor.add_dns_check(DNSCheck("payments.example.com"))
    
    return monitor

# Run monitoring
if __name__ == "__main__":
    monitor = setup_monitoring()
    results = monitor.run_all_checks()
    
    print(f"Success Rate: {results['summary']['success_rate']:.1f}%")
    print(f"Total Checks: {results['summary']['total_checks']}")
    print(f"Failed Checks: {results['summary']['failed_checks']}")
    
    # Print failed checks
    for check_type in ["health_checks", "ssl_checks", "dns_checks"]:
        for check in results[check_type]:
            if not check["success"]:
                print(f"FAILED: {check.get('name', check.get('hostname', check.get('domain')))} - {check['error']}")
```

## Tools and Platforms

### Common Observability Stack Commands

```bash
# Prometheus setup
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# Grafana setup
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  grafana/grafana

# Jaeger tracing
docker run -d \
  --name jaeger \
  -p 16686:16686 \
  -p 14268:14268 \
  jaegertracing/all-in-one:latest

# ELK Stack with Docker Compose
cat > docker-compose.yml << EOF
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
  
  kibana:
    image: docker.elastic.co/kibana/kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
  
  logstash:
    image: docker.elastic.co/logstash/logstash:8.8.0
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch
EOF

docker-compose up -d

# Prometheus queries for common metrics
# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# HTTP request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Interview Questions & Answers

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is observability? | Ability to understand internal system state from external outputs |
| 2 | Easy | What are the three pillars of observability? | Metrics, logs, and traces |
| 3 | Easy | What is monitoring? | Process of collecting, aggregating, and analyzing data about system behavior |
| 4 | Easy | What is alerting? | Notifying teams when systems exceed defined thresholds or fail |
| 5 | Easy | What is SRE? | Site Reliability Engineering - engineering approach to operations |
| 6 | Easy | What is SLA? | Service Level Agreement - commitment to customers about service availability |
| 7 | Easy | What is SLO? | Service Level Objective - target level of service within SLA |
| 8 | Easy | What is SLI? | Service Level Indicator - metric that measures service performance |
| 9 | Easy | What is uptime? | Percentage of time system is operational and accessible |
| 10 | Easy | What is downtime? | Period when system is unavailable or not functioning |
| 11 | Easy | What is MTTR? | Mean Time To Recovery - average time to restore service after failure |
| 12 | Easy | What is MTBF? | Mean Time Between Failures - average time between system failures |
| 13 | Easy | What is error budget? | Amount of unreliability allowed within SLO constraints |
| 14 | Easy | What is incident? | Event causing service degradation or outage |
| 15 | Easy | What is postmortem? | Analysis document created after incident resolution |
| 16 | Medium | What is distributed tracing? | Tracking requests across multiple services in distributed systems |
| 17 | Medium | What is span in tracing? | Unit of work in trace representing single operation |
| 18 | Medium | What is sampling in tracing? | Collecting subset of traces to reduce overhead |
| 19 | Medium | What is structured logging? | Logging with consistent, machine-readable format (JSON) |
| 20 | Medium | What is log aggregation? | Collecting logs from multiple sources into central location |
| 21 | Medium | What is metric cardinality? | Number of unique time series for given metric |
| 22 | Medium | What is prometheus? | Open-source monitoring system with dimensional data model |
| 23 | Medium | What is grafana? | Visualization platform for metrics and logs |
| 24 | Medium | What is alertmanager? | Component handling alerts from Prometheus |
| 25 | Medium | What is runbook? | Documentation providing step-by-step procedures for operations |
| 26 | Medium | What is escalation policy? | Procedure for routing alerts when initial responder doesn't respond |
| 27 | Medium | What is on-call rotation? | Schedule assigning responsibility for incident response |
| 28 | Medium | What is blameless postmortem? | Analysis focusing on systems and processes, not individuals |
| 29 | Medium | What is chaos engineering? | Discipline of experimenting on systems to build confidence |
| 30 | Medium | What is canary analysis? | Monitoring technique comparing new deployment against baseline |
| 31 | Hard | What is golden signals? | Four key metrics: latency, traffic, errors, saturation |
| 32 | Hard | What is RED method? | Rate, Errors, Duration - metrics for request-driven services |
| 33 | Hard | What is USE method? | Utilization, Saturation, Errors - metrics for resource monitoring |
| 34 | Hard | What is service map? | Visual representation of service dependencies and interactions |
| 35 | Hard | What is anomaly detection? | Identifying unusual patterns in metrics or logs |
| 36 | Hard | What is capacity planning? | Predicting resource needs based on growth and usage patterns |
| 37 | Hard | What is blackbox monitoring? | Monitoring system behavior from external perspective |
| 38 | Hard | What is whitebox monitoring? | Monitoring internal system metrics and states |
| 39 | Hard | What is synthetic monitoring? | Using artificial transactions to test system availability |
| 40 | Hard | What is real user monitoring? | Collecting performance data from actual user interactions |
| 41 | Hard | What is correlation analysis? | Finding relationships between different metrics and events |
| 42 | Hard | What is root cause analysis? | Systematic process to identify underlying cause of problems |
| 43 | Hard | What is incident command system? | Structured approach to incident response with defined roles |
| 44 | Hard | What is disaster recovery testing? | Regular testing of backup and recovery procedures |
| 45 | Hard | What is load testing? | Testing system behavior under expected and peak loads |
| 46 | Expert | What is observability-driven development? | Building applications with observability as primary concern |
| 47 | Expert | What is service level management? | Ongoing process of monitoring and improving service levels |
| 48 | Expert | What is reliability engineering culture? | Organizational practices promoting reliability and learning |
| 49 | Expert | What is progressive delivery observability? | Monitoring techniques for gradual feature rollouts |
| 50 | Expert | What is ML-powered operations? | Using machine learning for anomaly detection and prediction |
| 51 | Expert | What is observability as code? | Managing observability configurations through version control |
| 52 | Expert | What is multi-cloud observability? | Monitoring across multiple cloud providers |
| 53 | Expert | What is cost observability? | Monitoring and optimizing cloud infrastructure costs |
| 54 | Expert | What is security observability? | Monitoring for security threats and compliance |
| 55 | Expert | What is business observability? | Connecting technical metrics to business outcomes |
