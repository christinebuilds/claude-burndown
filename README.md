# claude-burndown

**A complete AI software factory for Claude Code.**

claude-burndown is a collection of development workflow commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — from planning through shipping. Install as slash commands, use them interactively or schedule them to run automatically.

Every change is on a branch. Every change is tested. Nothing is pushed. You review and merge what you like.

---

## Commands

### `/nightly-burndown` — Autonomous code maintenance

Scans your projects for no-regret tasks — TODO cleanups, missing error handling, lint fixes, test gaps, dead code — classifies them by risk, and executes the safe ones automatically.

```
$ claude -p /nightly-burndown
```

```
## Nightly Burndown — 2026-03-15

### Will Execute (~47 min total)
1. Add structured logging to adapters (25 min) — my-api
2. Add retry logic with exponential backoff (20 min) — my-api
3. Delete leftover test fixtures (2 min) — my-webapp

### Needs Your Input
- Which auth provider to migrate to? — my-api
- Add pagination to search endpoint? — my-api

Proceeding with autonomous tasks...
```

**What it scans for:**
- `TODO`, `FIXME`, `HACK`, `XXX` comments in source files
- Missing or incomplete tests
- Lint and type errors
- Stale git branches and uncommitted changes
- Outdated dependencies (patch versions only)
- Burndown tracker files (if configured)

**What it considers safe to execute:**
- Adding logging, error handling, or retry logic
- Fixing lint and type errors
- Writing tests for existing code
- Cleaning up resolved TODOs
- Deleting files explicitly marked safe-to-delete
- Updating docs to match current code

**What it flags as "needs input":**
- Architecture decisions
- New dependencies
- Deployment
- Anything touching external services or credentials

---

### `/security-check` — Security health scanner

A tiered security audit for your development environment. Scans for leaked secrets, vulnerable dependencies, stale credentials, and risky configurations.

```
$ claude -p "/security-check weekly"
```

```
# Security Check — 2026-03-17
Tier: Just-in-Time + Weekly

## Passed
- No secrets in staged files
- All .env files in .gitignore
- No critical CVEs in dependencies
- GitHub repo visibility matches intent

## Warnings
- 2 medium-severity npm advisories in my-webapp
- Playwright cache using 512MB disk space

## Recommended Actions
1. Run `npm audit fix` in my-webapp
2. Consider clearing Playwright cache if not actively testing
```

**Three tiers:**

| Tier | What it checks | When to run |
|------|---------------|-------------|
| **Just-in-Time** | Secrets in staged files, new dependency vetting, file permissions | Every commit / pre-push |
| **Weekly** | Git history secret scan, full dependency audit, background processes, GitHub repo visibility, active integrations | Monday nights |
| **Monthly** | OS security updates, credential rotation, stale software cleanup, GitHub OAuth app audit | 1st of the month |

**Run manually:**
```bash
claude -p "/security-check"          # default: just-in-time + weekly
claude -p "/security-check quick"    # just-in-time only (pre-push)
claude -p "/security-check weekly"   # just-in-time + weekly
claude -p "/security-check monthly"  # all tiers
```

---

### `/plan` — Architecture planning

Think through the problem before writing code. Explores 2-3 approaches with tradeoffs, identifies risks, and produces a concrete implementation plan. Gets alignment before building.

```
$ /plan
```

Best used at the start of a new feature, refactor, or complex change. Outputs a structured plan with file paths, steps, risks, and test strategy.

---

### `/qa` — Find and fix bugs

Full QA workflow: test the app (with real browser testing via Playwright when applicable), find bugs, fix them with atomic commits, verify fixes, and generate regression tests.

```
$ /qa
```

Each bug fix is a separate commit with a regression test. Outputs a QA report with findings, fixes, and confidence level. Supports web apps (browser testing), APIs (endpoint testing), and libraries (unit testing).

---

### `/ship` — Release to GitHub

The last step before code leaves your machine. Runs tests, scans for secrets, audits dependencies, reviews the diff for debug code, then creates a clean PR.

```
$ /ship
```

Never pushes directly to `main`. Always creates a branch + PR with a full description, test results, and security checklist.

---

### `/document-release` — Update stale docs

Auto-updates all project documentation to match what was just shipped. Audits README, ARCHITECTURE, CHANGELOG, and config examples against the current code.

```
$ /document-release
```

Best used after merging a PR. Each doc update is a separate commit.

---

## The full pipeline

These commands chain together into a complete development workflow:

```
/plan → build → /qa → /review → /ship → /document-release
```

