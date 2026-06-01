#!/usr/bin/env bash
# Helmsman — inject-state hook
#
# Event:   UserPromptSubmit
# Purpose: Inject the active project's stage and status as context before
#          every prompt. On the first prompt of a session, shows a richer
#          welcome banner so Claude knows Helmsman is active.
#
# Configure in .claude/settings.json:
#   "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "/path/to/hooks/inject-state.sh"}]}]
#
# Output on stdout is injected by Claude Code as context before the prompt.
# Exit 0 always — this hook never blocks.

set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── Find workspace ────────────────────────────────────────────────────────────
WORKSPACE=$(find_workspace) || exit 0
STATE=$(active_state_file "$WORKSPACE") || exit 0

# ── Read core fields ──────────────────────────────────────────────────────────
PROJECT=$(yaml_field project "$STATE")
MODE=$(yaml_field mode    "$STATE")
CURRENT=$(yaml_field current_stage "$STATE")

[[ -z "$PROJECT" || -z "$CURRENT" ]] && exit 0

STATUS=$(stage_status "$CURRENT" "$STATE")
LABEL=$(stage_label  "$CURRENT" "$STATE")
FAST_TRACK=$(yaml_field fast_track "$STATE")

# ── Session-start detection ───────────────────────────────────────────────────
# Read session_id from stdin JSON (requires jq; gracefully degrades without it).
SESSION_ID=""
if command -v jq &>/dev/null; then
  SESSION_ID=$(jq -r '.session_id // empty' 2>/dev/null) || true
fi

SESSION_MARKER="/tmp/helmsman-session-${SESSION_ID:-default}"
IS_SESSION_START=false
if [[ -n "$SESSION_ID" && ! -f "$SESSION_MARKER" ]]; then
  touch "$SESSION_MARKER"
  IS_SESSION_START=true
fi

# ── Status icon ───────────────────────────────────────────────────────────────
case "$STATUS" in
  complete)    ICON="✅" ;;
  in-review)   ICON="👁" ;;
  in-progress) ICON="🔄" ;;
  *)           ICON="⏳" ;;
esac

FAST_TRACK_TAG=""
[[ "$FAST_TRACK" == "true" ]] && FAST_TRACK_TAG=" ⚡fast-track"

# ── Output ────────────────────────────────────────────────────────────────────
if $IS_SESSION_START; then
  # Rich banner for the first prompt of a session.
  # Also show pending action hint based on status.
  PENDING_ACTION=""
  case "$STATUS" in
    in-review)   PENDING_ACTION="Run /approve to accept, or /comment \"<feedback>\" to request changes." ;;
    in-progress) PENDING_ACTION="Agent is working. Run /status for details." ;;
    complete)    PENDING_ACTION="Run /advance to move to the next stage." ;;
    pending)     PENDING_ACTION="Run /advance to start this stage." ;;
  esac

  cat <<EOF
[Helmsman] Session started — workspace: $WORKSPACE
Active project : $PROJECT ($MODE mode$FAST_TRACK_TAG)
Current stage  : $CURRENT — ${LABEL:-$CURRENT} $ICON $STATUS
${PENDING_ACTION:+Next action    : $PENDING_ACTION}
Run /status for the full pipeline view.
EOF
else
  # Compact one-liner for subsequent prompts.
  echo "[Helmsman] $PROJECT | $CURRENT (${LABEL:-$CURRENT}) $ICON $STATUS"
fi
