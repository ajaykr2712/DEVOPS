# Cloud Infrastructure Fundamentals

## Table of Contents
1. [AWS Core Services](#aws-core-services)
2. [GCP Core Services](#gcp-core-services)
3. [Azure Core Services](#azure-core-services)
4. [Identity and Access Management (IAM)](#identity-and-access-management-iam)
5. [Compute Services](#compute-services)
6. [Storage Services](#storage-services)
7. [Networking](#networking)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Cost Management](#cost-management)
10. [Infrastructure as Code](#infrastructure-as-code)
11. [Interview Questions](#interview-questions)

## AWS Core Services

### IAM (Identity and Access Management)

```json
// IAM Policy Example - S3 Read-Only Access
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:PrincipalTag/Department": "Engineering"
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2024-01-01T00:00:00Z"
        }
      }
    }
  ]
}
```

```bash
# AWS CLI Commands for IAM
# Create user
aws iam create-user --user-name john-doe

# Create access key
aws iam create-access-key --user-name john-doe

# Attach policy to user
aws iam attach-user-policy \
    --user-name john-doe \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Create role for EC2
aws iam create-role \
    --role-name EC2-S3-Access-Role \
    --assume-role-policy-document file://trust-policy.json

# Create and attach custom policy
aws iam create-policy \
    --policy-name S3ReadOnlyPolicy \
    --policy-document file://s3-readonly-policy.json

aws iam attach-role-policy \
    --role-name EC2-S3-Access-Role \
    --policy-arn arn:aws:iam::123456789012:policy/S3ReadOnlyPolicy
```

### EC2 (Elastic Compute Cloud)

```bash
#!/bin/bash
# scripts/aws-ec2-setup.sh

# Launch EC2 instance with user data
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --count 1 \
    --instance-type t3.medium \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyWebServer},{Key=Environment,Value=Production}]' \
    --iam-instance-profile Name=EC2-S3-Access-Role

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-asg \
    --launch-template LaunchTemplateName=my-launch-template,Version=1 \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 3 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
    --target-group-arns arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 \
    --health-check-type ELB \
    --health-check-grace-period 300

# Create Application Load Balancer
aws elbv2 create-load-balancer \
    --name my-load-balancer \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-5943793c \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4
```

### S3 (Simple Storage Service)

```python
# scripts/aws-s3-operations.py
import boto3
import json
from botocore.exceptions import ClientError
import logging

class S3Manager:
    def __init__(self, region_name='us-west-2'):
        self.s3_client = boto3.client('s3', region_name=region_name)
        self.s3_resource = boto3.resource('s3', region_name=region_name)
        self.logger = logging.getLogger(__name__)
    
    def create_bucket_with_lifecycle(self, bucket_name, region='us-west-2'):
        """Create S3 bucket with lifecycle policy"""
        try:
            # Create bucket
            if region == 'us-east-1':
                self.s3_client.create_bucket(Bucket=bucket_name)
            else:
                self.s3_client.create_bucket(
                    Bucket=bucket_name,
                    CreateBucketConfiguration={'LocationConstraint': region}
                )
            
            # Enable versioning
            self.s3_client.put_bucket_versioning(
                Bucket=bucket_name,
                VersioningConfiguration={'Status': 'Enabled'}
            )
            
            # Set lifecycle policy
            lifecycle_policy = {
                'Rules': [
                    {
                        'ID': 'transition-to-ia',
                        'Status': 'Enabled',
                        'Filter': {'Prefix': ''},
                        'Transitions': [
                            {
                                'Days': 30,
                                'StorageClass': 'STANDARD_IA'
                            },
                            {
                                'Days': 90,
                                'StorageClass': 'GLACIER'
                            },
                            {
                                'Days': 365,
                                'StorageClass': 'DEEP_ARCHIVE'
                            }
                        ]
                    },
                    {
                        'ID': 'delete-incomplete-multipart',
                        'Status': 'Enabled',
                        'Filter': {'Prefix': ''},
                        'AbortIncompleteMultipartUpload': {
                            'DaysAfterInitiation': 7
                        }
                    }
                ]
            }
            
            self.s3_client.put_bucket_lifecycle_configuration(
                Bucket=bucket_name,
                LifecycleConfiguration=lifecycle_policy
            )
            
            # Set bucket policy for public read
            bucket_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "PublicReadGetObject",
                        "Effect": "Allow",
                        "Principal": "*",
                        "Action": "s3:GetObject",
                        "Resource": f"arn:aws:s3:::{bucket_name}/public/*"
                    }
                ]
            }
            
            self.s3_client.put_bucket_policy(
                Bucket=bucket_name,
                Policy=json.dumps(bucket_policy)
            )
            
            self.logger.info(f"Bucket {bucket_name} created successfully")
            
        except ClientError as e:
            self.logger.error(f"Error creating bucket: {e}")
            raise
    
    def setup_cloudfront_distribution(self, bucket_name, domain_name=None):
        """Create CloudFront distribution for S3 bucket"""
        cloudfront = boto3.client('cloudfront')
        
        distribution_config = {
            'CallerReference': f"{bucket_name}-{int(time.time())}",
            'Comment': f"Distribution for {bucket_name}",
            'DefaultCacheBehavior': {
                'TargetOriginId': f"{bucket_name}-origin",
                'ViewerProtocolPolicy': 'redirect-to-https',
                'TrustedSigners': {
                    'Enabled': False,
                    'Quantity': 0
                },
                'ForwardedValues': {
                    'QueryString': False,
                    'Cookies': {'Forward': 'none'}
                },
                'MinTTL': 0,
                'DefaultTTL': 86400,
                'MaxTTL': 31536000
            },
            'Origins': {
                'Quantity': 1,
                'Items': [
                    {
                        'Id': f"{bucket_name}-origin",
                        'DomainName': f"{bucket_name}.s3.amazonaws.com",
                        'S3OriginConfig': {
                            'OriginAccessIdentity': ''
                        }
                    }
                ]
            },
            'Enabled': True
        }
        
        if domain_name:
            distribution_config['Aliases'] = {
                'Quantity': 1,
                'Items': [domain_name]
            }
        
        response = cloudfront.create_distribution(
            DistributionConfig=distribution_config
        )
        
        return response['Distribution']['DomainName']
    
    def sync_to_s3(self, local_dir, bucket_name, prefix=''):
        """Sync local directory to S3"""
        import os
        
        for root, dirs, files in os.walk(local_dir):
            for file in files:
                local_path = os.path.join(root, file)
                relative_path = os.path.relpath(local_path, local_dir)
                s3_path = os.path.join(prefix, relative_path).replace('\\', '/')
                
                try:
                    self.s3_client.upload_file(
                        local_path, 
                        bucket_name, 
                        s3_path,
                        ExtraArgs={
                            'ContentType': self._get_content_type(file),
                            'CacheControl': 'max-age=86400'
                        }
                    )
                    self.logger.info(f"Uploaded {local_path} to s3://{bucket_name}/{s3_path}")
                except ClientError as e:
                    self.logger.error(f"Failed to upload {local_path}: {e}")
    
    def _get_content_type(self, filename):
        """Get content type based on file extension"""
        import mimetypes
        content_type, _ = mimetypes.guess_type(filename)
        return content_type or 'binary/octet-stream'
```

### RDS (Relational Database Service)

```python
# scripts/aws-rds-setup.py
import boto3
import json
from botocore.exceptions import ClientError

class RDSManager:
    def __init__(self, region_name='us-west-2'):
        self.rds_client = boto3.client('rds', region_name=region_name)
        self.region = region_name
    
    def create_postgres_instance(self, db_instance_id, master_username, master_password):
        """Create PostgreSQL RDS instance with best practices"""
        try:
            response = self.rds_client.create_db_instance(
                DBInstanceIdentifier=db_instance_id,
                DBInstanceClass='db.t3.medium',
                Engine='postgres',
                EngineVersion='13.7',
                MasterUsername=master_username,
                MasterUserPassword=master_password,
                AllocatedStorage=100,
                StorageType='gp2',
                StorageEncrypted=True,
                
                # Network configuration
                VpcSecurityGroupIds=[
                    'sg-12345678'  # Database security group
                ],
                DBSubnetGroupName='my-db-subnet-group',
                PubliclyAccessible=False,
                
                # Backup configuration
                BackupRetentionPeriod=7,
                PreferredBackupWindow='03:00-04:00',
                PreferredMaintenanceWindow='sun:04:00-sun:05:00',
                
                # Monitoring
                MonitoringInterval=60,
                MonitoringRoleArn='arn:aws:iam::123456789012:role/rds-monitoring-role',
                EnablePerformanceInsights=True,
                
                # Security
                DeletionProtection=True,
                EnableCloudwatchLogsExports=['postgresql'],
                
                # Tags
                Tags=[
                    {'Key': 'Environment', 'Value': 'production'},
                    {'Key': 'Application', 'Value': 'myapp'},
                    {'Key': 'Backup', 'Value': 'required'}
                ]
            )
            
            print(f"RDS instance {db_instance_id} creation initiated")
            return response
            
        except ClientError as e:
            print(f"Error creating RDS instance: {e}")
            raise
    
    def create_read_replica(self, source_db_id, replica_id):
        """Create read replica for load distribution"""
        try:
            response = self.rds_client.create_db_instance_read_replica(
                DBInstanceIdentifier=replica_id,
                SourceDBInstanceIdentifier=source_db_id,
                DBInstanceClass='db.t3.medium',
                PubliclyAccessible=False,
                MonitoringInterval=60,
                EnablePerformanceInsights=True,
                Tags=[
                    {'Key': 'Purpose', 'Value': 'read-replica'},
                    {'Key': 'Source', 'Value': source_db_id}
                ]
            )
            
            print(f"Read replica {replica_id} creation initiated")
            return response
            
        except ClientError as e:
            print(f"Error creating read replica: {e}")
            raise
    
    def setup_automated_backups(self, db_instance_id):
        """Configure automated backups and snapshots"""
        
        # Manual snapshot
        snapshot_id = f"{db_instance_id}-manual-{int(time.time())}"
        self.rds_client.create_db_snapshot(
            DBSnapshotIdentifier=snapshot_id,
            DBInstanceIdentifier=db_instance_id
        )
        
        # Lambda function for automated snapshots
        lambda_code = '''
import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    rds = boto3.client('rds')
    
    db_instance_id = event['db_instance_id']
    timestamp = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    snapshot_id = f"{db_instance_id}-auto-{timestamp}"
    
    try:
        response = rds.create_db_snapshot(
            DBSnapshotIdentifier=snapshot_id,
            DBInstanceIdentifier=db_instance_id
        )
        
        # Delete old snapshots (keep last 7)
        snapshots = rds.describe_db_snapshots(
            DBInstanceIdentifier=db_instance_id,
            SnapshotType='manual'
        )
        
        snapshot_list = sorted(
            snapshots['DBSnapshots'],
            key=lambda x: x['SnapshotCreateTime'],
            reverse=True
        )
        
        # Delete snapshots older than 7 days
        for snapshot in snapshot_list[7:]:
            rds.delete_db_snapshot(
                DBSnapshotIdentifier=snapshot['DBSnapshotIdentifier']
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Snapshot {snapshot_id} created successfully')
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
'''
        
        return lambda_code
```

## GCP Core Services

### Compute Engine and GKE

```bash
#!/bin/bash
# scripts/gcp-setup.sh

# Set project and region
gcloud config set project my-project-id
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Create VPC network
gcloud compute networks create my-vpc \
    --subnet-mode custom \
    --description "Custom VPC for my application"

# Create subnet
gcloud compute networks subnets create my-subnet \
    --network my-vpc \
    --range 10.1.0.0/24 \
    --region us-central1

# Create firewall rules
gcloud compute firewall-rules create allow-internal \
    --network my-vpc \
    --allow tcp,udp,icmp \
    --source-ranges 10.1.0.0/24

gcloud compute firewall-rules create allow-http-https \
    --network my-vpc \
    --allow tcp:80,tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --target-tags web-server

# Create GKE cluster
gcloud container clusters create my-cluster \
    --zone us-central1-a \
    --machine-type e2-medium \
    --num-nodes 3 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 10 \
    --enable-autorepair \
    --enable-autoupgrade \
    --network my-vpc \
    --subnetwork my-subnet \
    --enable-ip-alias \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services

# Get cluster credentials
gcloud container clusters get-credentials my-cluster --zone us-central1-a

# Create instance template
gcloud compute instance-templates create web-server-template \
    --machine-type e2-medium \
    --network-interface network=my-vpc,subnet=my-subnet \
    --maintenance-policy MIGRATE \
    --tags web-server \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --boot-disk-size 20GB \
    --boot-disk-type pd-standard \
    --startup-script-url gs://my-bucket/startup-script.sh

# Create managed instance group
gcloud compute instance-groups managed create web-server-group \
    --template web-server-template \
    --size 3 \
    --zone us-central1-a

# Set up autoscaling
gcloud compute instance-groups managed set-autoscaling web-server-group \
    --max-num-replicas 10 \
    --min-num-replicas 3 \
    --target-cpu-utilization 0.7 \
    --zone us-central1-a
```

### Cloud Storage and BigQuery

```python
# scripts/gcp-storage-bigquery.py
from google.cloud import storage, bigquery
from google.cloud.exceptions import GoogleCloudError
import json

class GCPDataManager:
    def __init__(self, project_id):
        self.project_id = project_id
        self.storage_client = storage.Client(project=project_id)
        self.bigquery_client = bigquery.Client(project=project_id)
    
    def create_storage_bucket(self, bucket_name, location='US'):
        """Create Cloud Storage bucket with lifecycle management"""
        try:
            bucket = self.storage_client.bucket(bucket_name)
            bucket.location = location
            
            # Create bucket
            bucket = self.storage_client.create_bucket(bucket)
            
            # Set lifecycle policy
            lifecycle_rule = {
                'action': {'type': 'SetStorageClass', 'storageClass': 'NEARLINE'},
                'condition': {'age': 30}
            }
            
            lifecycle_rule_archive = {
                'action': {'type': 'SetStorageClass', 'storageClass': 'COLDLINE'},
                'condition': {'age': 90}
            }
            
            lifecycle_rule_delete = {
                'action': {'type': 'Delete'},
                'condition': {'age': 365}
            }
            
            bucket.lifecycle_rules = [lifecycle_rule, lifecycle_rule_archive, lifecycle_rule_delete]
            bucket.patch()
            
            print(f"Bucket {bucket_name} created successfully")
            return bucket
            
        except GoogleCloudError as e:
            print(f"Error creating bucket: {e}")
            raise
    
    def setup_bigquery_dataset(self, dataset_id):
        """Create BigQuery dataset and tables"""
        try:
            # Create dataset
            dataset_ref = self.bigquery_client.dataset(dataset_id)
            dataset = bigquery.Dataset(dataset_ref)
            dataset.location = "US"
            dataset.description = "Dataset for application analytics"
            
            dataset = self.bigquery_client.create_dataset(dataset)
            
            # Create user events table
            table_id = f"{self.project_id}.{dataset_id}.user_events"
            schema = [
                bigquery.SchemaField("event_id", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("user_id", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("event_type", "STRING", mode="REQUIRED"),
                bigquery.SchemaField("timestamp", "TIMESTAMP", mode="REQUIRED"),
                bigquery.SchemaField("properties", "JSON", mode="NULLABLE"),
                bigquery.SchemaField("session_id", "STRING", mode="NULLABLE"),
            ]
            
            table = bigquery.Table(table_id, schema=schema)
            table.time_partitioning = bigquery.TimePartitioning(
                type_=bigquery.TimePartitioningType.DAY,
                field="timestamp"
            )
            
            table = self.bigquery_client.create_table(table)
            
            # Create materialized view for daily aggregations
            view_id = f"{self.project_id}.{dataset_id}.daily_user_stats"
            view_query = f"""
            SELECT
                DATE(timestamp) as date,
                user_id,
                COUNT(*) as event_count,
                COUNT(DISTINCT session_id) as session_count,
                ARRAY_AGG(DISTINCT event_type) as event_types
            FROM `{table_id}`
            WHERE DATE(timestamp) = CURRENT_DATE()
            GROUP BY date, user_id
            """
            
            view = bigquery.Table(view_id)
            view.view_query = view_query
            view = self.bigquery_client.create_table(view)
            
            print(f"BigQuery dataset {dataset_id} created successfully")
            return dataset
            
        except GoogleCloudError as e:
            print(f"Error creating BigQuery dataset: {e}")
            raise
    
    def create_data_pipeline(self, source_bucket, dataset_id, table_id):
        """Create data pipeline from Cloud Storage to BigQuery"""
        
        # Cloud Function for data processing
        cloud_function_code = f'''
import json
from google.cloud import bigquery, storage
from google.cloud.exceptions import GoogleCloudError

def process_data_file(event, context):
    """Process uploaded file and load to BigQuery"""
    
    bucket_name = event['bucket']
    file_name = event['name']
    
    if not file_name.endswith('.json'):
        return
    
    storage_client = storage.Client()
    bigquery_client = bigquery.Client()
    
    # Download file
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    content = blob.download_as_text()
    
    # Parse JSON data
    try:
        data = [json.loads(line) for line in content.strip().split('\\n')]
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {{e}}")
        return
    
    # Load to BigQuery
    table_id = "{self.project_id}.{dataset_id}.{table_id}"
    table = bigquery_client.get_table(table_id)
    
    job_config = bigquery.LoadJobConfig(
        schema_update_options=[bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION],
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
    )
    
    job = bigquery_client.load_table_from_json(
        data, table, job_config=job_config
    )
    
    job.result()  # Wait for job to complete
    
    print(f"Loaded {{len(data)}} rows to {{table_id}}")
    
    # Move processed file to archive
    archive_blob = bucket.blob(f"processed/{{file_name}}")
    bucket.copy_blob(blob, bucket, archive_blob.name)
    blob.delete()
'''
        
        return cloud_function_code
```

## Azure Core Services

### Resource Management and App Service

```bash
#!/bin/bash
# scripts/azure-setup.sh

# Login and set subscription
az login
az account set --subscription "your-subscription-id"

# Create resource group
az group create \
    --name myapp-rg \
    --location westus2 \
    --tags Environment=Production Application=MyApp

# Create App Service Plan
az appservice plan create \
    --name myapp-plan \
    --resource-group myapp-rg \
    --location westus2 \
    --sku B2 \
    --number-of-workers 2

# Create Web App
az webapp create \
    --name myapp-webapp \
    --resource-group myapp-rg \
    --plan myapp-plan \
    --runtime "PYTHON|3.9"

# Configure app settings
az webapp config appsettings set \
    --name myapp-webapp \
    --resource-group myapp-rg \
    --settings \
        FLASK_ENV=production \
        DATABASE_URL="postgresql://user:pass@db.postgres.database.azure.com:5432/myapp"

# Set up deployment source
az webapp deployment source config \
    --name myapp-webapp \
    --resource-group myapp-rg \
    --repo-url https://github.com/username/myapp \
    --branch main \
    --manual-integration

# Create Azure Container Registry
az acr create \
    --name myappregistry \
    --resource-group myapp-rg \
    --sku Standard \
    --location westus2

# Create AKS cluster
az aks create \
    --resource-group myapp-rg \
    --name myapp-aks \
    --node-count 3 \
    --node-vm-size Standard_B2s \
    --enable-addons monitoring \
    --attach-acr myappregistry \
    --enable-managed-identity \
    --enable-autoscaler \
    --min-count 1 \
    --max-count 10

# Get AKS credentials
az aks get-credentials \
    --resource-group myapp-rg \
    --name myapp-aks
```

### Azure Functions and Cosmos DB

```python
# scripts/azure-functions-cosmosdb.py
import azure.functions as func
from azure.cosmos import CosmosClient, PartitionKey
from azure.identity import DefaultAzureCredential
import json
import logging

# Azure Function
def main(req: func.HttpRequest) -> func.HttpResponse:
    """Azure Function for processing user data"""
    
    logging.info('Processing user data request')
    
    try:
        # Get request data
        req_body = req.get_json()
        user_id = req_body.get('user_id')
        action = req_body.get('action')
        
        # Process with Cosmos DB
        cosmos_manager = CosmosDBManager()
        result = cosmos_manager.process_user_action(user_id, action)
        
        return func.HttpResponse(
            json.dumps({"status": "success", "result": result}),
            status_code=200,
            mimetype="application/json"
        )
        
    except Exception as e:
        logging.error(f"Error processing request: {str(e)}")
        return func.HttpResponse(
            json.dumps({"status": "error", "message": str(e)}),
            status_code=500,
            mimetype="application/json"
        )

class CosmosDBManager:
    def __init__(self):
        # Using managed identity for authentication
        credential = DefaultAzureCredential()
        self.client = CosmosClient(
            url="https://myapp-cosmos.documents.azure.com:443/",
            credential=credential
        )
        
        self.database_name = "myapp_db"
        self.container_name = "user_data"
        
        # Create database and container if they don't exist
        self._setup_database()
    
    def _setup_database(self):
        """Setup Cosmos DB database and container"""
        
        # Create database
        try:
            self.database = self.client.create_database(
                id=self.database_name,
                offer_throughput=400  # Shared throughput
            )
        except Exception:
            self.database = self.client.get_database_client(self.database_name)
        
        # Create container
        try:
            container = self.database.create_container(
                id=self.container_name,
                partition_key=PartitionKey(path="/user_id"),
                offer_throughput=400
            )
        except Exception:
            container = self.database.get_container_client(self.container_name)
        
        self.container = container
    
    def process_user_action(self, user_id: str, action: str):
        """Process user action and store in Cosmos DB"""
        
        # Read existing user data
        try:
            user_doc = self.container.read_item(
                item=user_id,
                partition_key=user_id
            )
        except Exception:
            # Create new user document
            user_doc = {
                "id": user_id,
                "user_id": user_id,
                "actions": [],
                "created_at": datetime.utcnow().isoformat()
            }
        
        # Add new action
        user_doc["actions"].append({
            "action": action,
            "timestamp": datetime.utcnow().isoformat()
        })
        
        user_doc["updated_at"] = datetime.utcnow().isoformat()
        
        # Upsert document
        result = self.container.upsert_item(user_doc)
        
        return result
    
    def get_user_analytics(self, user_id: str):
        """Get user analytics using SQL query"""
        
        query = """
        SELECT 
            c.user_id,
            COUNT(1) as total_actions,
            c.actions
        FROM c 
        WHERE c.user_id = @user_id
        """
        
        parameters = [{"name": "@user_id", "value": user_id}]
        
        results = list(self.container.query_items(
            query=query,
            parameters=parameters,
            enable_cross_partition_query=True
        ))
        
        return results[0] if results else None
```

## Identity and Access Management (IAM)

### Multi-Cloud IAM Best Practices

```json
// AWS IAM Policy - Least Privilege Example
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificS3Actions",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::my-app-bucket/user-uploads/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "private"
        },
        "IpAddress": {
          "aws:SourceIp": ["203.0.113.0/24", "198.51.100.0/24"]
        }
      }
    },
    {
      "Sid": "AllowListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-app-bucket",
      "Condition": {
        "StringLike": {
          "s3:prefix": "user-uploads/*"
        }
      }
    }
  ]
}
```

```python
# scripts/iam-automation.py
import boto3
import json
from typing import List, Dict

class IAMManager:
    def __init__(self):
        self.iam_client = boto3.client('iam')
        self.sts_client = boto3.client('sts')
    
    def create_service_role(self, role_name: str, service: str, policies: List[str]):
        """Create IAM role for AWS service"""
        
        # Trust policy for service
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": f"{service}.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        
        try:
            # Create role
            response = self.iam_client.create_role(
                RoleName=role_name,
                AssumeRolePolicyDocument=json.dumps(trust_policy),
                Description=f"Service role for {service}",
                Tags=[
                    {'Key': 'Service', 'Value': service},
                    {'Key': 'ManagedBy', 'Value': 'automation'},
                    {'Key': 'CreatedBy', 'Value': 'iam-manager'}
                ]
            )
            
            # Attach policies
            for policy_arn in policies:
                self.iam_client.attach_role_policy(
                    RoleName=role_name,
                    PolicyArn=policy_arn
                )
            
            return response['Role']['Arn']
            
        except Exception as e:
            print(f"Error creating role {role_name}: {e}")
            raise
    
    def create_cross_account_role(self, role_name: str, trusted_account: str, external_id: str = None):
        """Create cross-account access role"""
        
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": f"arn:aws:iam::{trusted_account}:root"
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {} if not external_id else {
                        "StringEquals": {
                            "sts:ExternalId": external_id
                        }
                    }
                }
            ]
        }
        
        response = self.iam_client.create_role(
            RoleName=role_name,
            AssumeRolePolicyDocument=json.dumps(trust_policy),
            Description=f"Cross-account role for account {trusted_account}"
        )
        
        return response['Role']['Arn']
    
    def audit_permissions(self, user_or_role_name: str, entity_type: str = 'user'):
        """Audit IAM permissions for user or role"""
        
        if entity_type == 'user':
            # Get user policies
            attached_policies = self.iam_client.list_attached_user_policies(
                UserName=user_or_role_name
            )
            inline_policies = self.iam_client.list_user_policies(
                UserName=user_or_role_name
            )
            groups = self.iam_client.get_groups_for_user(
                UserName=user_or_role_name
            )
        else:
            # Get role policies
            attached_policies = self.iam_client.list_attached_role_policies(
                RoleName=user_or_role_name
            )
            inline_policies = self.iam_client.list_role_policies(
                RoleName=user_or_role_name
            )
            groups = {'Groups': []}
        
        # Compile all permissions
        all_permissions = {
            'attached_policies': attached_policies['AttachedPolicies'],
            'inline_policies': inline_policies['PolicyNames'],
            'groups': [group['GroupName'] for group in groups['Groups']],
            'total_policies': len(attached_policies['AttachedPolicies']) + len(inline_policies['PolicyNames'])
        }
        
        return all_permissions
    
    def rotate_access_keys(self, username: str):
        """Rotate access keys for IAM user"""
        
        # List current access keys
        current_keys = self.iam_client.list_access_keys(UserName=username)
        
        if len(current_keys['AccessKeyMetadata']) >= 2:
            raise Exception("User already has 2 access keys. Delete one before creating new.")
        
        # Create new access key
        new_key = self.iam_client.create_access_key(UserName=username)
        
        print(f"New access key created: {new_key['AccessKey']['AccessKeyId']}")
        print("Please update your applications with the new key before deleting the old one.")
        
        # Mark old keys for deletion (after verification)
        for key_metadata in current_keys['AccessKeyMetadata']:
            old_key_id = key_metadata['AccessKeyId']
            print(f"Old key to delete after verification: {old_key_id}")
            
            # You can uncomment this after verifying new key works
            # self.iam_client.delete_access_key(
            #     UserName=username,
            #     AccessKeyId=old_key_id
            # )
        
        return new_key['AccessKey']
```

## Cost Management

### Cost Optimization Scripts

```python
# scripts/cloud-cost-optimizer.py
import boto3
import json
from datetime import datetime, timedelta
from typing import Dict, List

class AWSCostOptimizer:
    def __init__(self):
        self.cost_explorer = boto3.client('ce')
        self.ec2 = boto3.client('ec2')
        self.rds = boto3.client('rds')
        self.s3 = boto3.client('s3')
    
    def get_cost_by_service(self, days: int = 30) -> Dict:
        """Get cost breakdown by AWS service"""
        
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        response = self.cost_explorer.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='MONTHLY',
            Metrics=['BlendedCost'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': 'SERVICE'
                }
            ]
        )
        
        costs = {}
        for result in response['ResultsByTime']:
            for group in result['Groups']:
                service = group['Keys'][0]
                amount = float(group['Metrics']['BlendedCost']['Amount'])
                costs[service] = costs.get(service, 0) + amount
        
        return dict(sorted(costs.items(), key=lambda x: x[1], reverse=True))
    
    def find_unused_resources(self) -> Dict:
        """Find unused AWS resources"""
        
        unused_resources = {
            'ec2_instances': [],
            'ebs_volumes': [],
            'elastic_ips': [],
            'load_balancers': [],
            'rds_snapshots': []
        }
        
        # Find stopped EC2 instances
        ec2_instances = self.ec2.describe_instances(
            Filters=[
                {'Name': 'instance-state-name', 'Values': ['stopped']}
            ]
        )
        
        for reservation in ec2_instances['Reservations']:
            for instance in reservation['Instances']:
                # Check if stopped for more than 7 days
                stop_time = instance.get('StateTransitionReason', '')
                if 'stopped' in stop_time:
                    unused_resources['ec2_instances'].append({
                        'InstanceId': instance['InstanceId'],
                        'InstanceType': instance['InstanceType'],
                        'LaunchTime': instance['LaunchTime'],
                        'State': instance['State']['Name']
                    })
        
        # Find unattached EBS volumes
        volumes = self.ec2.describe_volumes(
            Filters=[
                {'Name': 'status', 'Values': ['available']}
            ]
        )
        
        for volume in volumes['Volumes']:
            unused_resources['ebs_volumes'].append({
                'VolumeId': volume['VolumeId'],
                'Size': volume['Size'],
                'VolumeType': volume['VolumeType'],
                'CreateTime': volume['CreateTime']
            })
        
        # Find unassociated Elastic IPs
        elastic_ips = self.ec2.describe_addresses()
        
        for eip in elastic_ips['Addresses']:
            if 'InstanceId' not in eip and 'NetworkInterfaceId' not in eip:
                unused_resources['elastic_ips'].append({
                    'AllocationId': eip['AllocationId'],
                    'PublicIp': eip['PublicIp']
                })
        
        return unused_resources
    
    def optimize_s3_storage(self, bucket_name: str) -> Dict:
        """Analyze S3 storage and suggest optimizations"""
        
        optimizations = {
            'lifecycle_suggestions': [],
            'multipart_cleanup': [],
            'storage_class_optimization': []
        }
        
        try:
            # Check lifecycle configuration
            try:
                lifecycle = self.s3.get_bucket_lifecycle_configuration(Bucket=bucket_name)
            except:
                optimizations['lifecycle_suggestions'].append({
                    'type': 'missing_lifecycle',
                    'suggestion': 'Add lifecycle policy to transition objects to cheaper storage classes'
                })
            
            # Check for incomplete multipart uploads
            multipart_uploads = self.s3.list_multipart_uploads(Bucket=bucket_name)
            
            if multipart_uploads.get('Uploads'):
                for upload in multipart_uploads['Uploads']:
                    optimizations['multipart_cleanup'].append({
                        'UploadId': upload['UploadId'],
                        'Key': upload['Key'],
                        'Initiated': upload['Initiated']
                    })
            
            # Suggest storage class optimization
            objects = self.s3.list_objects_v2(Bucket=bucket_name, MaxKeys=1000)
            
            if objects.get('Contents'):
                for obj in objects['Contents']:
                    # Objects older than 30 days in Standard class
                    if obj['LastModified'] < datetime.now(obj['LastModified'].tzinfo) - timedelta(days=30):
                        if obj.get('StorageClass', 'STANDARD') == 'STANDARD':
                            optimizations['storage_class_optimization'].append({
                                'Key': obj['Key'],
                                'LastModified': obj['LastModified'],
                                'Size': obj['Size'],
                                'Suggestion': 'Move to Standard-IA or Glacier'
                            })
        
        except Exception as e:
            print(f"Error analyzing bucket {bucket_name}: {e}")
        
        return optimizations
    
    def generate_cost_report(self) -> str:
        """Generate comprehensive cost optimization report"""
        
        print("🔍 Analyzing AWS costs and usage...")
        
        # Get cost breakdown
        costs = self.get_cost_by_service()
        
        # Find unused resources
        unused = self.find_unused_resources()
        
        # Calculate potential savings
        potential_savings = 0
        
        # Estimate savings from unused EC2 instances
        for instance in unused['ec2_instances']:
            # Rough estimate: $50/month for t3.medium
            instance_cost = {
                't3.micro': 10, 't3.small': 20, 't3.medium': 50,
                't3.large': 100, 't3.xlarge': 200
            }
            potential_savings += instance_cost.get(instance['InstanceType'], 50)
        
        # Estimate savings from unattached EBS volumes
        for volume in unused['ebs_volumes']:
            # $0.10 per GB per month for gp2
            potential_savings += volume['Size'] * 0.10
        
        # Estimate savings from Elastic IPs
        potential_savings += len(unused['elastic_ips']) * 3.65  # $3.65/month per unused EIP
        
        report = f"""
# AWS Cost Optimization Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Cost Breakdown (Last 30 days)
"""
        
        for service, cost in list(costs.items())[:10]:  # Top 10 services
            report += f"- **{service}**: ${cost:.2f}\n"
        
        report += f"""
## Unused Resources
- **Stopped EC2 Instances**: {len(unused['ec2_instances'])}
- **Unattached EBS Volumes**: {len(unused['ebs_volumes'])}
- **Unused Elastic IPs**: {len(unused['elastic_ips'])}

## Potential Monthly Savings: ${potential_savings:.2f}

## Recommendations
1. **Terminate or resize unused EC2 instances**
2. **Delete unattached EBS volumes after confirming they're not needed**
3. **Release unused Elastic IP addresses**
4. **Implement S3 lifecycle policies**
5. **Consider Reserved Instances for long-running workloads**
6. **Use Spot Instances for fault-tolerant workloads**
"""
        
        return report

# Usage example
if __name__ == "__main__":
    optimizer = AWSCostOptimizer()
    
    # Generate and save cost report
    report = optimizer.generate_cost_report()
    
    with open('aws_cost_optimization_report.md', 'w') as f:
        f.write(report)
    
    print("Cost optimization report saved to aws_cost_optimization_report.md")
```

## Interview Questions

### Common Cloud Infrastructure Interview Questions

**Q1: How do you design a highly available architecture in AWS?**

**Answer:**
```yaml
# Multi-AZ, Multi-Region Architecture
Components:
- Multiple Availability Zones (AZs)
- Application Load Balancer with health checks
- Auto Scaling Groups across AZs
- RDS Multi-AZ deployment
- Route 53 for DNS failover
- CloudFront for global distribution
- S3 Cross-Region Replication

Example:
- Primary region: us-east-1 (3 AZs)
- Secondary region: us-west-2 (disaster recovery)
- RTO: < 4 hours, RPO: < 1 hour
```

**Q2: Explain the difference between IaaS, PaaS, and SaaS.**

**Answer:**
- **IaaS (Infrastructure as a Service):** Virtual machines, storage, networking (EC2, S3, VPC)
- **PaaS (Platform as a Service):** Development platform without managing infrastructure (App Service, Heroku)
- **SaaS (Software as a Service):** Complete applications (Office 365, Salesforce)

**Q3: How do you implement security best practices in cloud?**

**Answer:**
```python
# Security Best Practices
1. Identity and Access Management:
   - Principle of least privilege
   - Multi-factor authentication
   - Regular access reviews

2. Network Security:
   - VPC with private subnets
   - Security groups (stateful)
   - NACLs (stateless)
   - WAF for application protection

3. Data Protection:
   - Encryption at rest and in transit
   - Key management (KMS)
   - Regular backups
   - Data classification

4. Monitoring and Logging:
   - CloudTrail for API logging
   - CloudWatch for monitoring
   - Security Hub for compliance
   - GuardDuty for threat detection
```

**Q4: How do you optimize cloud costs?**

**Answer:**
- **Right-sizing:** Match resources to actual usage
- **Reserved Instances:** For predictable workloads
- **Spot Instances:** For fault-tolerant applications
- **Auto Scaling:** Scale based on demand
- **Storage Optimization:** Use appropriate storage classes
- **Monitoring:** Regular cost analysis and cleanup

**Q5: Explain cloud networking concepts.**

**Answer:**
```yaml
# AWS VPC Example
VPC: 10.0.0.0/16
  Public Subnet 1: 10.0.1.0/24 (AZ-1a)
  Public Subnet 2: 10.0.2.0/24 (AZ-1b)
  Private Subnet 1: 10.0.11.0/24 (AZ-1a)
  Private Subnet 2: 10.0.12.0/24 (AZ-1b)

Internet Gateway: Public internet access
NAT Gateway: Private subnet internet access
Route Tables: Traffic routing rules
Security Groups: Instance-level firewall
```

**Q6: How do you implement disaster recovery in cloud?**

**Answer:**
```python
# DR Strategies (RTO/RPO requirements)

1. Backup and Restore (Hours/Days):
   - Regular backups to different region
   - Lowest cost, highest recovery time

2. Pilot Light (10s of minutes):
   - Minimal version running in DR region
   - Scale up when needed

3. Warm Standby (Minutes):
   - Scaled-down version running
   - Quick scale-up capability

4. Multi-Site Active/Active (Real-time):
   - Full production environment
   - Traffic distributed across regions
   - Highest cost, lowest recovery time
```

**Q7: What are the benefits of containerization in cloud?**

**Answer:**
- **Portability:** Run anywhere consistently
- **Scalability:** Horizontal scaling with orchestration
- **Resource Efficiency:** Better resource utilization
- **DevOps Integration:** CI/CD pipeline compatibility
- **Microservices:** Service decomposition
- **Isolation:** Application dependency management

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is cloud computing? | On-demand delivery of computing services over internet |
| 2 | Easy | What are the main cloud service models? | IaaS (Infrastructure), PaaS (Platform), SaaS (Software) as a Service |
| 3 | Easy | What is AWS? | Amazon Web Services - comprehensive cloud computing platform |
| 4 | Easy | What is EC2? | Elastic Compute Cloud - scalable virtual servers in AWS |
| 5 | Easy | What is S3? | Simple Storage Service - object storage service in AWS |
| 6 | Easy | What is IAM? | Identity and Access Management - controls access to cloud resources |
| 7 | Easy | What is VPC? | Virtual Private Cloud - isolated network environment |
| 8 | Easy | What is region and availability zone? | Region is geographic area, AZ is isolated datacenter within region |
| 9 | Easy | What is auto scaling? | Automatically adjusting compute resources based on demand |
| 10 | Easy | What is load balancer? | Distributes incoming traffic across multiple targets |
| 11 | Easy | What is CDN? | Content Delivery Network - globally distributed caching system |
| 12 | Easy | What is RDS? | Relational Database Service - managed database service |
| 13 | Easy | What is Lambda? | Serverless compute service that runs code without managing servers |
| 14 | Easy | What is CloudFormation? | Infrastructure as Code service for AWS resources |
| 15 | Easy | What is CloudWatch? | Monitoring and observability service for AWS resources |
| 16 | Medium | What is the difference between horizontal and vertical scaling? | Horizontal adds more instances, vertical adds more power to existing instance |
| 17 | Medium | What is elastic IP? | Static public IP address that can be reassigned to instances |
| 18 | Medium | What is subnet? | Segmented portion of VPC with specific IP range |
| 19 | Medium | What is NAT Gateway? | Allows private subnet instances to access internet |
| 20 | Medium | What is security group vs NACL? | Security group is stateful firewall, NACL is stateless subnet-level firewall |
| 21 | Medium | What is EBS vs instance store? | EBS is persistent network storage, instance store is temporary local storage |
| 22 | Medium | What is cross-region replication? | Automatically copying data between different AWS regions |
| 23 | Medium | What is disaster recovery? | Strategies for maintaining operations during outages |
| 24 | Medium | What is RTO and RPO? | Recovery Time Objective and Recovery Point Objective metrics |
| 25 | Medium | What is multi-AZ deployment? | Deploying across multiple availability zones for high availability |
| 26 | Medium | What is API Gateway? | Managed service for creating and managing APIs |
| 27 | Medium | What is SQS? | Simple Queue Service - managed message queuing service |
| 28 | Medium | What is SNS? | Simple Notification Service - pub/sub messaging service |
| 29 | Medium | What is CloudTrail? | Service that logs API calls for auditing and compliance |
| 30 | Medium | What is cost optimization? | Strategies to minimize cloud spending while maintaining performance |
| 31 | Hard | How to implement least privilege access? | Grant minimum permissions required, use roles and policies effectively |
| 32 | Hard | What is AWS Organizations? | Service for centrally managing multiple AWS accounts |
| 33 | Hard | What is Service Control Policy? | Type of policy in AWS Organizations to set permission guardrails |
| 34 | Hard | What is AWS Config? | Service that tracks resource configurations and compliance |
| 35 | Hard | What is GuardDuty? | Managed threat detection service using machine learning |
| 36 | Hard | What is AWS Secrets Manager? | Service for storing and rotating secrets like passwords |
| 37 | Hard | What is encryption in transit vs at rest? | In transit protects data movement, at rest protects stored data |
| 38 | Hard | What is AWS KMS? | Key Management Service for encryption key management |
| 39 | Hard | What is AWS WAF? | Web Application Firewall protecting against common web exploits |
| 40 | Hard | What is AWS Shield? | DDoS protection service with Standard and Advanced tiers |
| 41 | Hard | How to implement backup and restore strategy? | Automated backups, cross-region replication, testing restore procedures |
| 42 | Hard | What is AWS Well-Architected Framework? | Best practices for cloud architecture across 5 pillars |
| 43 | Hard | What is reserved vs spot vs on-demand instances? | Different pricing models: reserved (discount), spot (variable), on-demand (standard) |
| 44 | Hard | How to monitor and alert on costs? | Use billing alerts, AWS Budgets, Cost Explorer, tagging strategies |
| 45 | Hard | What is infrastructure drift? | When actual infrastructure differs from defined configuration |
| 46 | Expert | What is chaos engineering in cloud? | Intentionally introducing failures to test system resilience |
| 47 | Expert | How to implement zero-downtime deployments? | Blue-green, canary, rolling deployments with health checks |
| 48 | Expert | What is cloud native architecture? | Applications designed specifically for cloud environments |
| 49 | Expert | How to implement multi-cloud strategy? | Using multiple cloud providers for redundancy and avoiding vendor lock-in |
| 50 | Expert | What is serverless architecture patterns? | Event-driven, microservices, CQRS patterns using serverless components |
| 51 | Expert | How to implement compliance automation? | Automated compliance checking, remediation, and reporting |
| 52 | Expert | What is FinOps? | Cloud financial management practice optimizing costs and value |
| 53 | Expert | How to implement advanced networking? | Transit Gateway, Direct Connect, VPN, hybrid architectures |
| 54 | Expert | What is container orchestration in cloud? | Managing containerized applications using services like EKS, ECS |
| 55 | Expert | How to implement data governance in cloud? | Data classification, access controls, lineage tracking, privacy compliance |
