# Enterprise Database Platform Project

## Project Overview
This project implements a comprehensive enterprise database platform with automated provisioning, monitoring, backup, and performance optimization for multi-environment DevOps workflows.

## Architecture

```
Enterprise Database Platform
├── Database Clusters
│   ├── Production (Multi-AZ)
│   ├── Staging (Single-AZ)
│   └── Development (Local)
├── Automation Layer
│   ├── Provisioning
│   ├── Migration
│   └── Backup/Recovery
├── Monitoring Stack
│   ├── Metrics Collection
│   ├── Alerting
│   └── Dashboards
├── Security Layer
│   ├── Access Control
│   ├── Encryption
│   └── Auditing
└── Management Tools
    ├── CLI Tools
    ├── Web Interface
    └── API Gateway
```

## Project Structure

```
database-platform/
├── infrastructure/
│   ├── terraform/
│   │   ├── environments/
│   │   ├── modules/
│   │   └── variables/
│   └── ansible/
│       ├── playbooks/
│       └── roles/
├── automation/
│   ├── provisioning/
│   ├── migration/
│   ├── backup/
│   └── monitoring/
├── applications/
│   ├── web-dashboard/
│   ├── api-gateway/
│   └── cli-tools/
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   └── alertmanager/
├── security/
│   ├── policies/
│   ├── certificates/
│   └── audit-logs/
└── docs/
    ├── runbooks/
    ├── procedures/
    └── architecture/
```

## Implementation

### 1. Infrastructure as Code

#### Terraform Database Module
```hcl
# terraform/modules/database/main.tf
resource "aws_db_parameter_group" "main" {
  family = var.db_family
  name   = "${var.environment}-${var.application}-params"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.common_tags
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-${var.application}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.application} DB Subnet Group"
  })
}

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-${var.application}-db"
  
  # Engine configuration
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  parameter_group_name = aws_db_parameter_group.main.name
  
  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted
  kms_key_id          = var.kms_key_id
  
  # Database configuration
  db_name  = var.db_name
  username = var.master_username
  password = var.master_password
  port     = var.db_port
  
  # Network configuration
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = var.publicly_accessible
  
  # Backup configuration
  backup_retention_period   = var.backup_retention_period
  backup_window            = var.backup_window
  maintenance_window       = var.maintenance_window
  delete_automated_backups = false
  
  # High Availability
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone
  
  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null
  
  # Performance Insights
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  
  # Maintenance
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  
  # Deletion protection
  deletion_protection      = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-${var.application}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.application} Database"
  })
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# Read Replica (if enabled)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? var.read_replica_count : 0
  
  identifier = "${var.environment}-${var.application}-db-replica-${count.index + 1}"
  
  replicate_source_db = aws_db_instance.main.identifier
  instance_class     = var.read_replica_instance_class
  
  publicly_accessible = false
  skip_final_snapshot = true
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null
  
  performance_insights_enabled = var.performance_insights_enabled
  
  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.application} Read Replica ${count.index + 1}"
  })
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  
  name = "${var.environment}-${var.application}-rds-enhanced-monitoring"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  
  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.environment}-${var.application}-db-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.environment}-${var.application}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connection_threshold
  alarm_description   = "This metric monitors RDS connection count"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  
  tags = var.common_tags
}
```

#### Environment-Specific Configurations
```hcl
# terraform/environments/production/main.tf
module "production_database" {
  source = "../../modules/database"
  
  environment = "production"
  application = "myapp"
  
  # Engine configuration
  engine         = "postgres"
  engine_version = "14.9"
  instance_class = "db.r5.xlarge"
  
  # Storage configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id          = data.aws_kms_key.rds.arn
  
  # Database configuration
  db_name         = "myapp_production"
  master_username = "dbadmin"
  master_password = var.db_master_password
  db_port         = 5432
  
  # Network configuration
  subnet_ids         = data.aws_subnets.database.ids
  security_group_ids = [aws_security_group.database.id]
  publicly_accessible = false
  
  # Backup configuration
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # High Availability
  multi_az = true
  
  # Read Replicas
  create_read_replica         = true
  read_replica_count         = 2
  read_replica_instance_class = "db.r5.large"
  
  # Monitoring
  monitoring_interval             = 60
  performance_insights_enabled    = true
  performance_insights_kms_key_id = data.aws_kms_key.rds.arn
  
  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  # Maintenance
  auto_minor_version_upgrade = true
  allow_major_version_upgrade = false
  
  # Protection
  deletion_protection  = true
  skip_final_snapshot = false
  
  # Database parameters
  db_parameters = {
    "shared_preload_libraries" = "pg_stat_statements"
    "log_statement"           = "all"
    "log_min_duration_statement" = "1000"
    "log_checkpoints"         = "1"
    "log_connections"         = "1"
    "log_disconnections"      = "1"
    "log_lock_waits"         = "1"
    "log_temp_files"         = "0"
  }
  
  # Alarm configuration
  connection_threshold = 80
  alarm_actions       = [aws_sns_topic.database_alerts.arn]
  ok_actions         = [aws_sns_topic.database_alerts.arn]
  
  common_tags = {
    Environment = "production"
    Application = "myapp"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
}
```

