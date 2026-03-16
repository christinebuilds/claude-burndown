# claude-burndown

Autonomous nightly maintenance for your codebases, powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

claude-burndown scans your projects for no-regret tasks — TODO cleanups, missing tests, lint fixes, logging gaps, error handling — classifies them, and executes the safe ones automatically. Changes are always made on branches, never pushed, and reverted if tests fail.

## What it does

Every night (or whenever you run it), claude-burndown:

1. **Scans** your configured projects for TODOs, FIXMEs, test gaps, and code quality issues
2. **Classifies** each task: autonomous (safe to do) vs. needs your input vs. blocked
3. **Executes** the autonomous tasks — on a branch, with tests, reverting on failure
4. **Reports** what was done, what was skipped, and what needs your attention

```
## Burndown Complete — 2026-03-15

### Done
- [x] Add structured logging to adapters — my-api (25 min)
- [x] Add retry logic with exponential backoff — my-api (20 min)
- [x] Delete leftover test fixtures — my-webapp (2 min)

### Still Needs Input
- Which auth provider to migrate to? — my-api

---
3 tasks completed | 47 min spent | 55 tests passing
```

## Quick start

### 1. Install

```bash
git clone https://github.com/christineyws-beep/claude-burndown.git
cd claude-burndown
chmod +x install.sh uninstall.sh
./install.sh
```

The installer will:
- Install the `/nightly-burndown` slash command for Claude Code
- Create a config file at `~/.config/claude-burndown/burndown.yaml`
- Optionally set up nightly scheduling (macOS, Linux, or cron)

### 2. Configure your projects

Edit `~/.config/claude-burndown/burndown.yaml`:

```yaml
log_dir: ~/burndown-logs

projects:
  - name: my-webapp
    path: ~/code/my-webapp
    exclude: [node_modules, dist]

  - name: my-api
    path: ~/code/my-api
    notes: ~/notes/api-burndown.md
    exclude: [.venv, __pycache__]
```

### 3. Run it

From within Claude Code:

```
/nightly-burndown
```

Or from the command line:

```bash
claude -p /nightly-burndown
```

## Safety

claude-burndown is designed to be safe for unattended execution. See [SAFETY.md](docs/SAFETY.md) for the full safety model.

The short version:
- Changes are always on branches (`burndown/YYYY-MM-DD`), never on `main`
- Changes are reverted if tests fail
- It will **never** push, deploy, delete files, add dependencies, or touch secrets
- Every run produces a log you can review

## How it works

claude-burndown is a [Claude Code slash command](https://docs.anthropic.com/en/docs/claude-code/slash-commands) — a markdown prompt file that Claude interprets at runtime. There is no traditional code to run. The entire "program" is a structured prompt that tells Claude how to scan, classify, and execute tasks safely.

This means:
- **No dependencies** to install beyond Claude Code itself
- **No runtime** — it runs inside your existing Claude Code environment
- **Fully customizable** — edit the markdown to change behavior

## Scheduling

The installer can set up automatic nightly runs on:
- **macOS** via launchd
- **Linux** via systemd
- **Any Unix** via cron

See [SCHEDULING.md](docs/SCHEDULING.md) for details.

## Configuration

See [CONFIGURATION.md](docs/CONFIGURATION.md) for the full config reference.

## Uninstall

```bash
cd claude-burndown
./uninstall.sh
```

Removes the slash command, scheduling, and optionally the config. Logs are preserved.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated
- macOS, Linux, or WSL

## License

MIT
