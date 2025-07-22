#!/usr/bin/env python3
"""
Infrastructure Health Monitor

A comprehensive monitoring tool for cloud infrastructure health and performance.
Provides real-time monitoring, alerting, and predictive analytics.

Author: DevOps Excellence Team
Version: 2.0.0
License: MIT
"""

import json
import logging
import time
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum
import concurrent.futures
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class HealthStatus(Enum):
    """Health status enumeration."""
    HEALTHY = "healthy"
    WARNING = "warning"
    CRITICAL = "critical"
    UNKNOWN = "unknown"


@dataclass
class HealthCheck:
    """Data class for health check results."""
    name: str
    status: HealthStatus
    message: str
    timestamp: datetime
    response_time: float
    details: Dict[str, Any]


@dataclass
class Alert:
    """Data class for alerts."""
    level: str
    message: str
    timestamp: datetime
    source: str
    details: Dict[str, Any]


class InfrastructureMonitor:
    """
    Infrastructure Health Monitor
    
    Monitors various infrastructure components and services for health and performance.
    """
    
    def __init__(self, config_file: Optional[str] = None):
        """
        Initialize the infrastructure monitor.
        
        Args:
            config_file: Path to configuration file
        """
        self.config = self._load_config(config_file)
        self.alerts = []
        self.health_checks = []
        
        # Configure logging
        logging.basicConfig(
            level=getattr(logging, self.config.get('log_level', 'INFO')),
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def _load_config(self, config_file: Optional[str]) -> Dict[str, Any]:
        """
        Load configuration from file or use defaults.
        
        Args:
            config_file: Path to configuration file
            
        Returns:
            Dict[str, Any]: Configuration dictionary
        """
        default_config = {
            'checks': {
                'http_endpoints': [],
                'databases': [],
                'services': [],
                'ssl_certificates': []
            },
            'thresholds': {
                'response_time_warning': 1000,  # ms
                'response_time_critical': 5000,  # ms
                'cpu_warning': 80,  # percentage
                'cpu_critical': 95,  # percentage
                'memory_warning': 85,  # percentage
                'memory_critical': 95,  # percentage
                'disk_warning': 80,  # percentage
                'disk_critical': 90   # percentage
            },
            'notifications': {
                'email': {
                    'enabled': False,
                    'smtp_server': '',
                    'smtp_port': 587,
                    'username': '',
                    'password': '',
                    'recipients': []
                },
                'slack': {
                    'enabled': False,
                    'webhook_url': ''
                }
            },
            'monitoring_interval': 60,  # seconds
            'log_level': 'INFO'
        }
        
        if config_file:
            try:
                with open(config_file, 'r') as f:
                    user_config = json.load(f)
                    default_config.update(user_config)
            except Exception as e:
                self.logger.error(f"Error loading config file: {e}")
        
        return default_config
    
    def check_http_endpoint(self, endpoint: Dict[str, Any]) -> HealthCheck:
        """
        Check HTTP endpoint health.
        
        Args:
            endpoint: Endpoint configuration
            
        Returns:
            HealthCheck: Health check result
        """
        import requests
        
        url = endpoint['url']
        timeout = endpoint.get('timeout', 10)
        expected_status = endpoint.get('expected_status', 200)
        
        start_time = time.time()
        
        try:
            response = requests.get(url, timeout=timeout)
            response_time = (time.time() - start_time) * 1000  # Convert to ms
            
            # Determine status
            if response.status_code == expected_status:
                if response_time > self.config['thresholds']['response_time_critical']:
                    status = HealthStatus.CRITICAL
                    message = f"Slow response: {response_time:.2f}ms"
                elif response_time > self.config['thresholds']['response_time_warning']:
                    status = HealthStatus.WARNING
                    message = f"Slow response: {response_time:.2f}ms"
                else:
                    status = HealthStatus.HEALTHY
                    message = f"OK - {response_time:.2f}ms"
            else:
                status = HealthStatus.CRITICAL
                message = f"Unexpected status code: {response.status_code}"
            
            details = {
                'status_code': response.status_code,
                'response_size': len(response.content),
                'headers': dict(response.headers)
            }
            
        except requests.exceptions.Timeout:
            status = HealthStatus.CRITICAL
            message = f"Timeout after {timeout}s"
            response_time = timeout * 1000
            details = {'error': 'timeout'}
            
        except requests.exceptions.ConnectionError:
            status = HealthStatus.CRITICAL
            message = "Connection failed"
            response_time = 0
            details = {'error': 'connection_failed'}
            
        except Exception as e:
            status = HealthStatus.CRITICAL
            message = f"Error: {str(e)}"
            response_time = 0
            details = {'error': str(e)}
        
        return HealthCheck(
            name=f"HTTP - {url}",
            status=status,
            message=message,
            timestamp=datetime.now(),
            response_time=response_time,
            details=details
        )
    
    def check_database_connection(self, db_config: Dict[str, Any]) -> HealthCheck:
        """
        Check database connection health.
        
        Args:
            db_config: Database configuration
            
        Returns:
            HealthCheck: Health check result
        """
        db_type = db_config['type']
        host = db_config['host']
        port = db_config['port']
        database = db_config.get('database', '')
        
        start_time = time.time()
        
        try:
            if db_type == 'postgresql':
                import psycopg2
                conn = psycopg2.connect(
                    host=host,
                    port=port,
                    database=database,
                    user=db_config['username'],
                    password=db_config['password'],
                    connect_timeout=10
                )
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                conn.close()
                
            elif db_type == 'mysql':
                import mysql.connector
                conn = mysql.connector.connect(
                    host=host,
                    port=port,
                    database=database,
                    user=db_config['username'],
                    password=db_config['password'],
                    connection_timeout=10
                )
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                conn.close()
                
            elif db_type == 'redis':
                import redis
                r = redis.Redis(
                    host=host,
                    port=port,
                    password=db_config.get('password'),
                    socket_timeout=10
                )
                r.ping()
                
            else:
                raise ValueError(f"Unsupported database type: {db_type}")
            
            response_time = (time.time() - start_time) * 1000
            
            if response_time > 1000:  # 1 second
                status = HealthStatus.WARNING
                message = f"Slow connection: {response_time:.2f}ms"
            else:
                status = HealthStatus.HEALTHY
                message = f"Connected - {response_time:.2f}ms"
            
            details = {
                'connection_time': response_time,
                'type': db_type
            }
            
        except Exception as e:
            status = HealthStatus.CRITICAL
            message = f"Connection failed: {str(e)}"
            response_time = 0
            details = {'error': str(e), 'type': db_type}
        
        return HealthCheck(
            name=f"DB - {db_type}://{host}:{port}",
            status=status,
            message=message,
            timestamp=datetime.now(),
            response_time=response_time,
            details=details
        )
    
    def check_ssl_certificate(self, cert_config: Dict[str, Any]) -> HealthCheck:
        """
        Check SSL certificate validity.
        
        Args:
            cert_config: Certificate configuration
            
        Returns:
            HealthCheck: Health check result
        """
        import ssl
        import socket
        from datetime import datetime
        
        hostname = cert_config['hostname']
        port = cert_config.get('port', 443)
        
        try:
            context = ssl.create_default_context()
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
            
            # Parse expiration date
            expiry_date = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
            days_until_expiry = (expiry_date - datetime.now()).days
            
            if days_until_expiry < 7:
                status = HealthStatus.CRITICAL
                message = f"Certificate expires in {days_until_expiry} days"
            elif days_until_expiry < 30:
                status = HealthStatus.WARNING
                message = f"Certificate expires in {days_until_expiry} days"
            else:
                status = HealthStatus.HEALTHY
                message = f"Certificate valid for {days_until_expiry} days"
            
            details = {
                'expiry_date': cert['notAfter'],
                'days_until_expiry': days_until_expiry,
                'issuer': dict(x[0] for x in cert['issuer']),
                'subject': dict(x[0] for x in cert['subject'])
            }
            
        except Exception as e:
            status = HealthStatus.CRITICAL
            message = f"SSL check failed: {str(e)}"
            details = {'error': str(e)}
        
        return HealthCheck(
            name=f"SSL - {hostname}:{port}",
            status=status,
            message=message,
            timestamp=datetime.now(),
            response_time=0,
            details=details
        )
    
    def check_system_resources(self) -> List[HealthCheck]:
        """
        Check system resource utilization.
        
        Returns:
            List[HealthCheck]: List of system resource checks
        """
        import psutil
        
        checks = []
        
        # CPU Usage
        cpu_percent = psutil.cpu_percent(interval=1)
        if cpu_percent > self.config['thresholds']['cpu_critical']:
            status = HealthStatus.CRITICAL
        elif cpu_percent > self.config['thresholds']['cpu_warning']:
            status = HealthStatus.WARNING
        else:
            status = HealthStatus.HEALTHY
        
        checks.append(HealthCheck(
            name="System - CPU Usage",
            status=status,
            message=f"CPU usage: {cpu_percent:.1f}%",
            timestamp=datetime.now(),
            response_time=0,
            details={'cpu_percent': cpu_percent}
        ))
        
        # Memory Usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        if memory_percent > self.config['thresholds']['memory_critical']:
            status = HealthStatus.CRITICAL
        elif memory_percent > self.config['thresholds']['memory_warning']:
            status = HealthStatus.WARNING
        else:
            status = HealthStatus.HEALTHY
        
        checks.append(HealthCheck(
            name="System - Memory Usage",
            status=status,
            message=f"Memory usage: {memory_percent:.1f}%",
            timestamp=datetime.now(),
            response_time=0,
            details={
                'total': memory.total,
                'available': memory.available,
                'percent': memory_percent
            }
        ))
        
        # Disk Usage
        for partition in psutil.disk_partitions():
            try:
                disk_usage = psutil.disk_usage(partition.mountpoint)
                disk_percent = (disk_usage.used / disk_usage.total) * 100
                
                if disk_percent > self.config['thresholds']['disk_critical']:
                    status = HealthStatus.CRITICAL
                elif disk_percent > self.config['thresholds']['disk_warning']:
                    status = HealthStatus.WARNING
                else:
                    status = HealthStatus.HEALTHY
                
                checks.append(HealthCheck(
                    name=f"System - Disk Usage ({partition.mountpoint})",
                    status=status,
                    message=f"Disk usage: {disk_percent:.1f}%",
                    timestamp=datetime.now(),
                    response_time=0,
                    details={
                        'total': disk_usage.total,
                        'used': disk_usage.used,
                        'free': disk_usage.free,
                        'percent': disk_percent,
                        'mountpoint': partition.mountpoint
                    }
                ))
            except PermissionError:
                continue
        
        return checks
    
    def run_health_checks(self) -> List[HealthCheck]:
        """
        Run all configured health checks.
        
        Returns:
            List[HealthCheck]: List of all health check results
        """
        checks = []
        
        # Use ThreadPoolExecutor for concurrent checks
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = []
            
            # HTTP endpoint checks
            for endpoint in self.config['checks']['http_endpoints']:
                future = executor.submit(self.check_http_endpoint, endpoint)
                futures.append(future)
            
            # Database checks
            for db_config in self.config['checks']['databases']:
                future = executor.submit(self.check_database_connection, db_config)
                futures.append(future)
            
            # SSL certificate checks
            for cert_config in self.config['checks']['ssl_certificates']:
                future = executor.submit(self.check_ssl_certificate, cert_config)
                futures.append(future)
            
            # Wait for all checks to complete
            for future in concurrent.futures.as_completed(futures):
                try:
                    result = future.result()
                    checks.append(result)
                except Exception as e:
                    self.logger.error(f"Health check failed: {e}")
        
        # Add system resource checks
        checks.extend(self.check_system_resources())
        
        return checks
    
    def generate_alerts(self, checks: List[HealthCheck]) -> List[Alert]:
        """
        Generate alerts based on health check results.
        
        Args:
            checks: List of health check results
            
        Returns:
            List[Alert]: List of generated alerts
        """
        alerts = []
        
        for check in checks:
            if check.status in [HealthStatus.WARNING, HealthStatus.CRITICAL]:
                alert = Alert(
                    level=check.status.value,
                    message=f"{check.name}: {check.message}",
                    timestamp=check.timestamp,
                    source="infrastructure_monitor",
                    details=check.details
                )
                alerts.append(alert)
        
        return alerts
    
    def send_notifications(self, alerts: List[Alert]) -> None:
        """
        Send notifications for alerts.
        
        Args:
            alerts: List of alerts to send
        """
        if not alerts:
            return
        
        # Email notifications
        if self.config['notifications']['email']['enabled']:
            self._send_email_notifications(alerts)
        
        # Slack notifications
        if self.config['notifications']['slack']['enabled']:
            self._send_slack_notifications(alerts)
    
    def _send_email_notifications(self, alerts: List[Alert]) -> None:
        """Send email notifications."""
        try:
            email_config = self.config['notifications']['email']
            
            msg = MIMEMultipart()
            msg['From'] = email_config['username']
            msg['To'] = ', '.join(email_config['recipients'])
            msg['Subject'] = f"Infrastructure Alert - {len(alerts)} issues detected"
            
            body = "Infrastructure monitoring has detected the following issues:\n\n"
            for alert in alerts:
                body += f"[{alert.level.upper()}] {alert.message}\n"
                body += f"Time: {alert.timestamp}\n\n"
            
            msg.attach(MIMEText(body, 'plain'))
            
            server = smtplib.SMTP(email_config['smtp_server'], email_config['smtp_port'])
            server.starttls()
            server.login(email_config['username'], email_config['password'])
            server.send_message(msg)
            server.quit()
            
            self.logger.info(f"Email notification sent for {len(alerts)} alerts")
            
        except Exception as e:
            self.logger.error(f"Failed to send email notification: {e}")
    
    def _send_slack_notifications(self, alerts: List[Alert]) -> None:
        """Send Slack notifications."""
        try:
            import requests
            
            webhook_url = self.config['notifications']['slack']['webhook_url']
            
            critical_alerts = [a for a in alerts if a.level == 'critical']
            warning_alerts = [a for a in alerts if a.level == 'warning']
            
            color = "danger" if critical_alerts else "warning"
            
            message = {
                "attachments": [
                    {
                        "color": color,
                        "title": f"Infrastructure Alert - {len(alerts)} issues detected",
                        "fields": [
                            {
                                "title": "Critical",
                                "value": str(len(critical_alerts)),
                                "short": True
                            },
                            {
                                "title": "Warning",
                                "value": str(len(warning_alerts)),
                                "short": True
                            }
                        ],
                        "text": "\n".join([f"• {alert.message}" for alert in alerts[:10]])
                    }
                ]
            }
            
            response = requests.post(webhook_url, json=message)
            response.raise_for_status()
            
            self.logger.info(f"Slack notification sent for {len(alerts)} alerts")
            
        except Exception as e:
            self.logger.error(f"Failed to send Slack notification: {e}")
    
    def generate_report(self, checks: List[HealthCheck]) -> str:
        """
        Generate a health check report.
        
        Args:
            checks: List of health check results
            
        Returns:
            str: Formatted report
        """
        healthy_count = sum(1 for c in checks if c.status == HealthStatus.HEALTHY)
        warning_count = sum(1 for c in checks if c.status == HealthStatus.WARNING)
        critical_count = sum(1 for c in checks if c.status == HealthStatus.CRITICAL)
        
        report = f"""
Infrastructure Health Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
================================================

Summary:
- Total Checks: {len(checks)}
- Healthy: {healthy_count}
- Warning: {warning_count}
- Critical: {critical_count}

Detailed Results:
"""
        
        for check in checks:
            status_symbol = {
                HealthStatus.HEALTHY: "✅",
                HealthStatus.WARNING: "⚠️",
                HealthStatus.CRITICAL: "❌",
                HealthStatus.UNKNOWN: "❓"
            }.get(check.status, "❓")
            
            report += f"\n{status_symbol} {check.name}: {check.message}"
            if check.response_time > 0:
                report += f" ({check.response_time:.2f}ms)"
        
        return report
    
    def run_monitoring_loop(self) -> None:
        """Run continuous monitoring loop."""
        self.logger.info("Starting infrastructure monitoring...")
        
        while True:
            try:
                # Run health checks
                checks = self.run_health_checks()
                self.health_checks = checks
                
                # Generate alerts
                alerts = self.generate_alerts(checks)
                self.alerts.extend(alerts)
                
                # Send notifications
                if alerts:
                    self.send_notifications(alerts)
                
                # Log summary
                critical_count = sum(1 for c in checks if c.status == HealthStatus.CRITICAL)
                warning_count = sum(1 for c in checks if c.status == HealthStatus.WARNING)
                
                if critical_count > 0:
                    self.logger.error(f"Health check completed: {critical_count} critical, {warning_count} warning")
                elif warning_count > 0:
                    self.logger.warning(f"Health check completed: {warning_count} warning issues")
                else:
                    self.logger.info("Health check completed: All systems healthy")
                
                # Wait for next cycle
                time.sleep(self.config['monitoring_interval'])
                
            except KeyboardInterrupt:
                self.logger.info("Monitoring stopped by user")
                break
            except Exception as e:
                self.logger.error(f"Error in monitoring loop: {e}")
                time.sleep(30)  # Wait before retrying


def main():
    """Main function for CLI usage."""
    parser = argparse.ArgumentParser(description='Infrastructure Health Monitor')
    parser.add_argument('--config', help='Configuration file path')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    parser.add_argument('--output', choices=['text', 'json'], default='text', help='Output format')
    
    args = parser.parse_args()
    
    # Initialize monitor
    monitor = InfrastructureMonitor(config_file=args.config)
    
    if args.once:
        # Run once and display results
        checks = monitor.run_health_checks()
        
        if args.output == 'json':
            output = json.dumps([asdict(check) for check in checks], default=str, indent=2)
        else:
            output = monitor.generate_report(checks)
        
        print(output)
    else:
        # Run continuous monitoring
        monitor.run_monitoring_loop()


if __name__ == "__main__":
    main()
