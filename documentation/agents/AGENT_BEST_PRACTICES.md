# Agent Best Practices & Guidelines

**Version:** 1.0
**Last Updated:** January 8, 2026
**Scope:** All QUAD Platform Agents (Server-side) and Developer Agents (Client-side)

---

## Overview

This document establishes industry-standard guidelines for AI agents operating within QUAD Platform and on developer machines. These rules ensure security, reliability, performance, and maintainability across all agent implementations.

---

## 1. Security Guidelines

### 1.1 Authentication & Credentials

**✅ DO:**
- Use OAuth 2.0 for integrations requiring user credentials (GitHub, Jira, Slack, etc.)
- Rotate API keys every 90 days minimum
- Store secrets in secure vaults (Vaultwarden, HashiCorp Vault, AWS Secrets Manager)
- Use service account tokens for org-level operations (never personal tokens)
- Implement token expiration and refresh logic
- Log credential usage (without exposing secrets) for audit trails

**❌ DON'T:**
- Hardcode API keys, tokens, or passwords in code
- Store credentials in environment variables on the client machine
- Share service account credentials across environments (dev/qa/prod)
- Use personal user tokens for agent operations
- Log full credentials or sensitive data
- Store credentials in version control (git)
- Use basic auth when OAuth is available

**Example (✅ CORRECT):**
```typescript
// Fetch secret from secure vault
const apiKey = await vaultClient.getSecret('GITHUB_TOKEN');

// Use token with proper scoping
const githubClient = new GitHub({
  auth: apiKey,
  throttle: { onRateLimit: handleRateLimit }
});
```

### 1.2 Authorization & Permissions

**✅ DO:**
- Enforce principle of least privilege (agent gets minimum required permissions)
- Check user/org permissions before executing actions
- Validate webhook signatures and request origins
- Implement role-based access control (RBAC)
- Audit all agent actions with user context (who triggered, when, what was changed)
- Reject requests from unauthorized users/orgs immediately

**❌ DON'T:**
- Grant agents "admin" or "full access" permissions
- Execute actions without verifying user authorization
- Assume valid API key = valid authorization
- Bypass permission checks for "internal" operations
- Skip webhook signature verification
- Log user actions without associating org context

**Example (✅ CORRECT):**
```java
// Verify user has permission before agent action
public void generateCode(String userId, String orgId) {
    User user = userRepository.findById(userId);
    if (user == null || !user.getOrgId().equals(orgId)) {
        throw new UnauthorizedException("User not in this org");
    }

    // Log the action with full context
    auditLog.info("Agent action: Code generation by user {} in org {}", userId, orgId);

    // Proceed with action
    generateCodeForOrg(orgId);
}
```

### 1.3 Data Protection

**✅ DO:**
- Mask PII (emails, phone numbers, SSNs) in logs
- Encrypt data in transit (TLS 1.3+)
- Encrypt sensitive data at rest
- Never log production data in non-prod environments
- Implement data retention policies
- Delete old execution logs after 90 days
- Use read-only database access when appropriate

**❌ DON'T:**
- Log passwords, API keys, or tokens
- Send sensitive data over unencrypted channels
- Store PII longer than necessary
- Copy production data to non-prod without masking
- Log database query results containing PII
- Keep execution logs indefinitely

---

## 2. Context Management

### 2.1 Session & State

**✅ DO:**
- Store execution context in scoped variables (not global state)
- Use correlation IDs to track agent actions across logs
- Implement request timeout (set reasonable limits: API calls 30s, long-running 5m)
- Clear context after agent execution completes
- Serialize large objects before storing in memory
- Use immutable data structures where possible

**❌ DON'T:**
- Use global variables to store user/org context
- Keep sessions open indefinitely
- Store unlimited data in memory
- Assume context is valid across multiple requests
- Carry over context between different users/orgs
- Store raw API responses without parsing

**Example (✅ CORRECT):**
```typescript
async function executeAgent(userId: string, orgId: string) {
  const correlationId = generateUUID(); // Track this execution
  const context = {
    userId,
    orgId,
    correlationId,
    startTime: Date.now(),
    timeout: 30000 // 30 second timeout
  };

  try {
    logger.info(`[${correlationId}] Starting agent for user ${userId}`);
    const result = await agent.run(context);
    return result;
  } finally {
    logger.info(`[${correlationId}] Agent completed in ${Date.now() - context.startTime}ms`);
    // Clear context
    context = null;
  }
}
```

### 2.2 Dependency Injection

**✅ DO:**
- Inject dependencies (databases, APIs, services) rather than creating them in agents
- Use interfaces/abstractions for external services
- Make agents testable by allowing dependency mocking
- Pass configuration as constructor parameters

**❌ DON'T:**
- Create database connections inside agent methods
- Hardcode API endpoints
- Make agents tightly coupled to specific implementations
- Create singletons for stateful services
- Mix business logic with infrastructure concerns

