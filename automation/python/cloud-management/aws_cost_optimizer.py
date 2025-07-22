#!/usr/bin/env python3
"""
AWS Cost Optimizer

A comprehensive tool for analyzing and optimizing AWS costs across multiple accounts.
Provides recommendations for cost reduction and automated implementation of savings.

Author: DevOps Excellence Team
Version: 2.0.0
License: MIT
"""

import boto3
import json
import logging
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
import pandas as pd


@dataclass
class CostRecommendation:
    """Data class for cost optimization recommendations."""
    service: str
    resource_id: str
    current_cost: float
    potential_savings: float
    recommendation: str
    confidence: float
    implementation_effort: str


class AWSCostOptimizer:
    """
    AWS Cost Optimization Tool
    
    Analyzes AWS costs and provides actionable recommendations for cost reduction.
    """
    
    def __init__(self, profile: Optional[str] = None, region: str = 'us-east-1'):
        """
        Initialize the cost optimizer.
        
        Args:
            profile: AWS profile name
            region: AWS region
        """
        self.session = boto3.Session(profile_name=profile)
        self.region = region
        self.ce_client = self.session.client('ce', region_name='us-east-1')
        self.ec2_client = self.session.client('ec2', region_name=region)
        self.rds_client = self.session.client('rds', region_name=region)
        self.cloudwatch_client = self.session.client('cloudwatch', region_name=region)
        
        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
    
    def get_cost_usage(self, days: int = 30) -> Dict:
        """
        Get cost and usage data for the specified period.
        
        Args:
            days: Number of days to analyze
            
        Returns:
            Dict: Cost and usage data
        """
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        try:
            response = self.ce_client.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date.strftime('%Y-%m-%d'),
                    'End': end_date.strftime('%Y-%m-%d')
                },
                Granularity='DAILY',
                Metrics=['BlendedCost', 'UsageQuantity'],
                GroupBy=[
                    {'Type': 'DIMENSION', 'Key': 'SERVICE'},
                    {'Type': 'DIMENSION', 'Key': 'INSTANCE_TYPE'}
                ]
            )
            return response
        except Exception as e:
            self.logger.error(f"Error fetching cost data: {e}")
            return {}
    
    def analyze_ec2_instances(self) -> List[CostRecommendation]:
        """
        Analyze EC2 instances for optimization opportunities.
        
        Returns:
            List[CostRecommendation]: List of recommendations
        """
        recommendations = []
        
        try:
            # Get all EC2 instances
            instances = self.ec2_client.describe_instances()
            
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    if instance['State']['Name'] == 'running':
                        rec = self._analyze_instance_utilization(instance)
                        if rec:
                            recommendations.append(rec)
                            
        except Exception as e:
            self.logger.error(f"Error analyzing EC2 instances: {e}")
        
        return recommendations
    
    def _analyze_instance_utilization(self, instance: Dict) -> Optional[CostRecommendation]:
        """
        Analyze individual instance utilization.
        
        Args:
            instance: EC2 instance data
            
        Returns:
            Optional[CostRecommendation]: Recommendation if applicable
        """
        instance_id = instance['InstanceId']
        instance_type = instance['InstanceType']
        
        # Get CPU utilization metrics
        cpu_utilization = self._get_cpu_utilization(instance_id)
        
        if cpu_utilization < 20:  # Low utilization threshold
            # Calculate potential savings
            current_cost = self._estimate_instance_cost(instance_type)
            new_instance_type = self._recommend_smaller_instance(instance_type)
            new_cost = self._estimate_instance_cost(new_instance_type)
            savings = current_cost - new_cost
            
            return CostRecommendation(
                service='EC2',
                resource_id=instance_id,
                current_cost=current_cost,
                potential_savings=savings,
                recommendation=f"Downsize from {instance_type} to {new_instance_type}",
                confidence=0.85,
                implementation_effort='Low'
            )
        
        return None
    
    def _get_cpu_utilization(self, instance_id: str, days: int = 14) -> float:
        """
        Get average CPU utilization for an instance.
        
        Args:
            instance_id: EC2 instance ID
            days: Number of days to analyze
            
        Returns:
            float: Average CPU utilization percentage
        """
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(days=days)
        
        try:
            response = self.cloudwatch_client.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[
                    {'Name': 'InstanceId', 'Value': instance_id}
                ],
                StartTime=start_time,
                EndTime=end_time,
                Period=3600,  # 1 hour
                Statistics=['Average']
            )
            
            if response['Datapoints']:
                avg_cpu = sum(dp['Average'] for dp in response['Datapoints']) / len(response['Datapoints'])
                return avg_cpu
                
        except Exception as e:
            self.logger.error(f"Error getting CPU utilization for {instance_id}: {e}")
        
        return 100  # Assume high utilization if unable to get metrics
    
    def _estimate_instance_cost(self, instance_type: str) -> float:
        """
        Estimate monthly cost for an instance type.
        
        Args:
            instance_type: EC2 instance type
            
        Returns:
            float: Estimated monthly cost in USD
        """
        # Simplified cost estimation (use AWS Pricing API for production)
        cost_map = {
            't3.micro': 8.47,
            't3.small': 16.93,
            't3.medium': 33.87,
            't3.large': 67.74,
            't3.xlarge': 135.48,
            'm5.large': 87.60,
            'm5.xlarge': 175.20,
            'm5.2xlarge': 350.40,
            'c5.large': 78.84,
            'c5.xlarge': 157.68,
            'c5.2xlarge': 315.36
        }
        
        return cost_map.get(instance_type, 100.0)  # Default estimate
    
    def _recommend_smaller_instance(self, current_type: str) -> str:
        """
        Recommend a smaller instance type.
        
        Args:
            current_type: Current instance type
            
        Returns:
            str: Recommended smaller instance type
        """
        downsize_map = {
            't3.large': 't3.medium',
            't3.xlarge': 't3.large',
            'm5.xlarge': 'm5.large',
            'm5.2xlarge': 'm5.xlarge',
            'c5.xlarge': 'c5.large',
            'c5.2xlarge': 'c5.xlarge'
        }
        
        return downsize_map.get(current_type, current_type)
    
    def analyze_rds_instances(self) -> List[CostRecommendation]:
        """
        Analyze RDS instances for optimization opportunities.
        
        Returns:
            List[CostRecommendation]: List of recommendations
        """
        recommendations = []
        
        try:
            response = self.rds_client.describe_db_instances()
            
            for db_instance in response['DBInstances']:
                if db_instance['DBInstanceStatus'] == 'available':
                    rec = self._analyze_rds_utilization(db_instance)
                    if rec:
                        recommendations.append(rec)
                        
        except Exception as e:
            self.logger.error(f"Error analyzing RDS instances: {e}")
        
        return recommendations
    
    def _analyze_rds_utilization(self, db_instance: Dict) -> Optional[CostRecommendation]:
        """
        Analyze RDS instance utilization.
        
        Args:
            db_instance: RDS instance data
            
        Returns:
            Optional[CostRecommendation]: Recommendation if applicable
        """
        db_identifier = db_instance['DBInstanceIdentifier']
        db_class = db_instance['DBInstanceClass']
        
        # Get database connection metrics
        connections = self._get_rds_connections(db_identifier)
        cpu_utilization = self._get_rds_cpu_utilization(db_identifier)
        
        if connections < 10 and cpu_utilization < 30:  # Low utilization
            current_cost = self._estimate_rds_cost(db_class)
            new_class = self._recommend_smaller_rds(db_class)
            new_cost = self._estimate_rds_cost(new_class)
            savings = current_cost - new_cost
            
            return CostRecommendation(
                service='RDS',
                resource_id=db_identifier,
                current_cost=current_cost,
                potential_savings=savings,
                recommendation=f"Downsize from {db_class} to {new_class}",
                confidence=0.75,
                implementation_effort='Medium'
            )
        
        return None
    
    def _get_rds_connections(self, db_identifier: str) -> float:
        """Get average database connections."""
        # Implementation for RDS connection metrics
        return 50  # Placeholder
    
    def _get_rds_cpu_utilization(self, db_identifier: str) -> float:
        """Get RDS CPU utilization."""
        # Implementation for RDS CPU metrics
        return 50  # Placeholder
    
    def _estimate_rds_cost(self, db_class: str) -> float:
        """Estimate RDS monthly cost."""
        # Simplified RDS cost estimation
        cost_map = {
            'db.t3.micro': 15.18,
            'db.t3.small': 30.37,
            'db.t3.medium': 60.74,
            'db.t3.large': 121.47,
            'db.m5.large': 175.20,
            'db.m5.xlarge': 350.40
        }
        return cost_map.get(db_class, 200.0)
    
    def _recommend_smaller_rds(self, current_class: str) -> str:
        """Recommend smaller RDS instance class."""
        downsize_map = {
            'db.t3.small': 'db.t3.micro',
            'db.t3.medium': 'db.t3.small',
            'db.t3.large': 'db.t3.medium',
            'db.m5.large': 'db.t3.large',
            'db.m5.xlarge': 'db.m5.large'
        }
        return downsize_map.get(current_class, current_class)
    
    def generate_report(self, recommendations: List[CostRecommendation]) -> str:
        """
        Generate a comprehensive cost optimization report.
        
        Args:
            recommendations: List of cost recommendations
            
        Returns:
            str: Formatted report
        """
        total_savings = sum(rec.potential_savings for rec in recommendations)
        
        report = f"""
        ===============================================
        AWS Cost Optimization Report
        Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        ===============================================
        
        Summary:
        - Total Recommendations: {len(recommendations)}
        - Potential Monthly Savings: ${total_savings:.2f}
        - Annual Savings Projection: ${total_savings * 12:.2f}
        
        Detailed Recommendations:
        """
        
        for i, rec in enumerate(recommendations, 1):
            report += f"""
        {i}. {rec.service} - {rec.resource_id}
           Current Cost: ${rec.current_cost:.2f}/month
           Potential Savings: ${rec.potential_savings:.2f}/month
           Recommendation: {rec.recommendation}
           Confidence: {rec.confidence:.0%}
           Implementation Effort: {rec.implementation_effort}
        """
        
        return report
    
    def run_analysis(self) -> List[CostRecommendation]:
        """
        Run complete cost analysis.
        
        Returns:
            List[CostRecommendation]: All recommendations
        """
        self.logger.info("Starting AWS cost analysis...")
        
        all_recommendations = []
        
        # Analyze EC2 instances
        self.logger.info("Analyzing EC2 instances...")
        ec2_recommendations = self.analyze_ec2_instances()
        all_recommendations.extend(ec2_recommendations)
        
        # Analyze RDS instances
        self.logger.info("Analyzing RDS instances...")
        rds_recommendations = self.analyze_rds_instances()
        all_recommendations.extend(rds_recommendations)
        
        self.logger.info(f"Analysis complete. Found {len(all_recommendations)} recommendations.")
        
        return all_recommendations


