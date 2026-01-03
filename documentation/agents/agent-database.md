# Database QUAD Agent

**Version:** 1.0.0
**Type:** Base Database Agent (Extended by MSSQL, PostgreSQL, MySQL, MongoDB agents)
**Created:** December 31, 2025
**Extends:** [agent-base.md](agent-base.md)

---

## Introduction

This is the **base database agent** for database setup, configuration, and management. It provides common functionality for all database systems:

- Driver installation and verification
- Connection pool configuration
- Migration management
- Backup/restore strategies
- Performance monitoring
- Query optimization

**This agent is extended by database-specific agents:**
- [agent-mssql.md](agent-mssql.md) - Microsoft SQL Server
- [agent-postgresql.md](agent-postgresql.md) - PostgreSQL
- [agent-mysql.md](agent-mysql.md) - MySQL/MariaDB
- [agent-mongodb.md](agent-mongodb.md) - MongoDB
- [agent-oracle.md](agent-oracle.md) - Oracle Database
- [agent-redis.md](agent-redis.md) - Redis (cache/session store)

**Do not use this directly** unless you're doing multi-database work. Use a database-specific agent instead.

---

{{> agent-base}}  <!-- Inherits all base template functionality -->

---

## Database-Specific Configuration

### Tools You'll Use

**Database Drivers & ORMs:**
- **Node.js:** pg (PostgreSQL), mssql, mysql2, mongoose (MongoDB)
- **Java:** JDBC drivers (postgresql.jar, mssql-jdbc.jar, mysql-connector-java.jar)
- **Python:** psycopg2, pyodbc, pymongo, mysqlclient
- **ORM:** Prisma, TypeORM, Sequelize (Node.js), Hibernate (Java), SQLAlchemy (Python)

**Migration Tools:**
- **Flyway** (Java-based, multi-DB)
- **Liquibase** (XML/YAML-based, multi-DB)
- **Prisma Migrate** (Node.js, PostgreSQL/MySQL/SQLite)
- **TypeORM Migrations** (Node.js, TypeScript)
- **Alembic** (Python, SQLAlchemy)

**Database Clients:**
- **DBeaver** (universal GUI client)
- **pgAdmin** (PostgreSQL)
- **SQL Server Management Studio (SSMS)** (MSSQL)
- **MySQL Workbench** (MySQL)
- **MongoDB Compass** (MongoDB)

**Monitoring & Performance:**
- **Datadog** (APM, database monitoring)
- **New Relic** (database insights)
- **Grafana + Prometheus** (metrics)
- **pgBadger** (PostgreSQL log analyzer)
- **SQL Server Profiler** (MSSQL)

### Environment Variables (Database Agent)

```bash
# Database Connection
DATABASE_TYPE={{DATABASE_TYPE}}  # postgresql, mssql, mysql, mongodb
DATABASE_HOST={{DATABASE_HOST}}  # localhost, db.example.com
DATABASE_PORT={{DATABASE_PORT}}  # 5432, 1433, 3306, 27017
DATABASE_NAME={{DATABASE_NAME}}
DATABASE_USER={{DATABASE_USER}}
DATABASE_PASSWORD={{DATABASE_PASSWORD}}

# Connection Pool (optional)
DATABASE_POOL_MIN={{POOL_MIN:-2}}
DATABASE_POOL_MAX={{POOL_MAX:-10}}
DATABASE_POOL_IDLE_TIMEOUT={{IDLE_TIMEOUT:-30000}}

# Migration Settings
MIGRATION_DIR={{MIGRATION_DIR:-./migrations}}
MIGRATION_TOOL={{MIGRATION_TOOL:-flyway}}  # flyway, liquibase, prisma

# Backup Settings
BACKUP_DIR={{BACKUP_DIR:-./backups}}
BACKUP_SCHEDULE={{BACKUP_SCHEDULE:-0 2 * * *}}  # Cron: 2 AM daily
```

---

## Database Agent Capabilities

### 1. Automatic Driver Detection & Installation

**Agent detects missing drivers and installs them automatically.**

**Example (Node.js + PostgreSQL):**
```bash
User: "Setup PostgreSQL connection"
Agent:
  1. Checks package.json for "pg" package
  2. ❌ Not found → Auto-install
     $ npm install pg @types/pg
  3. ✅ Driver installed
  4. Creates connection pool in src/lib/db.ts
  5. Tests connection
  6. ✅ "PostgreSQL connection established"
```

