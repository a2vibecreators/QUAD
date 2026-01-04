# Schema Naming Convention Detection

**Version:** 1.0
**Created:** January 4, 2026
**Status:** Designed (Phase 2 Implementation)
**Category:** Project Onboarding / Import

---

## Problem Statement

When importing an existing project into QUAD, we need to understand its database schema naming conventions. Many legacy projects have inconsistent naming:

- 80% tables use `snake_case`
- 20% use `PascalCase` or `camelCase`
- Some have prefixes (`tbl_`, `t_`), others don't
- Column naming might differ from table naming

**User Impact:** Without detection, QUAD might generate code that doesn't match the project's style, causing confusion.

---

## Solution: Naming Convention Analyzer

### Detection Algorithm

```
┌─────────────────────────────────────────────────────────────────────┐
│                 SCHEMA NAMING CONVENTION ANALYZER                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   1. SCAN SCHEMA                                                     │
│      └── Read all table names, column names, index names            │
│                                                                      │
│   2. PATTERN DETECTION                                               │
│      ├── Table naming: snake_case / PascalCase / camelCase          │
│      ├── Prefix patterns: tbl_, t_, QUAD_, APP_                     │
│      ├── Suffix patterns: _tbl, _table, _entity                     │
│      ├── Column naming: snake_case / camelCase                      │
│      ├── FK naming: user_id / userId / fk_user                      │
│      └── PK naming: id / pk_id / tablename_id                       │
│                                                                      │
│   3. CALCULATE CONFIDENCE                                            │
│      ├── 90%+ match → HIGH confidence                               │
│      ├── 70-89% match → MEDIUM confidence                           │
│      ├── 50-69% match → LOW confidence                              │
│      └── <50% match → INCONSISTENT (no dominant pattern)            │
│                                                                      │
│   4. PRESENT OPTIONS TO USER                                         │
│      ├── Option A: Use detected pattern (if HIGH/MEDIUM)            │
│      ├── Option B: Use QUAD naming convention                       │
│      └── Option C: Custom (user defines rules)                      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Naming Pattern Categories

### Table Naming Patterns

| Pattern | Example | Detection Regex |
|---------|---------|-----------------|
| `snake_case` | `user_profiles` | `^[a-z][a-z0-9]*(_[a-z0-9]+)*$` |
| `PascalCase` | `UserProfiles` | `^[A-Z][a-zA-Z0-9]*$` |
| `camelCase` | `userProfiles` | `^[a-z][a-zA-Z0-9]*$` |
| `SCREAMING_SNAKE` | `USER_PROFILES` | `^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$` |
| `prefixed_snake` | `tbl_user_profiles` | `^[a-z]+_[a-z][a-z0-9_]*$` |

### Column Naming Patterns

| Pattern | Example | Common In |
|---------|---------|-----------|
| `snake_case` | `created_at` | PostgreSQL, Python/Django |
| `camelCase` | `createdAt` | JavaScript, TypeScript |
| `PascalCase` | `CreatedAt` | C#, .NET |

### Foreign Key Patterns

| Pattern | Example | Description |
|---------|---------|-------------|
| `entity_id` | `user_id` | Standard snake_case |
| `entityId` | `userId` | CamelCase style |
| `fk_entity` | `fk_user` | Explicit FK prefix |
| `entity_fk` | `user_fk` | FK suffix |

---

## Confidence Levels & UI Display

### HIGH Confidence (90%+)

```
┌─────────────────────────────────────────────────────────────┐
│  ✅ Naming Convention Detected: snake_case                  │
│                                                              │
│  Analysis:                                                   │
│  • 47/50 tables (94%) use snake_case                        │
│  • 3 tables use different patterns (likely legacy)          │
│                                                              │
│  Recommendation: Use detected pattern                        │
│                                                              │
│  [ Use snake_case ]  [ Use QUAD naming ]  [ Customize ]     │
└─────────────────────────────────────────────────────────────┘
```

### MEDIUM Confidence (70-89%)

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️ Naming Convention: Mostly snake_case                    │
│                                                              │
│  Analysis:                                                   │
│  • 38/50 tables (76%) use snake_case                        │
│  • 12 tables use PascalCase (older modules?)                │
│                                                              │
│  Inconsistent tables:                                        │
│  • UserAccounts (module: auth)                              │
│  • PaymentTransactions (module: billing)                    │
│  • ...8 more                                                 │
│                                                              │
│  [ Use snake_case ]  [ Use QUAD naming ]  [ Customize ]     │
└─────────────────────────────────────────────────────────────┘
```

