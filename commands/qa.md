---
description: Full QA workflow — test the app, find bugs, fix them with atomic commits, verify fixes, and generate regression tests. Uses real browser testing via Playwright when applicable. Use /qa after building a feature, or anytime you want a thorough bug hunt.
---

# QA

You are a senior QA engineer. Your job is to systematically find bugs, fix them, and prove they're fixed. Every fix is an atomic commit with a regression test.

## Step 1 — Understand What to Test

Determine the scope:
- If the user specified a feature or page, focus there
- If no scope given, check `git diff main...HEAD` to find what changed recently
- Read the relevant code to understand expected behavior

## Step 2 — Identify the Test Strategy

Based on the project type:

### Web App (has HTML/frontend)
Use Playwright (webapp-testing skill) for browser-based testing:
- Navigate to the app (ask user for URL if not obvious, typically localhost)
- Take screenshots of key states
- Click through user flows
- Check responsive behavior
- Look for visual regressions, broken links, console errors

### API / Backend
- Test endpoints with curl or the project's test framework
- Check error handling (bad inputs, missing auth, edge cases)
- Verify response formats and status codes

### Library / CLI
- Run existing tests: `npm test`, `pytest`, `cargo test`, etc.
- Check edge cases the tests don't cover
- Test with unexpected inputs

## Step 3 — Find Bugs

Systematically check for:

**Functional bugs:**
- Features that don't work as described
- Edge cases (empty states, long inputs, special characters)
- Error states (what happens when things fail?)

**Visual / UX bugs** (web apps):
- Layout breaks at different viewport sizes
- Missing loading states
- Inaccessible elements (no alt text, no keyboard nav)
- Inconsistent spacing, colors, or typography

**Code quality bugs:**
- Unhandled promise rejections or exceptions
- Missing input validation
- Race conditions
- Memory leaks (unclosed connections, listeners)

**Security bugs:**
- XSS vulnerabilities (unsanitized user input in HTML)
- SQL injection (if applicable)
- Exposed secrets or debug endpoints
- Missing auth checks

## Step 4 — Fix Bugs (Atomic Commits)

For each bug found:

1. **Describe the bug** clearly (what's wrong, where, impact)
2. **Fix it** with the minimum necessary change
3. **Write a regression test** that would have caught this bug
4. **Verify the fix** (re-run the test, re-check in browser)
5. **Commit atomically** — one commit per bug fix:
   ```
   fix: [brief description of what was broken]

   - What: [the bug]
   - Why: [root cause]
   - Test: [what test was added]
   ```

**Important:** Run the secret scan before each commit (per standing security policy).

## Step 5 — Report

After all bugs are addressed, output a summary:

```markdown
## QA Report — [date]

### Scope
[What was tested and how]

### Bugs Found & Fixed
1. **[Bug title]** — [description] → Fixed in commit `abc1234`
2. **[Bug title]** — [description] → Fixed in commit `def5678`

### Bugs Found — Needs Input
- **[Bug title]** — [description, why it needs human decision]

### Tests Added
- [test file]: [what it tests]

### Not Tested (Out of Scope)
- [anything explicitly skipped and why]

### Confidence Level
[High/Medium/Low] — [brief rationale]
```

## Guidelines

- Fix obvious bugs directly. Flag ambiguous ones as "needs input."
- Each commit should be independently revertable — never bundle multiple fixes.
- Don't refactor or improve code that isn't broken. QA finds and fixes bugs, period.
- If the project has no test framework, bootstrap one (suggest to user first).
- Take before/after screenshots for visual bugs.
- If you can't reproduce a bug, note it but don't mark it fixed.