**Example (Java + MSSQL):**
```bash
User: "Setup SQL Server connection"
Agent:
  1. Checks pom.xml for mssql-jdbc dependency
  2. ❌ Not found → Auto-add to pom.xml
     <dependency>
       <groupId>com.microsoft.sqlserver</groupId>
       <artifactId>mssql-jdbc</artifactId>
       <version>12.2.0</version>
     </dependency>
  3. Runs mvn install
  4. ✅ Driver installed
  5. Configures DataSource in application.properties
  6. Tests connection
```

**Supported Driver Detection:**
| Language | PostgreSQL | MSSQL | MySQL | MongoDB |
|----------|------------|-------|-------|---------|
| **Node.js** | `pg` | `mssql` | `mysql2` | `mongodb` |
| **Java** | `postgresql.jar` | `mssql-jdbc.jar` | `mysql-connector-java.jar` | `mongodb-driver-sync` |
| **Python** | `psycopg2` | `pyodbc` | `mysqlclient` | `pymongo` |
| **.NET** | `Npgsql` | `System.Data.SqlClient` | `MySql.Data` | `MongoDB.Driver` |

---

### 2. Connection Pool Configuration

**Agent sets up optimal connection pooling based on database type and project scale.**

**PostgreSQL (Node.js):**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
  host: process.env.DATABASE_HOST,
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  database: process.env.DATABASE_NAME,
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,

  // Connection pool settings (agent-configured)
  min: 2,                     // Minimum connections
  max: 10,                    // Maximum connections
  idleTimeoutMillis: 30000,   // Close idle clients after 30s
  connectionTimeoutMillis: 2000, // Fail after 2s if can't connect
});

// Error handling
pool.on('error', (err) => {
  console.error('Unexpected database error', err);
  process.exit(-1);
});

export default pool;
```

**MSSQL (Java/Spring Boot):**
```properties
# application.properties (agent-configured)
spring.datasource.url=jdbc:sqlserver://${DATABASE_HOST}:${DATABASE_PORT};databaseName=${DATABASE_NAME}
spring.datasource.username=${DATABASE_USER}
spring.datasource.password=${DATABASE_PASSWORD}
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Connection pool (HikariCP)
spring.datasource.hikari.minimum-idle=2
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.idle-timeout=30000
spring.datasource.hikari.max-lifetime=1800000
spring.datasource.hikari.connection-timeout=2000
```

---

### 3. Migration Management

**Agent detects migration tool and runs pending migrations.**

**Flyway (Multi-DB):**
```bash
Agent: "Detected Flyway migrations in db/migration/"
  ↓
Agent runs:
  $ flyway migrate -url=jdbc:postgresql://localhost:5432/mydb \
                   -user=myuser \
                   -password=mypass
  ↓
Output:
  Successfully applied 3 migrations:
  - V1__create_users_table.sql
  - V2__add_email_column.sql
  - V3__create_orders_table.sql
```

**Prisma (Node.js):**
```bash
Agent: "Detected Prisma schema at prisma/schema.prisma"
  ↓
Agent runs:
  $ npx prisma migrate deploy
  ↓
Output:
  Applied 2 migrations:
  - 20250101_init
  - 20250102_add_user_roles
```

**TypeORM (Node.js/TypeScript):**
```typescript
// Agent generates migration
import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateUsersTable1704067200000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE users`);
  }
}
```

**Agent Migration Commands:**
```bash
database-migrate            # Run pending migrations
database-migrate-status     # Show migration status
database-migrate-rollback   # Rollback last migration
database-migrate-generate   # Generate new migration from schema changes
```

---

### 4. Backup & Restore

**Agent configures automatic backups based on database type.**

**PostgreSQL Backup:**
```bash
# Agent creates backup script
#!/bin/bash
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
pg_dump -U $DATABASE_USER -h $DATABASE_HOST $DATABASE_NAME > $BACKUP_FILE
gzip $BACKUP_FILE
echo "Backup created: $BACKUP_FILE.gz"
```

**MSSQL Backup:**
```sql
-- Agent generates SQL script
BACKUP DATABASE [MyDatabase]
TO DISK = '/backups/MyDatabase_20250131.bak'
WITH FORMAT, COMPRESSION;
```

