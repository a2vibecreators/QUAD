# QUAD Framework - Cloudflare Integration

**Version:** 1.0.0
**Last Updated:** January 2, 2026
**Purpose:** Domain setup, DNS management, and CDN configuration via Cloudflare API

---

## Overview

QUAD integrates with Cloudflare to provide:
- **Domain Operations**: Purchase, transfer, and configure custom domains
- **DNS Management**: Automatic DNS record configuration for QUAD environments
- **SSL/TLS**: Automatic certificate provisioning and renewal
- **CDN & Caching**: Performance optimization for deployed applications
- **DDoS Protection**: Enterprise-grade security for all deployments

---

## QUAD Stage Alignment

| Stage | Cloudflare Feature | Use Case |
|-------|-------------------|----------|
| **Q (Question)** | Domain Search | Check domain availability during Domain setup |
| **U (Understand)** | DNS Analytics | Understand traffic patterns and DNS health |
| **A (Allocate)** | Zone Configuration | Allocate environments (DEV, QA, PROD) |
| **D (Deliver)** | CDN Purge | Clear cache on new deployments |

---

## Tier Availability

| Feature | SCALAR | VECTOR | MATRIX |
|---------|--------|--------|--------|
| Domain Search | ✅ | ✅ | ✅ |
| DNS Record Management | ✅ | ✅ | ✅ |
| SSL Certificates | ✅ | ✅ | ✅ |
| CDN Cache Purge | ❌ | ✅ | ✅ |
| Custom Page Rules | ❌ | ✅ | ✅ |
| Advanced Analytics | ❌ | ❌ | ✅ |
| Load Balancing | ❌ | ❌ | ✅ |
| Bot Management | ❌ | ❌ | ✅ |

---

## Authentication

### API Token Setup

1. **Create Cloudflare API Token:**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
   - Click "Create Token"
   - Use template: "Edit zone DNS"
   - Add permissions:
     - Zone: Read, DNS: Edit
     - Zone: Read (for domain search)
   - Restrict to specific zones or account-wide

2. **Store in QUAD:**
   - Go to Domain Settings → Cloudflare Integration
   - Enter API Token
   - QUAD stores encrypted in `QUAD_validated_credentials` table

### Required Permissions

| Permission | Scope | Purpose |
|------------|-------|---------|
| Zone:Read | Account | List and search domains |
| Zone:Edit | Account | Create/modify zones |
| DNS:Read | Zone | Read DNS records |
| DNS:Edit | Zone | Create/update DNS records |
| SSL:Read | Zone | Check certificate status |
| Cache:Purge | Zone | Clear CDN cache on deploy |

---

## API Endpoints (QUAD Nexus)

### Domain Operations

| Method | Endpoint | Tier | Description |
|--------|----------|------|-------------|
| GET | `/api/domains/search` | ALL | Search domain availability |
| POST | `/api/domains/register` | ALL | Register new domain |
| GET | `/api/domains/{id}/dns` | ALL | List DNS records |
| POST | `/api/domains/{id}/dns` | ALL | Create DNS record |
| PUT | `/api/domains/{id}/dns/{recordId}` | ALL | Update DNS record |
| DELETE | `/api/domains/{id}/dns/{recordId}` | ALL | Delete DNS record |

### SSL/TLS

| Method | Endpoint | Tier | Description |
|--------|----------|------|-------------|
| GET | `/api/domains/{id}/ssl` | ALL | Get SSL status |
| POST | `/api/domains/{id}/ssl/verify` | ALL | Verify SSL provisioning |
| PUT | `/api/domains/{id}/ssl/mode` | VECTOR+ | Set SSL mode (flexible/full/strict) |

### CDN & Performance

| Method | Endpoint | Tier | Description |
|--------|----------|------|-------------|
| POST | `/api/domains/{id}/cache/purge` | VECTOR+ | Purge entire cache |
| POST | `/api/domains/{id}/cache/purge/files` | VECTOR+ | Purge specific files |
| GET | `/api/domains/{id}/analytics` | MATRIX | Traffic analytics |
| POST | `/api/domains/{id}/page-rules` | MATRIX | Create page rules |

