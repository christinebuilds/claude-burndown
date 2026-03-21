# claude-burndown

**An opinionated, security-first command suite for autonomous Claude Code development.**

Autonomous AI coding is powerful. It is also dangerous. An unattended AI agent with access to your codebase, your secrets, your deploy pipelines, and your git remotes can do real damage — silently, at 3am, with no one watching.

claude-burndown exists because that is unacceptable.

This is a collection of slash commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that covers the full development lifecycle — planning, building, QA, shipping, security, and overnight maintenance. Every command enforces hard safety boundaries. Every change lands on a branch. Nothing is pushed. Nothing is deployed. You review and merge what you like.

Adapted from [garrytan/gstack](https://github.com/garrytan/gstack), extended with a security suite, autonomous execution, and upstream sync.

**Read the full story:** [Claude-ing after dark? How to practice safe autonomous coding.](https://christinesu.substack.com/p/claude-ing-after-dark-how-to-practice)

---

## Why this exists

AI coding agents are getting good enough to run unsupervised. But "good enough to write code" is not the same as "safe enough to run unattended." Without guardrails, an autonomous agent can:

- Push untested code to production
- Leak secrets into git history
- Add malicious or vulnerable dependencies
- Delete files it shouldn't touch
- Modify CI/CD pipelines
- Deploy broken builds

These are not hypothetical risks. They are the default behavior of an unconstrained agent given broad tool access.

claude-burndown is the guardrail layer. It gives you an autonomous development pipeline with the constraints that a responsible engineering org would enforce — except the constraints are embedded in every command and cannot be overridden at runtime.

---

## The hard rules

These rules are enforced across every command. They are non-negotiable. There is no flag, config option, or prompt that disables them.

- **NEVER pushes to any remote** — all changes stay local on branches
- **NEVER deploys anywhere** — no Railway, Vercel, Netlify, AWS, or any platform
- **NEVER touches secrets or `.env` files** — credentials, tokens, and API keys are off-limits
- **NEVER modifies CI/CD pipelines** — GitHub Actions, CircleCI, Jenkins configs are untouchable
- **NEVER deletes files** — unless explicitly marked safe-to-delete in a burndown tracker
- **NEVER adds dependencies without approval** — new packages require a human decision
- **NEVER makes breaking changes** — no API changes, no removed exports, no interface changes

If something unexpected happens, every change is on a `burndown/YYYY-MM-DD` branch. Delete the branch and move on.

---

## Two-layer safety: defense in depth

Safety is enforced at two independent layers. Both must permit an action for it to happen.

**Layer 1: Prompt rules** — every command contains explicit safety instructions that Claude follows during execution. These are non-negotiable directives embedded in the prompt itself. Claude is told what it must never do, and it obeys.

**Layer 2: Tool allowlists** — when running on a schedule, the `--allowedTools` flag restricts which Claude Code tools can be invoked. This is a hard boundary enforced by Claude Code's runtime, not by the prompt. Even if the prompt were somehow manipulated, the tool layer blocks unauthorized actions.

This is defense in depth. The prompt layer defines intent. The tool layer enforces capability. Neither alone is sufficient. Together, they create a system where autonomous execution is bounded by design.

See [docs/SAFETY.md](docs/SAFETY.md) for the full safety model.

---

## Your virtual CISO

claude-burndown includes a three-command security suite that acts as a chief information security officer built into your development workflow. It scans, attacks, and models threats against your own code — automatically, on a schedule, without you needing to remember.

### `/security-check` — Continuous security monitoring

A tiered security audit for your entire development environment. Three tiers, each progressively deeper:

| Tier | What it checks | When to run |
|------|---------------|-------------|
| **Just-in-Time** | Secrets in staged files, dependency vetting, file permissions | Every commit / pre-push |
| **Weekly** | Git history secret scan, full dependency audit, background processes, GitHub repo visibility, active integrations | Monday nights |
| **Monthly** | OS security updates, credential rotation review, stale software cleanup, GitHub OAuth app audit | 1st of the month |

```bash
claude -p "/security-check"          # just-in-time + weekly (default)
claude -p "/security-check quick"    # just-in-time only (pre-push)
claude -p "/security-check monthly"  # all three tiers
```

### `/red-team` — Adversarial penetration testing

A full adversarial security test against your own application. Thinks like an attacker — creative, persistent, systematic. Five test suites:

1. **Prompt injection** — system prompt extraction, indirect injection via data channels, context overflow, tool manipulation, output poisoning
2. **Auth & authorization** — auth bypass, IDOR, rate limit testing, free tier bypass
3. **Input validation** — SQL injection, XSS, path traversal, command injection, oversized payloads
4. **Configuration & headers** — security headers, CORS, exposed debug endpoints, information disclosure
5. **Data exfiltration** — API key leakage, unbounded data returns, error message disclosure

Only tests your own application. Never touches third-party services.

### `/threat-model` — Attack surface mapping

Maps every way an attacker could compromise your system. Produces a living `THREATS.md` with data flow diagrams, adversary profiles (script kiddie through supply chain attacker), STRIDE analysis, risk ratings, and specific mitigations.

Think of it as the paranoid CISO who asks "what could go wrong?" before you ship.

---

## Commands

### Security suite

| Command | Purpose |
|---------|---------|
| `/security-check` | Tiered security audit — secrets, dependencies, credentials, configs |
| `/red-team` | Adversarial penetration testing against your own app |
| `/threat-model` | Attack surface mapping with STRIDE analysis and risk ratings |

### Development pipeline

| Command | Purpose |
|---------|---------|
| `/plan` | Multi-role architecture planning — CEO, Design, or Eng review modes |
| `/qa` | Full QA: test, find bugs, fix with atomic commits, verify, write regression tests |
| `/qa-only` | Bug audit without modifications — report only |
| `/qa-design` | Design QA: spacing, hierarchy, typography, visual bugs |
| `/ship` | Tests + secret scan + dependency audit + PR creation |

### Maintenance

| Command | Purpose |
|---------|---------|
| `/nightly-burndown` | Autonomous overnight code maintenance |
| `/document-release` | Auto-update docs to match shipped code |
| `/changelog` | Generate user-friendly release notes from git commits |
| `/retro` | Engineering retrospective — commit history, velocity, patterns |

### Utilities

| Command | Purpose |
|---------|---------|
| `/api-review` | Lint REST APIs for consistency across endpoints |
| `/design-consultation` | Design system proposal — aesthetic, typography, color, layout |
| `/release` | Semver tagging and GitHub release management |
| `/setup-browser-cookies` | Import browser cookies for authenticated Playwright testing |
| `/gstack-sync` | Check upstream gstack for new or updated skills |

---

## The full pipeline

These commands chain together into a complete development workflow:

```
/plan  ->  build  ->  /qa  ->  /ship  ->  /document-release
                                  |
                          /security-check
                          /red-team
                          /threat-model
```

| Step | Command | What happens |
|------|---------|-------------|
| 1 | `/plan` | Think through the approach, explore tradeoffs, get alignment |
| 2 | *(you + Claude)* | Write the code |
| 3 | `/qa` | Test, find bugs, fix with atomic commits, write regression tests |
| 4 | `/ship` | Run tests, scan for secrets, audit dependencies, create PR |
| 5 | `/document-release` | Update all docs to match the code |
| 6 | `/nightly-burndown` | Autonomous overnight maintenance (scheduled) |
| 7 | `/security-check` | Continuous security audits (scheduled) |

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
    notes: ~/notes/api-burndown.md
    exclude: [.venv, __pycache__]
```

### 3. Run

From within a Claude Code session:
```
/nightly-burndown
/security-check
/red-team
/threat-model
```

From the command line:
```bash
claude -p /nightly-burndown
claude -p "/security-check weekly"
```

Or let them run on a schedule.

---

## Scheduling

The installer offers automated scheduling for all recurring commands:

| Command | Default schedule | Purpose |
|---------|-----------------|---------|
| `/nightly-burndown` | Daily at 12:30am | Autonomous code maintenance |
| `/security-check weekly` | Monday at 1:00am | Security audit |
| `/security-check monthly` | 1st of month at 2:00am | Deep security audit |

All jobs run during off-peak hours (midnight-5am) to minimize token costs.

| Platform | Method | Runs when asleep? |
|----------|--------|-------------------|
| macOS | launchd | Runs on wake |
| Linux | systemd user timer | Yes (if machine is on) |
| Any Unix | cron | Yes (if machine is on) |

Templates are in `scheduling/launchd/` and `scheduling/systemd/`. See [docs/SCHEDULING.md](docs/SCHEDULING.md) for management commands.

---

## How it works

claude-burndown commands are [Claude Code slash commands](https://docs.anthropic.com/en/docs/claude-code) — markdown files that Claude interprets as structured instructions. The entire "program" is a prompt. There is no traditional code.

- **Zero dependencies** beyond Claude Code
- **No build step, no runtime** — runs inside your existing Claude Code environment
- **Fully customizable** — edit the markdown files to change any behavior
- **Portable** — works on any project in any language

---

## Configuration

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
- git

## Attribution

Adapted from [garrytan/gstack](https://github.com/garrytan/gstack). Extended with a security suite (security-check, red-team, threat-model), autonomous overnight execution (nightly-burndown), and automated upstream sync (gstack-sync).

## Contributing

Contributions welcome. The commands live in `commands/` — each is a markdown prompt that drives all behavior. If you find tasks it should handle, safety rules it should enforce, or scanning patterns it misses, open an issue or PR.

## License

MIT