---

## 3. Reliability & Error Handling

### 3.1 Retries & Resilience

**✅ DO:**
- Implement exponential backoff for failed API calls (1s, 2s, 4s, 8s)
- Retry transient errors (429, 503, timeouts) up to 3 times
- Log all retries with attempt count and reason
- Use circuit breaker pattern for failing external services
- Implement graceful degradation (fail safely, not catastrophically)
- Test failure scenarios

**❌ DON'T:**
- Retry indefinitely (set max attempts)
- Retry non-transient errors (400, 401, 403)
- Use the same retry delay every time (exponential backoff required)
- Treat all exceptions the same (distinguish transient vs permanent)
- Retry without logging
- Assume external API is always available

**Example (✅ CORRECT):**
```typescript
async function callExternalAPI(url: string, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fetch(url, { timeout: 30000 });
    } catch (error) {
      if (!isTransientError(error) || attempt === maxRetries) {
        logger.error(`API call failed: ${error.message}`);
        throw error;
      }

      const delay = Math.pow(2, attempt - 1) * 1000; // Exponential backoff
      logger.warn(`Retry ${attempt}/${maxRetries} after ${delay}ms`);
      await sleep(delay);
    }
  }
}
```

### 3.2 Validation & Input Sanitization

**✅ DO:**
- Validate all inputs at system boundaries (user input, API requests, webhooks)
- Reject oversized payloads (>10MB)
- Check required fields before processing
- Sanitize user input to prevent injection attacks
- Validate email, URL, and phone formats
- Type-check function parameters
- Use schema validation (JSON Schema, Zod, etc.)

**❌ DON'T:**
- Trust user input (validate everything)
- Accept unlimited payload sizes
- Process data without type checking
- Concatenate user input into SQL queries (use prepared statements)
- Skip validation for "internal" requests
- Assume valid format without checking

**Example (✅ CORRECT):**
```typescript
async function createTicketFromEmail(emailData: unknown) {
  // Validate input schema
  const schema = z.object({
    from: z.string().email(),
    to: z.string().email(),
    subject: z.string().min(1).max(200),
    body: z.string().max(10000),
  });

  const validated = schema.parse(emailData); // Throws if invalid

  // Sanitize content
  const sanitizedBody = sanitizeHtml(validated.body);

  // Process safe data
  return createTicket(validated, sanitizedBody);
}
```

### 3.3 Error Messages & Logging

**✅ DO:**
- Log errors with full context (user, org, correlation ID, timestamp)
- Provide user-friendly error messages (hide technical details)
- Include error codes for programmatic handling
- Log stack traces only in non-production environments
- Use structured logging (JSON format with consistent fields)
- Log both success and failure paths for critical operations

**❌ DON'T:**
- Expose internal error details to users
- Log sensitive data (passwords, tokens, PII)
- Use generic "Error occurred" messages
- Log without context (who, when, where)
- Ignore errors silently
- Mix success and error logging

**Example (✅ CORRECT):**
```typescript
try {
  const ticket = await createTicket(userId, orgId, data);
  logger.info({
    event: 'ticket_created',
    userId,
    orgId,
    ticketId: ticket.id,
    duration: Date.now() - startTime
  });
} catch (error) {
  logger.error({
    event: 'ticket_creation_failed',
    userId,
    orgId,
    errorCode: error.code,
    errorMessage: error.message, // Technical detail
    userMessage: 'Failed to create ticket. Please try again.', // User-friendly
    timestamp: new Date().toISOString()
  });

  throw new APIError('Failed to create ticket', 500);
}
```

---

## 4. Performance Guidelines

### 4.1 Timeouts & Rate Limiting

**✅ DO:**
- Set timeouts for all external API calls (default: 30 seconds)
- Implement rate limiting per user/org (e.g., 10 API calls/minute)
- Respect upstream API rate limits (check X-RateLimit headers)
- Queue long-running operations asynchronously
- Use caching for frequently accessed data (Redis, in-memory, etc.)
- Implement circuit breaker for failing services

**❌ DON'T:**
- Make API calls without timeouts (wait forever)
- Ignore rate limit headers from upstream APIs
- Run heavy computations on the request thread
- Make sequential API calls when parallel is possible
- Cache data indefinitely (set expiration)
- Make the same API call twice in quick succession

**Example (✅ CORRECT):**
```typescript
async function fetchUserData(userId: string) {
  // Check cache first
  const cached = await cache.get(`user:${userId}`);
  if (cached) return cached;

  // Fetch with timeout
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 30000);

  try {
    const response = await fetch(`/api/users/${userId}`, {
      signal: controller.signal,
      headers: { 'X-Request-ID': correlationId }
    });

    // Respect rate limits
    const rateLimitRemaining = response.headers.get('X-RateLimit-Remaining');
    if (rateLimitRemaining === '0') {
      await circuitBreaker.open();
    }

    const data = await response.json();

    // Cache for 5 minutes
    await cache.set(`user:${userId}`, data, { ttl: 300 });

    return data;
  } finally {
    clearTimeout(timeout);
  }
}
```

