# Database Agent - Universal Database Copy & Anonymization

## Vision
Fast, flexible database-to-database copy with optional anonymization and filtering.
**Any DB → Any DB** in the fastest way possible.

## Supported Databases

| Database | Source | Target | Notes |
|----------|--------|--------|-------|
| PostgreSQL | ✅ | ✅ | Primary support, COPY command for speed |
| MySQL | ✅ | ✅ | LOAD DATA INFILE for bulk inserts |
| SQL Server | ✅ | ✅ | BCP utility, BULK INSERT |
| Oracle | ✅ | ✅ | SQL*Loader, Direct Path |
| MongoDB | ✅ | ✅ | mongodump/mongorestore |
| SQLite | ✅ | ✅ | For dev/testing |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE AGENT                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   SOURCE    │    │   PIPELINE  │    │   TARGET    │         │
│  │   DATABASE  │───▶│             │───▶│   DATABASE  │         │
│  └─────────────┘    │  • Extract  │    └─────────────┘         │
│                     │  • Transform│                              │
│  PostgreSQL         │  • Anonymize│    PostgreSQL               │
│  MySQL              │  • Filter   │    MySQL                    │
│  SQL Server         │  • Load     │    SQL Server               │
│  Oracle             │             │    Oracle                   │
│  MongoDB            └─────────────┘    MongoDB                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Speed Optimizations

### 1. Parallel Extraction & Loading
- Partition large tables by ID ranges
- Process multiple tables simultaneously
- Configurable worker count (default: 4)

### 2. Streaming Transfer
- Don't load entire table into memory
- Stream rows from source → transform → target
- Use cursor-based pagination

### 3. Bulk Operations
| Database | Bulk Method | Speed Gain |
|----------|-------------|------------|
| PostgreSQL | COPY FROM/TO | 10-50x |
| MySQL | LOAD DATA INFILE | 20x |
| SQL Server | BULK INSERT | 15x |
| Oracle | SQL*Loader | 25x |

### 4. Disable Constraints During Load
- DROP/DISABLE indexes
- DISABLE foreign keys
- DISABLE triggers
- Re-enable after load

## Operation Types

### 1. Full Copy (`copy_full`)
Copy entire tables from source to target.
```json
{
  "operation_type": "copy_full",
  "source_env": "PROD",
  "target_env": "DEV",
  "tables": ["users", "orders", "products"],
  "anonymize": true,
  "parallel_workers": 4
}
```

### 2. Filtered Copy (`copy_filtered`)
Copy subset of data using SQL WHERE clause.
```json
{
  "operation_type": "copy_filtered",
  "source_env": "PROD",
  "target_env": "DEV",
  "tables": {
    "users": "created_at > '2024-01-01'",
    "orders": "user_id IN (SELECT id FROM users WHERE ...)",
    "products": null  // Copy all
  },
  "anonymize": true
}
```

### 3. Schema Sync (`sync_schema`)
Copy schema only, no data.
```json
{
  "operation_type": "sync_schema",
  "source_env": "PROD",
  "target_env": "DEV",
  "tables": ["*"],  // All tables
  "include_indexes": true,
  "include_constraints": true
}
```

### 4. Sample Generation (`generate_sample`)
AI-generate realistic test data based on project context.
```json
{
  "operation_type": "generate_sample",
  "target_env": "DEV",
  "context": "E-commerce platform selling electronics",
  "config": {
    "users": 10000,
    "orders": 50000,
    "products": 500,
    "locale": "en_US"
  }
}
```

## Anonymization Strategies

| Strategy | Example Input | Example Output | Use Case |
|----------|---------------|----------------|----------|
| `hash` | john@email.com | a3f2b1c4d5... | Need consistent FK |
| `faker` | john@email.com | mike@fake.com | Realistic testing |
| `mask` | john@email.com | j***@***.com | Show format |
| `null` | john@email.com | NULL | Remove entirely |
| `scramble` | John Smith | Htoj Msiht | Preserve length |
| `tokenize` | 4111-1111-1111 | tok_abc123 | PCI compliance |

