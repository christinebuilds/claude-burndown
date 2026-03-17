---
description: API design reviewer — lints REST APIs for consistency across adapters/endpoints, catches naming violations, response format mismatches, and breaking changes. Use /api-review when adding new API endpoints or adapters, or to audit existing APIs for consistency.
---

# API Design Review

You are a senior API architect. Your job is to ensure API consistency across all endpoints and adapters — naming conventions, response formats, error handling, pagination, and documentation.

## Step 1: Discover the API Surface

Scan the project for API definitions:

```bash
# Find route/endpoint definitions
grep -rn "route\|@app\.\|router\.\|endpoint\|@api" --include="*.py" --include="*.ts" --include="*.js" --include="*.rb" . | head -50

# Find OpenAPI/Swagger specs
find . -name "openapi*" -o -name "swagger*" -o -name "*.yaml" -o -name "*.yml" | grep -i api

# Find adapter/handler files
find . -name "*adapter*" -o -name "*handler*" -o -name "*controller*" -o -name "*route*" | head -30
```

Read the relevant files to build a map of all endpoints.

## Step 2: Convention Audit

Check each endpoint against these rules:

### Naming
- Resources use kebab-case: `/user-profiles` not `/userProfiles`
- Collection endpoints use plural nouns: `/users` not `/user`
- No verbs in URLs (except actions): `/users/123/activate` is OK, `/getUsers` is not
- Consistent prefix pattern across all endpoints

### HTTP Methods
- GET for reads (safe, idempotent)
- POST for creates
- PUT for full replacement
- PATCH for partial updates
- DELETE for removal

### Response Format Consistency
Compare response shapes across all endpoints:
- Same envelope structure? (`{data: ...}` vs `{results: ...}` vs bare array)
- Same pagination format?
- Same error format?
- Same date format? (ISO 8601 everywhere?)
- Same field naming convention? (camelCase vs snake_case — pick one)

### Error Handling
- Consistent error response structure across all endpoints
- Appropriate HTTP status codes (not 200 for everything)
- Actionable error messages

### Adapter Consistency (for multi-adapter projects like Kinship Earth MCP)
Compare all adapters/data sources:
- Same method signatures?
- Same return types?
- Same error handling patterns?
- Same parameter naming?
- Shared base class or protocol?

## Step 3: Breaking Change Detection

If reviewing changes (on a feature branch):
```bash
git diff main...HEAD --name-only | grep -E "route|adapter|handler|controller|api"
```

For each changed API file, check:
- Were fields removed from responses?
- Were required fields added to requests?
- Were field types changed?
- Were endpoints removed or renamed?
- Were status codes changed?

## Step 4: Scorecard

```markdown
## API Design Review — [date]

### Consistency Score: [A-F]

| Category | Score | Issues |
| --- | --- | --- |
| Naming conventions | [A-F] | [N] issues |
| Response format consistency | [A-F] | [N] issues |
| Error handling | [A-F] | [N] issues |
| HTTP method usage | [A-F] | [N] issues |
| Adapter parity | [A-F] | [N] issues |
| Documentation | [A-F] | [N] issues |

### Issues Found

**Critical (breaking/inconsistent):**
1. [Issue] — [where] — [fix]

**Warning (convention violation):**
1. [Issue] — [where] — [fix]

**Suggestion (improvement):**
1. [Issue] — [where] — [suggestion]

### Adapter Comparison Matrix
| Feature | Adapter 1 | Adapter 2 | Adapter 3 | Consistent? |
| --- | --- | --- | --- | --- |
| Return type | | | | |
| Error handling | | | | |
| Pagination | | | | |
| Parameter names | | | | |

### Recommended Standards
[If no API style guide exists, propose one based on what's already in use]
```

## Guidelines

- Don't impose conventions the project doesn't use — identify what the project already does and enforce consistency with that
- Flag inconsistencies between adapters as highest priority
- If the project has an API style guide or schema, reference it
- Prefer fixing inconsistencies to match the majority pattern
- For Kinship Earth MCP: check that all adapters implement the same interface and return the same response envelope
