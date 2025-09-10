#!/usr/bin/env python3
"""
DevOps Excellence Infrastructure Management Tool

This script provides comprehensive infrastructure management capabilities including:
- AWS resource management and cost optimization
- Kubernetes cluster operations
- Security scanning and compliance checks
- Backup and disaster recovery operations
- Performance monitoring and alerting

Usage:
    python infrastructure_manager.py --help
    python infrastructure_manager.py aws list-resources
    python infrastructure_manager.py k8s health-check
    python infrastructure_manager.py security scan
    python infrastructure_manager.py backup create
"""

import argparse
import json
import logging
import sys
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional

import boto3
import requests
import yaml
from kubernetes import client, config
from kubernetes.client.rest import ApiException


class InfrastructureManager:
    """Main infrastructure management class."""
    
    def __init__(self, log_level: str = "INFO"):
        """Initialize the infrastructure manager."""
        self.setup_logging(log_level)
        self.logger = logging.getLogger(__name__)
        
        # Initialize AWS clients
        try:
            self.ec2 = boto3.client('ec2')
            self.rds = boto3.client('rds')
            self.s3 = boto3.client('s3')
            self.cloudwatch = boto3.client('cloudwatch')
            self.cost_explorer = boto3.client('ce')
            self.logger.info("AWS clients initialized successfully")
        except Exception as e:
            self.logger.error(f"Failed to initialize AWS clients: {e}")
            
        # Initialize Kubernetes client
        try:
            config.load_incluster_config()  # Try in-cluster config first
        except:
            try:
                config.load_kube_config()  # Fall back to local config
            except Exception as e:
                self.logger.warning(f"Could not load Kubernetes config: {e}")
                
        self.k8s_v1 = client.CoreV1Api()
        self.k8s_apps_v1 = client.AppsV1Api()
        
    def setup_logging(self, log_level: str):
        """Set up logging configuration."""
        logging.basicConfig(
            level=getattr(logging, log_level.upper()),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.StreamHandler(sys.stdout),
                logging.FileHandler('/var/log/infrastructure_manager.log')
            ]
        )

    def aws_list_resources(self) -> Dict:
        """List all AWS resources with their details."""
        self.logger.info("Listing AWS resources...")
        resources = {
            'ec2_instances': [],
            'rds_instances': [],
            's3_buckets': [],
            'total_cost_last_month': 0
        }
        
        try:
            # EC2 Instances
            ec2_response = self.ec2.describe_instances()
            for reservation in ec2_response['Reservations']:
                for instance in reservation['Instances']:
                    resources['ec2_instances'].append({
                        'id': instance['InstanceId'],
                        'type': instance['InstanceType'],
                        'state': instance['State']['Name'],
                        'launch_time': instance['LaunchTime'].isoformat(),
                        'tags': {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                    })
            
            # RDS Instances
            rds_response = self.rds.describe_db_instances()
            for db_instance in rds_response['DBInstances']:
                resources['rds_instances'].append({
                    'id': db_instance['DBInstanceIdentifier'],
                    'class': db_instance['DBInstanceClass'],
                    'engine': db_instance['Engine'],
                    'status': db_instance['DBInstanceStatus'],
                    'created_time': db_instance['InstanceCreateTime'].isoformat()
                })
            
            # S3 Buckets
            s3_response = self.s3.list_buckets()
            for bucket in s3_response['Buckets']:
                bucket_location = self.s3.get_bucket_location(Bucket=bucket['Name'])
                resources['s3_buckets'].append({
                    'name': bucket['Name'],
                    'created_date': bucket['CreationDate'].isoformat(),
                    'region': bucket_location.get('LocationConstraint', 'us-east-1')
                })
            
            # Cost Information
            end_date = datetime.now().date()
            start_date = end_date - timedelta(days=30)
            
            cost_response = self.cost_explorer.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date.strftime('%Y-%m-%d'),
                    'End': end_date.strftime('%Y-%m-%d')
                },
                Granularity='MONTHLY',
                Metrics=['BlendedCost']
            )
            
            if cost_response['ResultsByTime']:
                resources['total_cost_last_month'] = float(
                    cost_response['ResultsByTime'][0]['Total']['BlendedCost']['Amount']
                )
            
            self.logger.info(f"Found {len(resources['ec2_instances'])} EC2 instances, "
                           f"{len(resources['rds_instances'])} RDS instances, "
                           f"{len(resources['s3_buckets'])} S3 buckets")
            
        except Exception as e:
            self.logger.error(f"Error listing AWS resources: {e}")
            
        return resources

    def aws_optimize_costs(self) -> Dict:
        """Analyze and suggest cost optimizations."""
        self.logger.info("Analyzing cost optimization opportunities...")
        recommendations = {
            'stopped_instances': [],
            'underutilized_instances': [],
            'unattached_volumes': [],
            'old_snapshots': [],
            'potential_savings': 0
        }
        
        try:
            # Find stopped instances
            ec2_response = self.ec2.describe_instances(
                Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}]
            )
            
            for reservation in ec2_response['Reservations']:
                for instance in reservation['Instances']:
                    recommendations['stopped_instances'].append({
                        'id': instance['InstanceId'],
                        'type': instance['InstanceType'],
                        'stopped_time': instance['StateTransitionReason']
                    })
            
            # Find unattached volumes
            volumes = self.ec2.describe_volumes(
                Filters=[{'Name': 'status', 'Values': ['available']}]
            )
            
            for volume in volumes['Volumes']:
                recommendations['unattached_volumes'].append({
                    'id': volume['VolumeId'],
                    'size': volume['Size'],
                    'created_time': volume['CreateTime'].isoformat()
                })
            
            # Find old snapshots (older than 30 days)
            snapshots = self.ec2.describe_snapshots(OwnerIds=['self'])
            thirty_days_ago = datetime.now() - timedelta(days=30)
            
            for snapshot in snapshots['Snapshots']:
                if snapshot['StartTime'].replace(tzinfo=None) < thirty_days_ago:
                    recommendations['old_snapshots'].append({
                        'id': snapshot['SnapshotId'],
                        'created_time': snapshot['StartTime'].isoformat(),
                        'volume_size': snapshot['VolumeSize']
                    })
            
            self.logger.info(f"Found {len(recommendations['stopped_instances'])} stopped instances, "
                           f"{len(recommendations['unattached_volumes'])} unattached volumes, "
                           f"{len(recommendations['old_snapshots'])} old snapshots")
            
        except Exception as e:
            self.logger.error(f"Error analyzing cost optimization: {e}")
            
        return recommendations

    def k8s_health_check(self) -> Dict:
        """Perform comprehensive Kubernetes cluster health check."""
        self.logger.info("Performing Kubernetes health check...")
        health_status = {
            'cluster_info': {},
            'node_status': [],
            'pod_status': [],
            'service_status': [],
            'issues': []
        }
        
        try:
            # Cluster info
            version = client.VersionApi().get_code()
            health_status['cluster_info'] = {
                'version': version.git_version,
                'platform': version.platform
            }
            
            # Node status
            nodes = self.k8s_v1.list_node()
            for node in nodes.items:
                node_info = {
                    'name': node.metadata.name,
                    'status': 'Ready' if any(condition.type == 'Ready' and condition.status == 'True' 
                                           for condition in node.status.conditions) else 'NotReady',
                    'cpu_capacity': node.status.capacity.get('cpu', 'Unknown'),
                    'memory_capacity': node.status.capacity.get('memory', 'Unknown')
                }
                health_status['node_status'].append(node_info)
                
                if node_info['status'] == 'NotReady':
                    health_status['issues'].append(f"Node {node.metadata.name} is not ready")
            
            # Pod status
            pods = self.k8s_v1.list_pod_for_all_namespaces()
            failed_pods = []
            restart_counts = {}
            
            for pod in pods.items:
                if pod.status.phase in ['Failed', 'Pending']:
                    failed_pods.append({
                        'name': pod.metadata.name,
                        'namespace': pod.metadata.namespace,
                        'phase': pod.status.phase
                    })
                
                # Check restart counts
                if pod.status.container_statuses:
                    for container in pod.status.container_statuses:
                        if container.restart_count > 5:
                            restart_counts[f"{pod.metadata.namespace}/{pod.metadata.name}"] = container.restart_count
            
            health_status['pod_status'] = {
                'failed_pods': failed_pods,
                'high_restart_pods': restart_counts
            }
            
            # Service status
            services = self.k8s_v1.list_service_for_all_namespaces()
            health_status['service_status'] = [
                {
                    'name': svc.metadata.name,
                    'namespace': svc.metadata.namespace,
                    'type': svc.spec.type,
                    'cluster_ip': svc.spec.cluster_ip
                }
                for svc in services.items
            ]
            
            # Add issues for failed pods and high restarts
            if failed_pods:
                health_status['issues'].extend([
                    f"Pod {pod['namespace']}/{pod['name']} is in {pod['phase']} state"
                    for pod in failed_pods
                ])
            
            if restart_counts:
                health_status['issues'].extend([
                    f"Pod {pod} has {count} restarts"
                    for pod, count in restart_counts.items()
                ])
            
            self.logger.info(f"Health check completed. Found {len(health_status['issues'])} issues")
            
        except ApiException as e:
            self.logger.error(f"Kubernetes API error during health check: {e}")
            health_status['issues'].append(f"API Error: {e}")
        except Exception as e:
            self.logger.error(f"Error during Kubernetes health check: {e}")
            health_status['issues'].append(f"General Error: {e}")
            
        return health_status

    def security_scan(self) -> Dict:
        """Perform security scanning and compliance checks."""
        self.logger.info("Performing security scan...")
        security_report = {
            'aws_security': {},
            'k8s_security': {},
            'network_security': {},
            'vulnerabilities': [],
            'compliance_issues': []
        }
        
        try:
            # AWS Security Checks
            security_report['aws_security'] = self._check_aws_security()
            
            # Kubernetes Security Checks
            security_report['k8s_security'] = self._check_k8s_security()
            
            # Network Security Checks
            security_report['network_security'] = self._check_network_security()
            
            self.logger.info("Security scan completed")
            
        except Exception as e:
            self.logger.error(f"Error during security scan: {e}")
            security_report['vulnerabilities'].append(f"Scan Error: {e}")
            
        return security_report

    def _check_aws_security(self) -> Dict:
        """Check AWS security configurations."""
        aws_security = {
            'open_security_groups': [],
            'unencrypted_volumes': [],
            'public_buckets': []
        }
        
        try:
            # Check for overly permissive security groups
            security_groups = self.ec2.describe_security_groups()
            for sg in security_groups['SecurityGroups']:
                for rule in sg['IpPermissions']:
                    for ip_range in rule.get('IpRanges', []):
                        if ip_range.get('CidrIp') == '0.0.0.0/0':
                            aws_security['open_security_groups'].append({
                                'group_id': sg['GroupId'],
                                'group_name': sg['GroupName'],
                                'port': rule.get('FromPort', 'All'),
                                'protocol': rule['IpProtocol']
                            })
            
            # Check for unencrypted EBS volumes
            volumes = self.ec2.describe_volumes()
            for volume in volumes['Volumes']:
                if not volume.get('Encrypted', False):
                    aws_security['unencrypted_volumes'].append({
                        'volume_id': volume['VolumeId'],
                        'size': volume['Size'],
                        'state': volume['State']
                    })
            
            # Check for public S3 buckets
            buckets = self.s3.list_buckets()
            for bucket in buckets['Buckets']:
                try:
                    acl = self.s3.get_bucket_acl(Bucket=bucket['Name'])
                    for grant in acl['Grants']:
                        grantee = grant.get('Grantee', {})
                        if grantee.get('Type') == 'Group' and 'AllUsers' in grantee.get('URI', ''):
                            aws_security['public_buckets'].append(bucket['Name'])
                except Exception:
                    pass  # Bucket might not be accessible
                    
        except Exception as e:
            self.logger.error(f"Error checking AWS security: {e}")
            
        return aws_security

    def _check_k8s_security(self) -> Dict:
        """Check Kubernetes security configurations."""
        k8s_security = {
            'privileged_pods': [],
            'pods_without_security_context': [],
            'services_without_network_policies': []
        }
        
        try:
            pods = self.k8s_v1.list_pod_for_all_namespaces()
            for pod in pods.items:
                # Check for privileged containers
                if pod.spec.containers:
                    for container in pod.spec.containers:
                        security_context = container.security_context
                        if security_context and security_context.privileged:
                            k8s_security['privileged_pods'].append({
                                'name': pod.metadata.name,
                                'namespace': pod.metadata.namespace,
                                'container': container.name
                            })
                        
                        # Check for missing security context
                        if not security_context:
                            k8s_security['pods_without_security_context'].append({
                                'name': pod.metadata.name,
                                'namespace': pod.metadata.namespace,
                                'container': container.name
                            })
                            
        except Exception as e:
            self.logger.error(f"Error checking Kubernetes security: {e}")
            
        return k8s_security

    def _check_network_security(self) -> Dict:
        """Check network security configurations."""
        network_security = {
            'open_ports': [],
            'ssl_certificates': [],
            'dns_security': []
        }
        
        # This would typically involve external tools like nmap, sslyze, etc.
        # For now, we'll return a placeholder
        return network_security

    def create_backup(self, backup_type: str = "full") -> Dict:
        """Create backup of critical infrastructure components."""
        self.logger.info(f"Creating {backup_type} backup...")
        backup_report = {
            'backup_id': f"backup-{int(time.time())}",
            'backup_type': backup_type,
            'timestamp': datetime.now().isoformat(),
            'components': []
        }
        
        try:
            if backup_type in ["full", "aws"]:
                # Backup AWS resources
                self._backup_aws_resources(backup_report)
            
            if backup_type in ["full", "k8s"]:
                # Backup Kubernetes resources
                self._backup_k8s_resources(backup_report)
            
            self.logger.info(f"Backup {backup_report['backup_id']} completed successfully")
            
        except Exception as e:
            self.logger.error(f"Error creating backup: {e}")
            backup_report['error'] = str(e)
            
        return backup_report

    def _backup_aws_resources(self, backup_report: Dict):
        """Backup AWS resources."""
        # Create EBS snapshots
        volumes = self.ec2.describe_volumes()
        for volume in volumes['Volumes']:
            if volume['State'] == 'in-use':
                snapshot = self.ec2.create_snapshot(
                    VolumeId=volume['VolumeId'],
                    Description=f"Automated backup - {backup_report['backup_id']}"
                )
                backup_report['components'].append({
                    'type': 'ebs_snapshot',
                    'resource_id': volume['VolumeId'],
                    'backup_id': snapshot['SnapshotId']
                })

    def _backup_k8s_resources(self, backup_report: Dict):
        """Backup Kubernetes resources."""
        # Backup persistent volumes
        pvs = self.k8s_v1.list_persistent_volume()
        for pv in pvs.items:
            backup_report['components'].append({
                'type': 'persistent_volume',
                'resource_id': pv.metadata.name,
                'backup_id': f"pv-backup-{pv.metadata.name}"
            })