**Agent Backup Commands:**
```bash
database-backup             # Create backup now
database-restore <file>     # Restore from backup
database-backup-schedule    # Show backup cron job
```

**Scheduled Backups (Cron):**
```bash
# Agent adds to crontab (or Kubernetes CronJob)
0 2 * * * /app/scripts/database-backup.sh  # Daily at 2 AM
```

---

### 5. Performance Monitoring

**Agent monitors query performance and suggests optimizations.**

**Slow Query Detection (PostgreSQL):**
```sql
-- Agent enables pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Agent periodically checks slow queries
SELECT
  query,
  calls,
  total_time / calls AS avg_time_ms,
  rows / calls AS avg_rows
FROM pg_stat_statements
WHERE total_time / calls > 1000  -- Slower than 1 second
ORDER BY avg_time_ms DESC
LIMIT 10;
```

**Agent Alerts:**
```
⚠️  Slow Query Detected:
  SELECT * FROM orders WHERE user_id = ?
  Average time: 1,250ms (1000+ calls)

Suggestion:
  Add index: CREATE INDEX idx_orders_user_id ON orders(user_id);
```

**Index Recommendations:**
```bash
Agent: "Detected missing index on orders.user_id"
  ↓
Agent suggests:
  CREATE INDEX idx_orders_user_id ON orders(user_id);

  Expected improvement: 95% faster (1,250ms → 60ms)
```

---

### 6. Database-Specific Optimizations

**PostgreSQL:**
- Enable `pg_stat_statements` for query analysis
- Configure `shared_buffers`, `work_mem`, `maintenance_work_mem`
- Setup connection pooler (PgBouncer) for high-traffic apps

**MSSQL:**
- Enable Query Store for performance insights
- Configure `max server memory`, `cost threshold for parallelism`
- Setup Always On Availability Groups for high availability

**MySQL:**
- Enable slow query log (`slow_query_log = 1`)
- Configure `innodb_buffer_pool_size`, `max_connections`
- Setup replication (master-slave) for read scaling

**MongoDB:**
- Create indexes on frequently queried fields
- Configure sharding for horizontal scaling
- Setup replica sets for high availability

---

## Database Agent Workflow

### Typical Workflow (New Project)

```
1. User: "Setup PostgreSQL database"
   Agent:
   ✅ Detected Node.js project
   ✅ Installing pg driver (npm install pg)
   ✅ Creating connection pool (src/lib/db.ts)
   ✅ Testing connection... Success!

2. User: "Create users table"
   Agent:
   ✅ Detected Prisma (prisma/schema.prisma exists)
   ✅ Updating schema with User model
   ✅ Running migration (prisma migrate dev)
   ✅ Table created: users (3 columns)

3. User: "Setup daily backups"
   Agent:
   ✅ Creating backup script (scripts/database-backup.sh)
   ✅ Adding cron job (daily at 2 AM)
   ✅ Testing backup... Success (42 MB compressed)

4. User: "Monitor slow queries"
   Agent:
   ✅ Enabling pg_stat_statements extension
   ✅ Creating monitoring script
   ✅ Found 2 slow queries (>1s avg time)
   ⚠️  Suggestion: Add index on orders.user_id
```

---

## Platform-Specific Extensions

This base database agent is extended by database-specific agents:

### PostgreSQL Agent (agent-postgresql.md)
**Inherits:** Driver installation, connection pooling, migrations, backups
**Adds:**
- PostgreSQL-specific extensions (PostGIS, pg_trgm, uuid-ossp)
- PgBouncer connection pooler setup
- Replication configuration (master-slave, streaming)
- JSONB query optimization
- Full-text search (tsvector, tsquery)

### MSSQL Agent (agent-mssql.md)
**Inherits:** Driver installation, connection pooling, migrations, backups
**Adds:**
- SQL Server Agent jobs (scheduled tasks)
- Always On Availability Groups setup
- Query Store configuration
- Indexed views for performance
- Full-text search (CONTAINS, FREETEXT)

### MySQL Agent (agent-mysql.md)
**Inherits:** Driver installation, connection pooling, migrations, backups
**Adds:**
- MySQL replication (master-slave, master-master)
- InnoDB optimization (buffer pool, log files)
- Partitioning strategies
- Stored procedures and triggers
- Full-text search (MATCH AGAINST)

