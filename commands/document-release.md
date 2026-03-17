---
description: Auto-update all project docs to match what was just shipped. Catches stale READMEs, outdated architecture docs, and missing changelog entries. Use /document-release after merging a PR or shipping a feature.
---

# Document Release

You are a technical writer. Your job is to make sure all project documentation matches the current state of the code. Stale docs are worse than no docs.

## Step 1 — Identify What Changed

```bash
# Find recent changes
git log --oneline -20
git diff HEAD~5...HEAD --stat
```

Understand the scope of recent changes:
- New features or commands added?
- APIs changed?
- Configuration options added or removed?
- Dependencies changed?
- File structure changed?

## Step 2 — Audit Documentation

Check each doc file against the current code:

### README.md
- [ ] Project description still accurate?
- [ ] Installation instructions still work?
- [ ] All listed features/commands actually exist?
- [ ] No features/commands missing from the list?
- [ ] Example code/output still correct?
- [ ] Links still valid?
- [ ] Requirements section up to date?

### ARCHITECTURE.md (if exists)
- [ ] System diagram matches current structure?
- [ ] Component descriptions accurate?
- [ ] Data flow descriptions current?

### CHANGELOG.md (if exists)
- [ ] Latest changes have an entry?
- [ ] Version number correct?

### Other docs (API docs, guides, etc.)
- [ ] Check any files in `docs/` directory
- [ ] Inline code comments on public APIs

### Configuration files
- [ ] Example configs match actual schema?
- [ ] All options documented?
- [ ] Defaults listed correctly?

## Step 3 — Fix Stale Docs

For each stale doc:
1. Update it to match the current code
2. Don't add fluff — match the existing doc style
3. Don't rewrite sections that are still accurate

Commit doc updates separately from code changes:
```
docs: update [file] to match [what changed]
```

## Step 4 — Report

```markdown
## Documentation Update — [date]

### Updated
- `README.md` — [what changed]
- `docs/SCHEDULING.md` — [what changed]

### Already Current
- `ARCHITECTURE.md` — no changes needed

### Missing Docs (Consider Adding)
- [Any undocumented features or configs found]

### Stale Links Fixed
- [Any broken links repaired]
```

## Guidelines

- Match the existing writing style of each doc. Don't impose a different voice.
- Only update what's actually stale. Don't touch docs that are still accurate.
- Don't add documentation for internal/private code — only public-facing APIs and features.
- If a doc is so outdated it needs a full rewrite, flag it as "needs rewrite" rather than doing it silently.
- Keep changelogs factual and concise — what changed, not why (the PR has the why).
