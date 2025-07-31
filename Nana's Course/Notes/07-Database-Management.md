# Advanced Database Management & DevOps Integration

## Table of Contents
1. [Database Fundamentals](#database-fundamentals)
2. [Database Types & Selection](#database-types)
3. [Database Design & Modeling](#database-design)
4. [Database in DevOps](#database-devops)
5. [Database Security](#database-security)
6. [Performance & Optimization](#performance-optimization)
7. [Backup & Recovery](#backup-recovery)
8. [Database Automation](#database-automation)
9. [Monitoring & Observability](#monitoring-observability)
10. [Best Practices](#best-practices)

## Database Fundamentals {#database-fundamentals}

### What is a Database?
A database is an organized collection of structured information, or data, typically stored electronically in a computer system. It's managed by a Database Management System (DBMS).

### Key Concepts
- **Data**: Raw facts and figures
- **Information**: Processed data with meaning
- **Database**: Collection of related data
- **DBMS**: Software to manage databases
- **Schema**: Structure and organization of data
- **ACID Properties**: Atomicity, Consistency, Isolation, Durability

### Database Components
```
Database System Architecture
├── Users/Applications
├── Database Management System (DBMS)
├── Database Engine
├── Storage Engine
└── Physical Storage
```

## Database Types & Selection {#database-types}

### Relational Databases (SQL)
```sql
-- Example: PostgreSQL
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10,2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Popular SQL Databases
- **PostgreSQL**: Advanced open-source database
- **MySQL**: Popular open-source database
- **Oracle**: Enterprise database solution
- **SQL Server**: Microsoft database platform
- **SQLite**: Lightweight embedded database

### NoSQL Databases

#### Document Databases
```javascript
// MongoDB Example
{
  "_id": ObjectId("..."),
  "username": "john_doe",
  "email": "john@example.com",
  "profile": {
    "firstName": "John",
    "lastName": "Doe",
    "age": 30
  },
  "orders": [
    {
      "orderId": "ORD-001",
      "amount": 99.99,
      "date": ISODate("2024-01-15")
    }
  ]
}
```

#### Key-Value Stores
```redis
# Redis Examples
SET user:1000 "John Doe"
HSET user:1000:profile name "John Doe" email "john@example.com"
LPUSH user:1000:orders "order:1" "order:2"
EXPIRE user:1000:session 3600
```

#### Column-Family
```sql
-- Cassandra Example
CREATE KEYSPACE ecommerce 
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);
```

#### Graph Databases
```cypher
// Neo4j Example
CREATE (u:User {name: 'John', email: 'john@example.com'})
CREATE (p:Product {name: 'Laptop', price: 999.99})
CREATE (u)-[:PURCHASED {date: '2024-01-15'}]->(p)
```

### Database Selection Criteria

| Use Case | Recommended Database | Reason |
|----------|---------------------|---------|
| OLTP Applications | PostgreSQL, MySQL | ACID compliance, mature |
| Analytics/OLAP | ClickHouse, BigQuery | Columnar storage, fast aggregation |
| Document Storage | MongoDB, CouchDB | Flexible schema, JSON-like |
| Caching | Redis, Memcached | In-memory, high performance |
| Time Series | InfluxDB, TimescaleDB | Optimized for time-based data |
| Search | Elasticsearch, Solr | Full-text search capabilities |
| Graph Analysis | Neo4j, Amazon Neptune | Relationship traversal |

## Database Design & Modeling {#database-design}

### Entity-Relationship Modeling
```
E-Commerce ERD Example:

[Customer] ──1:M── [Order] ──M:1── [Order_Item] ──M:1── [Product]
    │                                                        │
    │                                                        │
    └──1:M── [Customer_Address]              [Category] ──1:M──┘
```

### Normalization
```sql
-- 1NF: Atomic values
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

-- 2NF: Remove partial dependencies
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    order_date DATE,
    total_amount DECIMAL(10,2)
);

-- 3NF: Remove transitive dependencies
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category_id INTEGER REFERENCES categories(id),
    price DECIMAL(8,2)
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    description TEXT
);
```

### Database Schema Versioning
```sql
-- migrations/001_create_users_table.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- migrations/002_add_user_profile.sql
ALTER TABLE users ADD COLUMN profile_data JSONB;
CREATE INDEX idx_users_profile ON users USING GIN (profile_data);

-- migrations/003_create_audit_log.sql
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    old_values JSONB,
    new_values JSONB,
    user_id INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Database in DevOps {#database-devops}

### Infrastructure as Code for Databases

#### Terraform Example
```hcl
# terraform/database.tf
resource "aws_db_instance" "main" {
  identifier = "myapp-db"
  engine     = "postgres"
  engine_version = "14.9"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = true
  
  db_name  = "myapp"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "myapp-db-final-snapshot"
  
  tags = {
    Name        = "MyApp Database"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "myapp-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  
  tags = {
    Name = "MyApp DB subnet group"
  }
}

resource "aws_security_group" "database" {
  name_prefix = "myapp-db-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "MyApp Database Security Group"
  }
}
```

#### Docker Compose for Development
```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: devpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U developer"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  mongodb:
    image: mongo:6
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db

volumes:
  postgres_data:
  redis_data:
  mongodb_data:
```

### Database Migration Automation
```bash
#!/bin/bash
# scripts/migrate.sh

set -e

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-myapp}
DB_USER=${DB_USER:-postgres}
MIGRATIONS_DIR="./migrations"

run_migrations() {
    echo "Running database migrations..."
    
    # Create migrations table if it doesn't exist
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version VARCHAR(255) PRIMARY KEY,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    "
    
    # Get applied migrations
    applied_migrations=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT version FROM schema_migrations ORDER BY version;")
    
    # Run pending migrations
    for migration_file in $(ls $MIGRATIONS_DIR/*.sql | sort); do
        migration_version=$(basename $migration_file .sql)
        
        if ! echo "$applied_migrations" | grep -q "$migration_version"; then
            echo "Applying migration: $migration_version"
            psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $migration_file
            
            # Record migration
            psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
                INSERT INTO schema_migrations (version) VALUES ('$migration_version');
            "
            
            echo "Migration $migration_version applied successfully"
        else
            echo "Migration $migration_version already applied"
        fi
    done
    
    echo "All migrations completed"
}

rollback_migration() {
    local version=$1
    echo "Rolling back migration: $version"
    
    if [ -f "$MIGRATIONS_DIR/rollback_${version}.sql" ]; then
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$MIGRATIONS_DIR/rollback_${version}.sql"
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "DELETE FROM schema_migrations WHERE version = '$version';"
        echo "Rollback completed"
    else
        echo "Rollback script not found for version: $version"
        exit 1
    fi
}

case $1 in
    up)
        run_migrations
        ;;
    rollback)
        if [ -z "$2" ]; then
            echo "Usage: $0 rollback <version>"
            exit 1
        fi
        rollback_migration $2
        ;;
    *)
        echo "Usage: $0 {up|rollback <version>}"
        exit 1
        ;;
esac
```

### Database CI/CD Pipeline
```yaml
# .github/workflows/database.yml
name: Database CI/CD

on:
  push:
    paths:
      - 'migrations/**'
      - 'database/**'
  pull_request:
    paths:
      - 'migrations/**'
      - 'database/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Install PostgreSQL client
        run: sudo apt-get update && sudo apt-get install -y postgresql-client
        
      - name: Run migrations
        env:
          DB_HOST: localhost
          DB_PORT: 5432
          DB_NAME: test_db
          DB_USER: test_user
          PGPASSWORD: test_password
        run: ./scripts/migrate.sh up
        
      - name: Run database tests
        env:
          DB_HOST: localhost
          DB_PORT: 5432
          DB_NAME: test_db
          DB_USER: test_user
          PGPASSWORD: test_password
        run: ./scripts/test-database.sh
        
      - name: Validate schema
        env:
          DB_HOST: localhost
          DB_PORT: 5432
          DB_NAME: test_db
          DB_USER: test_user
          PGPASSWORD: test_password
        run: ./scripts/validate-schema.sh

  deploy-staging:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - name: Deploy to staging
        env:
          DB_HOST: ${{ secrets.STAGING_DB_HOST }}
          DB_PORT: ${{ secrets.STAGING_DB_PORT }}
          DB_NAME: ${{ secrets.STAGING_DB_NAME }}
          DB_USER: ${{ secrets.STAGING_DB_USER }}
          PGPASSWORD: ${{ secrets.STAGING_DB_PASSWORD }}
        run: ./scripts/migrate.sh up

  deploy-production:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - name: Deploy to production
        env:
          DB_HOST: ${{ secrets.PROD_DB_HOST }}
          DB_PORT: ${{ secrets.PROD_DB_PORT }}
          DB_NAME: ${{ secrets.PROD_DB_NAME }}
          DB_USER: ${{ secrets.PROD_DB_USER }}
          PGPASSWORD: ${{ secrets.PROD_DB_PASSWORD }}
        run: ./scripts/migrate.sh up
```

## Database Security {#database-security}

### Access Control & Authentication
```sql
-- Role-based access control
CREATE ROLE app_read;
CREATE ROLE app_write;
CREATE ROLE app_admin;

-- Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_write;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;

-- Create users with roles
CREATE USER app_user WITH PASSWORD 'secure_password';
GRANT app_write TO app_user;

CREATE USER readonly_user WITH PASSWORD 'readonly_password';
GRANT app_read TO readonly_user;
```

### Data Encryption
```sql
-- Column-level encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Store encrypted data
INSERT INTO users (username, email, ssn_encrypted)
VALUES ('john_doe', 'john@example.com', 
        crypt('123-45-6789', gen_salt('bf')));

-- Query encrypted data
SELECT username, email 
FROM users 
WHERE ssn_encrypted = crypt('123-45-6789', ssn_encrypted);
```

### Database Auditing
```sql
-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, old_values, user_id)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), current_setting('app.user_id')::INTEGER);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, old_values, new_values, user_id)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW), current_setting('app.user_id')::INTEGER);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, new_values, user_id)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW), current_setting('app.user_id')::INTEGER);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit trigger to tables
CREATE TRIGGER users_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

## Performance & Optimization {#performance-optimization}

### Indexing Strategies
```sql
-- B-tree indexes (default)
CREATE INDEX idx_users_email ON users(email);

-- Composite indexes
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);

-- Partial indexes
CREATE INDEX idx_active_users ON users(username) WHERE active = true;

-- Functional indexes
CREATE INDEX idx_users_lower_email ON users(lower(email));

-- GIN indexes for JSONB
CREATE INDEX idx_users_profile ON users USING GIN (profile_data);

-- Full-text search
CREATE INDEX idx_products_search ON products USING GIN (to_tsvector('english', name || ' ' || description));
```

### Query Optimization
```sql
-- Use EXPLAIN ANALYZE to understand query performance
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.username
ORDER BY order_count DESC;

-- Optimize with proper indexes
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Use materialized views for complex aggregations
CREATE MATERIALIZED VIEW user_order_stats AS
SELECT 
    u.id,
    u.username,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

CREATE UNIQUE INDEX idx_user_order_stats_id ON user_order_stats(id);
```

### Connection Pooling
```javascript
// Node.js with connection pooling
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  max: 20, // Maximum number of connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Use pooled connections
async function getUser(id) {
  const client = await pool.connect();
  try {
    const result = await client.query('SELECT * FROM users WHERE id = $1', [id]);
    return result.rows[0];
  } finally {
    client.release();
  }
}
```

## Backup & Recovery {#backup-recovery}

### Backup Strategies
```bash
#!/bin/bash
# scripts/backup.sh

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-myapp}
DB_USER=${DB_USER:-postgres}
BACKUP_DIR="/backups"
DATE=$(date +"%Y%m%d_%H%M%S")

# Full database backup
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$BACKUP_DIR/full_backup_$DATE.sql"

# Compressed backup
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME | gzip > "$BACKUP_DIR/compressed_backup_$DATE.sql.gz"

# Custom format backup (faster restore)
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -Fc -f "$BACKUP_DIR/custom_backup_$DATE.dump"

# Schema-only backup
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -s -f "$BACKUP_DIR/schema_backup_$DATE.sql"

# Data-only backup
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -a -f "$BACKUP_DIR/data_backup_$DATE.sql"

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.dump" -mtime +7 -delete

echo "Backup completed: $DATE"
```

### Point-in-Time Recovery
```bash
#!/bin/bash
# scripts/restore-pit.sh

BACKUP_FILE=$1
TARGET_TIME=$2
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-myapp}
DB_USER=${DB_USER:-postgres}

if [ -z "$BACKUP_FILE" ] || [ -z "$TARGET_TIME" ]; then
    echo "Usage: $0 <backup_file> <target_time>"
    echo "Example: $0 backup_20240115.dump '2024-01-15 14:30:00'"
    exit 1
fi

echo "Performing point-in-time recovery to: $TARGET_TIME"

# Stop application
systemctl stop myapp

# Create recovery database
createdb -h $DB_HOST -p $DB_PORT -U $DB_USER ${DB_NAME}_recovery

# Restore from backup
pg_restore -h $DB_HOST -p $DB_PORT -U $DB_USER -d ${DB_NAME}_recovery $BACKUP_FILE

# Apply WAL files up to target time
# This requires WAL archiving to be configured
echo "restore_command = 'cp /archive/%f %p'" > recovery.conf
echo "recovery_target_time = '$TARGET_TIME'" >> recovery.conf

# Restart PostgreSQL to apply recovery
systemctl restart postgresql

echo "Point-in-time recovery completed"
```

## Database Automation {#database-automation}

### Automated Database Provisioning
```python
#!/usr/bin/env python3
# scripts/provision-database.py

import boto3
import json
import time
from typing import Dict, Any

class DatabaseProvisioner:
    def __init__(self, region: str = 'us-west-2'):
        self.rds_client = boto3.client('rds', region_name=region)
        self.region = region
    
    def create_database_instance(self, config: Dict[str, Any]) -> str:
        """Create RDS database instance"""
        try:
            response = self.rds_client.create_db_instance(
                DBInstanceIdentifier=config['db_instance_identifier'],
                DBInstanceClass=config['db_instance_class'],
                Engine=config['engine'],
                EngineVersion=config.get('engine_version'),
                MasterUsername=config['master_username'],
                MasterUserPassword=config['master_password'],
                AllocatedStorage=config['allocated_storage'],
                VpcSecurityGroupIds=config.get('vpc_security_group_ids', []),
                DBSubnetGroupName=config.get('db_subnet_group_name'),
                BackupRetentionPeriod=config.get('backup_retention_period', 7),
                StorageEncrypted=config.get('storage_encrypted', True),
                MultiAZ=config.get('multi_az', False),
                PubliclyAccessible=config.get('publicly_accessible', False),
                Tags=config.get('tags', [])
            )
            
            db_instance_id = response['DBInstance']['DBInstanceIdentifier']
            print(f"Database instance creation initiated: {db_instance_id}")
            
            # Wait for instance to be available
            self.wait_for_instance_available(db_instance_id)
            
            return db_instance_id
            
        except Exception as e:
            print(f"Error creating database instance: {str(e)}")
            raise
    
    def wait_for_instance_available(self, db_instance_id: str, timeout: int = 1800):
        """Wait for database instance to become available"""
        print(f"Waiting for database instance {db_instance_id} to become available...")
        
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                response = self.rds_client.describe_db_instances(
                    DBInstanceIdentifier=db_instance_id
                )
                
                status = response['DBInstances'][0]['DBInstanceStatus']
                print(f"Current status: {status}")
                
                if status == 'available':
                    endpoint = response['DBInstances'][0]['Endpoint']['Address']
                    port = response['DBInstances'][0]['Endpoint']['Port']
                    print(f"Database instance is available at: {endpoint}:{port}")
                    return endpoint, port
                elif status in ['failed', 'stopped']:
                    raise Exception(f"Database instance failed with status: {status}")
                
                time.sleep(30)
                
            except Exception as e:
                print(f"Error checking instance status: {str(e)}")
                time.sleep(30)
        
        raise Exception(f"Timeout waiting for database instance to become available")
    
    def create_read_replica(self, source_db_id: str, replica_id: str) -> str:
        """Create read replica"""
        try:
            response = self.rds_client.create_db_instance_read_replica(
                DBInstanceIdentifier=replica_id,
                SourceDBInstanceIdentifier=source_db_id,
                PubliclyAccessible=False
            )
            
            print(f"Read replica creation initiated: {replica_id}")
            self.wait_for_instance_available(replica_id)
            return replica_id
            
        except Exception as e:
            print(f"Error creating read replica: {str(e)}")
            raise

def main():
    config = {
        'db_instance_identifier': 'myapp-prod-db',
        'db_instance_class': 'db.t3.micro',
        'engine': 'postgres',
        'engine_version': '14.9',
        'master_username': 'dbadmin',
        'master_password': 'SecurePassword123!',
        'allocated_storage': 20,
        'backup_retention_period': 7,
        'storage_encrypted': True,
        'multi_az': True,
        'publicly_accessible': False,
        'tags': [
            {'Key': 'Environment', 'Value': 'production'},
            {'Key': 'Application', 'Value': 'myapp'}
        ]
    }
    
    provisioner = DatabaseProvisioner()
    db_instance_id = provisioner.create_database_instance(config)
    print(f"Database provisioning completed: {db_instance_id}")

if __name__ == "__main__":
    main()
```

## Monitoring & Observability {#monitoring-observability}

### Database Monitoring
```sql
-- PostgreSQL monitoring queries
-- Connection monitoring
SELECT 
    count(*) as total_connections,
    count(*) FILTER (WHERE state = 'active') as active_connections,
    count(*) FILTER (WHERE state = 'idle') as idle_connections
FROM pg_stat_activity;

-- Long running queries
SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
ORDER BY duration DESC;

-- Table size monitoring
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Prometheus Metrics
```yaml
# docker-compose.yml for monitoring stack
version: '3.8'

services:
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter
    environment:
      DATA_SOURCE_NAME: "postgresql://monitoring:password@postgres:5432/myapp?sslmode=disable"
    ports:
      - "9187:9187"
    depends_on:
      - postgres

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
```

## Best Practices {#best-practices}

### Development Best Practices
```yaml
# Database development guidelines
database_development:
  schema_design:
    - Use appropriate data types
    - Normalize to 3NF minimum
    - Consider denormalization for performance
    - Use constraints for data integrity
    
  naming_conventions:
    tables: snake_case_plural
    columns: snake_case
    indexes: idx_table_columns
    constraints: pk_table, fk_table_ref, uk_table_columns
    
  migration_practices:
    - Always use transactions
    - Test migrations on staging
    - Plan rollback strategies
    - Use schema versioning
    
  security:
    - Least privilege access
    - Use parameterized queries
    - Encrypt sensitive data
    - Regular security audits
```

### Performance Best Practices
- **Indexing**: Create indexes for frequently queried columns
- **Query Optimization**: Use EXPLAIN ANALYZE to optimize queries
- **Connection Pooling**: Limit database connections
- **Caching**: Implement application-level caching
- **Partitioning**: Use table partitioning for large datasets

### Backup & Recovery Best Practices
- **Regular Backups**: Automated daily backups
- **Test Restores**: Regularly test backup restoration
- **Multiple Locations**: Store backups in multiple locations
- **Point-in-Time Recovery**: Enable WAL archiving
- **Documentation**: Maintain recovery procedures

## Conclusion

Database management in DevOps requires a comprehensive approach covering:
- Proper database selection and design
- Infrastructure automation
- Security implementation
- Performance optimization
- Monitoring and observability
- Backup and recovery planning

By following these practices and implementing the provided examples, you can build robust, scalable, and secure database systems that integrate seamlessly with modern DevOps workflows.
