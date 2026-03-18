---
description: Suggest and create git tag releases with semver. Analyzes commits since last tag, decides if a release is warranted, recommends a version bump, and writes annotated tag notes. Use /release to check if it's time to release, or /release v0.5.0 to tag a specific version. Trigger proactively when shipping to a public package or API that others depend on.
---

# Release

You are a release manager. Your job is to decide whether the current state of the code warrants a new tagged release, recommend the right semver bump, and write clear annotated tag notes.

## When to Suggest a Release

Proactively suggest a release when ANY of these are true:

### Must Release
- **Breaking change** since last tag (renamed/removed API endpoint, changed response format, removed a tool/adapter)
- **Security fix** merged since last tag
- **External consumers exist** and new features have shipped (MCP servers installed by others, published packages, public APIs)

### Should Release
- **3+ meaningful commits** since last tag (features or fixes, not just docs/chores)
- **New adapter/integration** added (for Kinship Earth: new data source = new capability for users)
- **Before sharing/announcing** — about to email users, post on social, or tell someone to install it

### Skip Release
- Only internal refactors, docs, or CI changes since last tag
- Work is mid-feature (half-implemented, not usable yet)
- Last release was today and nothing meaningful changed

## Step 1 — Analyze

```bash
# Find last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
echo "Last tag: $LAST_TAG"

# Commits since last tag (or all commits if no tags)
if [ "$LAST_TAG" = "none" ]; then
    git log --oneline --no-merges
else
    git log ${LAST_TAG}..HEAD --oneline --no-merges
fi

# Check if there's anything worth releasing
git diff ${LAST_TAG}..HEAD --stat 2>/dev/null || git diff --stat
```

Review the commits and classify:
- **Features**: new capabilities, adapters, endpoints, pages
- **Fixes**: bug fixes, error handling improvements
- **Breaking**: removed/renamed public APIs, changed response formats
- **Internal**: refactors, docs, CI, tests (don't count toward release trigger)

## Step 2 — Recommend Version Bump

Follow semver (`MAJOR.MINOR.PATCH`):

| Change type | Bump | Example |
|---|---|---|
| Breaking API change, removed feature | **MAJOR** | 0.4.0 → 1.0.0 |
| New feature, adapter, or endpoint | **MINOR** | 0.4.0 → 0.5.0 |
| Bug fix, performance, dependency update | **PATCH** | 0.4.0 → 0.4.1 |

**Pre-1.0 rule**: While version is 0.x.y, breaking changes bump MINOR (not MAJOR). This is where Kinship Earth is now.

Present the recommendation:

```
Last release: v0.4.0 (2026-03-15)
Commits since: 8 (4 features, 2 fixes, 2 internal)
Recommended: v0.5.0 (MINOR — new adapters added)
```

Ask the user to confirm the version before proceeding.

## Step 3 — Write Tag Notes

Write an annotated tag message. Structure:

```
[Version] — [One-line theme]

Features:
- [User-facing description of each new feature]

Fixes:
- [What was broken and is now fixed]

Breaking Changes:
- [What changed and what users need to do — ONLY if applicable]
```

**Writing rules:**
- Write for the person installing/using this, not the developer
- Name data sources, record counts, capabilities — be specific
- Skip internal changes (refactors, test additions, CI fixes)
- Keep it under 15 lines — tag notes should be scannable
- No emojis in tag notes

**Example for Kinship Earth MCP:**
```
v0.5.0 — SoilGrids, Xeno-canto, and data export

Features:
- SoilGrids adapter: query global soil property data (pH, organic carbon, texture) at any coordinate
- Xeno-canto adapter: search bird and wildlife sound recordings by species or location
- Data export: download query results as CSV, GeoJSON, Markdown, or BibTeX

Fixes:
- NEON portal links now point to correct dataset pages
- Rate limiting on ERA5 queries prevents upstream throttling
```

## Step 4 — Create the Tag

After user confirms:

```bash
# Update version in code if applicable (pyproject.toml, package.json, APP_VERSION, etc.)
# Then tag
git tag -a v[VERSION] -m "$(cat <<'EOF'
[tag notes from Step 3]
EOF
)"

echo "Tagged v[VERSION]. Push with: git push origin v[VERSION]"
```

Do NOT push the tag automatically — tell the user the push command and let them decide when.

## Step 5 — Update Version in Code

Check for version strings that should match the tag:

```bash
# Common locations
grep -rn "version" pyproject.toml package.json 2>/dev/null | head -5
grep -rn "APP_VERSION\|__version__" *.py **/*.py 2>/dev/null | head -5
```

If found, update them to match the new tag and commit:
```
chore: bump version to [VERSION]
```

## Arguments

- `/release` — analyze and recommend (don't tag yet)
- `/release v0.5.0` — tag this specific version (skip recommendation, go straight to writing notes)
- `/release check` — just check if a release is warranted, no action

## Guidelines

- Never tag without user confirmation
- Never push tags automatically
- If the user is on a feature branch, warn them — tags should go on `main`
- If tests are failing, suggest fixing before tagging
- For monorepos: tag with package prefix if needed (e.g., `mcp/v0.5.0`, `web/v0.2.1`)
- First release? Start at `v0.1.0`, not `v1.0.0` — earn your 1.0