### 2. Database Automation Scripts

#### Advanced Migration Tool
```python
#!/usr/bin/env python3
# automation/migration/migrate.py

import os
import sys
import argparse
import psycopg2
import logging
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple
import hashlib

class DatabaseMigrator:
    def __init__(self, db_config: Dict[str, str], migrations_dir: str):
        self.db_config = db_config
        self.migrations_dir = Path(migrations_dir)
        self.setup_logging()
        
    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('migration.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def get_connection(self):
        """Establish database connection"""
        try:
            conn = psycopg2.connect(**self.db_config)
            conn.autocommit = False
            return conn
        except Exception as e:
            self.logger.error(f"Failed to connect to database: {e}")
            raise
    
    def create_migrations_table(self):
        """Create migrations tracking table"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS schema_migrations (
                        version VARCHAR(255) PRIMARY KEY,
                        filename VARCHAR(255) NOT NULL,
                        checksum VARCHAR(64) NOT NULL,
                        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        execution_time_ms INTEGER
                    );
                """)
            conn.commit()
            self.logger.info("Migrations table created/verified")
        except Exception as e:
            conn.rollback()
            self.logger.error(f"Failed to create migrations table: {e}")
            raise
        finally:
            conn.close()
    
    def get_applied_migrations(self) -> Dict[str, Dict]:
        """Get list of applied migrations"""
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT version, filename, checksum, applied_at, execution_time_ms
                    FROM schema_migrations
                    ORDER BY version
                """)
                
                migrations = {}
                for row in cursor.fetchall():
                    migrations[row[0]] = {
                        'filename': row[1],
                        'checksum': row[2],
                        'applied_at': row[3],
                        'execution_time_ms': row[4]
                    }
                return migrations
        except Exception as e:
            self.logger.error(f"Failed to get applied migrations: {e}")
            raise
        finally:
            conn.close()
    
    def get_migration_files(self) -> List[Tuple[str, Path]]:
        """Get sorted list of migration files"""
        migration_files = []
        
        for file_path in self.migrations_dir.glob("*.sql"):
            version = file_path.stem.split('_')[0]
            migration_files.append((version, file_path))
        
        # Sort by version
        migration_files.sort(key=lambda x: x[0])
        return migration_files
    
    def calculate_checksum(self, file_path: Path) -> str:
        """Calculate SHA256 checksum of migration file"""
        with open(file_path, 'rb') as f:
            content = f.read()
            return hashlib.sha256(content).hexdigest()
    
    def validate_migrations(self) -> bool:
        """Validate migration files against applied migrations"""
        applied_migrations = self.get_applied_migrations()
        migration_files = self.get_migration_files()
        
        for version, file_path in migration_files:
            if version in applied_migrations:
                file_checksum = self.calculate_checksum(file_path)
                applied_checksum = applied_migrations[version]['checksum']
                
                if file_checksum != applied_checksum:
                    self.logger.error(
                        f"Migration {version} checksum mismatch! "
                        f"File: {file_checksum}, Applied: {applied_checksum}"
                    )
                    return False
        
        self.logger.info("Migration validation passed")
        return True
    
    def run_migration(self, version: str, file_path: Path) -> bool:
        """Run a single migration"""
        self.logger.info(f"Running migration: {version} - {file_path.name}")
        
        start_time = datetime.now()
        conn = self.get_connection()
        
        try:
            with open(file_path, 'r') as f:
                migration_sql = f.read()
            
            with conn.cursor() as cursor:
                # Execute migration
                cursor.execute(migration_sql)
                
                # Record migration
                execution_time = int((datetime.now() - start_time).total_seconds() * 1000)
                checksum = self.calculate_checksum(file_path)
                
                cursor.execute("""
                    INSERT INTO schema_migrations 
                    (version, filename, checksum, applied_at, execution_time_ms)
                    VALUES (%s, %s, %s, %s, %s)
                """, (version, file_path.name, checksum, datetime.now(), execution_time))
            
            conn.commit()
            self.logger.info(f"Migration {version} completed in {execution_time}ms")
            return True
            
        except Exception as e:
            conn.rollback()
            self.logger.error(f"Migration {version} failed: {e}")
            return False
        finally:
            conn.close()
    
    def migrate_up(self, target_version: str = None) -> bool:
        """Run pending migrations"""
        self.create_migrations_table()
        
        if not self.validate_migrations():
            return False
        
        applied_migrations = self.get_applied_migrations()
        migration_files = self.get_migration_files()
        
        pending_migrations = []
        for version, file_path in migration_files:
            if version not in applied_migrations:
                pending_migrations.append((version, file_path))
                if target_version and version == target_version:
                    break
        
        if not pending_migrations:
            self.logger.info("No pending migrations")
            return True
        
        self.logger.info(f"Found {len(pending_migrations)} pending migrations")
        
        for version, file_path in pending_migrations:
            if not self.run_migration(version, file_path):
                return False
        
        self.logger.info("All migrations completed successfully")
        return True
    
    def rollback_migration(self, version: str) -> bool:
        """Rollback a specific migration"""
        rollback_file = self.migrations_dir / f"rollback_{version}.sql"
        
        if not rollback_file.exists():
            self.logger.error(f"Rollback file not found: {rollback_file}")
            return False
        
        self.logger.info(f"Rolling back migration: {version}")
        
        conn = self.get_connection()
        try:
            with open(rollback_file, 'r') as f:
                rollback_sql = f.read()
            
            with conn.cursor() as cursor:
                # Execute rollback
                cursor.execute(rollback_sql)
                
                # Remove migration record
                cursor.execute(
                    "DELETE FROM schema_migrations WHERE version = %s",
                    (version,)
                )
            
            conn.commit()
            self.logger.info(f"Migration {version} rolled back successfully")
            return True
            
        except Exception as e:
            conn.rollback()
            self.logger.error(f"Rollback failed: {e}")
            return False
        finally:
            conn.close()
    
    def migration_status(self):
        """Show migration status"""
        applied_migrations = self.get_applied_migrations()
        migration_files = self.get_migration_files()
        
        print("\n=== Migration Status ===")
        print(f"{'Version':<20} {'Status':<10} {'Applied At':<20} {'Execution Time'}")
        print("-" * 70)
        
        for version, file_path in migration_files:
            if version in applied_migrations:
                migration = applied_migrations[version]
                status = "Applied"
                applied_at = migration['applied_at'].strftime('%Y-%m-%d %H:%M:%S')
                exec_time = f"{migration['execution_time_ms']}ms"
            else:
                status = "Pending"
                applied_at = "-"
                exec_time = "-"
            
            print(f"{version:<20} {status:<10} {applied_at:<20} {exec_time}")

def main():
    parser = argparse.ArgumentParser(description='Database Migration Tool')
    parser.add_argument('action', choices=['up', 'rollback', 'status'], 
                       help='Migration action to perform')
    parser.add_argument('--version', help='Target version for migration')
    parser.add_argument('--migrations-dir', default='./migrations',
                       help='Directory containing migration files')
    
    args = parser.parse_args()
    
    # Database configuration from environment
    db_config = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', 5432)),
        'database': os.getenv('DB_NAME', 'myapp'),
        'user': os.getenv('DB_USER', 'postgres'),
        'password': os.getenv('DB_PASSWORD', '')
    }
    
    migrator = DatabaseMigrator(db_config, args.migrations_dir)
    
    try:
        if args.action == 'up':
            success = migrator.migrate_up(args.version)
        elif args.action == 'rollback':
            if not args.version:
                print("Version required for rollback")
                sys.exit(1)
            success = migrator.rollback_migration(args.version)
        elif args.action == 'status':
            migrator.migration_status()
            success = True
        
        sys.exit(0 if success else 1)
        
    except Exception as e:
        print(f"Migration failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### 3. Backup and Recovery System

#### Automated Backup Script
```bash
#!/bin/bash
# automation/backup/backup-database.sh

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/backup.conf"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
LOG_FILE="${BACKUP_DIR}/backup.log"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
PARALLEL_JOBS="${PARALLEL_JOBS:-4}"

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check required tools
    for cmd in pg_dump pg_dumpall aws s3; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "$cmd is not installed"
        fi
    done
    
    # Check backup directory
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR" || error_exit "Cannot create backup directory: $BACKUP_DIR"
    fi
    
    # Check database connectivity
    if ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" &> /dev/null; then
        error_exit "Cannot connect to database"
    fi
    
    log "Prerequisites check passed"
}