### 4.2 Async & Batch Operations

**✅ DO:**
- Use async/await for non-blocking operations
- Batch API requests when possible (GraphQL mutations, bulk endpoints)
- Process events asynchronously using job queues
- Implement pagination for large result sets
- Parallelize independent operations
- Monitor queue depth to prevent backups

**❌ DON'T:**
- Make sequential API calls (use parallel when safe)
- Process large datasets in a single request
- Block the request thread on I/O operations
- Ignore pagination (always fetch all available data)
- Process unbounded lists in memory
- Spawn unlimited worker threads

**Example (✅ CORRECT):**
```typescript
async function generateCodeForMultipleTickets(ticketIds: string[]) {
  // Batch into chunks of 10
  const chunks = chunkArray(ticketIds, 10);

  for (const chunk of chunks) {
    // Process chunk in parallel
    await Promise.all(
      chunk.map(ticketId => generateCodeForTicket(ticketId))
    );

    // Add delay between batches to avoid overwhelming system
    await sleep(1000);
  }
}
```

### 4.3 Monitoring & Observability

**✅ DO:**
- Emit metrics (execution time, success rate, queue depth)
- Implement distributed tracing (correlation IDs across service calls)
- Monitor error rates and alert on thresholds
- Track agent SLAs (e.g., 95th percentile response time < 5s)
- Create dashboards for agent health
- Log key decision points in agent logic

**❌ DON'T:**
- Deploy agents without monitoring
- Log every single operation (too noisy)
- Forget to instrument external API calls
- Assume agents are working without visibility
- Ignore performance degradation

---

## 5. Testing & Validation

### 5.1 Unit Testing

**✅ DO:**
- Test agents with mocked external dependencies
- Test success and failure paths
- Test edge cases (empty input, very large input, special characters)
- Test authorization checks
- Maintain >80% code coverage for agent logic
- Test error handling paths

**❌ DON'T:**
- Test agents by hitting real external APIs
- Skip error case testing
- Assume "happy path" always works
- Test with production credentials
- Write tests without assertions

### 5.2 Integration Testing

**✅ DO:**
- Use test fixtures for external services (test databases, mock APIs)
- Test agent integration with real services in staging environment
- Verify audit logs are created correctly
- Test with realistic data volumes
- Test rate limit handling

**❌ DON'T:**
- Run integration tests against production
- Test with real user data
- Skip rate limit testing

---

## 6. Deployment & Updates

### 6.1 Version Management

**✅ DO:**
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Document breaking changes in changelog
- Deprecate features 2 versions before removing
- Test new versions in staging before production
- Maintain backward compatibility when possible

**❌ DON'T:**
- Deploy untested code to production
- Remove features without warning
- Skip documentation for breaking changes

### 6.2 Rollback & Recovery

**✅ DO:**
- Keep previous agent versions available for quick rollback
- Implement health checks to detect agent failures
- Auto-rollback on repeated failures
- Test rollback procedures regularly
- Document recovery procedures

**❌ DON'T:**
- Deploy without rollback plan
- Assume rollback will always work
- Forget to test rollback process

---

## 7. Compliance & Auditing

### 7.1 Audit Trails

**✅ DO:**
- Log every agent action with user, org, timestamp, details
- Make logs immutable (append-only)
- Retain logs for minimum 1 year
- Implement log retention policies based on log type
- Provide audit log API for compliance reporting
- Include context (why the action was triggered)

**❌ DON'T:**
- Delete or modify logs
- Log without sufficient detail
- Store logs in easily-modified databases
- Forget correlation IDs in logs
- Log PII that needs to be forgotten

### 7.2 Compliance Requirements

**✅ DO:**
- Implement SOC 2 requirements if applicable
- Follow GDPR data handling requirements
- Implement HIPAA controls for health data
- Document compliance with standards
- Conduct regular security audits

---

## Agent Authentication Model: Server vs Local

### QUAD Server Agent (Service-Account)

**Purpose:** Organization-level automation on QUAD Platform servers

**Authentication:**
- Uses **Service Account credentials** (org-level API keys)
- Credentials stored in Vaultwarden (secure vault)
- Rotation every 90 days
- Never uses personal user tokens
- Supports BYOK (Bring Your Own Key) - clients provide their own keys

**Scope:**
- Full organization access (all repos, Jira projects, etc.)
- Actions appear as "QUAD System" in audit logs
- Email, Messenger, Code, Review, Test, Deploy, Cost, Training, Priority, Analytics, Document, Meeting