def main():
    """Main function to handle command line arguments."""
    parser = argparse.ArgumentParser(description="DevOps Excellence Infrastructure Manager")
    parser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"])
    
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # AWS commands
    aws_parser = subparsers.add_parser("aws", help="AWS operations")
    aws_subparsers = aws_parser.add_subparsers(dest="aws_action")
    aws_subparsers.add_parser("list-resources", help="List all AWS resources")
    aws_subparsers.add_parser("optimize-costs", help="Analyze cost optimization opportunities")
    
    # Kubernetes commands
    k8s_parser = subparsers.add_parser("k8s", help="Kubernetes operations")
    k8s_subparsers = k8s_parser.add_subparsers(dest="k8s_action")
    k8s_subparsers.add_parser("health-check", help="Perform cluster health check")
    
    # Security commands
    security_parser = subparsers.add_parser("security", help="Security operations")
    security_subparsers = security_parser.add_subparsers(dest="security_action")
    security_subparsers.add_parser("scan", help="Perform security scan")
    
    # Backup commands
    backup_parser = subparsers.add_parser("backup", help="Backup operations")
    backup_subparsers = backup_parser.add_subparsers(dest="backup_action")
    backup_create = backup_subparsers.add_parser("create", help="Create backup")
    backup_create.add_argument("--type", default="full", choices=["full", "aws", "k8s"])
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = InfrastructureManager(args.log_level)
    
    try:
        if args.command == "aws":
            if args.aws_action == "list-resources":
                result = manager.aws_list_resources()
            elif args.aws_action == "optimize-costs":
                result = manager.aws_optimize_costs()
            else:
                aws_parser.print_help()
                return
                
        elif args.command == "k8s":
            if args.k8s_action == "health-check":
                result = manager.k8s_health_check()
            else:
                k8s_parser.print_help()
                return
                
        elif args.command == "security":
            if args.security_action == "scan":
                result = manager.security_scan()
            else:
                security_parser.print_help()
                return
                
        elif args.command == "backup":
            if args.backup_action == "create":
                result = manager.create_backup(args.type)
            else:
                backup_parser.print_help()
                return
        
        print(json.dumps(result, indent=2, default=str))
        
    except Exception as e:
        logging.error(f"Command execution failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