# Full database backup
full_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/full_backup_${timestamp}.sql"
    local compressed_file="${backup_file}.gz"
    
    log "Starting full backup: $backup_file"
    
    # Create backup
    pg_dumpall -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" \
        --verbose \
        --clean \
        --if-exists \
        > "$backup_file" 2>> "$LOG_FILE"
    
    # Compress backup
    gzip "$backup_file"
    
    # Calculate checksums
    sha256sum "$compressed_file" > "${compressed_file}.sha256"
    
    # Upload to S3 (if configured)
    if [[ -n "${S3_BUCKET:-}" ]]; then
        aws s3 cp "$compressed_file" "s3://$S3_BUCKET/backups/full/" \
            --storage-class STANDARD_IA \
            --server-side-encryption AES256
        aws s3 cp "${compressed_file}.sha256" "s3://$S3_BUCKET/backups/full/"
    fi
    
    log "Full backup completed: $compressed_file"
    echo "$compressed_file"
}

# Database-specific backup
database_backup() {
    local db_name="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/${db_name}_backup_${timestamp}.custom"
    
    log "Starting database backup: $db_name"
    
    # Create custom format backup (faster restore)
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db_name" \
        --verbose \
        --format=custom \
        --compress=9 \
        --jobs="$PARALLEL_JOBS" \
        --file="$backup_file" 2>> "$LOG_FILE"
    
    # Calculate checksum
    sha256sum "$backup_file" > "${backup_file}.sha256"
    
    # Upload to S3 (if configured)
    if [[ -n "${S3_BUCKET:-}" ]]; then
        aws s3 cp "$backup_file" "s3://$S3_BUCKET/backups/databases/" \
            --storage-class STANDARD_IA \
            --server-side-encryption AES256
        aws s3 cp "${backup_file}.sha256" "s3://$S3_BUCKET/backups/databases/"
    fi
    
    log "Database backup completed: $backup_file"
    echo "$backup_file"
}