---

## Automatic DNS Configuration

When a Domain connects a custom domain, QUAD automatically configures:

### Default Records

```dns
# Root domain → QUAD load balancer
@       A       <QUAD_LB_IP>        ; Proxied via Cloudflare

# WWW redirect
www     CNAME   @                    ; Proxied via Cloudflare

# Environment subdomains
dev     A       <QUAD_DEV_IP>        ; DEV environment
qa      A       <QUAD_QA_IP>         ; QA environment
staging A       <QUAD_STAGING_IP>    ; Staging environment

# API subdomain
api     A       <QUAD_API_IP>        ; API endpoint

# MX records for email (if using Cloudflare Email Routing)
@       MX      route1.mx.cloudflare.net   ; Priority 10
@       MX      route2.mx.cloudflare.net   ; Priority 20
```

### Environment-Specific Subdomains

QUAD uses the pattern: `{region}{env}.{domain}`

| Environment | Pattern | Example |
|-------------|---------|---------|
| Production | `@` (root) | `quadframe.work` |
| QA | `qa` | `qa.quadframe.work` |
| DEV | `dev` | `dev.quadframe.work` |
| API (Prod) | `api` | `api.quadframe.work` |
| API (QA) | `usqa-api` | `usqa-api.quadframe.work` |

---

## SSL/TLS Configuration

### Supported Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **Off** | No encryption | Never recommended |
| **Flexible** | Cloudflare → Origin HTTP | Legacy systems (SCALAR) |
| **Full** | Cloudflare → Origin HTTPS (any cert) | Self-signed certs |
| **Full (Strict)** | Cloudflare → Origin HTTPS (valid cert) | Production (VECTOR+) |

### Automatic Certificate Management

1. **Universal SSL** (included free)
   - Covers `*.domain.com` and `domain.com`
   - Auto-renewed by Cloudflare
   - Single-level subdomains only

2. **Advanced Certificate Manager** (MATRIX tier)
   - Multi-level wildcards: `*.*.domain.com`
   - Custom hostnames
   - Dedicated certificates

---

## Deployment Integration

### Cache Purge on Deploy

When a Flow is delivered (deployed), QUAD automatically:

```json
{
  "event": "deployment_complete",
  "actions": [
    {
      "type": "cloudflare_cache_purge",
      "target": "all",
      "zone_id": "{{CLOUDFLARE_ZONE_ID}}"
    }
  ]
}
```

### Selective Purge (Recommended)

For large sites, purge only changed files:

```json
{
  "event": "deployment_complete",
  "actions": [
    {
      "type": "cloudflare_cache_purge",
      "target": "files",
      "files": [
        "https://example.com/index.html",
        "https://example.com/css/main.css",
        "https://example.com/js/app.js"
      ]
    }
  ]
}
```

---

## Page Rules (VECTOR+ Tier)

### Common Rules

**1. Force HTTPS**
```
Pattern: http://*example.com/*
Action: Always Use HTTPS
```

**2. Cache Everything (Static Site)**
```
Pattern: *example.com/*.html
Action: Cache Level = Cache Everything
Edge Cache TTL = 1 month
```

**3. Bypass Cache for API**
```
Pattern: *api.example.com/*
Action: Cache Level = Bypass
```

**4. Redirect WWW to Root**
```
Pattern: www.example.com/*
Action: Forwarding URL (301)
Destination: https://example.com/$1
```

---

## Security Configuration

### DDoS Protection

All QUAD deployments receive:
- Layer 3/4 DDoS mitigation (automatic)
- Layer 7 protection (HTTP flood)
- Rate limiting (MATRIX tier)

### Bot Management (MATRIX Tier)

```json
{
  "mode": "challenge",
  "sensitivity": "medium",
  "whitelist": [
    "googlebot",
    "bingbot",
    "quad-health-check"
  ]
}
```

### WAF Rules (MATRIX Tier)

QUAD configures recommended WAF rules:
- OWASP Core Ruleset
- SQLi/XSS protection
- Path traversal prevention

---