### Default PII Detection
Automatically detect common PII columns:
- `email`, `e_mail`, `email_address`
- `name`, `full_name`, `first_name`, `last_name`
- `phone`, `phone_number`, `mobile`
- `ssn`, `social_security`
- `address`, `street`, `city`, `zip`, `postal`
- `dob`, `date_of_birth`, `birth_date`
- `card_number`, `credit_card`, `ccn`

## API Endpoints

### Create Operation
```bash
POST /api/database-operations
{
  "domain_id": "uuid",
  "operation_type": "copy_full",
  "source_env": "PROD",
  "target_env": "DEV",
  "tables": ["users", "orders"],
  "anonymize": true,
  "filter": {
    "users": "status = 'active'"
  },
  "parallel_workers": 4,
  "required_approvers": ["DBA", "DATA_OWNER"]
}
```

### Approve Operation
```bash
PATCH /api/database-operations/{id}
{
  "action": "approve",
  "approver_role": "DBA",
  "comments": "Approved for Q4 testing"
}
```

### Execute Operation
```bash
PATCH /api/database-operations/{id}
{
  "action": "execute"
}
```

### Check Progress
```bash
GET /api/database-operations/{id}/progress
{
  "status": "in_progress",
  "tables_completed": 3,
  "tables_total": 5,
  "rows_copied": 150000,
  "rows_total": 250000,
  "current_table": "orders",
  "eta_seconds": 120
}
```

## Multi-Stakeholder Approval

For PROD → DEV operations, require approval from:

| Role | Responsibility |
|------|----------------|
| DBA | Verify target DB capacity, timing |
| DATA_OWNER | Authorize data access |
| SECURITY | Verify anonymization rules |
| MANAGER | Business approval |

Approval workflow:
1. User creates copy operation
2. System notifies approvers (Slack/email)
3. Each approver reviews and approves/rejects
4. When all approve → ready to execute
5. User clicks "Execute" or schedules for off-hours

## Security Features

1. **Vault Integration**: Passwords stored in Vaultwarden, only paths in DB
2. **Audit Log**: Every operation logged with who, what, when
3. **IP Allowlist**: Restrict which IPs can connect to databases
4. **Encryption in Transit**: SSL/TLS for all connections
5. **No Data in Logs**: Anonymized data never logged

## Example Workflow

### Scenario: Refresh DEV with PROD data

1. **BA creates request**:
   - "Need fresh PROD-like data in DEV for testing"
   - Selects tables: users, orders, products
   - Enables anonymization

2. **System detects PII**:
   - users.email → faker
   - users.phone → mask
   - users.ssn → null
   - orders.credit_card → tokenize

3. **Approval requests sent**:
   - DBA: Reviews capacity
   - Data Owner: Approves data access
   - Security: Verifies anonymization

4. **All approve → Execute**:
   - 10:00 PM: Job starts (off-peak)
   - 10:05 PM: Schema synced
   - 10:10 PM: users table (50K rows) - 30 sec
   - 10:15 PM: orders table (200K rows) - 2 min
   - 10:20 PM: Complete

5. **Notification**: "DEV refreshed with 250K rows, all PII anonymized"

## Schema Changes Needed

```prisma
// Enhanced database_operations
model QUAD_database_operations {
  // ... existing fields ...

  // New fields for flexibility
  filter_conditions Json?     // { "table": "WHERE clause" }
  parallel_workers  Int @default(4)
  disable_constraints Boolean @default(true)

  // Progress tracking
  tables_completed  Int @default(0)
  tables_total      Int @default(0)
  rows_copied       BigInt @default(0)
  rows_total        BigInt?
  current_table     String?
  bytes_transferred BigInt @default(0)

  // Scheduling
  scheduled_at      DateTime?

  // Cross-database mapping
  column_mappings   Json?     // For type conversions between DBs
}
```

## Future Enhancements

1. **Incremental Copy**: Only copy rows changed since last sync (CDC)
2. **Data Masking API**: Real-time masking for read replicas
3. **Schema Migration**: Automatic ALTER TABLE generation
4. **Data Validation**: Row counts, checksums, sample verification
5. **Rollback**: Snapshot before copy, restore on failure
