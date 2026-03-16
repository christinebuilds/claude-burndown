---
description: Run a nightly burndown — scan configured projects for no-regret tasks, classify them, and autonomously execute safe tasks. Use when the user says "nightly burndown", "find tasks to do", "what can you work on", or invokes /nightly-burndown. Can be scheduled to run unattended.
---

# Nightly Burndown — Autonomous Task Execution

You are running an automated nightly burndown. Your job is to:
1. Load the user's project configuration
2. Scan all configured projects for pending tasks
3. Classify each as autonomous vs. needs-input vs. blocked
4. Execute all safe, no-regret autonomous tasks
5. Report what was done and what's left

---

## Step 0 — Load Configuration

Read the configuration file at `~/.config/claude-burndown/burndown.yaml`.

This YAML file declares:
- `log_dir`: where to write burndown reports
- `projects`: a list of projects, each with `name`, `path`, optional `notes` path, and optional `exclude` patterns
- `max_execution_minutes`: time cap for autonomous work (default 60)
- `safety`: overrides for safety rules

Parse the YAML and iterate over each project in the `projects` list.

If the config file does not exist, tell the user to run the setup:
```
cp ~/.config/claude-burndown/burndown.example.yaml ~/.config/claude-burndown/burndown.yaml
```
Then edit it to add their projects.

---

## Step 1 — Scan for Tasks

For each project in the config:

**1a. Check for a burndown/notes file** (if `notes` path is configured):
- Read it for existing task lists, backlog items, sprint history

**1b. Scan the codebase** at the project `path`:
- Search for `TODO`, `FIXME`, `HACK`, `XXX` comments in source files
- Exclude directories listed in the project's `exclude` config
- Check for failing or missing tests
- Look for common issues: outdated dependencies (patch versions), lint errors, type errors

**1c. Check git status**:
- Uncommitted changes
- Unpushed commits
- Stale branches

---

## Step 2 — Classify Tasks

Classify every task into one of these buckets:

**AUTONOMOUS (safe to do now)** — No user decision needed. Examples:
- Delete confirmed leftover files/dirs marked in burndown tracker
- Add logging, error handling, retry logic
- Fix lint/type errors
- Update dependencies (patch versions only)
- Write missing tests for existing code
- Clean up TODO comments that are already resolved
- Update documentation to match current code

**NEEDS INPUT** — Requires a decision from the user. Examples:
- Architecture choices
- Deployment decisions
- Content or copy decisions
- Adding new dependencies
- Anything involving external accounts, payments, or credentials

**BLOCKED** — Depends on something external. Examples:
- Waiting for deployment to complete
- Waiting for feedback from users/testers
- Waiting for a deadline or event
- Depends on another task being completed first

---

## Step 3 — Estimate & Present Plan

For each AUTONOMOUS task, estimate time in minutes. Sort by:
1. Quick wins first (< 5 min)
2. Then by impact (tests > error handling > logging > docs > cleanup)
3. Cap total execution at `max_execution_minutes` from config (default 60)

Present the burndown list:

```
## Nightly Burndown — [Date]

### Will Execute (~X min total)
1. [Task] (est: X min) — [project name]
2. ...

### Needs Your Input
- [Decision needed] — [project name]

### Blocked
- [What's blocked and why] — [project name]

Proceeding with autonomous tasks...
```

If running interactively, wait for user confirmation before executing.
If running unattended (no user present), proceed automatically.

---

## Step 4 — Execute Autonomous Tasks

For each task:
1. `cd` to the project directory
2. Create a git branch if making code changes: `burndown/YYYY-MM-DD`
3. Make the change
4. Run tests if the project has them
5. If tests pass, commit with a clear message
6. If tests fail, revert and log the failure

**Safety rules (non-negotiable):**
- NEVER push to any remote repository
- NEVER deploy anything (no Railway, Vercel, Netlify, GoDaddy, etc.)
- NEVER modify production configuration
- NEVER delete files unless explicitly marked safe-to-delete in a burndown tracker
- NEVER make breaking API or interface changes
- NEVER add new dependencies without user approval
- NEVER modify CI/CD pipelines
- NEVER touch credentials, secrets, or environment files
- If a change breaks tests, revert immediately and move on
- If unsure whether a task is truly autonomous, skip it

---

## Step 5 — Update Trackers

After execution:
1. If the project has a burndown/notes file, update it:
   - Mark completed tasks with checkmark and date
   - Add a sprint history row if code was changed
2. Write a burndown report to the configured `log_dir`:
   - Filename: `YYYY-MM-DD.md`
   - Include the full summary from Step 6

---

## Step 6 — Report

Present a clean summary:

```
## Burndown Complete — [Date]

### Done
- [x] [Task] — [project name] (X min)
- ...

### Skipped (failed or reverted)
- [ ] [Task] — reason

### Still Needs Input
- [Decision] — [project name]

### Next Session Suggestions
- [What to prioritize next time]

---
[X] tasks completed | [Y] min spent | [Z] tests passing
```

---

## Error Handling

- If a project path doesn't exist, log a warning and skip it
- If git operations fail, skip that project (don't block others)
- If tests can't be run (missing test runner, broken config), make the change but flag it as "untested" in the report
- If the config file is malformed, report the parse error and exit gracefully
