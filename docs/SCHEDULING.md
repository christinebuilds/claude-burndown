# Scheduling

claude-burndown can run automatically on a schedule. The installer handles setup, but here's what happens under the hood for each platform.

## macOS (launchd)

The installer creates a Launch Agent at `~/Library/LaunchAgents/com.claude.nightly-burndown.plist`.

```bash
# Check status
launchctl list | grep claude

# Run immediately (for testing)
launchctl start com.claude.nightly-burndown

# Stop the schedule
launchctl unload ~/Library/LaunchAgents/com.claude.nightly-burndown.plist

# Restart the schedule
launchctl load ~/Library/LaunchAgents/com.claude.nightly-burndown.plist
```

**Note:** launchd only runs when your Mac is awake. If it's asleep at the scheduled time, the job runs when you next wake it.

## Linux (systemd)

The installer creates a user service and timer at `~/.config/systemd/user/`.

```bash
# Check status
systemctl --user status claude-burndown.timer

# Run immediately (for testing)
systemctl --user start claude-burndown.service

# View logs
journalctl --user -u claude-burndown.service

# Stop the schedule
systemctl --user stop claude-burndown.timer
systemctl --user disable claude-burndown.timer

# Restart the schedule
systemctl --user enable claude-burndown.timer
systemctl --user start claude-burndown.timer
```

## Cron (any Unix)

The installer adds a crontab entry.

```bash
# View the cron job
crontab -l | grep burndown

# Remove it
crontab -l | grep -v "nightly-burndown" | crontab -
```

## Changing the schedule

Re-run the installer to change the time:

```bash
cd claude-burndown
./install.sh
```

Or edit the schedule directly:
- **macOS:** Edit the `Hour` and `Minute` values in `~/Library/LaunchAgents/com.claude.nightly-burndown.plist`, then `launchctl unload` + `launchctl load`
- **Linux:** Edit `~/.config/systemd/user/claude-burndown.timer`, then `systemctl --user daemon-reload`
- **Cron:** `crontab -e` and modify the time fields

## Running manually

You can always run the burndown manually, with or without scheduling:

```bash
claude -p /nightly-burndown
```

Or from within a Claude Code session:

```
/nightly-burndown
```
