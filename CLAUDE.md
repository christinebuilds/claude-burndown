# claude-burndown

An opinionated, security-first command suite for autonomous Claude Code development. Adapted from [garrytan/gstack](https://github.com/garrytan/gstack).

## Project structure

- `commands/` — Slash command markdown files (the core product). Each `.md` file is a structured prompt that Claude Code interprets as instructions.
- `docs/` — Safety model, configuration reference, scheduling guide.
- `config/` — Example YAML config for project registration.
- `scheduling/` — Templates for launchd, systemd, and cron.
- `install.sh` / `uninstall.sh` — Installer and uninstaller scripts.

## Hard safety rules

These are enforced across every command and are non-negotiable:

- NEVER push to any remote
- NEVER deploy anywhere
- NEVER touch secrets or `.env` files
- NEVER modify CI/CD pipelines
- NEVER delete files (unless marked safe-to-delete in a burndown tracker)
- NEVER add dependencies without approval
- NEVER make breaking changes

## Two-layer safety model

1. **Prompt rules** — safety directives embedded in each command's markdown
2. **Tool allowlists** — `--allowedTools` restricts which Claude Code tools can be invoked at runtime

## Adding or modifying commands

- Each command is a standalone markdown file in `commands/`
- Commands use frontmatter (`description` field) + markdown body
- Test locally by copying to `~/.claude/commands/` and running via `/command-name`
- See `CONTRIBUTING.md` for the full process
