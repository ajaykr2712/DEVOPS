# Networking & Security Fundamentals

## Table of Contents
1. [DNS and Domain Management](#dns-and-domain-management)
2. [TLS/SSL and HTTPS](#tlsssl-and-https)
3. [JWT and Authentication](#jwt-and-authentication)
4. [MTU and Network Optimization](#mtu-and-network-optimization)
5. [Secrets Management](#secrets-management)
6. [API Authentication and Authorization](#api-authentication-and-authorization)
7. [OWASP Security Guidelines](#owasp-security-guidelines)
8. [Network Security Architecture](#network-security-architecture)
9. [Security Monitoring and Incident Response](#security-monitoring-and-incident-response)
10. [Interview Questions](#interview-questions)
11. [Interview Questions and Answers](#interview-questions-and-answers)

## DNS and Domain Management

### DNS Configuration and Management

```bash
#!/bin/bash
# scripts/dns-management.sh

# DNS record types and management

# Check DNS resolution
dig example.com A +short
dig example.com AAAA +short
dig example.com MX +short
dig example.com TXT +short
dig example.com CNAME +short

# Trace DNS resolution path
dig +trace example.com

# Check specific DNS server
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com

# Reverse DNS lookup
dig -x 8.8.8.8

# Check DNS propagation globally
for server in 8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9; do
    echo "Checking DNS server: $server"
    dig @$server example.com A +short
done

# Monitor DNS response times
time dig example.com > /dev/null

# Check DNSSEC validation
dig +dnssec example.com
```

```python
# scripts/dns-health-monitor.py
import dns.resolver
import dns.query
import dns.zone
import time
import requests
from datetime import datetime
from typing import Dict, List
import json

class DNSHealthMonitor:
    def __init__(self):
        self.dns_servers = [
            '8.8.8.8',      # Google
            '1.1.1.1',      # Cloudflare
            '208.67.222.222', # OpenDNS
            '9.9.9.9'       # Quad9
        ]
        self.record_types = ['A', 'AAAA', 'MX', 'TXT', 'CNAME']
    
    def check_dns_resolution(self, domain: str) -> Dict:
        """Check DNS resolution across multiple servers"""
        results = {
            'domain': domain,
            'timestamp': datetime.now().isoformat(),
            'servers': {},
            'health_score': 0
        }
        
        healthy_servers = 0
        
        for server in self.dns_servers:
            server_results = {
                'server': server,
                'records': {},
                'response_time': None,
                'status': 'unknown'
            }
            
            try:
                # Configure resolver
                resolver = dns.resolver.Resolver()
                resolver.nameservers = [server]
                resolver.timeout = 5
                resolver.lifetime = 10
                
                start_time = time.time()
                
                # Check each record type
                for record_type in self.record_types:
                    try:
                        answers = resolver.resolve(domain, record_type)
                        server_results['records'][record_type] = [
                            str(answer) for answer in answers
                        ]
                    except dns.resolver.NXDOMAIN:
                        server_results['records'][record_type] = 'NXDOMAIN'
                    except dns.resolver.NoAnswer:
                        server_results['records'][record_type] = 'No Answer'
                    except Exception as e:
                        server_results['records'][record_type] = f'Error: {str(e)}'
                
                server_results['response_time'] = round((time.time() - start_time) * 1000, 2)
                server_results['status'] = 'healthy'
                healthy_servers += 1
                
            except Exception as e:
                server_results['status'] = f'failed: {str(e)}'
            
            results['servers'][server] = server_results
        
        results['health_score'] = (healthy_servers / len(self.dns_servers)) * 100
        return results
    
    def check_dns_propagation(self, domain: str, expected_ip: str) -> Dict:
        """Check DNS propagation across global servers"""
        # Public DNS checkers from different regions
        global_servers = {
            'us-east': '8.8.8.8',
            'us-west': '208.67.220.220',
            'europe': '208.67.222.222',
            'asia': '1.1.1.1',
            'australia': '9.9.9.9'
        }
        
        propagation_results = {
            'domain': domain,
            'expected_ip': expected_ip,
            'timestamp': datetime.now().isoformat(),
            'regions': {},
            'propagation_percentage': 0
        }
        
        propagated_count = 0
        
        for region, server in global_servers.items():
            try:
                resolver = dns.resolver.Resolver()
                resolver.nameservers = [server]
                resolver.timeout = 3
                
                answers = resolver.resolve(domain, 'A')
                actual_ip = str(answers[0])
                
                is_propagated = actual_ip == expected_ip
                if is_propagated:
                    propagated_count += 1
                
                propagation_results['regions'][region] = {
                    'server': server,
                    'resolved_ip': actual_ip,
                    'expected_ip': expected_ip,
                    'propagated': is_propagated
                }
                
            except Exception as e:
                propagation_results['regions'][region] = {
                    'server': server,
                    'error': str(e),
                    'propagated': False
                }
        
        propagation_results['propagation_percentage'] = (propagated_count / len(global_servers)) * 100
        return propagation_results
    
    def monitor_dns_performance(self, domains: List[str], duration_minutes: int = 60):
        """Monitor DNS performance over time"""
        monitoring_data = []
        end_time = time.time() + (duration_minutes * 60)
        
        while time.time() < end_time:
            for domain in domains:
                result = self.check_dns_resolution(domain)
                monitoring_data.append(result)
                
                # Calculate average response time
                response_times = []
                for server_data in result['servers'].values():
                    if server_data['response_time']:
                        response_times.append(server_data['response_time'])
                
                avg_response_time = sum(response_times) / len(response_times) if response_times else 0
                
                print(f"[{datetime.now()}] {domain}: Health={result['health_score']:.1f}%, Avg Response={avg_response_time:.1f}ms")
            
            time.sleep(60)  # Check every minute
        
        return monitoring_data
    
    def generate_dns_report(self, monitoring_data: List[Dict]) -> str:
        """Generate DNS health report"""
        if not monitoring_data:
            return "No monitoring data available"
        
        # Aggregate data by domain
        domain_stats = {}
        
        for entry in monitoring_data:
            domain = entry['domain']
            if domain not in domain_stats:
                domain_stats[domain] = {
                    'checks': 0,
                    'total_health_score': 0,
                    'response_times': [],
                    'issues': []
                }
            
            domain_stats[domain]['checks'] += 1
            domain_stats[domain]['total_health_score'] += entry['health_score']
            
            # Collect response times
            for server_data in entry['servers'].values():
                if server_data['response_time']:
                    domain_stats[domain]['response_times'].append(server_data['response_time'])
                elif server_data['status'] != 'healthy':
                    domain_stats[domain]['issues'].append(f"{server_data['server']}: {server_data['status']}")
        
        # Generate report
        report = f"""
# DNS Health Monitoring Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary
"""
        
        for domain, stats in domain_stats.items():
            avg_health = stats['total_health_score'] / stats['checks']
            avg_response_time = sum(stats['response_times']) / len(stats['response_times']) if stats['response_times'] else 0
            
            report += f"""
### {domain}
- **Average Health Score**: {avg_health:.1f}%
- **Average Response Time**: {avg_response_time:.1f}ms
- **Total Checks**: {stats['checks']}
- **Issues Found**: {len(set(stats['issues']))}
"""
            
            if stats['issues']:
                report += "- **Common Issues**:\n"
                for issue in set(stats['issues'])[:5]:  # Top 5 unique issues
                    report += f"  - {issue}\n"
        
        return report

# Route 53 / CloudFlare DNS automation
class DNSManager:
    def __init__(self, provider='route53'):
        self.provider = provider
        if provider == 'route53':
            import boto3
            self.client = boto3.client('route53')
        elif provider == 'cloudflare':
            # CloudFlare API setup would go here
            pass
    
    def create_health_check(self, domain: str, ip: str) -> str:
        """Create Route 53 health check"""
        if self.provider == 'route53':
            response = self.client.create_health_check(
                Type='HTTP',
                ResourcePath='/health',
                FullyQualifiedDomainName=domain,
                Port=80,
                RequestInterval=30,
                FailureThreshold=3,
                Tags=[
                    {'Key': 'Name', 'Value': f'{domain}-health-check'},
                    {'Key': 'Environment', 'Value': 'production'}
                ]
            )
            return response['HealthCheck']['Id']
    
    def setup_failover_routing(self, hosted_zone_id: str, domain: str, primary_ip: str, secondary_ip: str):
        """Setup DNS failover routing"""
        if self.provider == 'route53':
            # Primary record
            self.client.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': domain,
                                'Type': 'A',
                                'SetIdentifier': 'primary',
                                'Failover': 'PRIMARY',
                                'TTL': 60,
                                'ResourceRecords': [{'Value': primary_ip}],
                                'HealthCheckId': 'primary-health-check-id'
                            }
                        },
                        {
                            'Action': 'UPSERT',
                            'ResourceRecordSet': {
                                'Name': domain,
                                'Type': 'A',
                                'SetIdentifier': 'secondary',
                                'Failover': 'SECONDARY',
                                'TTL': 60,
                                'ResourceRecords': [{'Value': secondary_ip}]
                            }
                        }
                    ]
                }
            )
```

## TLS/SSL and HTTPS

### SSL/TLS Certificate Management

```bash
#!/bin/bash
# scripts/ssl-management.sh

# Generate SSL certificate with Let's Encrypt
certbot certonly \
    --nginx \
    --domains example.com,www.example.com \
    --email admin@example.com \
    --agree-tos \
    --non-interactive

# Check SSL certificate details
openssl x509 -in /etc/ssl/certs/example.com.crt -text -noout

# Check SSL certificate expiration
openssl x509 -in /etc/ssl/certs/example.com.crt -dates -noout

# Test SSL connection
openssl s_client -connect example.com:443 -servername example.com

# Check SSL certificate from remote server
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -dates -noout

# Generate self-signed certificate for development
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes \
    -subj "/C=US/ST=CA/L=San Francisco/O=MyCompany/CN=localhost"

# Convert certificate formats
openssl x509 -outform der -in certificate.pem -out certificate.der
openssl x509 -inform der -in certificate.der -out certificate.pem

# Create certificate signing request (CSR)
openssl req -new -newkey rsa:2048 -nodes -keyout domain.key -out domain.csr \
    -subj "/C=US/ST=CA/L=San Francisco/O=MyCompany/CN=example.com"
```

```python
# scripts/ssl-certificate-monitor.py
import ssl
import socket
import datetime
import requests
from urllib.parse import urlparse
from cryptography import x509
from cryptography.hazmat.backends import default_backend
import smtplib
from email.mime.text import MIMEText
from typing import Dict, List

class SSLCertificateMonitor:
    def __init__(self):
        self.warning_days = 30  # Warn when cert expires in 30 days
        self.critical_days = 7  # Critical when cert expires in 7 days
    
    def get_certificate_info(self, hostname: str, port: int = 443) -> Dict:
        """Get SSL certificate information"""
        try:
            # Create SSL context
            context = ssl.create_default_context()
            
            # Connect and get certificate
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert_der = ssock.getpeercert_chain()[0]
                    cert_pem = ssl.DER_cert_to_PEM_cert(cert_der.dump())
                    
                    # Parse certificate
                    cert = x509.load_pem_x509_certificate(cert_pem.encode(), default_backend())
                    
                    # Extract information
                    subject = cert.subject.rfc4514_string()
                    issuer = cert.issuer.rfc4514_string()
                    not_before = cert.not_valid_before
                    not_after = cert.not_valid_after
                    
                    # Calculate days until expiration
                    days_until_expiry = (not_after - datetime.datetime.utcnow()).days
                    
                    # Get SAN (Subject Alternative Names)
                    try:
                        san_extension = cert.extensions.get_extension_for_oid(
                            x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME
                        )
                        san_names = [name.value for name in san_extension.value]
                    except x509.ExtensionNotFound:
                        san_names = []
                    
                    return {
                        'hostname': hostname,
                        'port': port,
                        'subject': subject,
                        'issuer': issuer,
                        'not_before': not_before,
                        'not_after': not_after,
                        'days_until_expiry': days_until_expiry,
                        'san_names': san_names,
                        'status': self._get_status(days_until_expiry),
                        'serial_number': str(cert.serial_number),
                        'version': cert.version.name,
                        'signature_algorithm': cert.signature_algorithm_oid._name
                    }
                    
        except Exception as e:
            return {
                'hostname': hostname,
                'port': port,
                'error': str(e),
                'status': 'error'
            }
    
    def _get_status(self, days_until_expiry: int) -> str:
        """Determine certificate status based on expiry"""
        if days_until_expiry < 0:
            return 'expired'
        elif days_until_expiry <= self.critical_days:
            return 'critical'
        elif days_until_expiry <= self.warning_days:
            return 'warning'
        else:
            return 'ok'
    
    def check_multiple_sites(self, sites: List[Dict]) -> List[Dict]:
        """Check SSL certificates for multiple sites"""
        results = []
        
        for site in sites:
            hostname = site.get('hostname')
            port = site.get('port', 443)
            
            print(f"Checking SSL certificate for {hostname}:{port}")
            cert_info = self.get_certificate_info(hostname, port)
            
            # Add site metadata
            cert_info.update({
                'site_name': site.get('name', hostname),
                'environment': site.get('environment', 'unknown'),
                'team': site.get('team', 'unknown')
            })
            
            results.append(cert_info)
        
        return results
    
    def validate_ssl_chain(self, hostname: str, port: int = 443) -> Dict:
        """Validate SSL certificate chain"""
        try:
            # Check chain validation
            response = requests.get(f"https://{hostname}:{port}", timeout=10, verify=True)
            
            return {
                'hostname': hostname,
                'chain_valid': True,
                'response_code': response.status_code,
                'ssl_version': response.raw.version,
                'cipher_suite': getattr(response.raw, 'cipher', 'unknown')
            }
            
        except requests.exceptions.SSLError as e:
            return {
                'hostname': hostname,
                'chain_valid': False,
                'error': str(e)
            }
        except Exception as e:
            return {
                'hostname': hostname,
                'chain_valid': False,
                'error': f"Connection error: {str(e)}"
            }
    
    def generate_ssl_report(self, certificates: List[Dict]) -> str:
        """Generate SSL certificate status report"""
        
        # Categorize certificates
        expired = [cert for cert in certificates if cert.get('status') == 'expired']
        critical = [cert for cert in certificates if cert.get('status') == 'critical']
        warning = [cert for cert in certificates if cert.get('status') == 'warning']
        ok = [cert for cert in certificates if cert.get('status') == 'ok']
        errors = [cert for cert in certificates if cert.get('status') == 'error']
        
        report = f"""
# SSL Certificate Monitoring Report
Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary
- **Total Certificates**: {len(certificates)}
- **Expired**: {len(expired)}
- **Critical (< {self.critical_days} days)**: {len(critical)}
- **Warning (< {self.warning_days} days)**: {len(warning)}
- **OK**: {len(ok)}
- **Errors**: {len(errors)}

"""
        
        if expired:
            report += "## 🚨 Expired Certificates\n"
            for cert in expired:
                report += f"- **{cert['hostname']}**: Expired {abs(cert.get('days_until_expiry', 0))} days ago\n"
        
        if critical:
            report += "## ⚠️ Critical (Expiring Soon)\n"
            for cert in critical:
                report += f"- **{cert['hostname']}**: Expires in {cert.get('days_until_expiry', 0)} days\n"
        
        if warning:
            report += "## ⚡ Warning (Expiring Within 30 Days)\n"
            for cert in warning:
                report += f"- **{cert['hostname']}**: Expires in {cert.get('days_until_expiry', 0)} days\n"
        
        if errors:
            report += "## ❌ Connection Errors\n"
            for cert in errors:
                report += f"- **{cert['hostname']}**: {cert.get('error', 'Unknown error')}\n"
        
        return report
    
    def setup_certificate_renewal(self, certificates: List[Dict]) -> str:
        """Generate certificate renewal script"""
        
        renewal_script = """#!/bin/bash
# SSL Certificate Renewal Script
# Generated automatically - review before executing

set -e

echo "Starting SSL certificate renewal process..."

"""
        
        for cert in certificates:
            if cert.get('status') in ['critical', 'warning']:
                hostname = cert['hostname']
                
                renewal_script += f"""
# Renew certificate for {hostname}
echo "Renewing certificate for {hostname}..."
certbot certonly --nginx --domains {hostname} --non-interactive --agree-tos

# Reload nginx to pick up new certificate
nginx -t && systemctl reload nginx

"""
        
        renewal_script += """
echo "Certificate renewal process completed!"

# Send notification
echo "SSL certificates renewed on $(date)" | mail -s "SSL Certificate Renewal" admin@example.com
"""
        
        return renewal_script

# Automated certificate monitoring with notifications
class CertificateNotificationManager:
    def __init__(self, smtp_server: str, smtp_port: int, username: str, password: str):
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.username = username
        self.password = password
    
    def send_certificate_alert(self, certificates: List[Dict], recipients: List[str]):
        """Send email alert for expiring certificates"""
        
        critical_certs = [cert for cert in certificates if cert.get('status') == 'critical']
        expired_certs = [cert for cert in certificates if cert.get('status') == 'expired']
        
        if not critical_certs and not expired_certs:
            return
        
        subject = f"SSL Certificate Alert - {len(critical_certs + expired_certs)} certificates need attention"
        
        body = f"""
SSL Certificate Alert

Expired Certificates ({len(expired_certs)}):
"""
        
        for cert in expired_certs:
            body += f"- {cert['hostname']}: Expired {abs(cert.get('days_until_expiry', 0))} days ago\n"
        
        body += f"\nCritical Certificates ({len(critical_certs)}):\n"
        
        for cert in critical_certs:
            body += f"- {cert['hostname']}: Expires in {cert.get('days_until_expiry', 0)} days\n"
        
        body += "\nPlease renew these certificates immediately to prevent service disruption."
        
        # Send email
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = self.username
        msg['To'] = ', '.join(recipients)
        
        try:
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.username, self.password)
            server.send_message(msg)
            server.quit()
            
            print(f"Alert sent to {', '.join(recipients)}")
            
        except Exception as e:
            print(f"Failed to send email alert: {e}")
```

## JWT and Authentication

### JWT Implementation and Security

```python
# scripts/jwt-authentication.py
import jwt
import hashlib
import secrets
import time
from datetime import datetime, timedelta, timezone
from typing import Dict, Optional, List
from functools import wraps
import bcrypt
import redis
import json

class JWTAuthManager:
    def __init__(self, secret_key: str, algorithm: str = 'HS256'):
        self.secret_key = secret_key
        self.algorithm = algorithm
        self.access_token_expire = timedelta(minutes=15)
        self.refresh_token_expire = timedelta(days=7)
        
        # Redis for token blacklisting and refresh token storage
        self.redis_client = redis.Redis(host='localhost', port=6379, db=0)
    
    def generate_tokens(self, user_id: str, user_data: Dict) -> Dict:
        """Generate access and refresh tokens"""
        
        # Access token payload
        access_payload = {
            'user_id': user_id,
            'username': user_data.get('username'),
            'email': user_data.get('email'),
            'roles': user_data.get('roles', []),
            'permissions': user_data.get('permissions', []),
            'iat': datetime.now(timezone.utc),
            'exp': datetime.now(timezone.utc) + self.access_token_expire,
            'token_type': 'access'
        }
        
        # Refresh token payload
        refresh_payload = {
            'user_id': user_id,
            'iat': datetime.now(timezone.utc),
            'exp': datetime.now(timezone.utc) + self.refresh_token_expire,
            'token_type': 'refresh',
            'jti': secrets.token_urlsafe(32)  # Unique token ID
        }
        
        # Generate tokens
        access_token = jwt.encode(access_payload, self.secret_key, algorithm=self.algorithm)
        refresh_token = jwt.encode(refresh_payload, self.secret_key, algorithm=self.algorithm)
        
        # Store refresh token in Redis
        self.redis_client.setex(
            f"refresh_token:{refresh_payload['jti']}", 
            int(self.refresh_token_expire.total_seconds()),
            json.dumps({
                'user_id': user_id,
                'created_at': datetime.now(timezone.utc).isoformat()
            })
        )
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token,
            'access_token_expires': access_payload['exp'].isoformat(),
            'refresh_token_expires': refresh_payload['exp'].isoformat(),
            'token_type': 'Bearer'
        }
    
    def verify_token(self, token: str, token_type: str = 'access') -> Optional[Dict]:
        """Verify and decode JWT token"""
        try:
            # Check if token is blacklisted
            if self.is_token_blacklisted(token):
                return None
            
            # Decode token
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            
            # Verify token type
            if payload.get('token_type') != token_type:
                return None
            
            # Check expiration
            if datetime.fromtimestamp(payload['exp'], timezone.utc) < datetime.now(timezone.utc):
                return None
            
            return payload
            
        except jwt.InvalidTokenError:
            return None
        except Exception:
            return None
    
    def refresh_access_token(self, refresh_token: str) -> Optional[Dict]:
        """Generate new access token using refresh token"""
        
        # Verify refresh token
        payload = self.verify_token(refresh_token, 'refresh')
        if not payload:
            return None
        
        # Check if refresh token exists in Redis
        jti = payload.get('jti')
        if not jti or not self.redis_client.exists(f"refresh_token:{jti}"):
            return None
        
        # Get user data
        user_id = payload['user_id']
        user_data = self.get_user_data(user_id)  # Implement this method
        
        if not user_data:
            return None
        
        # Generate new access token
        access_payload = {
            'user_id': user_id,
            'username': user_data.get('username'),
            'email': user_data.get('email'),
            'roles': user_data.get('roles', []),
            'permissions': user_data.get('permissions', []),
            'iat': datetime.now(timezone.utc),
            'exp': datetime.now(timezone.utc) + self.access_token_expire,
            'token_type': 'access'
        }
        
        access_token = jwt.encode(access_payload, self.secret_key, algorithm=self.algorithm)
        
        return {
            'access_token': access_token,
            'expires': access_payload['exp'].isoformat(),
            'token_type': 'Bearer'
        }
    
    def blacklist_token(self, token: str):
        """Add token to blacklist"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            exp = payload.get('exp')
            jti = payload.get('jti', hashlib.sha256(token.encode()).hexdigest())
            
            # Calculate TTL until token expiration
            ttl = exp - int(time.time())
            if ttl > 0:
                self.redis_client.setex(f"blacklist:{jti}", ttl, "1")
                
        except jwt.InvalidTokenError:
            pass
    
    def is_token_blacklisted(self, token: str) -> bool:
        """Check if token is blacklisted"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            jti = payload.get('jti', hashlib.sha256(token.encode()).hexdigest())
            return self.redis_client.exists(f"blacklist:{jti}")
        except jwt.InvalidTokenError:
            return True
    
    def revoke_refresh_token(self, refresh_token: str):
        """Revoke refresh token"""
        payload = self.verify_token(refresh_token, 'refresh')
        if payload and payload.get('jti'):
            self.redis_client.delete(f"refresh_token:{payload['jti']}")
    
    def revoke_all_user_tokens(self, user_id: str):
        """Revoke all tokens for a user"""
        # Find all refresh tokens for user
        pattern = "refresh_token:*"
        for key in self.redis_client.scan_iter(match=pattern):
            token_data = self.redis_client.get(key)
            if token_data:
                data = json.loads(token_data)
                if data.get('user_id') == user_id:
                    self.redis_client.delete(key)

# Authentication decorators
def require_auth(auth_manager: JWTAuthManager):
    """Decorator to require authentication"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            from flask import request, jsonify, g
            
            # Get token from header
            auth_header = request.headers.get('Authorization')
            if not auth_header or not auth_header.startswith('Bearer '):
                return jsonify({'error': 'Authentication required'}), 401
            
            token = auth_header.split(' ')[1]
            
            # Verify token
            payload = auth_manager.verify_token(token)
            if not payload:
                return jsonify({'error': 'Invalid or expired token'}), 401
            
            # Store user info in request context
            g.current_user = payload
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def require_roles(auth_manager: JWTAuthManager, required_roles: List[str]):
    """Decorator to require specific roles"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            from flask import g, jsonify
            
            user_roles = g.current_user.get('roles', [])
            
            # Check if user has any of the required roles
            if not any(role in user_roles for role in required_roles):
                return jsonify({'error': 'Insufficient permissions'}), 403
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def require_permissions(auth_manager: JWTAuthManager, required_permissions: List[str]):
    """Decorator to require specific permissions"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            from flask import g, jsonify
            
            user_permissions = g.current_user.get('permissions', [])
            
            # Check if user has all required permissions
            if not all(perm in user_permissions for perm in required_permissions):
                return jsonify({'error': 'Insufficient permissions'}), 403
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Password security utilities
class PasswordManager:
    @staticmethod
    def hash_password(password: str) -> str:
        """Hash password using bcrypt"""
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')
    
    @staticmethod
    def verify_password(password: str, hashed: str) -> bool:
        """Verify password against hash"""
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
    
    @staticmethod
    def generate_secure_password(length: int = 16) -> str:
        """Generate cryptographically secure password"""
        import string
        
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(length))
    
    @staticmethod
    def check_password_strength(password: str) -> Dict:
        """Check password strength and return score"""
        import re
        
        score = 0
        feedback = []
        
        # Length check
        if len(password) >= 12:
            score += 2
        elif len(password) >= 8:
            score += 1
        else:
            feedback.append("Password should be at least 8 characters long")
        
        # Character variety
        if re.search(r'[a-z]', password):
            score += 1
        else:
            feedback.append("Add lowercase letters")
        
        if re.search(r'[A-Z]', password):
            score += 1
        else:
            feedback.append("Add uppercase letters")
        
        if re.search(r'\d', password):
            score += 1
        else:
            feedback.append("Add numbers")
        
        if re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            score += 1
        else:
            feedback.append("Add special characters")
        
        # Common patterns
        if not re.search(r'(.)\1{2,}', password):  # No 3+ repeated characters
            score += 1
        else:
            feedback.append("Avoid repeating characters")
        
        # Determine strength
        if score >= 6:
            strength = "strong"
        elif score >= 4:
            strength = "medium"
        else:
            strength = "weak"
        
        return {
            'strength': strength,
            'score': score,
            'max_score': 7,
            'feedback': feedback
        }

# Example Flask application with JWT authentication
"""
from flask import Flask, request, jsonify, g
import json

app = Flask(__name__)
auth_manager = JWTAuthManager('your-secret-key')

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    # Authenticate user (implement your user authentication logic)
    user = authenticate_user(username, password)
    if not user:
        return jsonify({'error': 'Invalid credentials'}), 401
    
    # Generate tokens
    tokens = auth_manager.generate_tokens(user['id'], user)
    
    return jsonify({
        'message': 'Login successful',
        **tokens
    })

@app.route('/refresh', methods=['POST'])
def refresh():
    data = request.get_json()
    refresh_token = data.get('refresh_token')
    
    result = auth_manager.refresh_access_token(refresh_token)
    if not result:
        return jsonify({'error': 'Invalid refresh token'}), 401
    
    return jsonify(result)

@app.route('/logout', methods=['POST'])
@require_auth(auth_manager)
def logout():
    auth_header = request.headers.get('Authorization')
    token = auth_header.split(' ')[1]
    
    # Blacklist the token
    auth_manager.blacklist_token(token)
    
    return jsonify({'message': 'Logout successful'})

@app.route('/profile', methods=['GET'])
@require_auth(auth_manager)
def profile():
    return jsonify({
        'user': g.current_user,
        'message': 'Profile data'
    })

@app.route('/admin', methods=['GET'])
@require_auth(auth_manager)
@require_roles(auth_manager, ['admin', 'superuser'])
def admin_endpoint():
    return jsonify({'message': 'Admin only content'})
"""

## MTU and Network Optimization

### Network Performance Optimization

```bash
#!/bin/bash
# scripts/network-optimization.sh

# MTU Discovery and Optimization

# Check current MTU
ip link show | grep mtu

# Test MTU size with ping
ping -M do -s 1472 google.com  # 1472 + 28 (IP+ICMP) = 1500
ping -M do -s 8972 google.com  # Test for jumbo frames (9000 MTU)

# Find optimal MTU size
find_optimal_mtu() {
    local host=$1
    local max_mtu=1500
    local min_mtu=576
    local test_size
    
    echo "Finding optimal MTU for $host..."
    
    for ((size=max_mtu; size>=min_mtu; size-=4)); do
        test_size=$((size - 28))  # Subtract IP + ICMP headers
        
        if ping -M do -s $test_size -c 1 -W 1 $host >/dev/null 2>&1; then
            echo "Optimal MTU: $size"
            break
        fi
    done
}

# Set MTU for interface
set_mtu() {
    local interface=$1
    local mtu=$2
    
    echo "Setting MTU for $interface to $mtu"
    sudo ip link set dev $interface mtu $mtu
}

# Network performance testing
test_network_performance() {
    local host=$1
    
    echo "Testing network performance to $host..."
    
    # Ping test
    echo "=== Ping Test ==="
    ping -c 10 $host
    
    # Traceroute
    echo "=== Traceroute ==="
    traceroute $host
    
    # MTR (My Traceroute)
    echo "=== MTR Test ==="
    mtr --report --report-cycles 10 $host
    
    # Bandwidth test with iperf3 (if available)
    if command -v iperf3 &> /dev/null; then
        echo "=== Bandwidth Test ==="
        iperf3 -c $host -t 30
    fi
}

# TCP optimization
optimize_tcp() {
    echo "Applying TCP optimizations..."
    
    # Increase TCP buffer sizes
    echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
    echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf
    
    # Enable TCP window scaling
    echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
    
    # Enable TCP timestamps
    echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
    
    # Enable TCP SACK
    echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
    
    # Increase TCP congestion window
    echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf
    
    # Apply changes
    sysctl -p
    
    echo "TCP optimizations applied"
}

# Network interface statistics
show_network_stats() {
    local interface=$1
    
    echo "Network statistics for $interface:"
    echo "=================================="
    
    # Interface information
    ip addr show $interface
    
    # Statistics
    cat /proc/net/dev | grep $interface
    
    # Errors and drops
    echo ""
    echo "Errors and drops:"
    ethtool -S $interface | grep -E "(error|drop|discard)"
    
    # Speed and duplex
    echo ""
    echo "Speed and duplex:"
    ethtool $interface | grep -E "(Speed|Duplex)"
}

# Example usage
# find_optimal_mtu google.com
# test_network_performance google.com
# show_network_stats eth0
```

```python
# scripts/network-monitor.py
import subprocess
import time
import json
import socket
import struct
import select
import threading
from typing import Dict, List
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd

class NetworkMonitor:
    def __init__(self):
        self.monitoring = False
        self.stats = []
    
    def ping_host(self, host: str, count: int = 4) -> Dict:
        """Ping host and return statistics"""
        try:
            result = subprocess.run(
                ['ping', '-c', str(count), host],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                # Parse ping output
                lines = result.stdout.split('\n')
                stats_line = [line for line in lines if 'min/avg/max' in line]
                
                if stats_line:
                    # Extract statistics
                    stats_part = stats_line[0].split('=')[1].strip()
                    min_time, avg_time, max_time, stddev = stats_part.split('/')
                    
                    return {
                        'host': host,
                        'success': True,
                        'min_time': float(min_time),
                        'avg_time': float(avg_time),
                        'max_time': float(max_time),
                        'stddev': float(stddev),
                        'packet_loss': self._extract_packet_loss(result.stdout)
                    }
            
            return {
                'host': host,
                'success': False,
                'error': result.stderr
            }
            
        except Exception as e:
            return {
                'host': host,
                'success': False,
                'error': str(e)
            }
    
    def _extract_packet_loss(self, ping_output: str) -> float:
        """Extract packet loss percentage from ping output"""
        for line in ping_output.split('\n'):
            if 'packet loss' in line:
                # Extract percentage
                parts = line.split(',')
                for part in parts:
                    if 'packet loss' in part:
                        return float(part.split('%')[0].strip().split()[-1])
        return 0.0
    
    def traceroute_host(self, host: str) -> List[Dict]:
        """Perform traceroute and return hop information"""
        try:
            result = subprocess.run(
                ['traceroute', '-n', host],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            hops = []
            lines = result.stdout.split('\n')[1:]  # Skip header
            
            for line in lines:
                if line.strip():
                    parts = line.strip().split()
                    if len(parts) >= 2:
                        hop_num = parts[0]
                        
                        # Parse hop data
                        hop_data = {
                            'hop': int(hop_num) if hop_num.isdigit() else 0,
                            'ip': '',
                            'times': []
                        }
                        
                        # Extract IP and times
                        for part in parts[1:]:
                            if '.' in part and part.count('.') == 3:
                                hop_data['ip'] = part
                            elif part.endswith('ms'):
                                try:
                                    hop_data['times'].append(float(part[:-2]))
                                except ValueError:
                                    pass
                        
                        hops.append(hop_data)
            
            return hops
            
        except Exception as e:
            return [{'error': str(e)}]
    
    def test_mtu_size(self, host: str, start_size: int = 1500) -> int:
        """Test MTU size using ping with don't fragment flag"""
        max_working_size = 0
        
        for size in range(start_size, 500, -4):  # Test decreasing sizes
            packet_size = size - 28  # Subtract IP + ICMP headers
            
            try:
                result = subprocess.run(
                    ['ping', '-M', 'do', '-s', str(packet_size), '-c', '1', '-W', '1', host],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                
                if result.returncode == 0:
                    max_working_size = size
                    break
                    
            except subprocess.TimeoutExpired:
                continue
        
        return max_working_size
    
    def monitor_bandwidth(self, interface: str, duration: int = 60) -> Dict:
        """Monitor bandwidth usage on interface"""
        def get_interface_stats():
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if interface in line:
                        stats = line.split()
                        return {
                            'rx_bytes': int(stats[1]),
                            'rx_packets': int(stats[2]),
                            'tx_bytes': int(stats[9]),
                            'tx_packets': int(stats[10])
                        }
            return None
        
        start_stats = get_interface_stats()
        if not start_stats:
            return {'error': f'Interface {interface} not found'}
        
        start_time = time.time()
        time.sleep(duration)
        end_time = time.time()
        
        end_stats = get_interface_stats()
        if not end_stats:
            return {'error': f'Interface {interface} not found'}
        
        elapsed = end_time - start_time
        
        return {
            'interface': interface,
            'duration': elapsed,
            'rx_bytes_per_sec': (end_stats['rx_bytes'] - start_stats['rx_bytes']) / elapsed,
            'tx_bytes_per_sec': (end_stats['tx_bytes'] - start_stats['tx_bytes']) / elapsed,
            'rx_mbps': ((end_stats['rx_bytes'] - start_stats['rx_bytes']) * 8) / (elapsed * 1024 * 1024),
            'tx_mbps': ((end_stats['tx_bytes'] - start_stats['tx_bytes']) * 8) / (elapsed * 1024 * 1024),
            'rx_packets_per_sec': (end_stats['rx_packets'] - start_stats['rx_packets']) / elapsed,
            'tx_packets_per_sec': (end_stats['tx_packets'] - start_stats['tx_packets']) / elapsed
        }
    
    def continuous_monitoring(self, hosts: List[str], interval: int = 60):
        """Continuously monitor network performance"""
        self.monitoring = True
        
        while self.monitoring:
            timestamp = datetime.now()
            
            for host in hosts:
                # Ping test
                ping_result = self.ping_host(host, count=4)
                ping_result['timestamp'] = timestamp
                ping_result['test_type'] = 'ping'
                
                self.stats.append(ping_result)
                
                # MTU test (less frequent)
                if len(self.stats) % 10 == 0:  # Every 10th iteration
                    mtu_result = {
                        'host': host,
                        'timestamp': timestamp,
                        'test_type': 'mtu',
                        'mtu_size': self.test_mtu_size(host)
                    }
                    self.stats.append(mtu_result)
                
                print(f"[{timestamp}] {host}: {ping_result}")
            
            time.sleep(interval)
    
    def generate_network_report(self) -> str:
        """Generate network performance report"""
        if not self.stats:
            return "No monitoring data available"
        
        # Separate ping and MTU data
        ping_data = [stat for stat in self.stats if stat.get('test_type') == 'ping' and stat.get('success')]
        mtu_data = [stat for stat in self.stats if stat.get('test_type') == 'mtu']
        
        report = f"""
# Network Performance Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Ping Statistics
"""
        
        if ping_data:
            # Group by host
            hosts = set(stat['host'] for stat in ping_data)
            
            for host in hosts:
                host_data = [stat for stat in ping_data if stat['host'] == host]
                
                avg_times = [stat['avg_time'] for stat in host_data]
                packet_losses = [stat['packet_loss'] for stat in host_data]
                
                if avg_times:
                    report += f"""
### {host}
- **Average Latency**: {sum(avg_times)/len(avg_times):.2f}ms
- **Min Latency**: {min(avg_times):.2f}ms
- **Max Latency**: {max(avg_times):.2f}ms
- **Average Packet Loss**: {sum(packet_losses)/len(packet_losses):.2f}%
- **Total Tests**: {len(host_data)}
"""
        
        if mtu_data:
            report += "\n## MTU Test Results\n"
            for stat in mtu_data[-5:]:  # Last 5 MTU tests
                report += f"- **{stat['host']}**: {stat['mtu_size']} bytes\n"
        
        return report

# Usage example
if __name__ == "__main__":
    monitor = NetworkMonitor()
    
    # Test specific host
    result = monitor.ping_host("google.com")
    print(f"Ping result: {result}")
    
    # Test MTU
    mtu = monitor.test_mtu_size("google.com")
    print(f"MTU size: {mtu}")
    
    # Monitor bandwidth
    bandwidth = monitor.monitor_bandwidth("eth0", 10)
    print(f"Bandwidth: {bandwidth}")
    
    # Start continuous monitoring
    hosts = ["google.com", "cloudflare.com", "github.com"]
    
    # Run in background thread
    monitor_thread = threading.Thread(
        target=monitor.continuous_monitoring,
        args=(hosts, 30)
    )
    monitor_thread.daemon = True
    monitor_thread.start()
    
    # Let it run for a while, then generate report
    time.sleep(300)  # 5 minutes
    monitor.monitoring = False
    
    report = monitor.generate_network_report()
    print(report)
```

## Interview Questions

### Common Networking & Security Interview Questions

**Q1: Explain the difference between symmetric and asymmetric encryption.**

**Answer:**
- **Symmetric Encryption:** Same key for encryption/decryption. Fast, good for bulk data. Examples: AES, DES
- **Asymmetric Encryption:** Public/private key pairs. Slower, used for key exchange and digital signatures. Examples: RSA, ECC

```python
# Example usage in TLS handshake:
# 1. Client requests server's public key
# 2. Client generates symmetric key, encrypts with server's public key
# 3. Server decrypts with private key to get symmetric key
# 4. Both use symmetric key for session encryption
```

**Q2: How does JWT token security work and what are the vulnerabilities?**

**Answer:**
```python
# JWT Structure: header.payload.signature
# Security considerations:

1. **Algorithm Confusion**: Always specify algorithm
   jwt.decode(token, key, algorithms=['HS256'])  # Good
   jwt.decode(token, key)  # Vulnerable

2. **Secret Key Management**: Use strong, unique keys
   # Bad: jwt_secret = "password123"
   # Good: jwt_secret = secrets.token_urlsafe(64)

3. **Token Storage**: 
   # Client-side: Secure httpOnly cookies > localStorage
   # Server-side: Token blacklisting for logout

4. **Expiration**: Short-lived access tokens + refresh tokens
   access_token_expire = timedelta(minutes=15)
   refresh_token_expire = timedelta(days=7)
```

**Q3: What is MTU and how does it affect network performance?**

**Answer:**
- **MTU (Maximum Transmission Unit):** Largest packet size that can be transmitted without fragmentation
- **Standard Ethernet MTU:** 1500 bytes
- **Jumbo Frames:** Up to 9000 bytes for high-performance networks

```bash
# MTU Issues:
# 1. Fragmentation reduces performance
# 2. Path MTU discovery failures
# 3. Dropped packets if MTU mismatch

# Testing MTU:
ping -M do -s 1472 google.com  # Test 1500 MTU
ping -M do -s 8972 google.com  # Test 9000 MTU

# Optimize MTU:
ip link set dev eth0 mtu 9000
```

**Q4: How do you implement secure API authentication?**

**Answer:**
```python
# Multi-layer API security:

1. **Authentication Methods:**
   - JWT tokens with RS256 (asymmetric)
   - API keys with rate limiting
   - OAuth 2.0 for third-party access

2. **Authorization:**
   - Role-based access control (RBAC)
   - Permission-based authorization
   - Resource-level permissions

3. **Transport Security:**
   - HTTPS only (TLS 1.2+)
   - Certificate pinning
   - HSTS headers

4. **Request Validation:**
   - Input sanitization
   - Request signing (HMAC)
   - Rate limiting per user/IP

5. **Monitoring:**
   - Failed authentication attempts
   - Unusual access patterns
   - Token usage analytics
```

**Q5: Explain DNS security best practices.**

**Answer:**
```python
# DNS Security Measures:

1. **DNSSEC**: Cryptographic signatures for DNS records
   dig +dnssec example.com

2. **DNS over HTTPS (DoH)**: Encrypted DNS queries
   curl -H "accept: application/dns-json" \
        "https://cloudflare-dns.com/dns-query?name=example.com"

3. **DNS Filtering**: Block malicious domains
   - Use secure DNS providers (1.1.1.1, 8.8.8.8)
   - Implement DNS sinkholing

4. **Monitoring**: 
   - DNS query logs
   - Unusual resolution patterns
   - DNS tunnel detection

5. **Configuration Security:**
   - Disable DNS recursion for public servers
   - Rate limiting
   - Access control lists
```

**Q6: How do you handle secrets management in production?**

**Answer:**
```python
# Secrets Management Best Practices:

1. **Never in Code**: No hardcoded secrets
   # Bad: password = "secret123"
   # Good: password = os.environ.get('DB_PASSWORD')

2. **Centralized Management**:
   - AWS Secrets Manager / Parameter Store
   - HashiCorp Vault
   - Azure Key Vault

3. **Rotation**: Regular secret rotation
   def rotate_api_key():
       new_key = generate_secure_key()
       update_secret_manager('api_key', new_key)
       notify_applications()

4. **Access Control**: Least privilege principle
   # IAM policies for secret access
   # Service-specific secrets

5. **Encryption**: Encrypt at rest and in transit
   # Use encryption keys separate from secrets
   # Hardware Security Modules (HSM) for critical keys
```

**Q7: What are the OWASP Top 10 and how do you prevent them?**

**Answer:**
```python
# OWASP Top 10 2021 Prevention:

1. **Broken Access Control**:
   - Implement proper authorization checks
   - Deny by default, allow by exception

2. **Cryptographic Failures**:
   - Use strong encryption (AES-256, RSA-2048+)
   - Proper key management

3. **Injection**:
   - Parameterized queries
   - Input validation and sanitization

4. **Insecure Design**:
   - Threat modeling
   - Security by design principles

5. **Security Misconfiguration**:
   - Security hardening
   - Regular security audits

6. **Vulnerable Components**:
   - Dependency scanning
   - Regular updates

7. **Authentication Failures**:
   - Multi-factor authentication
   - Strong password policies

8. **Software Integrity Failures**:
   - Code signing
   - Supply chain security

9. **Logging Failures**:
   - Comprehensive logging
   - Real-time monitoring

10. **Server-Side Request Forgery**:
    - Input validation
    - Network segmentation
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is DNS? | Domain Name System - translates human-readable domain names to IP addresses |
| 2 | Easy | What is HTTPS? | HTTP over SSL/TLS providing encrypted communication |
| 3 | Easy | What is SSL/TLS? | Cryptographic protocols for secure communication over networks |
| 4 | Easy | What is a firewall? | Network security system monitoring and controlling traffic based on rules |
| 5 | Easy | What is authentication vs authorization? | Authentication verifies identity, authorization determines access permissions |
| 6 | Easy | What is encryption? | Process of converting plaintext into ciphertext for security |
| 7 | Easy | What is a VPN? | Virtual Private Network creating secure connection over public network |
| 8 | Easy | What is TCP vs UDP? | TCP is reliable connection-oriented, UDP is fast connectionless protocol |
| 9 | Easy | What is an IP address? | Unique identifier for devices on network (IPv4/IPv6) |
| 10 | Easy | What is a subnet mask? | Defines network and host portions of IP address |
| 11 | Easy | What is NAT? | Network Address Translation - maps private IPs to public IPs |
| 12 | Easy | What is DHCP? | Dynamic Host Configuration Protocol - automatically assigns IP addresses |
| 13 | Easy | What is a MAC address? | Media Access Control - unique hardware identifier for network interfaces |
| 14 | Easy | What is OSI model? | 7-layer model describing network communication: Physical, Data Link, Network, Transport, Session, Presentation, Application |
| 15 | Easy | What is port forwarding? | Redirecting network traffic from one port to another |
| 16 | Medium | What is JWT? | JSON Web Token - compact token format for securely transmitting information |
| 17 | Medium | What is OAuth 2.0? | Authorization framework allowing third-party access without sharing credentials |
| 18 | Medium | What is SAML? | Security Assertion Markup Language for exchanging authentication data |
| 19 | Medium | What is certificate authority? | Trusted entity that issues digital certificates |
| 20 | Medium | What is PKI? | Public Key Infrastructure for managing digital certificates and keys |
| 21 | Medium | What is DNS record types? | A (IPv4), AAAA (IPv6), CNAME (alias), MX (mail), TXT (text), NS (nameserver) |
| 22 | Medium | What is DNS caching? | Storing DNS query results to improve performance |
| 23 | Medium | What is load balancing algorithms? | Round-robin, least connections, weighted, IP hash methods |
| 24 | Medium | What is CDN security? | DDoS protection, SSL termination, WAF integration |
| 25 | Medium | What is API security? | Authentication, authorization, rate limiting, input validation |
| 26 | Medium | What is rate limiting? | Controlling frequency of requests to prevent abuse |
| 27 | Medium | What is input validation? | Checking user input against expected format and constraints |
| 28 | Medium | What is SQL injection? | Attack inserting malicious SQL code into application queries |
| 29 | Medium | What is XSS? | Cross-Site Scripting - injecting malicious scripts into web pages |
| 30 | Medium | What is CSRF? | Cross-Site Request Forgery - unauthorized actions on behalf of user |
| 31 | Hard | What is MTU and path MTU discovery? | Maximum Transmission Unit - largest packet size; discovery finds optimal MTU |
| 32 | Hard | What is BGP? | Border Gateway Protocol - routing protocol for internet backbone |
| 33 | Hard | What is VLAN? | Virtual LAN - logical network segmentation within physical network |
| 34 | Hard | What is network segmentation? | Dividing network into smaller segments for security and performance |
| 35 | Hard | What is zero trust architecture? | Security model requiring verification for every access request |
| 36 | Hard | What is secrets management? | Secure storage, rotation, and access control for sensitive data |
| 37 | Hard | What is certificate pinning? | Associating host with expected certificate to prevent MITM attacks |
| 38 | Hard | What is DNSSEC? | DNS Security Extensions - adds cryptographic signatures to DNS |
| 39 | Hard | What is OWASP Top 10? | List of most critical web application security risks |
| 40 | Hard | What is WAF? | Web Application Firewall - filters malicious web traffic |
| 41 | Hard | What is DDoS protection? | Defending against distributed denial-of-service attacks |
| 42 | Hard | What is intrusion detection system? | IDS monitors network for malicious activity |
| 43 | Hard | What is SIEM? | Security Information and Event Management - centralized security monitoring |
| 44 | Hard | What is vulnerability management? | Process of identifying, assessing, and mitigating security vulnerabilities |
| 45 | Hard | What is penetration testing? | Simulated cyber attack to find security weaknesses |
| 46 | Expert | What is network performance optimization? | Techniques like TCP optimization, compression, caching, QoS |
| 47 | Expert | What is MPLS? | Multiprotocol Label Switching - data forwarding technique |
| 48 | Expert | What is SD-WAN? | Software-Defined Wide Area Network - centralized network control |
| 49 | Expert | What is network automation? | Using software to configure and manage networks |
| 50 | Expert | What is intent-based networking? | Network management approach using business intent |
| 51 | Expert | What is container security? | Securing containerized applications and orchestration platforms |
| 52 | Expert | What is service mesh security? | Security features in service mesh like mTLS, policies |
| 53 | Expert | What is cloud security posture management? | Continuous monitoring of cloud security configurations |
| 54 | Expert | What is infrastructure as code security? | Security practices for IaC templates and deployments |
| 55 | Expert | What is DevSecOps? | Integrating security practices throughout DevOps pipeline |