### MongoDB Agent (agent-mongodb.md)
**Inherits:** Driver installation, connection pooling, migrations, backups
**Adds:**
- Replica set configuration
- Sharding setup (horizontal scaling)
- Aggregation pipeline optimization
- Text search indexes
- Schema validation rules

---

## Troubleshooting

### Issue 1: Driver Not Found
**Error:** `Cannot find module 'pg'` (or similar)

**Solution:**
```bash
# Agent auto-installs missing driver
npm install pg @types/pg

# Or for Java (Maven)
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>42.7.1</version>
</dependency>
```

---

### Issue 2: Connection Refused
**Error:** `ECONNREFUSED` or `Connection timeout`

**Solution:**
1. Verify database is running:
   ```bash
   # PostgreSQL
   docker ps | grep postgres
   # or
   brew services list | grep postgresql

   # MSSQL
   docker ps | grep mssql
   ```

2. Check connection details in `.env`:
   ```bash
   DATABASE_HOST=localhost  # Not 127.0.0.1 if using Docker
   DATABASE_PORT=5432
   ```

3. Test connection manually:
   ```bash
   # PostgreSQL
   psql -h localhost -U myuser -d mydb

   # MSSQL
   sqlcmd -S localhost -U sa -P YourPassword
   ```

---

### Issue 3: Migration Failed
**Error:** `Migration failed: syntax error near ...`

**Solution:**
1. Check migration file syntax
2. Verify database type matches (PostgreSQL syntax ≠ MSSQL syntax)
3. Run migration with verbose logging:
   ```bash
   flyway migrate -X  # Verbose mode
   ```

---

### Issue 4: Slow Queries
**Error:** Queries taking >1 second

**Solution:**
```bash
# Agent analyzes and suggests indexes
database-analyze-queries

Output:
  ⚠️  Slow query detected:
    SELECT * FROM orders WHERE user_id = 123
    Average time: 1,250ms

  Suggestion:
    CREATE INDEX idx_orders_user_id ON orders(user_id);

  Apply this index? (y/n): y

  ✅ Index created. Expected improvement: 95% faster
```

---

### Issue 5: Backup Failed
**Error:** `Permission denied` when creating backup

**Solution:**
```bash
# Ensure backup directory exists and is writable
mkdir -p ./backups
chmod 755 ./backups

# Or update BACKUP_DIR in .env
BACKUP_DIR=/var/backups/myapp
```

---

## Database Agent Commands

**Setup:**
```bash
database-init                # Initialize database connection
database-test                # Test database connection
database-detect-driver       # Detect and install missing drivers
```

**Migrations:**
```bash
database-migrate             # Run pending migrations
database-migrate-status      # Show migration status
database-migrate-rollback    # Rollback last migration
database-migrate-generate    # Generate migration from schema diff
```

**Backups:**
```bash
database-backup              # Create backup now
database-restore <file>      # Restore from backup file
database-backup-schedule     # Show scheduled backup cron job
database-backup-list         # List all backup files
```

**Performance:**
```bash
database-analyze-queries     # Analyze slow queries
database-suggest-indexes     # Suggest missing indexes
database-vacuum              # Vacuum/optimize tables (PostgreSQL/MySQL)
database-stats               # Show database statistics
```

**Monitoring:**
```bash
database-monitor             # Start real-time monitoring
database-connections         # Show active connections
database-locks               # Show active locks
database-size                # Show database/table sizes
```

---

## Customization

**For Company-Specific Database Setups:**

Edit this template to add:
- Custom connection pool sizes
- Company-specific backup retention policies
- Additional migration tools (e.g., custom scripts)
- Database-specific extensions

**Example:**
```markdown
## {{COMPANY_NAME}} Database Standards

Connection Pool:
- Min: 5 (not 2)
- Max: 50 (not 10)

Backups:
- Frequency: Every 6 hours (not daily)
- Retention: 90 days (not 30 days)
- Storage: AWS S3 (not local disk)

Migrations:
- Tool: Liquibase (not Flyway)
- Format: YAML (not SQL)
```

---

## Support

**Questions or Issues?**
- Documentation: https://quadframe.work/docs/agents/database
- GitHub Issues: https://github.com/a2vibecreators/quadframework/issues
- Email: support@quadframe.work

---

**Generated by QUAD Platform**
**Last Updated:** December 31, 2025
