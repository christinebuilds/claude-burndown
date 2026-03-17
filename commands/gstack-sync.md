---
description: Check gstack repo for new or updated skills, compare against our commands, and report what's changed. Run weekly to stay current. Use /gstack-sync to check for updates.
---

# gstack Sync — Weekly Upstream Check

Check the gstack repo (github.com/garrytan/gstack) for new or updated skills, and compare against our local commands.

## Step 1: Check gstack for changes

```bash
# Get latest gstack commit date and recent commits
gh api repos/garrytan/gstack/commits --jq '.[0:10] | .[] | .commit.committer.date + " " + .commit.message' 2>/dev/null | head -20

# Get gstack VERSION
gh api repos/garrytan/gstack/contents/VERSION --jq '.content' | base64 -d 2>/dev/null

# Get gstack CHANGELOG (last 50 lines)
gh api repos/garrytan/gstack/contents/CHANGELOG.md --jq '.content' | base64 -d 2>/dev/null | head -50

# List all skill directories
gh api repos/garrytan/gstack/contents --jq '.[].name' 2>/dev/null | sort
```

## Step 2: Compare against our commands

List our current commands:
```bash
ls ~/.claude/commands/*.md | xargs -I{} basename {} .md | sort
```

## Step 3: Identify gaps

For each gstack skill directory, check:
1. **New skills** — any directory we don't have an equivalent for?
2. **Updated skills** — has the SKILL.md content changed significantly since we last synced?
3. **New patterns** — any new conventions (e.g., conductor.json for parallel sessions) worth adopting?

To check a specific skill for updates:
```bash
gh api repos/garrytan/gstack/contents/<skill-name>/SKILL.md --jq '.sha' 2>/dev/null
```

## Step 4: Report

```markdown
## gstack Sync — [date]

### gstack Version: [version]
### Last checked: [date]

### New Skills Found
- [skill name] — [what it does] — **Recommend: integrate / skip / watch**

### Updated Skills
- [skill name] — [what changed] — **Recommend: update / no action**

### New Patterns
- [pattern] — [what it is] — **Recommend: adopt / skip**

### Our Extras (not in gstack)
- [commands we have that gstack doesn't]

### No Action Needed
- [skills that are up to date]
```

## Step 5: Create Task

If there are actionable updates, create a Google Tasks item:
- Title: `gstack sync: [N] updates found — [date]`
- Notes: Summary of what's new and recommendations

## Schedule

This runs as part of the Monday `/nightly-burndown` or can be invoked manually with `/gstack-sync`.

## Our Mapping

| gstack | Ours | Notes |
| --- | --- | --- |
| `/plan-ceo-review` | `/plan ceo` | Integrated as mode |
| `/plan-design-review` | `/plan design` | Integrated as mode |
| `/plan-eng-review` | `/plan eng` | Integrated as mode |
| `/design-consultation` | `/design-consultation` | Adapted |
| `/review` | `/review` (built-in) | Built-in skill |
| `/ship` | `/ship` | Adapted |
| `/qa` | `/qa` | Adapted |
| `/qa-only` | `/qa-only` | Adapted |
| `/qa-design-review` | `/qa-design` | Adapted |
| `/browse` | `webapp-testing` (built-in) | Different approach — Playwright vs custom binary |
| `/setup-browser-cookies` | `/setup-browser-cookies` | Adapted |
| `/retro` | `/retro` | Adapted |
| `/document-release` | `/document-release` | Adapted |
| `/gstack-upgrade` | `/gstack-sync` | We check upstream; they self-update |