## Database Tables

### QUAD_domain_operations

Tracks domain purchase and configuration:

```prisma
model QUAD_domain_operations {
  id                String   @id @default(uuid())
  domain_id         String
  operation_type    String   // purchase, transfer, configure_dns
  cloudflare_zone_id String?
  status            String   // pending, in_progress, completed, failed
  dns_records       Json?    // Configured DNS records
  ssl_status        String?  // pending, active, expired
  created_at        DateTime @default(now())
  updated_at        DateTime @updatedAt
}
```

### QUAD_integration_health_checks

Monitors Cloudflare API connectivity:

```prisma
model QUAD_integration_health_checks {
  id                String   @id @default(uuid())
  integration_type  String   // cloudflare
  status            String   // healthy, degraded, down
  last_check_at     DateTime
  response_time_ms  Int
  error_message     String?
  next_check_at     DateTime
}
```

---

## Example: Complete Domain Setup Flow

### 1. Domain Search

```bash
curl -X GET "https://api.quadframe.work/api/domains/search?name=mycompany" \
  -H "Authorization: Bearer $QUAD_TOKEN"
```

**Response:**
```json
{
  "available": [
    { "domain": "mycompany.com", "price": 12.99 },
    { "domain": "mycompany.dev", "price": 14.99 },
    { "domain": "mycompany.io", "price": 39.99 }
  ],
  "taken": ["mycompany.org", "mycompany.net"]
}
```

### 2. Register Domain

```bash
curl -X POST "https://api.quadframe.work/api/domains/register" \
  -H "Authorization: Bearer $QUAD_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "domain": "mycompany.dev",
    "auto_configure": true
  }'
```

**Response:**
```json
{
  "id": "uuid",
  "domain": "mycompany.dev",
  "status": "pending_verification",
  "cloudflare_zone_id": "abc123",
  "auto_configured_records": [
    { "type": "A", "name": "@", "content": "1.2.3.4" },
    { "type": "CNAME", "name": "www", "content": "@" },
    { "type": "A", "name": "dev", "content": "1.2.3.5" }
  ],
  "ssl_status": "pending",
  "quad_insight": "Domain registered. SSL will be active in ~15 minutes."
}
```

### 3. Verify SSL Status

```bash
curl -X GET "https://api.quadframe.work/api/domains/{id}/ssl" \
  -H "Authorization: Bearer $QUAD_TOKEN"
```

**Response:**
```json
{
  "ssl_status": "active",
  "certificate_type": "universal",
  "issuer": "Cloudflare Inc",
  "valid_from": "2026-01-02",
  "valid_to": "2026-04-02",
  "auto_renew": true
}
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| SSL not active | DNS not propagated | Wait 24-48 hours, check with `dig` |
| 522 Error | Origin not reachable | Check QUAD server is running |
| 524 Error | Origin timeout | Increase timeout or check server load |
| DNS not resolving | Nameservers not updated | Update nameservers at registrar |

### Health Check Endpoint

```bash
curl -X GET "https://api.quadframe.work/api/health/cloudflare"
```

**Response:**
```json
{
  "status": "healthy",
  "api_response_time_ms": 145,
  "zones_count": 3,
  "last_cache_purge": "2026-01-02T10:30:00Z"
}
```

---

## Security Considerations

1. **API Token Security**
   - Use scoped tokens (not Global API Key)
   - Rotate tokens quarterly
   - Store in QUAD's encrypted credential vault

2. **Zone Lockdown**
   - Enable Zone Lockdown for sensitive paths
   - Whitelist QUAD health check IPs

3. **Audit Logging**
   - All Cloudflare API calls logged in `QUAD_api_request_logs`
   - Accessible to MATRIX tier via Nexus

---

## Related Documentation

- [Multi-Tenant Domain Setup](../MULTI_TENANT_DOMAIN_SETUP.md)
- [SSO Setup Guide](./SSO_SETUP_GUIDE.md)
- [Tool Integration Methods](./TOOL_INTEGRATION_METHODS.md)

---

**Generated by QUAD Framework**
**Last Updated:** January 2, 2026