### LOW Confidence (50-69%)

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️ Mixed Naming Conventions Detected                       │
│                                                              │
│  Analysis:                                                   │
│  • 30/50 tables (60%) use snake_case                        │
│  • 15/50 tables (30%) use PascalCase                        │
│  • 5/50 tables (10%) use camelCase                          │
│                                                              │
│  This schema has inconsistent naming.                        │
│  We recommend standardizing with QUAD naming.                │
│                                                              │
│  [ Use Most Common (snake_case) ]  [ Use QUAD naming ]      │
└─────────────────────────────────────────────────────────────┘
```

### INCONSISTENT (<50%)

```
┌─────────────────────────────────────────────────────────────┐
│  ❌ No Dominant Naming Convention                            │
│                                                              │
│  Analysis:                                                   │
│  • 20/50 tables (40%) use snake_case                        │
│  • 18/50 tables (36%) use PascalCase                        │
│  • 12/50 tables (24%) use camelCase                         │
│                                                              │
│  This schema has no consistent pattern.                      │
│  Options:                                                    │
│                                                              │
│  [ Use QUAD naming (Recommended) ]                           │
│  [ Pick one: snake_case | PascalCase | camelCase ]          │
│  [ Define custom rules ]                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Table: QUAD_schema_analysis

Store the analysis results for reference:

```sql
CREATE TABLE QUAD_schema_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES QUAD_domains(id) ON DELETE CASCADE,

    -- Analysis results
    total_tables INTEGER NOT NULL,
    total_columns INTEGER NOT NULL,

    -- Table naming breakdown
    table_snake_case_count INTEGER DEFAULT 0,
    table_pascal_case_count INTEGER DEFAULT 0,
    table_camel_case_count INTEGER DEFAULT 0,
    table_other_count INTEGER DEFAULT 0,
    table_dominant_pattern VARCHAR(30),      -- 'snake_case', 'PascalCase', etc.
    table_confidence VARCHAR(20),            -- 'HIGH', 'MEDIUM', 'LOW', 'INCONSISTENT'
    table_confidence_pct DECIMAL(5,2),       -- 94.00

    -- Column naming breakdown
    column_snake_case_count INTEGER DEFAULT 0,
    column_camel_case_count INTEGER DEFAULT 0,
    column_pascal_case_count INTEGER DEFAULT 0,
    column_dominant_pattern VARCHAR(30),
    column_confidence VARCHAR(20),
    column_confidence_pct DECIMAL(5,2),

    -- Prefix/suffix detection
    detected_prefix VARCHAR(20),             -- 'tbl_', 'QUAD_', etc.
    prefix_usage_pct DECIMAL(5,2),
    detected_suffix VARCHAR(20),
    suffix_usage_pct DECIMAL(5,2),

    -- User decision
    chosen_convention VARCHAR(30),           -- What user picked
    chosen_at TIMESTAMP WITH TIME ZONE,
    chosen_by UUID REFERENCES QUAD_users(id),

    -- Exceptions (tables that don't follow chosen convention)
    exception_tables JSONB,                  -- [{"table": "UserAccounts", "pattern": "PascalCase"}]

    -- Metadata
    analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    analysis_version VARCHAR(10) DEFAULT '1.0',

    CONSTRAINT valid_table_confidence CHECK (table_confidence IN ('HIGH', 'MEDIUM', 'LOW', 'INCONSISTENT')),
    CONSTRAINT valid_column_confidence CHECK (column_confidence IN ('HIGH', 'MEDIUM', 'LOW', 'INCONSISTENT'))
);

CREATE INDEX idx_schema_analysis_domain ON QUAD_schema_analysis(domain_id);
```

---

## API Endpoints

### Analyze Schema

```
POST /api/domains/{domainId}/schema/analyze
```

**Request:**
```json
{
  "connectionString": "postgresql://...",  // or use saved connection
  "connectionId": "uuid",                  // if using saved DB connection
  "includeViews": false,
  "excludePatterns": ["pg_*", "information_schema.*"]
}
```