def main():
    """Main function for CLI usage."""
    parser = argparse.ArgumentParser(description='AWS Cost Optimizer')
    parser.add_argument('--profile', help='AWS profile name')
    parser.add_argument('--region', default='us-east-1', help='AWS region')
    parser.add_argument('--output', choices=['text', 'json'], default='text', help='Output format')
    parser.add_argument('--save-report', help='Save report to file')
    
    args = parser.parse_args()
    
    # Initialize optimizer
    optimizer = AWSCostOptimizer(profile=args.profile, region=args.region)
    
    # Run analysis
    recommendations = optimizer.run_analysis()
    
    # Generate and display report
    if args.output == 'json':
        output = json.dumps([
            {
                'service': rec.service,
                'resource_id': rec.resource_id,
                'current_cost': rec.current_cost,
                'potential_savings': rec.potential_savings,
                'recommendation': rec.recommendation,
                'confidence': rec.confidence,
                'implementation_effort': rec.implementation_effort
            }
            for rec in recommendations
        ], indent=2)
    else:
        output = optimizer.generate_report(recommendations)
    
    print(output)
    
    # Save report if requested
    if args.save_report:
        with open(args.save_report, 'w') as f:
            f.write(output)
        print(f"\nReport saved to {args.save_report}")


if __name__ == "__main__":
    main()