# Schema-only backup
schema_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/schema_backup_${timestamp}.sql"
    
    log "Starting schema backup"
    
    # Get list of databases
    databases=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';" | xargs)
    
    for db in $databases; do
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db" \
            --schema-only \
            --verbose \
            >> "$backup_file" 2>> "$LOG_FILE"
    done
    
    gzip "$backup_file"
    sha256sum "${backup_file}.gz" > "${backup_file}.gz.sha256"
    
    log "Schema backup completed: ${backup_file}.gz"
    echo "${backup_file}.gz"
}

# Incremental backup using WAL files
incremental_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local wal_backup_dir="${BACKUP_DIR}/wal_${timestamp}"
    
    log "Starting incremental backup (WAL)"
    
    mkdir -p "$wal_backup_dir"
    
    # Archive WAL files
    if [[ -n "${WAL_ARCHIVE_DIR:-}" ]] && [[ -d "$WAL_ARCHIVE_DIR" ]]; then
        rsync -av "$WAL_ARCHIVE_DIR/" "$wal_backup_dir/" >> "$LOG_FILE" 2>&1
        
        # Create archive
        tar -czf "${wal_backup_dir}.tar.gz" -C "$BACKUP_DIR" "$(basename "$wal_backup_dir")"
        rm -rf "$wal_backup_dir"
        
        # Upload to S3
        if [[ -n "${S3_BUCKET:-}" ]]; then
            aws s3 cp "${wal_backup_dir}.tar.gz" "s3://$S3_BUCKET/backups/wal/" \
                --storage-class STANDARD_IA \
                --server-side-encryption AES256
        fi
        
        log "Incremental backup completed: ${wal_backup_dir}.tar.gz"
        echo "${wal_backup_dir}.tar.gz"
    else
        log "WAL archive directory not configured or doesn't exist"
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up backups older than $RETENTION_DAYS days"
    
    # Local cleanup
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "*.custom" -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
    find "$BACKUP_DIR" -name "*.sha256" -mtime +$RETENTION_DAYS -delete
    
    # S3 cleanup (if configured)
    if [[ -n "${S3_BUCKET:-}" ]]; then
        cutoff_date=$(date -d "$RETENTION_DAYS days ago" '+%Y-%m-%d')
        aws s3 ls "s3://$S3_BUCKET/backups/" --recursive | \
        awk -v date="$cutoff_date" '$1 < date {print $4}' | \
        while read -r file; do
            aws s3 rm "s3://$S3_BUCKET/$file"
        done
    fi
    
    log "Cleanup completed"
}

# Verify backup integrity
verify_backup() {
    local backup_file="$1"
    
    log "Verifying backup: $backup_file"
    
    # Check file exists and is not empty
    if [[ ! -f "$backup_file" ]] || [[ ! -s "$backup_file" ]]; then
        error_exit "Backup file is missing or empty: $backup_file"
    fi
    
    # Verify checksum
    if [[ -f "${backup_file}.sha256" ]]; then
        if ! sha256sum -c "${backup_file}.sha256" &> /dev/null; then
            error_exit "Backup checksum verification failed: $backup_file"
        fi
    fi
    
    # Test restore (for custom format)
    if [[ "$backup_file" == *.custom ]]; then
        pg_restore --list "$backup_file" &> /dev/null || error_exit "Backup file is corrupted: $backup_file"
    fi
    
    log "Backup verification passed: $backup_file"
}

# Send notifications
send_notification() {
    local subject="$1"
    local message="$2"
    local status="$3"
    
    # Slack notification (if configured)
    if [[ -n "${SLACK_WEBHOOK:-}" ]]; then
        local color="good"
        [[ "$status" == "error" ]] && color="danger"
        
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"attachments\":[{\"color\":\"$color\",\"title\":\"$subject\",\"text\":\"$message\"}]}" \
            "$SLACK_WEBHOOK" &> /dev/null
    fi
    
    # Email notification (if configured)
    if [[ -n "${EMAIL_TO:-}" ]] && command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$EMAIL_TO"
    fi
}

