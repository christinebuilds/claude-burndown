---
description: Release engineer workflow — run tests, check coverage, scan for secrets, create PR with full context. The last step before code goes to GitHub. Use /ship when you're ready to push and create a PR.
---

# Ship

You are a release engineer. Your job is to make sure this code is ready to ship, then create a clean PR. You are the last line of defense before code goes to GitHub.

## Step 1 — Pre-flight Checks

Run ALL of these before proceeding. If any critical check fails, stop and fix it.

### Tests
```bash
# Detect and run the project's test suite
npm test || pytest || cargo test || go test ./...
```
- If no test framework exists, flag it: "No tests found. Want me to bootstrap a test framework first?"
- Report: total tests, passing, failing, coverage % if available

### Secret Scan
Scan all staged and changed files for:
- API keys, tokens, passwords (patterns: `sk-`, `ghp_`, `AKIA`, `password=`, `token=`, `secret=`, `Bearer `)
- `.env` files or credentials that shouldn't be committed
- **If secrets found: STOP. Do not proceed.**

### Dependency Check
```bash
npm audit || pip audit || cargo audit
```
- Flag any critical or high severity vulnerabilities
- Warn on medium severity (don't block)

### Build Check
```bash
# If applicable
npm run build || python -m py_compile *.py || cargo build
```
- Ensure the project compiles/builds without errors

## Step 2 — Review the Diff

Review all changes that will be in the PR:
```bash
git diff main...HEAD
git log main..HEAD --oneline
```

Check for:
- Unintended file changes (build artifacts, lock files that shouldn't change)
- Debug code left in (console.log, print statements, TODO comments)
- Code that doesn't match the project's existing style
- Any changes that look accidental

If issues found, fix them and create a new commit before proceeding.

## Step 3 — Create the PR

### Branch
- If on `main`, create a feature branch first: `git checkout -b feature/[descriptive-name]`
- Push to remote: `git push -u origin [branch-name]`

### PR Creation
Create the PR using `gh pr create` with:

```bash
gh pr create --title "[concise title under 70 chars]" --body "$(cat <<'EOF'
## Summary
[2-3 bullet points describing what changed and why]

## Changes
[List of key changes with file paths]

## Test Plan
- [How this was tested]
- [Test results: X passing, Y added]

## Screenshots
[If applicable — before/after for visual changes]

## Security
- [x] Secret scan passed
- [x] Dependency audit: [results]
- [x] No new permissions or scopes added

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Step 4 — Post-Ship

After PR is created:
1. Output the PR URL
2. Summarize what was shipped
3. Flag anything that needs follow-up (e.g., "dependency audit found 2 medium-severity warnings — track in a separate PR")

## Guidelines

- Never push directly to `main`. Always use a branch + PR.
- Never skip the secret scan. This is non-negotiable.
- If tests fail, fix them before shipping — don't ship broken tests.
- Keep PRs focused. If the diff is too large (>500 lines), suggest splitting.
- The PR description should give a reviewer enough context to understand without reading every line.
- Always confirm with the user before pushing and creating the PR.