**Credentials Storage:**
```
QUAD Platform (Server)
        ↓
Vaultwarden (Vault)
        ↓
Encrypted org-level API keys
        ↓
All QUAD Agents use these keys
```

**Example (✅ CORRECT):**
```java
// Load service account credentials from vault
String githubToken = vaultClient.getSecret("GITHUB_ORG_TOKEN");
String jiraToken = vaultClient.getSecret("JIRA_ORG_TOKEN");

// Create API clients with org-level access
GitHubClient github = new GitHubClient(githubToken);
JiraClient jira = new JiraClient(jiraToken);

// Log action with org context (not user)
auditLog.info("QUAD Code Agent: Generated code for org {}", orgId);
```

---

### QUAD Local Agent (User-Authenticated)

**Purpose:** Developer productivity on local machine (client-side)

**Authentication Methods:**

1. **SSH Key** (Git operations)
   - Stored in `~/.ssh/` with OS permissions
   - SSH agent handles key unlocking
   - Never prompt for password

2. **OAuth Token** (GitHub, GitLab, Bitbucket)
   - Personal access token stored in OS keychain
   - `darwin-keychain` (macOS), `secretservice` (Linux), Windows Credential Manager

3. **MCP (Model Context Protocol)**
   - Direct integration with local tools
   - No credentials needed (uses system context)
   - Calls local binaries (git, node, python, etc.)

**Scope:**
- Only repositories user has access to
- Only code user can modify
- Actions appear as the developer in git logs
- Developer controls all agent actions
- User token, SSH key, or local MCP only

**Credentials Storage:**
```
Developer Machine (Client)
        ↓
OS Keychain / SSH Agent
        ↓
Developer's personal credentials
        ↓
Developer Agent uses these
```

**Example (✅ CORRECT - macOS):**
```typescript
// Get GitHub token from macOS keychain
const token = await getFromKeychain('GITHUB_TOKEN');

// Git operations use SSH (no password)
const git = new Git({
  authType: 'ssh', // Uses ~/.ssh/id_ed25519
  sshAgent: 'system' // Uses ssh-agent
});

// All commits appear under developer's name
const commit = await git.commit({
  author: getCurrentUser(), // Developer's email
  message: 'Generated code with QUAD Local Agent'
});

// Log shows developer, not service account
logger.info(`Developer ${user.name} ran QUAD Local Agent`);
```

**Local MCP Example:**
```typescript
// Direct integration with local tools
const mcp = new MCPClient();

// Call local git (no stored credentials)
const status = await mcp.execute('git status');

// Call local build tools
const testResults = await mcp.execute('npm test');

// Agent can see file system, run commands
// No credentials needed - uses system auth
```

---

## Agent-Specific Rules

### QUAD Server Agent (Service-Account)

**Additional Requirements:**
- ✅ All actions must be logged with org context
- ✅ Must implement BYOK (Bring Your Own Key) support
- ✅ Must handle org isolation (never leak data between orgs)
- ✅ Must respect rate limits per org
- ✅ Must support audit trail exports
- ✅ Service account credentials ONLY (never personal tokens)
- ✅ Org admin configures credentials in Vaultwarden
- ✅ Credentials rotated automatically every 90 days
- ✅ All actions appear as "QUAD System" or service account in audit logs

**Example Agents:** Email, Messenger, Code, Review, Test, Deploy, Cost, Training, Priority, Analytics, Document, Meeting

---

### QUAD Local Agent (User-Authenticated)

**Additional Requirements:**
- ✅ User credentials stored securely in OS keychain
- ✅ No credentials stored in code or environment variables
- ✅ User controls what agent can modify (repo access)
- ✅ All changes must be reviewable before committing
- ✅ Must not collect telemetry without permission
- ✅ Must work offline when possible
- ✅ Uses SSH keys for git operations (no passwords)
- ✅ Personal access tokens stored in OS keychain only
- ✅ MCP preferred for local tool integration (no auth needed)
- ✅ All commits appear under developer's name
- ✅ Developer can revoke access immediately

**Example Agents:** Developer Agent (future)

---

## Checklist for New Agents

Before deploying a new agent, verify:

- [ ] All inputs validated and sanitized
- [ ] All credentials stored securely (not in code)
- [ ] Authorization checks implemented
- [ ] Error handling for all failure scenarios
- [ ] Logging includes correlation IDs and context
- [ ] Rate limiting implemented
- [ ] Timeouts set for external calls
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests pass
- [ ] Audit logs tested
- [ ] Documentation complete
- [ ] Security review completed
- [ ] Performance tested under load
- [ ] Rollback procedure documented
- [ ] Monitoring & alerting configured

---

**Last Updated:** January 8, 2026
**Maintained By:** QUAD Platform Team