# Main execution
main() {
    local backup_type="${1:-full}"
    local database_name="${2:-}"
    
    log "Starting backup process: $backup_type"
    
    check_prerequisites
    
    case "$backup_type" in
        full)
            backup_file=$(full_backup)
            verify_backup "$backup_file"
            ;;
        database)
            [[ -z "$database_name" ]] && error_exit "Database name required for database backup"
            backup_file=$(database_backup "$database_name")
            verify_backup "$backup_file"
            ;;
        schema)
            backup_file=$(schema_backup)
            verify_backup "$backup_file"
            ;;
        incremental)
            backup_file=$(incremental_backup)
            [[ -n "$backup_file" ]] && verify_backup "$backup_file"
            ;;
        *)
            error_exit "Invalid backup type: $backup_type"
            ;;
    esac
    
    cleanup_old_backups
    
    local message="Backup completed successfully: $backup_file"
    log "$message"
    send_notification "Database Backup Success" "$message" "success"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 4. Monitoring and Alerting

#### Comprehensive Database Monitoring
```python
#!/usr/bin/env python3
# monitoring/database-monitor.py

import psycopg2
import time
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any
import requests
import os

class DatabaseMonitor:
    def __init__(self, db_config: Dict[str, Any], alert_config: Dict[str, Any]):
        self.db_config = db_config
        self.alert_config = alert_config
        self.setup_logging()
        
        # Thresholds
        self.thresholds = {
            'cpu_percent': 80,
            'memory_percent': 85,
            'connection_percent': 80,
            'disk_usage_percent': 85,
            'replication_lag_seconds': 300,
            'long_query_seconds': 300,
            'deadlock_count': 5,
            'cache_hit_ratio': 95
        }
        
    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/var/log/database-monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def get_connection(self):
        """Get database connection"""
        return psycopg2.connect(**self.db_config)
    
    def collect_metrics(self) -> Dict[str, Any]:
        """Collect comprehensive database metrics"""
        metrics = {}
        
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                # Connection metrics
                metrics.update(self.get_connection_metrics(cursor))
                
                # Performance metrics
                metrics.update(self.get_performance_metrics(cursor))
                
                # Storage metrics
                metrics.update(self.get_storage_metrics(cursor))
                
                # Replication metrics
                metrics.update(self.get_replication_metrics(cursor))
                
                # Lock metrics
                metrics.update(self.get_lock_metrics(cursor))
                
                # Cache metrics
                metrics.update(self.get_cache_metrics(cursor))
                
                # Query metrics
                metrics.update(self.get_query_metrics(cursor))
        
        metrics['timestamp'] = datetime.utcnow().isoformat()
        return metrics
    
    def get_connection_metrics(self, cursor) -> Dict[str, Any]:
        """Get connection-related metrics"""
        cursor.execute("""
            SELECT 
                count(*) as total_connections,
                count(*) FILTER (WHERE state = 'active') as active_connections,
                count(*) FILTER (WHERE state = 'idle') as idle_connections,
                count(*) FILTER (WHERE state = 'idle in transaction') as idle_in_transaction
            FROM pg_stat_activity
            WHERE datname = current_database()
        """)
        
        result = cursor.fetchone()
        
        # Get max_connections setting
        cursor.execute("SHOW max_connections")
        max_connections = int(cursor.fetchone()[0])
        
        return {
            'connections': {
                'total': result[0],
                'active': result[1],
                'idle': result[2],
                'idle_in_transaction': result[3],
                'max_connections': max_connections,
                'connection_percent': (result[0] / max_connections) * 100
            }
        }
    
    def get_performance_metrics(self, cursor) -> Dict[str, Any]:
        """Get performance metrics"""
        # Database statistics
        cursor.execute("""
            SELECT 
                numbackends,
                xact_commit,
                xact_rollback,
                blks_read,
                blks_hit,
                tup_returned,
                tup_fetched,
                tup_inserted,
                tup_updated,
                tup_deleted,
                conflicts,
                temp_files,
                temp_bytes,
                deadlocks
            FROM pg_stat_database 
            WHERE datname = current_database()
        """)
        
        result = cursor.fetchone()
        
        # Calculate cache hit ratio
        cache_hit_ratio = 0
        if result[3] + result[4] > 0:  # blks_read + blks_hit
            cache_hit_ratio = (result[4] / (result[3] + result[4])) * 100
        
        return {
            'performance': {
                'backends': result[0],
                'transactions_committed': result[1],
                'transactions_rolled_back': result[2],
                'blocks_read': result[3],
                'blocks_hit': result[4],
                'cache_hit_ratio': cache_hit_ratio,
                'tuples_returned': result[5],
                'tuples_fetched': result[6],
                'tuples_inserted': result[7],
                'tuples_updated': result[8],
                'tuples_deleted': result[9],
                'conflicts': result[10],
                'temp_files': result[11],
                'temp_bytes': result[12],
                'deadlocks': result[13]
            }
        }
    
    def get_storage_metrics(self, cursor) -> Dict[str, Any]:
        """Get storage metrics"""
        # Database size
        cursor.execute("""
            SELECT pg_database_size(current_database()) as db_size
        """)
        db_size = cursor.fetchone()[0]
        
        # Table sizes
        cursor.execute("""
            SELECT 
                schemaname,
                tablename,
                pg_total_relation_size(schemaname||'.'||tablename) as size
            FROM pg_tables 
            WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
            ORDER BY size DESC 
            LIMIT 10
        """)
        
        top_tables = []
        for row in cursor.fetchall():
            top_tables.append({
                'schema': row[0],
                'table': row[1],
                'size': row[2]
            })
        
        return {
            'storage': {
                'database_size': db_size,
                'top_tables': top_tables
            }
        }
    
    def get_replication_metrics(self, cursor) -> Dict[str, Any]:
        """Get replication metrics"""
        # Check if this is a primary server
        cursor.execute("SELECT pg_is_in_recovery()")
        is_replica = cursor.fetchone()[0]
        
        if not is_replica:
            # Primary server - get replication slots
            cursor.execute("""
                SELECT 
                    slot_name,
                    active,
                    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) as lag_bytes
                FROM pg_replication_slots
            """)
            
            replication_slots = []
            for row in cursor.fetchall():
                replication_slots.append({
                    'slot_name': row[0],
                    'active': row[1],
                    'lag_bytes': row[2]
                })
            
            return {
                'replication': {
                    'is_replica': False,
                    'slots': replication_slots
                }
            }
        else:
            # Replica server - get lag information
            cursor.execute("""
                SELECT 
                    pg_last_wal_receive_lsn(),
                    pg_last_wal_replay_lsn(),
                    EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::int as lag_seconds
            """)
            
            result = cursor.fetchone()
            return {
                'replication': {
                    'is_replica': True,
                    'last_receive_lsn': result[0],
                    'last_replay_lsn': result[1],
                    'lag_seconds': result[2] or 0
                }
            }
    
    def get_lock_metrics(self, cursor) -> Dict[str, Any]:
        """Get lock metrics"""
        cursor.execute("""
            SELECT 
                mode,
                count(*) as count
            FROM pg_locks 
            WHERE database = (SELECT oid FROM pg_database WHERE datname = current_database())
            GROUP BY mode
        """)
        
        locks = {}
        for row in cursor.fetchall():
            locks[row[0]] = row[1]
        
        # Get blocked queries
        cursor.execute("""
            SELECT count(*) 
            FROM pg_stat_activity 
            WHERE wait_event_type = 'Lock' 
            AND datname = current_database()
        """)
        
        blocked_queries = cursor.fetchone()[0]
        
        return {
            'locks': {
                'by_mode': locks,
                'blocked_queries': blocked_queries
            }
        }
    
    def get_cache_metrics(self, cursor) -> Dict[str, Any]:
        """Get cache metrics"""
        cursor.execute("""
            SELECT 
                sum(heap_blks_read) as heap_read,
                sum(heap_blks_hit) as heap_hit,
                sum(idx_blks_read) as idx_read,
                sum(idx_blks_hit) as idx_hit
            FROM pg_statio_user_tables
        """)
        
        result = cursor.fetchone()
        
        # Calculate hit ratios
        heap_hit_ratio = 0
        if result[0] + result[1] > 0:
            heap_hit_ratio = (result[1] / (result[0] + result[1])) * 100
        
        idx_hit_ratio = 0
        if result[2] + result[3] > 0:
            idx_hit_ratio = (result[3] / (result[2] + result[3])) * 100
        
        return {
            'cache': {
                'heap_blocks_read': result[0],
                'heap_blocks_hit': result[1],
                'heap_hit_ratio': heap_hit_ratio,
                'index_blocks_read': result[2],
                'index_blocks_hit': result[3],
                'index_hit_ratio': idx_hit_ratio
            }
        }
    
    def get_query_metrics(self, cursor) -> Dict[str, Any]:
        """Get query metrics"""
        # Long running queries
        cursor.execute("""
            SELECT 
                pid,
                now() - query_start as duration,
                state,
                query
            FROM pg_stat_activity 
            WHERE state = 'active' 
            AND now() - query_start > interval '5 minutes'
            AND datname = current_database()
            ORDER BY duration DESC
        """)
        
        long_queries = []
        for row in cursor.fetchall():
            long_queries.append({
                'pid': row[0],
                'duration_seconds': row[1].total_seconds(),
                'state': row[2],
                'query': row[3][:100] + '...' if len(row[3]) > 100 else row[3]
            })
        
        return {
            'queries': {
                'long_running': long_queries
            }
        }
    
    def check_alerts(self, metrics: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Check metrics against thresholds and generate alerts"""
        alerts = []
        
        # Connection alerts
        conn_percent = metrics['connections']['connection_percent']
        if conn_percent > self.thresholds['connection_percent']:
            alerts.append({
                'severity': 'warning',
                'metric': 'connection_percent',
                'value': conn_percent,
                'threshold': self.thresholds['connection_percent'],
                'message': f"High connection usage: {conn_percent:.1f}%"
            })
        
        # Cache hit ratio alerts
        cache_ratio = metrics['performance']['cache_hit_ratio']
        if cache_ratio < self.thresholds['cache_hit_ratio']:
            alerts.append({
                'severity': 'warning',
                'metric': 'cache_hit_ratio',
                'value': cache_ratio,
                'threshold': self.thresholds['cache_hit_ratio'],
                'message': f"Low cache hit ratio: {cache_ratio:.1f}%"
            })
        
        # Replication lag alerts
        if 'replication' in metrics and metrics['replication']['is_replica']:
            lag_seconds = metrics['replication']['lag_seconds']
            if lag_seconds > self.thresholds['replication_lag_seconds']:
                alerts.append({
                    'severity': 'critical',
                    'metric': 'replication_lag_seconds',
                    'value': lag_seconds,
                    'threshold': self.thresholds['replication_lag_seconds'],
                    'message': f"High replication lag: {lag_seconds} seconds"
                })
        
        # Deadlock alerts
        deadlocks = metrics['performance']['deadlocks']
        if deadlocks > self.thresholds['deadlock_count']:
            alerts.append({
                'severity': 'warning',
                'metric': 'deadlocks',
                'value': deadlocks,
                'threshold': self.thresholds['deadlock_count'],
                'message': f"High deadlock count: {deadlocks}"
            })
        
        # Long query alerts
        long_queries = len(metrics['queries']['long_running'])
        if long_queries > 0:
            alerts.append({
                'severity': 'warning',
                'metric': 'long_queries',
                'value': long_queries,
                'threshold': 0,
                'message': f"Long running queries detected: {long_queries}"
            })
        
        return alerts
    
    def send_alerts(self, alerts: List[Dict[str, Any]]):
        """Send alerts via configured channels"""
        if not alerts:
            return
        
        for alert in alerts:
            self.logger.warning(f"ALERT: {alert['message']}")
            
            # Send to Slack
            if 'slack_webhook' in self.alert_config:
                self.send_slack_alert(alert)
            
            # Send to email
            if 'email' in self.alert_config:
                self.send_email_alert(alert)
            
            # Send to PagerDuty
            if 'pagerduty' in self.alert_config and alert['severity'] == 'critical':
                self.send_pagerduty_alert(alert)
    
    def send_slack_alert(self, alert: Dict[str, Any]):
        """Send alert to Slack"""
        color = 'danger' if alert['severity'] == 'critical' else 'warning'
        
        payload = {
            'attachments': [{
                'color': color,
                'title': f"Database Alert - {alert['severity'].upper()}",
                'text': alert['message'],
                'fields': [
                    {
                        'title': 'Metric',
                        'value': alert['metric'],
                        'short': True
                    },
                    {
                        'title': 'Value',
                        'value': str(alert['value']),
                        'short': True
                    }
                ],
                'timestamp': int(time.time())
            }]
        }
        
        try:
            response = requests.post(
                self.alert_config['slack_webhook'],
                json=payload,
                timeout=10
            )
            response.raise_for_status()
        except Exception as e:
            self.logger.error(f"Failed to send Slack alert: {e}")
    
    def publish_metrics(self, metrics: Dict[str, Any]):
        """Publish metrics to monitoring system"""
        # Export to Prometheus format
        prometheus_metrics = self.format_prometheus_metrics(metrics)
        
        # Write to file for Prometheus file_sd
        metrics_file = '/var/lib/prometheus/database_metrics.prom'
        os.makedirs(os.path.dirname(metrics_file), exist_ok=True)
        
        with open(metrics_file, 'w') as f:
            f.write(prometheus_metrics)
    
    def format_prometheus_metrics(self, metrics: Dict[str, Any]) -> str:
        """Format metrics for Prometheus"""
        lines = []
        
        # Connection metrics
        lines.append(f'database_connections_total {metrics["connections"]["total"]}')
        lines.append(f'database_connections_active {metrics["connections"]["active"]}')
        lines.append(f'database_connections_idle {metrics["connections"]["idle"]}')
        lines.append(f'database_connections_percent {metrics["connections"]["connection_percent"]}')
        
        # Performance metrics
        lines.append(f'database_cache_hit_ratio {metrics["performance"]["cache_hit_ratio"]}')
        lines.append(f'database_transactions_committed {metrics["performance"]["transactions_committed"]}')
        lines.append(f'database_transactions_rolled_back {metrics["performance"]["transactions_rolled_back"]}')
        lines.append(f'database_deadlocks {metrics["performance"]["deadlocks"]}')
        
        # Storage metrics
        lines.append(f'database_size_bytes {metrics["storage"]["database_size"]}')
        
        # Replication metrics
        if 'replication' in metrics:
            if metrics['replication']['is_replica']:
                lines.append(f'database_replication_lag_seconds {metrics["replication"]["lag_seconds"]}')
        
        # Lock metrics
        lines.append(f'database_blocked_queries {metrics["locks"]["blocked_queries"]}')
        
        # Query metrics
        lines.append(f'database_long_running_queries {len(metrics["queries"]["long_running"])}')
        
        return '\n'.join(lines) + '\n'
    
    def run_monitoring_cycle(self):
        """Run a single monitoring cycle"""
        try:
            self.logger.info("Starting monitoring cycle")
            
            # Collect metrics
            metrics = self.collect_metrics()
            
            # Check for alerts
            alerts = self.check_alerts(metrics)
            
            # Send alerts if any
            if alerts:
                self.send_alerts(alerts)
            
            # Publish metrics
            self.publish_metrics(metrics)
            
            self.logger.info(f"Monitoring cycle completed. Found {len(alerts)} alerts")
            
        except Exception as e:
            self.logger.error(f"Monitoring cycle failed: {e}")
            raise

def main():
    # Configuration
    db_config = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', 5432)),
        'database': os.getenv('DB_NAME', 'postgres'),
        'user': os.getenv('DB_USER', 'monitor'),
        'password': os.getenv('DB_PASSWORD', '')
    }
    
    alert_config = {
        'slack_webhook': os.getenv('SLACK_WEBHOOK'),
        'email': {
            'smtp_server': os.getenv('SMTP_SERVER'),
            'smtp_port': int(os.getenv('SMTP_PORT', 587)),
            'username': os.getenv('SMTP_USERNAME'),
            'password': os.getenv('SMTP_PASSWORD'),
            'from_addr': os.getenv('ALERT_FROM_EMAIL'),
            'to_addr': os.getenv('ALERT_TO_EMAIL')
        }
    }
    
    monitor = DatabaseMonitor(db_config, alert_config)
    
    # Run monitoring loop
    interval = int(os.getenv('MONITOR_INTERVAL', 60))  # seconds
    
    while True:
        try:
            monitor.run_monitoring_cycle()
            time.sleep(interval)
        except KeyboardInterrupt:
            monitor.logger.info("Monitoring stopped by user")
            break
        except Exception as e:
            monitor.logger.error(f"Unexpected error: {e}")
            time.sleep(interval)

if __name__ == "__main__":
    main()
```

