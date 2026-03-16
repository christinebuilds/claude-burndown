# Configuration

claude-burndown uses a YAML config file at `~/.config/claude-burndown/burndown.yaml`.

## Full reference

```yaml
# Where to write burndown reports (one file per run)
log_dir: ~/burndown-logs

# Maximum minutes to spend on autonomous tasks per run
max_execution_minutes: 60

# Projects to scan
projects:
  - name: my-webapp              # Display name (required)
    path: ~/code/my-webapp       # Absolute or ~ path to project root (required)
    notes: ~/notes/webapp.md     # Optional: burndown tracker file
    exclude:                     # Optional: directories to skip when scanning
      - node_modules
      - .next
      - dist
      - .venv

  - name: my-api
    path: ~/code/my-api
    exclude: [.venv, __pycache__]

# Safety overrides
safety:
  allow_delete_untracked: false
  allow_dependency_updates: true
  require_tests_pass: true
```

## Fields

### `log_dir`

Directory where burndown reports are written. One markdown file per run, named `YYYY-MM-DD.md`. Created automatically if it doesn't exist.

### `max_execution_minutes`

Time cap for autonomous work in a single run. Tasks beyond this limit are logged as "deferred" in the report. Default: 60.

### `projects`

A list of projects to scan. Each project has:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Display name for reports |
| `path` | Yes | Path to the project root. Supports `~`. |
| `notes` | No | Path to a burndown tracker file. If present, completed tasks are checked off here. |
| `exclude` | No | List of directory names to skip when scanning for TODOs and issues. Common choices: `node_modules`, `.venv`, `dist`, `build`, `vendor`, `__pycache__` |

### `safety`

| Field | Default | Description |
|-------|---------|-------------|
| `allow_delete_untracked` | `false` | Allow deleting files not tracked by git |
| `allow_dependency_updates` | `true` | Allow updating dependencies to newer patch versions |
| `require_tests_pass` | `true` | Revert changes if tests fail after modification |

## Tips

- Start with 1-2 projects and expand once you trust the output
- Set `max_execution_minutes: 15` for the first few runs to keep changes small
- Use the `notes` field if you maintain a burndown tracker — completed tasks will be checked off automatically
- Check `~/burndown-logs/` after each run to review what was done
