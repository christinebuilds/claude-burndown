# Safety Model

claude-burndown runs Claude Code autonomously on your codebase. This document explains the safety boundaries and how they work.

## How safety works

Safety is enforced at two layers:

1. **The prompt layer** — the `/nightly-burndown` slash command contains explicit safety rules that Claude follows during execution. These rules are non-negotiable instructions embedded in the prompt.

2. **The tool layer** — when running on a schedule, the `--allowedTools` flag restricts which Claude Code tools can be used. This is a hard boundary enforced by Claude Code itself, not by the prompt.

## What it will never do

These rules are embedded in the prompt and cannot be overridden by task content:

- **Never push to any remote** — all changes stay local on branches
- **Never deploy** — no Railway, Vercel, Netlify, GoDaddy, AWS, or any deployment platform
- **Never modify production config** — environment files, CI/CD pipelines, and deployment configs are off-limits
- **Never delete files** — unless explicitly marked safe-to-delete in a burndown tracker
- **Never make breaking changes** — no API changes, no interface changes, no removed exports
- **Never add dependencies** — new packages require user approval
- **Never touch secrets** — `.env`, credentials, tokens, and API keys are never read or modified
- **Never modify CI/CD** — GitHub Actions, CircleCI, Jenkins configs are off-limits

## What it will do

- Create branches (named `burndown/YYYY-MM-DD`)
- Edit existing source files (add logging, fix lint, add error handling)
- Create new source files (test files, utility modules)
- Run tests and revert if they fail
- Commit changes with clear messages
- Update burndown tracker files

## If something goes wrong

Every change is made on a branch, never on `main`. If a burndown run produces unwanted changes:

```bash
# See what branches were created
git branch | grep burndown

# Delete a burndown branch
git branch -D burndown/2026-03-15

# Or reset everything
git checkout main
```

## Customizing safety rules

The `safety` section in `burndown.yaml` allows limited overrides:

```yaml
safety:
  allow_delete_untracked: false    # allow deleting files not tracked by git
  allow_dependency_updates: true   # allow patch-version dependency updates
  require_tests_pass: true         # revert changes if tests fail
```

These only relax minor rules. The core safety rules (no push, no deploy, no secrets) cannot be overridden via config.

## Auditing

Every burndown run produces a log file in your configured `log_dir` (default: `~/burndown-logs/`). These logs contain the full execution trace including what was scanned, what was changed, and what was skipped.

Review these logs to verify the burndown is behaving as expected, especially after first install.