## Deployment Instructions

### 1. Environment Setup
```bash
# Clone the repository
git clone <repository-url>
cd database-platform

# Install dependencies
pip install -r requirements.txt
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration
```

### 2. Infrastructure Deployment
```bash
# Initialize Terraform
cd terraform/environments/production
terraform init

# Plan deployment
terraform plan -var-file="production.tfvars"

# Deploy infrastructure
terraform apply -var-file="production.tfvars"
```

### 3. Application Deployment
```bash
# Build and deploy monitoring stack
cd monitoring
docker-compose up -d

# Setup database monitoring
cd ../automation/monitoring
python database-monitor.py &
```

### 4. Backup Configuration
```bash
# Configure backup system
cd automation/backup
cp backup.conf.example backup.conf
# Edit backup.conf with your settings

# Setup cron jobs
crontab -e
# Add: 0 2 * * * /path/to/backup-database.sh full
# Add: 0 */6 * * * /path/to/backup-database.sh incremental
```

## Expected Outcomes

1. **Automated Database Provisioning**: Consistent database deployment across environments
2. **Advanced Migration Management**: Safe and reliable schema evolution
3. **Comprehensive Monitoring**: Real-time visibility into database performance
4. **Automated Backup & Recovery**: Reliable data protection with point-in-time recovery
5. **Security Best Practices**: Access control, encryption, and auditing
6. **Performance Optimization**: Automated performance tuning and optimization
7. **Disaster Recovery**: Complete disaster recovery procedures and automation

## Technologies Used

- **Terraform**: Infrastructure provisioning
- **PostgreSQL**: Primary database system
- **Python**: Automation and monitoring scripts
- **Prometheus/Grafana**: Metrics and visualization
- **Docker**: Containerization
- **AWS RDS**: Managed database service
- **Ansible**: Configuration management
- **Bash**: System automation scripts

This platform provides enterprise-grade database management capabilities that integrate seamlessly with modern DevOps practices and can be adapted for various database systems and cloud providers.