**Response:**
```json
{
  "analysisId": "uuid",
  "totalTables": 50,
  "totalColumns": 342,
  "tableNaming": {
    "dominantPattern": "snake_case",
    "confidence": "HIGH",
    "confidencePct": 94.0,
    "breakdown": {
      "snake_case": 47,
      "PascalCase": 3,
      "camelCase": 0
    },
    "exceptions": [
      {"table": "UserAccounts", "detectedPattern": "PascalCase"},
      {"table": "PaymentLog", "detectedPattern": "PascalCase"},
      {"table": "AuditTrail", "detectedPattern": "PascalCase"}
    ]
  },
  "columnNaming": {
    "dominantPattern": "snake_case",
    "confidence": "HIGH",
    "confidencePct": 98.0
  },
  "prefixDetected": null,
  "suffixDetected": null,
  "recommendations": [
    {
      "option": "USE_DETECTED",
      "label": "Use snake_case (matches 94% of tables)",
      "isRecommended": true
    },
    {
      "option": "USE_QUAD",
      "label": "Use QUAD naming convention",
      "isRecommended": false
    },
    {
      "option": "CUSTOM",
      "label": "Define custom rules",
      "isRecommended": false
    }
  ]
}
```

### Apply Convention Choice

```
POST /api/domains/{domainId}/schema/convention
```

**Request:**
```json
{
  "analysisId": "uuid",
  "chosenConvention": "USE_DETECTED",  // or "USE_QUAD" or "CUSTOM"
  "customRules": null  // only if CUSTOM
}
```

---

## Code Generation Impact

Once convention is chosen, QUAD uses it for:

| Generated Artifact | Convention Applied To |
|-------------------|----------------------|
| Entity classes | Class names, property names |
| Repository interfaces | Method naming |
| API DTOs | Field naming |
| Migration scripts | Table/column names |
| Test fixtures | Variable naming |

### Example: snake_case Convention

```java
// Entity generated with snake_case awareness
@Entity
@Table(name = "user_profiles")  // matches existing
public class UserProfile {

    @Column(name = "created_at")  // matches existing
    private LocalDateTime createdAt;

    @Column(name = "display_name")
    private String displayName;
}
```

### Example: QUAD Convention Override

```java
// If user chose QUAD naming for new tables
@Entity
@Table(name = "QUAD_user_metrics")  // new QUAD table
public class UserMetrics {

    @Column(name = "metric_value")
    private BigDecimal metricValue;
}
```

---

## Edge Cases

### 1. Empty Schema (New Project)
```
No tables found. Using QUAD naming convention by default.
```

### 2. Very Small Schema (<5 tables)
```
Only 3 tables found. Confidence: LOW (sample too small).
Recommend: Use QUAD naming or wait until more tables exist.
```

### 3. Multi-Schema Database
```
Multiple schemas detected:
• public: 40 tables (snake_case, HIGH confidence)
• legacy: 20 tables (PascalCase, HIGH confidence)
• staging: 5 tables (mixed, LOW confidence)

Analyze each schema separately? [Yes] [No, analyze all together]
```

### 4. Reserved/System Tables
```
Excluding system tables from analysis:
• pg_* (PostgreSQL system)
• information_schema.* (metadata)
• QUAD_* (QUAD framework - if importing into existing QUAD)
```

---

## Implementation Priority

| Priority | Feature | Notes |
|----------|---------|-------|
| P1 | Basic detection (snake/Pascal/camel) | Core algorithm |
| P1 | Confidence calculation | Threshold logic |
| P1 | UI display with options | User choice flow |
| P2 | Prefix/suffix detection | tbl_, _id patterns |
| P2 | Store analysis results | QUAD_schema_analysis table |
| P3 | Multi-schema support | Per-schema analysis |
| P3 | Historical tracking | Compare before/after |

---

## Related Documents

- [DATABASE_ARCHITECTURE.md](../database/DATABASE_ARCHITECTURE.md) - QUAD naming conventions
- [DISCUSSIONS_LOG.md](../internal/DISCUSSIONS_LOG.md) - Architecture decisions
- [MESSENGER_CHANNEL_ARCHITECTURE.md](../architecture/MESSENGER_CHANNEL_ARCHITECTURE.md) - Similar pattern for channel abstraction

---

**Summary:** When importing existing projects, QUAD analyzes schema naming patterns, shows confidence level, and lets users choose between detected convention, QUAD convention, or custom rules. This ensures generated code matches the project's existing style.
