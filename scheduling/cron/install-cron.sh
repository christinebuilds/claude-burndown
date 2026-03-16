#!/bin/bash
# Install a cron job for claude-burndown
# Usage: ./install-cron.sh [hour] [minute]

HOUR="${1:-22}"
MINUTE="${2:-0}"
CLAUDE_PATH="$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")"
LOG_DIR="${HOME}/burndown-logs"

mkdir -p "$LOG_DIR"

CRON_LINE="$MINUTE $HOUR * * * cd $HOME && $CLAUDE_PATH -p /nightly-burndown --allowedTools Edit,Write,Bash,Read,Glob,Grep,Agent,Skill > $LOG_DIR/latest.log 2> $LOG_DIR/latest-error.log"

# Check if already installed
if crontab -l 2>/dev/null | grep -q "nightly-burndown"; then
    echo "Burndown cron job already exists. Replacing..."
    crontab -l 2>/dev/null | grep -v "nightly-burndown" | crontab -
fi

(crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -

echo "Installed cron job: burndown runs daily at ${HOUR}:$(printf '%02d' $MINUTE)"
echo "Logs: $LOG_DIR/latest.log"
