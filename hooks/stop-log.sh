#!/usr/bin/env bash
# Helmsman — stop-log hook
#
# Event:   Stop
# Purpose: Append a session-end marker to the active project's decisions.log.md
#          whenever a Claude Code session ends. Provides an audit trail of
#          which sessions touched a project without requiring manual logging.
#
# Configure in .claude/settings.json:
#   "Stop": [{"hooks": [{"type": "command", "command": "/path/to/hooks/stop-log.sh"}]}]
#
# This hook never outputs to stdout (that would continue the conversation).
# All output goes to stderr (shown in terminal, not to Claude).
# Exit 0 always — this hook never blocks.

set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── Find workspace and active project ─────────────────────────────────────────
WORKSPACE=$(find_workspace) || exit 0
STATE=$(active_state_file "$WORKSPACE") || exit 0

PROJECT=$(yaml_field project "$STATE")
[[ -z "$PROJECT" ]] && exit 0

# ── Read session info ─────────────────────────────────────────────────────────
SESSION_ID=""
TRANSCRIPT_PATH=""
if command -v jq &>/dev/null; then
  INPUT=$(cat)
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null) || true
  TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null) || true
fi

CURRENT=$(yaml_field current_stage "$STATE")
LABEL=$(stage_label "$CURRENT" "$STATE")
STATUS=$(stage_status "$CURRENT" "$STATE")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE=$(date -u +"%Y-%m-%d")

# ── Write session marker to decisions.log.md ─────────────────────────────────
DECISIONS_LOG="$WORKSPACE/projects/$PROJECT/decisions.log.md"
[[ -f "$DECISIONS_LOG" ]] || exit 0  # don't create the file; just append if it exists

cat >> "$DECISIONS_LOG" <<EOF

---

## $DATE — Session ended

- **Stage at close:** $CURRENT — ${LABEL:-$CURRENT} ($STATUS)
- **Session ID:** ${SESSION_ID:-unknown}
- **Transcript:** ${TRANSCRIPT_PATH:-not recorded}
EOF

# Clean up session marker file so next session gets a fresh start banner
SESSION_MARKER="/tmp/helmsman-session-${SESSION_ID:-default}"
rm -f "$SESSION_MARKER" 2>/dev/null || true

exit 0
