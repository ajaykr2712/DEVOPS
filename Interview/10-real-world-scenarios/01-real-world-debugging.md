# Real-World Debugging Scenarios

## Table of Contents
1. [Overview](#overview)
2. [Production Rollout Issues](#production-rollout-issues)
3. [DNS and Network Failures](#dns-and-network-failures)
4. [API Performance Problems](#api-performance-problems)
5. [Infrastructure and Scaling Issues](#infrastructure-and-scaling-issues)
6. [Security Incidents](#security-incidents)
7. [Cost and Resource Management](#cost-and-resource-management)
8. [CI/CD Pipeline Failures](#cicd-pipeline-failures)
9. [Database Performance Issues](#database-performance-issues)
10. [Interview Questions & Scenarios](#interview-questions--scenarios)

## Overview

Real-world debugging requires systematic problem-solving, understanding of distributed systems, and the ability to work under pressure. This guide covers common production scenarios and debugging approaches.

## Production Rollout Issues

### Scenario 1: Failed Rolling Deployment

**Situation**: A rolling deployment is failing with 50% of pods unable to start, causing service degradation.

**Investigation Process**:

```bash
# 1. Check pod status and events
kubectl get pods -l app=my-service
kubectl describe pod <failing-pod-name>

# 2. Check recent deployments
kubectl rollout status deployment/my-service
kubectl rollout history deployment/my-service

# 3. Compare configurations
kubectl diff -f new-deployment.yaml

# 4. Check resource constraints
kubectl top nodes
kubectl describe nodes

# 5. Examine logs
kubectl logs -f deployment/my-service --previous
kubectl logs -f deployment/my-service -c init-container
```

**Python Script for Automated Rollout Monitoring**:

```python
import subprocess
import time
import json
from typing import Dict, List, Optional
import logging

class RolloutMonitor:
    def __init__(self, namespace: str = "default"):
        self.namespace = namespace
        self.logger = logging.getLogger(__name__)
    
    def check_rollout_status(self, deployment_name: str) -> Dict:
        """Check the status of a deployment rollout"""
        try:
            # Get deployment status
            cmd = f"kubectl get deployment {deployment_name} -n {self.namespace} -o json"
            result = subprocess.run(cmd.split(), capture_output=True, text=True)
            
            if result.returncode != 0:
                return {"error": f"Failed to get deployment: {result.stderr}"}
            
            deployment = json.loads(result.stdout)
            status = deployment.get("status", {})
            
            return {
                "name": deployment_name,
                "replicas": status.get("replicas", 0),
                "ready_replicas": status.get("readyReplicas", 0),
                "updated_replicas": status.get("updatedReplicas", 0),
                "available_replicas": status.get("availableReplicas", 0),
                "conditions": status.get("conditions", [])
            }
            
        except Exception as e:
            return {"error": str(e)}
    
    def get_pod_issues(self, deployment_name: str) -> List[Dict]:
        """Get detailed information about problematic pods"""
        try:
            # Get pods for deployment
            cmd = f"kubectl get pods -l app={deployment_name} -n {self.namespace} -o json"
            result = subprocess.run(cmd.split(), capture_output=True, text=True)
            
            if result.returncode != 0:
                return [{"error": f"Failed to get pods: {result.stderr}"}]
            
            pods_data = json.loads(result.stdout)
            issues = []
            
            for pod in pods_data.get("items", []):
                pod_name = pod["metadata"]["name"]
                pod_status = pod.get("status", {})
                
                # Check if pod is not running
                if pod_status.get("phase") != "Running":
                    issue = {
                        "pod_name": pod_name,
                        "phase": pod_status.get("phase"),
                        "conditions": pod_status.get("conditions", []),
                        "container_statuses": pod_status.get("containerStatuses", [])
                    }
                    
                    # Get events for this pod
                    events_cmd = f"kubectl get events --field-selector involvedObject.name={pod_name} -n {self.namespace} -o json"
                    events_result = subprocess.run(events_cmd.split(), capture_output=True, text=True)
                    
                    if events_result.returncode == 0:
                        events_data = json.loads(events_result.stdout)
                        issue["events"] = [
                            {
                                "reason": event.get("reason"),
                                "message": event.get("message"),
                                "timestamp": event.get("firstTimestamp")
                            }
                            for event in events_data.get("items", [])
                        ]
                    
                    issues.append(issue)
            
            return issues
            
        except Exception as e:
            return [{"error": str(e)}]
    
    def auto_rollback_if_needed(self, deployment_name: str, success_threshold: float = 0.8) -> Dict:
        """Automatically rollback if deployment is failing"""
        status = self.check_rollout_status(deployment_name)
        
        if "error" in status:
            return status
        
        replicas = status.get("replicas", 0)
        ready_replicas = status.get("ready_replicas", 0)
        
        if replicas == 0:
            return {"action": "none", "reason": "No replicas to check"}
        
        success_rate = ready_replicas / replicas
        
        if success_rate < success_threshold:
            # Perform rollback
            rollback_cmd = f"kubectl rollout undo deployment/{deployment_name} -n {self.namespace}"
            result = subprocess.run(rollback_cmd.split(), capture_output=True, text=True)
            
            if result.returncode == 0:
                return {
                    "action": "rollback",
                    "reason": f"Success rate {success_rate:.2%} below threshold {success_threshold:.2%}",
                    "rollback_output": result.stdout
                }
            else:
                return {
                    "action": "rollback_failed",
                    "reason": f"Rollback command failed: {result.stderr}"
                }
        
        return {
            "action": "none",
            "reason": f"Success rate {success_rate:.2%} above threshold"
        }
    
    def monitor_rollout(self, deployment_name: str, timeout_minutes: int = 10):
        """Monitor a rollout and provide real-time status"""
        start_time = time.time()
        timeout_seconds = timeout_minutes * 60
        
        while time.time() - start_time < timeout_seconds:
            status = self.check_rollout_status(deployment_name)
            
            if "error" in status:
                self.logger.error(f"Error checking rollout: {status['error']}")
                time.sleep(30)
                continue
            
            replicas = status.get("replicas", 0)
            ready_replicas = status.get("ready_replicas", 0)
            
            self.logger.info(f"Rollout status: {ready_replicas}/{replicas} pods ready")
            
            # Check if rollout is complete
            if replicas > 0 and ready_replicas == replicas:
                self.logger.info("Rollout completed successfully!")
                return {"status": "success", "duration": time.time() - start_time}
            
            # Check for issues
            issues = self.get_pod_issues(deployment_name)
            if issues:
                self.logger.warning(f"Found {len(issues)} pod issues")
                for issue in issues:
                    if "error" not in issue:
                        self.logger.warning(f"Pod {issue['pod_name']}: {issue['phase']}")
            
            time.sleep(30)
        
        # Timeout reached
        self.logger.error(f"Rollout monitoring timed out after {timeout_minutes} minutes")
        return {"status": "timeout", "duration": timeout_seconds}

# Usage example
def debug_failed_rollout():
    monitor = RolloutMonitor(namespace="production")
    
    deployment_name = "user-service"
    
    # Check current status
    status = monitor.check_rollout_status(deployment_name)
    print(f"Deployment status: {json.dumps(status, indent=2)}")
    
    # Get pod issues
    issues = monitor.get_pod_issues(deployment_name)
    if issues:
        print(f"Pod issues found: {json.dumps(issues, indent=2)}")
    
    # Consider rollback
    rollback_result = monitor.auto_rollback_if_needed(deployment_name)
    print(f"Rollback decision: {json.dumps(rollback_result, indent=2)}")
```

### Scenario 2: Configuration Drift Detection

**Situation**: Services are behaving inconsistently across environments due to configuration drift.

**Detection Script**:

```python
import os
import yaml
import json
import hashlib
from typing import Dict, List, Any
from dataclasses import dataclass
from pathlib import Path

@dataclass
class ConfigDrift:
    environment: str
    service: str
    key: str
    expected_value: Any
    actual_value: Any
    drift_type: str  # "missing", "different", "extra"

class ConfigDriftDetector:
    def __init__(self, baseline_env: str = "production"):
        self.baseline_env = baseline_env
        self.configurations = {}
    
    def load_configurations(self, config_paths: Dict[str, str]):
        """Load configurations from different environments"""
        for env, path in config_paths.items():
            try:
                with open(path, 'r') as f:
                    if path.endswith('.yaml') or path.endswith('.yml'):
                        config = yaml.safe_load(f)
                    else:
                        config = json.load(f)
                
                self.configurations[env] = self.flatten_config(config)
                
            except Exception as e:
                print(f"Error loading config for {env}: {e}")
                self.configurations[env] = {}
    
    def flatten_config(self, config: Dict, prefix: str = "") -> Dict[str, Any]:
        """Flatten nested configuration for comparison"""
        flattened = {}
        
        for key, value in config.items():
            full_key = f"{prefix}.{key}" if prefix else key
            
            if isinstance(value, dict):
                flattened.update(self.flatten_config(value, full_key))
            else:
                flattened[full_key] = value
        
        return flattened
    
    def detect_drift(self, service_name: str = "all") -> List[ConfigDrift]:
        """Detect configuration drift across environments"""
        if self.baseline_env not in self.configurations:
            raise ValueError(f"Baseline environment {self.baseline_env} not loaded")
        
        baseline_config = self.configurations[self.baseline_env]
        drifts = []
        
        for env, config in self.configurations.items():
            if env == self.baseline_env:
                continue
            
            # Check for missing or different values
            for key, baseline_value in baseline_config.items():
                if service_name != "all" and not key.startswith(service_name):
                    continue
                
                if key not in config:
                    drifts.append(ConfigDrift(
                        environment=env,
                        service=service_name,
                        key=key,
                        expected_value=baseline_value,
                        actual_value=None,
                        drift_type="missing"
                    ))
                elif config[key] != baseline_value:
                    drifts.append(ConfigDrift(
                        environment=env,
                        service=service_name,
                        key=key,
                        expected_value=baseline_value,
                        actual_value=config[key],
                        drift_type="different"
                    ))
            
            # Check for extra values
            for key, value in config.items():
                if service_name != "all" and not key.startswith(service_name):
                    continue
                
                if key not in baseline_config:
                    drifts.append(ConfigDrift(
                        environment=env,
                        service=service_name,
                        key=key,
                        expected_value=None,
                        actual_value=value,
                        drift_type="extra"
                    ))
        
        return drifts
    
    def generate_drift_report(self, drifts: List[ConfigDrift]) -> str:
        """Generate a human-readable drift report"""
        if not drifts:
            return "No configuration drift detected."
        
        report = "Configuration Drift Report\n"
        report += "=" * 50 + "\n\n"
        
        # Group by environment
        by_env = {}
        for drift in drifts:
            if drift.environment not in by_env:
                by_env[drift.environment] = []
            by_env[drift.environment].append(drift)
        
        for env, env_drifts in by_env.items():
            report += f"Environment: {env}\n"
            report += "-" * 20 + "\n"
            
            for drift in env_drifts:
                report += f"  Key: {drift.key}\n"
                report += f"  Type: {drift.drift_type}\n"
                
                if drift.drift_type == "missing":
                    report += f"  Expected: {drift.expected_value}\n"
                    report += f"  Actual: <missing>\n"
                elif drift.drift_type == "different":
                    report += f"  Expected: {drift.expected_value}\n"
                    report += f"  Actual: {drift.actual_value}\n"
                elif drift.drift_type == "extra":
                    report += f"  Extra value: {drift.actual_value}\n"
                
                report += "\n"
            
            report += "\n"
        
        return report
    
    def auto_fix_drift(self, drifts: List[ConfigDrift], dry_run: bool = True) -> Dict[str, Any]:
        """Automatically fix configuration drift"""
        fixes = []
        
        for drift in drifts:
            if drift.drift_type == "missing":
                fix = {
                    "action": "add",
                    "environment": drift.environment,
                    "key": drift.key,
                    "value": drift.expected_value
                }
            elif drift.drift_type == "different":
                fix = {
                    "action": "update",
                    "environment": drift.environment,
                    "key": drift.key,
                    "old_value": drift.actual_value,
                    "new_value": drift.expected_value
                }
            elif drift.drift_type == "extra":
                fix = {
                    "action": "remove",
                    "environment": drift.environment,
                    "key": drift.key,
                    "value": drift.actual_value
                }
            
            fixes.append(fix)
        
        if dry_run:
            return {"dry_run": True, "fixes": fixes}
        
        # Implement actual fixing logic here
        # This would involve updating configuration files or K8s configmaps
        
        return {"dry_run": False, "fixes": fixes, "applied": len(fixes)}

# Usage example
def detect_config_drift_example():
    detector = ConfigDriftDetector(baseline_env="production")
    
    # Load configurations from different environments
    config_paths = {
        "production": "config/prod.yaml",
        "staging": "config/staging.yaml",
        "development": "config/dev.yaml"
    }
    
    # For demo, create sample configs
    sample_configs = {
        "production": {
            "database": {"host": "prod-db.example.com", "port": 5432, "pool_size": 20},
            "redis": {"host": "prod-redis.example.com", "port": 6379},
            "feature_flags": {"new_ui": True, "beta_feature": False}
        },
        "staging": {
            "database": {"host": "staging-db.example.com", "port": 5432, "pool_size": 10},
            "redis": {"host": "staging-redis.example.com", "port": 6379},
            "feature_flags": {"new_ui": True, "beta_feature": True}  # Drift!
        },
        "development": {
            "database": {"host": "dev-db.example.com", "port": 5432},  # Missing pool_size!
            "redis": {"host": "dev-redis.example.com", "port": 6379},
            "feature_flags": {"new_ui": False, "beta_feature": False},
            "debug": {"enabled": True}  # Extra config!
        }
    }
    
    # Set configurations directly for demo
    for env, config in sample_configs.items():
        detector.configurations[env] = detector.flatten_config(config)
    
    # Detect drift
    drifts = detector.detect_drift()
    
    # Generate report
    report = detector.generate_drift_report(drifts)
    print(report)
    
    # Generate fix recommendations
    fixes = detector.auto_fix_drift(drifts, dry_run=True)
    print("Recommended fixes:")
    print(json.dumps(fixes, indent=2))

# Run example
# detect_config_drift_example()
```

## DNS and Network Failures

### Scenario 3: DNS Resolution Failures

**Situation**: Intermittent DNS resolution failures causing service timeouts.

**DNS Debugging Script**:

```python
import socket
import time
import dns.resolver
import subprocess
import threading
from typing import List, Dict, Any
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed
import statistics

@dataclass
class DNSTestResult:
    domain: str
    query_type: str
    resolver: str
    success: bool
    response_time: float
    result: Any
    error: str = None

class DNSDebugger:
    def __init__(self):
        self.resolvers = [
            "8.8.8.8",      # Google
            "1.1.1.1",      # Cloudflare
            "208.67.222.222", # OpenDNS
            "8.8.4.4",      # Google Secondary
            None            # System default
        ]
    
    def test_dns_resolution(self, domain: str, query_type: str = "A", 
                           resolver_ip: str = None, timeout: int = 5) -> DNSTestResult:
        """Test DNS resolution for a specific domain"""
        start_time = time.time()
        
        try:
            resolver = dns.resolver.Resolver()
            if resolver_ip:
                resolver.nameservers = [resolver_ip]
            
            resolver.timeout = timeout
            resolver.lifetime = timeout
            
            result = resolver.resolve(domain, query_type)
            response_time = time.time() - start_time
            
            answers = [str(rdata) for rdata in result]
            
            return DNSTestResult(
                domain=domain,
                query_type=query_type,
                resolver=resolver_ip or "system",
                success=True,
                response_time=response_time,
                result=answers
            )
            
        except Exception as e:
            response_time = time.time() - start_time
            return DNSTestResult(
                domain=domain,
                query_type=query_type,
                resolver=resolver_ip or "system",
                success=False,
                response_time=response_time,
                result=None,
                error=str(e)
            )
    
    def comprehensive_dns_test(self, domains: List[str], 
                              query_types: List[str] = ["A", "AAAA", "CNAME"]) -> List[DNSTestResult]:
        """Run comprehensive DNS tests across multiple resolvers"""
        results = []
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = []
            
            for domain in domains:
                for query_type in query_types:
                    for resolver in self.resolvers:
                        future = executor.submit(
                            self.test_dns_resolution,
                            domain, query_type, resolver
                        )
                        futures.append(future)
            
            for future in as_completed(futures):
                results.append(future.result())
        
        return results
    
    def analyze_dns_patterns(self, results: List[DNSTestResult]) -> Dict[str, Any]:
        """Analyze DNS test results for patterns and issues"""
        analysis = {
            "total_tests": len(results),
            "success_rate": 0,
            "resolver_performance": {},
            "domain_issues": {},
            "query_type_issues": {},
            "response_time_stats": {}
        }
        
        successful_tests = [r for r in results if r.success]
        analysis["success_rate"] = len(successful_tests) / len(results) if results else 0
        
        # Analyzer by resolver
        resolver_stats = {}
        for result in results:
            resolver = result.resolver
            if resolver not in resolver_stats:
                resolver_stats[resolver] = {"total": 0, "success": 0, "response_times": []}
            
            resolver_stats[resolver]["total"] += 1
            if result.success:
                resolver_stats[resolver]["success"] += 1
                resolver_stats[resolver]["response_times"].append(result.response_time)
        
        for resolver, stats in resolver_stats.items():
            success_rate = stats["success"] / stats["total"] if stats["total"] > 0 else 0
            avg_response_time = statistics.mean(stats["response_times"]) if stats["response_times"] else 0
            
            analysis["resolver_performance"][resolver] = {
                "success_rate": success_rate,
                "average_response_time": avg_response_time,
                "total_tests": stats["total"]
            }
        
        # Analyze by domain
        domain_stats = {}
        for result in results:
            domain = result.domain
            if domain not in domain_stats:
                domain_stats[domain] = {"total": 0, "success": 0, "errors": []}
            
            domain_stats[domain]["total"] += 1
            if result.success:
                domain_stats[domain]["success"] += 1
            else:
                domain_stats[domain]["errors"].append(result.error)
        
        for domain, stats in domain_stats.items():
            success_rate = stats["success"] / stats["total"] if stats["total"] > 0 else 0
            if success_rate < 0.8:  # Flag domains with <80% success rate
                analysis["domain_issues"][domain] = {
                    "success_rate": success_rate,
                    "common_errors": list(set(stats["errors"]))
                }
        
        return analysis
    
    def monitor_dns_health(self, domains: List[str], interval_seconds: int = 60, 
                          duration_minutes: int = 10):
        """Monitor DNS health over time"""
        start_time = time.time()
        end_time = start_time + (duration_minutes * 60)
        
        results = []
        
        print(f"Starting DNS monitoring for {duration_minutes} minutes...")
        
        while time.time() < end_time:
            print(f"Running DNS tests at {time.strftime('%H:%M:%S')}")
            
            test_results = self.comprehensive_dns_test(domains)
            results.extend(test_results)
            
            analysis = self.analyze_dns_patterns(test_results)
            print(f"Success rate: {analysis['success_rate']:.2%}")
            
            # Alert on issues
            if analysis['success_rate'] < 0.9:
                print("⚠️  DNS issues detected!")
                for domain, issues in analysis['domain_issues'].items():
                    print(f"  - {domain}: {issues['success_rate']:.2%} success rate")
            
            if time.time() < end_time:
                time.sleep(interval_seconds)
        
        return results
    
    def trace_dns_path(self, domain: str) -> Dict[str, Any]:
        """Trace DNS resolution path"""
        trace_info = {
            "domain": domain,
            "system_resolvers": [],
            "authoritative_servers": [],
            "resolution_path": []
        }
        
        try:
            # Get system resolvers
            with open('/etc/resolv.conf', 'r') as f:
                for line in f:
                    if line.startswith('nameserver'):
                        resolver = line.split()[1]
                        trace_info["system_resolvers"].append(resolver)
        except:
            pass
        
        try:
            # Trace authoritative servers
            resolver = dns.resolver.Resolver()
            
            # Get root servers first
            root_servers = resolver.resolve('.', 'NS')
            
            # Trace down the hierarchy
            current_domain = domain
            while current_domain:
                try:
                    ns_records = resolver.resolve(current_domain, 'NS')
                    trace_info["authoritative_servers"].extend([str(ns) for ns in ns_records])
                    
                    # Move up one level
                    parts = current_domain.split('.')
                    if len(parts) > 1:
                        current_domain = '.'.join(parts[1:])
                    else:
                        break
                except:
                    break
        
        except Exception as e:
            trace_info["error"] = str(e)
        
        return trace_info

# Network troubleshooting utilities
class NetworkDiagnostics:
    @staticmethod
    def ping_test(host: str, count: int = 4) -> Dict[str, Any]:
        """Perform ping test"""
        try:
            result = subprocess.run(
                ['ping', '-c', str(count), host],
                capture_output=True, text=True, timeout=30
            )
            
            return {
                "host": host,
                "success": result.returncode == 0,
                "output": result.stdout,
                "error": result.stderr if result.returncode != 0 else None
            }
        except Exception as e:
            return {
                "host": host,
                "success": False,
                "error": str(e)
            }
    
    @staticmethod
    def traceroute_test(host: str) -> Dict[str, Any]:
        """Perform traceroute test"""
        try:
            result = subprocess.run(
                ['traceroute', host],
                capture_output=True, text=True, timeout=60
            )
            
            return {
                "host": host,
                "success": result.returncode == 0,
                "hops": result.stdout.split('\n') if result.returncode == 0 else [],
                "error": result.stderr if result.returncode != 0 else None
            }
        except Exception as e:
            return {
                "host": host,
                "success": False,
                "error": str(e)
            }
    
    @staticmethod
    def port_scan(host: str, ports: List[int]) -> Dict[str, Any]:
        """Scan specific ports on a host"""
        results = {
            "host": host,
            "port_status": {}
        }
        
        for port in ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(5)
                result = sock.connect_ex((host, port))
                sock.close()
                
                results["port_status"][port] = "open" if result == 0 else "closed"
            except Exception as e:
                results["port_status"][port] = f"error: {e}"
        
        return results

# Example usage
def debug_dns_issues():
    debugger = DNSDebugger()
    
    # Test specific domains
    domains = [
        "google.com",
        "github.com",
        "internal-service.company.com",  # This might fail
        "api.example.com"
    ]
    
    print("Running comprehensive DNS tests...")
    results = debugger.comprehensive_dns_test(domains)
    
    # Analyze results
    analysis = debugger.analyze_dns_patterns(results)
    
    print(f"\nDNS Test Results:")
    print(f"Total tests: {analysis['total_tests']}")
    print(f"Overall success rate: {analysis['success_rate']:.2%}")
    
    print(f"\nResolver Performance:")
    for resolver, stats in analysis['resolver_performance'].items():
        print(f"  {resolver}: {stats['success_rate']:.2%} success, "
              f"{stats['average_response_time']:.3f}s avg response time")
    
    if analysis['domain_issues']:
        print(f"\nDomains with issues:")
        for domain, issues in analysis['domain_issues'].items():
            print(f"  {domain}: {issues['success_rate']:.2%} success rate")
            print(f"    Common errors: {issues['common_errors']}")
    
    # Trace DNS path for problematic domains
    for domain in analysis['domain_issues'].keys():
        print(f"\nDNS trace for {domain}:")
        trace = debugger.trace_dns_path(domain)
        print(f"  System resolvers: {trace['system_resolvers']}")
        print(f"  Authoritative servers: {trace['authoritative_servers'][:3]}...")

# Run DNS debugging
# debug_dns_issues()
```

## API Performance Problems

### Scenario 4: API Latency Investigation

**Situation**: API response times have increased from 100ms to 2-3 seconds over the past week.

**Performance Analysis Script**:

```python
import time
import requests
import statistics
import threading
import queue
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field
from datetime import datetime, timedelta
import json
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor
import psutil
import matplotlib.pyplot as plt

@dataclass
class APITest:
    endpoint: str
    method: str = "GET"
    headers: Dict[str, str] = field(default_factory=dict)
    payload: Optional[Dict] = None
    timeout: int = 30
    expected_status: int = 200

@dataclass
class APIResult:
    endpoint: str
    method: str
    status_code: int
    response_time: float
    response_size: int
    timestamp: datetime
    error: Optional[str] = None
    response_body: Optional[str] = None

class APIPerformanceTester:
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.results: List[APIResult] = []
    
    def test_endpoint(self, test: APITest) -> APIResult:
        """Test a single API endpoint"""
        url = f"{self.base_url}{test.endpoint}"
        start_time = time.time()
        timestamp = datetime.now()
        
        try:
            response = self.session.request(
                method=test.method,
                url=url,
                headers=test.headers,
                json=test.payload,
                timeout=test.timeout
            )
            
            response_time = time.time() - start_time
            response_size = len(response.content)
            
            return APIResult(
                endpoint=test.endpoint,
                method=test.method,
                status_code=response.status_code,
                response_time=response_time,
                response_size=response_size,
                timestamp=timestamp,
                response_body=response.text[:500] if response.status_code != test.expected_status else None
            )
            
        except Exception as e:
            response_time = time.time() - start_time
            
            return APIResult(
                endpoint=test.endpoint,
                method=test.method,
                status_code=0,
                response_time=response_time,
                response_size=0,
                timestamp=timestamp,
                error=str(e)
            )
    
    def load_test(self, test: APITest, concurrent_users: int = 10, 
                  duration_seconds: int = 60) -> List[APIResult]:
        """Perform load testing on an endpoint"""
        results = []
        end_time = time.time() + duration_seconds
        
        def worker():
            while time.time() < end_time:
                result = self.test_endpoint(test)
                results.append(result)
                # Small delay to prevent overwhelming
                time.sleep(0.1)
        
        # Start concurrent threads
        threads = []
        for _ in range(concurrent_users):
            thread = threading.Thread(target=worker)
            thread.start()
            threads.append(thread)
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        return results
    
    def analyze_results(self, results: List[APIResult]) -> Dict[str, Any]:
        """Analyze API test results"""
        if not results:
            return {"error": "No results to analyze"}
        
        # Filter successful requests for response time analysis
        successful_results = [r for r in results if r.status_code == 200 and r.error is None]
        response_times = [r.response_time for r in successful_results]
        
        analysis = {
            "total_requests": len(results),
            "successful_requests": len(successful_results),
            "success_rate": len(successful_results) / len(results) if results else 0,
            "error_rate": (len(results) - len(successful_results)) / len(results) if results else 0
        }
        
        if response_times:
            analysis.update({
                "response_time_stats": {
                    "min": min(response_times),
                    "max": max(response_times),
                    "mean": statistics.mean(response_times),
                    "median": statistics.median(response_times),
                    "p95": self._percentile(response_times, 95),
                    "p99": self._percentile(response_times, 99)
                }
            })
        
        # Analyze status codes
        status_codes = {}
        for result in results:
            status = result.status_code
            status_codes[status] = status_codes.get(status, 0) + 1
        
        analysis["status_code_distribution"] = status_codes
        
        # Analyze errors
        errors = {}
        for result in results:
            if result.error:
                error_type = type(result.error).__name__ if hasattr(result.error, '__class__') else str(result.error)
                errors[error_type] = errors.get(error_type, 0) + 1
        
        analysis["error_distribution"] = errors
        
        # Time-based analysis
        if len(results) > 1:
            time_series = self._create_time_series(results)
            analysis["time_series"] = time_series
        
        return analysis
    
    def _percentile(self, data: List[float], percentile: int) -> float:
        """Calculate percentile"""
        if not data:
            return 0
        sorted_data = sorted(data)
        index = int(len(sorted_data) * percentile / 100)
        return sorted_data[min(index, len(sorted_data) - 1)]
    
    def _create_time_series(self, results: List[APIResult], window_seconds: int = 10) -> Dict[str, List]:
        """Create time series data for analysis"""
        if not results:
            return {}
        
        # Sort by timestamp
        sorted_results = sorted(results, key=lambda r: r.timestamp)
        start_time = sorted_results[0].timestamp
        
        time_buckets = {}
        
        for result in sorted_results:
            # Calculate which time bucket this result belongs to
            seconds_elapsed = (result.timestamp - start_time).total_seconds()
            bucket = int(seconds_elapsed // window_seconds) * window_seconds
            
            if bucket not in time_buckets:
                time_buckets[bucket] = {
                    "response_times": [],
                    "request_count": 0,
                    "error_count": 0
                }
            
            time_buckets[bucket]["request_count"] += 1
            
            if result.error:
                time_buckets[bucket]["error_count"] += 1
            else:
                time_buckets[bucket]["response_times"].append(result.response_time)
        
        # Convert to lists for plotting
        timestamps = sorted(time_buckets.keys())
        avg_response_times = []
        request_rates = []
        error_rates = []
        
        for ts in timestamps:
            bucket = time_buckets[ts]
            
            # Average response time
            if bucket["response_times"]:
                avg_response_times.append(statistics.mean(bucket["response_times"]))
            else:
                avg_response_times.append(0)
            
            # Request rate (requests per second)
            request_rates.append(bucket["request_count"] / window_seconds)
            
            # Error rate
            error_rate = bucket["error_count"] / bucket["request_count"] if bucket["request_count"] > 0 else 0
            error_rates.append(error_rate)
        
        return {
            "timestamps": timestamps,
            "avg_response_times": avg_response_times,
            "request_rates": request_rates,
            "error_rates": error_rates
        }
    
    def diagnose_slow_endpoint(self, test: APITest) -> Dict[str, Any]:
        """Diagnose performance issues with a specific endpoint"""
        diagnosis = {
            "endpoint": test.endpoint,
            "baseline_test": None,
            "load_test": None,
            "resource_usage": None,
            "recommendations": []
        }
        
        # Baseline test (single request)
        print(f"Running baseline test for {test.endpoint}...")
        baseline_result = self.test_endpoint(test)
        diagnosis["baseline_test"] = {
            "response_time": baseline_result.response_time,
            "status_code": baseline_result.status_code,
            "response_size": baseline_result.response_size,
            "error": baseline_result.error
        }
        
        # Load test
        print(f"Running load test for {test.endpoint}...")
        load_results = self.load_test(test, concurrent_users=5, duration_seconds=30)
        load_analysis = self.analyze_results(load_results)
        diagnosis["load_test"] = load_analysis
        
        # Resource usage during test
        diagnosis["resource_usage"] = self._get_system_resources()
        
        # Generate recommendations
        diagnosis["recommendations"] = self._generate_recommendations(
            baseline_result, load_analysis
        )
        
        return diagnosis
    
    def _get_system_resources(self) -> Dict[str, Any]:
        """Get current system resource usage"""
        return {
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_io": psutil.disk_io_counters()._asdict() if psutil.disk_io_counters() else {},
            "network_io": psutil.net_io_counters()._asdict() if psutil.net_io_counters() else {}
        }
    
    def _generate_recommendations(self, baseline: APIResult, 
                                 load_analysis: Dict[str, Any]) -> List[str]:
        """Generate performance recommendations"""
        recommendations = []
        
        if baseline.response_time > 1.0:
            recommendations.append("High baseline response time - investigate database queries and external API calls")
        
        if load_analysis.get("success_rate", 1.0) < 0.95:
            recommendations.append("Low success rate under load - check error handling and resource limits")
        
        response_stats = load_analysis.get("response_time_stats", {})
        if response_stats.get("p95", 0) > response_stats.get("mean", 0) * 2:
            recommendations.append("High response time variance - investigate request processing inconsistencies")
        
        if load_analysis.get("error_rate", 0) > 0.05:
            recommendations.append("High error rate - review error logs and implement better error handling")
        
        return recommendations

# Database performance analysis
class DatabaseProfiler:
    def __init__(self, db_connection_string: str):
        self.connection_string = db_connection_string
        self.slow_queries = []
    
    def analyze_slow_queries(self, duration_minutes: int = 10) -> List[Dict[str, Any]]:
        """Analyze slow queries (mock implementation)"""
        # In reality, this would connect to your database and analyze slow query logs
        mock_slow_queries = [
            {
                "query": "SELECT * FROM users WHERE email LIKE '%@%'",
                "duration": 2.5,
                "rows_examined": 1000000,
                "rows_sent": 1,
                "timestamp": datetime.now(),
                "recommendation": "Add index on email column"
            },
            {
                "query": "SELECT COUNT(*) FROM orders o JOIN users u ON o.user_id = u.id",
                "duration": 1.8,
                "rows_examined": 500000,
                "rows_sent": 1,
                "timestamp": datetime.now(),
                "recommendation": "Optimize JOIN with proper indexing"
            }
        ]
        
        return mock_slow_queries
    
    def suggest_optimizations(self, queries: List[Dict[str, Any]]) -> List[str]:
        """Suggest database optimizations"""
        suggestions = []
        
        for query in queries:
            if query["rows_examined"] > 10000:
                suggestions.append(f"Query examining {query['rows_examined']} rows needs indexing")
            
            if query["duration"] > 1.0:
                suggestions.append(f"Query taking {query['duration']}s should be optimized")
        
        # General suggestions
        suggestions.extend([
            "Consider implementing query result caching",
            "Review database connection pooling configuration",
            "Analyze query execution plans for optimization opportunities"
        ])
        
        return suggestions

# Example usage
def diagnose_api_performance():
    # Initialize tester
    tester = APIPerformanceTester("https://api.example.com")
    
    # Define test cases
    tests = [
        APITest("/users", "GET"),
        APITest("/users/123", "GET"),
        APITest("/orders", "GET", headers={"Authorization": "Bearer token"}),
        APITest("/search", "POST", payload={"query": "test"})
    ]
    
    # Run diagnostics for each endpoint
    for test in tests:
        print(f"\n{'='*50}")
        print(f"Diagnosing {test.method} {test.endpoint}")
        print(f"{'='*50}")
        
        diagnosis = tester.diagnose_slow_endpoint(test)
        
        print(f"Baseline Response Time: {diagnosis['baseline_test']['response_time']:.3f}s")
        
        load_test = diagnosis['load_test']
        if 'response_time_stats' in load_test:
            stats = load_test['response_time_stats']
            print(f"Load Test Results:")
            print(f"  Success Rate: {load_test['success_rate']:.2%}")
            print(f"  Mean Response Time: {stats['mean']:.3f}s")
            print(f"  95th Percentile: {stats['p95']:.3f}s")
            print(f"  99th Percentile: {stats['p99']:.3f}s")
        
        print(f"Recommendations:")
        for rec in diagnosis['recommendations']:
            print(f"  - {rec}")

# Run performance diagnosis
# diagnose_api_performance()
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | How would you debug a failing deployment? | Check logs, verify configuration, test connectivity, rollback if needed |
| 2 | Easy | What steps to troubleshoot slow API response? | Check server resources, database queries, network latency, caching |
| 3 | Easy | How to investigate application crashes? | Examine error logs, stack traces, memory usage, recent changes |
| 4 | Easy | What to do when users report login issues? | Verify authentication service, check user credentials, review access logs |
| 5 | Easy | How to handle database connection failures? | Check connection strings, database status, network connectivity, connection pools |
| 6 | Easy | What causes high CPU usage? | Inefficient algorithms, infinite loops, heavy computations, resource contention |
| 7 | Easy | How to diagnose memory leaks? | Monitor memory usage over time, analyze heap dumps, check object retention |
| 8 | Easy | What to check for disk space issues? | Log files, temporary files, database growth, backup files |
| 9 | Easy | How to troubleshoot DNS issues? | Test DNS resolution, check DNS servers, verify domain configuration |
| 10 | Easy | What causes SSL certificate errors? | Expired certificates, wrong domain, certificate chain issues |
| 11 | Medium | Production API suddenly returns 500 errors | Check recent deployments, application logs, database connectivity, dependencies |
| 12 | Medium | Website becomes extremely slow during peak hours | Analyze traffic patterns, check database performance, review caching strategy |
| 13 | Medium | Users can't access application from specific regions | Investigate CDN configuration, regional network issues, geo-blocking |
| 14 | Medium | Database queries timing out frequently | Check query performance, index usage, connection pool settings, lock contention |
| 15 | Medium | Microservice communication failing intermittently | Examine network stability, service discovery, circuit breakers, retry policies |
| 16 | Medium | Application memory usage growing continuously | Profile memory allocation, check for leaks, analyze garbage collection |
| 17 | Medium | CI/CD pipeline randomly failing | Review pipeline logs, check resource constraints, verify dependencies |
| 18 | Medium | Load balancer showing unhealthy instances | Check health check endpoints, application startup time, resource allocation |
| 19 | Medium | File uploads failing for large files | Investigate upload limits, timeout settings, disk space, bandwidth |
| 20 | Medium | Scheduled jobs not executing | Verify cron configuration, check job scheduler status, review permissions |
| 21 | Hard | S3 bucket accidentally exposed publicly | Immediately restrict access, audit exposed data, implement bucket policies, notify stakeholders |
| 22 | Hard | Kubernetes pods keep crashing with OOMKilled | Analyze memory usage patterns, adjust resource limits, optimize application memory |
| 23 | Hard | DNS failover not working during outage | Test failover configuration, verify health checks, check DNS propagation times |
| 24 | Hard | API latency increased after database migration | Compare query performance, check connection settings, analyze new schema |
| 25 | Hard | Container registry running out of space | Implement cleanup policies, remove old images, optimize image sizes |
| 26 | Hard | Network packet loss in multi-cloud setup | Analyze network paths, check MTU settings, review routing configuration |
| 27 | Hard | Prometheus metrics showing high cardinality | Identify problematic metrics, implement label best practices, consider federation |
| 28 | Hard | Application performance degraded after auto-scaling | Review scaling policies, analyze resource allocation, check application limits |
| 29 | Hard | Cross-region data replication failing | Check network connectivity, verify replication settings, monitor replication lag |
| 30 | Hard | Security scan found vulnerabilities in production | Assess impact, prioritize patches, implement temporary mitigations, update dependencies |
| 31 | Expert | Complete data center outage | Activate disaster recovery, failover to backup region, communicate with stakeholders |
| 32 | Expert | Major security breach detected | Isolate affected systems, preserve evidence, engage security team, notify authorities |
| 33 | Expert | Performance regression after major refactoring | Compare before/after metrics, profile critical paths, identify bottlenecks |
| 34 | Expert | Distributed system experiencing split-brain | Implement proper consensus mechanisms, check network partitions, review quorum settings |
| 35 | Expert | Cloud costs unexpectedly doubled | Analyze cost breakdown, identify anomalies, implement cost controls, review resource usage |
| 36 | Expert | Zero-downtime deployment causing data corruption | Rollback immediately, analyze data integrity, implement proper migration strategies |
| 37 | Expert | Global CDN cache poisoning | Purge affected content, investigate attack vector, implement cache validation |
| 38 | Expert | Message queue backup causing system slowdown | Analyze message flow, implement dead letter queues, optimize processing |
| 39 | Expert | Compliance audit failed due to data handling | Review data practices, implement proper controls, document procedures |
| 40 | Expert | Third-party API rate limits affecting business | Implement caching, request optimization, negotiate higher limits, add fallbacks |
| 41 | Expert | How do you handle debugging in production? | Use observability tools, reproduce in staging, minimize impact, document findings |
| 42 | Expert | What's your approach to performance optimization? | Profile first, identify bottlenecks, measure improvements, test thoroughly |
| 43 | Expert | How do you investigate intermittent issues? | Increase logging, add monitoring, use statistical analysis, look for patterns |
| 44 | Expert | What's your incident response process? | Immediate response, impact assessment, communication, resolution, post-mortem |
| 45 | Expert | How do you prevent cascading failures? | Circuit breakers, bulkheads, graceful degradation, timeout management |
| 46 | Expert | Describe your capacity planning process | Monitor trends, forecast growth, test limits, plan buffer capacity |
| 47 | Expert | How do you handle technical debt? | Regular assessment, prioritization, incremental improvements, documentation |
| 48 | Expert | What's your approach to system reliability? | Design for failure, redundancy, monitoring, testing, continuous improvement |
| 49 | Expert | How do you manage dependencies? | Version pinning, dependency scanning, update strategies, fallback options |
| 50 | Expert | Describe your debugging methodology | Reproduce issue, gather data, form hypothesis, test systematically, document solution |
| 51 | Expert | How do you handle data corruption? | Stop writes, assess damage, restore from backup, implement validation |
| 52 | Expert | What's your disaster recovery strategy? | Regular backups, tested procedures, multi-region setup, communication plan |
| 53 | Expert | How do you optimize for cost? | Resource right-sizing, usage monitoring, reserved instances, automation |
| 54 | Expert | Describe your security incident response | Contain threat, assess impact, preserve evidence, remediate, communicate |
| 55 | Expert | How do you ensure system observability? | Comprehensive monitoring, logging, tracing, alerting, dashboards |