| Step | Command | What it does |
|------|---------|-------------|
| 1. Plan | `/plan` | Think through the approach, get alignment |
| 2. Build | *(you + Claude)* | Write the code |
| 3. QA | `/qa` | Test, find bugs, fix with atomic commits |
| 4. Review | `/review` | Code review for risks and quality |
| 5. Ship | `/ship` | Tests + secret scan + PR creation |
| 6. Docs | `/document-release` | Update docs to match the code |
| 7. Maintain | `/nightly-burndown` | Autonomous overnight maintenance |
| 8. Secure | `/security-check` | Automated security audits |

---

## Quick start

### 1. Install

```bash
git clone https://github.com/christinebuilds/claude-burndown.git
cd claude-burndown
chmod +x install.sh uninstall.sh
./install.sh
```

The installer will:
- Install all slash commands for Claude Code
- Create a config file at `~/.config/claude-burndown/burndown.yaml`
- Optionally set up automated scheduling (macOS launchd, Linux systemd, or cron)

### 2. Add your projects

Edit `~/.config/claude-burndown/burndown.yaml`:

```yaml
log_dir: ~/burndown-logs
max_execution_minutes: 60

projects:
  - name: my-webapp
    path: ~/code/my-webapp
    exclude: [node_modules, dist, .next]

  - name: my-api
    path: ~/code/my-api
    notes: ~/notes/api-burndown.md     # optional burndown tracker
    exclude: [.venv, __pycache__]
```

### 3. Run it

From within a Claude Code session:
```
/nightly-burndown
/security-check
```

From the command line:
```bash
claude -p /nightly-burndown
claude -p "/security-check weekly"
```

Or let them run on a schedule — the installer sets this up for you.

---

## Safety model

claude-burndown is built for unattended execution. Safety is enforced at two layers: the prompt (what Claude is instructed to do) and the tool allowlist (what Claude is permitted to do).

### Nightly burndown safety

| Rule | Enforced by |
|------|------------|
| All changes on branches, never `main` | prompt |
| Revert if tests fail | prompt |
| Never push to any remote | prompt |
| Never deploy anywhere | prompt |
| Never delete files (unless marked safe) | prompt |
| Never add dependencies | prompt |
| Never touch secrets or `.env` files | prompt |
| Never modify CI/CD pipelines | prompt |
| Tool access restricted to file operations | `--allowedTools` flag |

### Security check safety

| Rule | Enforced by |
|------|------------|
| Read-only — never modifies files | prompt + `--allowedTools` |
| No network access except `gh` CLI | `--allowedTools` flag |
| Cannot install or remove packages | `--allowedTools` flag |
| Cannot push code or modify remotes | `--allowedTools` flag |
| Reports findings, never auto-fixes | prompt |

If something unexpected happens with the burndown, every change is on a `burndown/YYYY-MM-DD` branch:

```bash
git branch -D burndown/2026-03-15   # delete unwanted changes
```

See [docs/SAFETY.md](docs/SAFETY.md) for the full safety model.

---

## Scheduling

The installer offers automated scheduling for all commands:

| Command | Default schedule | Purpose |
|---------|-----------------|---------|
| `/nightly-burndown` | Daily at 12:30am | Code maintenance |
| `/security-check weekly` | Monday at 1:00am | Security audit |
| `/security-check monthly` | 1st of month at 2:00am | Deep security audit |

| Platform | Method | Runs when asleep? |
|----------|--------|-------------------|
| macOS | launchd | Runs on wake |
| Linux | systemd user timer | Yes (if machine is on) |
| Any Unix | cron | Yes (if machine is on) |

Templates are in `scheduling/launchd/` and `scheduling/systemd/`.

See [docs/SCHEDULING.md](docs/SCHEDULING.md) for management commands.

---

## How it works

claude-burndown commands are [Claude Code slash commands](https://docs.anthropic.com/en/docs/claude-code) — markdown files that Claude interprets as structured instructions. The entire "program" is a prompt. There is no traditional code to execute.

This means:
- **Zero dependencies** beyond Claude Code
- **No build step, no runtime** — it runs inside your existing Claude Code environment
- **Fully customizable** — edit the command files to change any behavior
- **Portable** — works on any project in any language

---

## Configuration reference

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for the full YAML reference, including safety overrides and project options.

---

## Uninstall

```bash
cd claude-burndown
./uninstall.sh
```

Removes all slash commands, scheduling jobs, and optionally the config. Logs are preserved.

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated
- macOS, Linux, or WSL
- git (for branch creation and change tracking)

## Contributing

Contributions welcome. The commands live in `commands/` — each is a markdown prompt that drives all behavior. If you find tasks it should handle, safety rules it should enforce, or scanning patterns it misses, open an issue or PR.

## License

MIT
