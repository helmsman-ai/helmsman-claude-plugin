#!/usr/bin/env bash
# Helmsman — pre-push-guard hook
#
# Event:   PreToolUse (matcher: Bash)
# Purpose: Block `git push` if the active project has not yet completed the
#          pre-launch stage (08-pre-launch or equivalent final gated stage).
#          Protects against shipping code that bypassed the launch checklist.
#
# Configure in .claude/settings.json:
#   "PreToolUse": [{
#     "matcher": "Bash",
#     "hooks": [{"type": "command", "command": "/path/to/hooks/pre-push-guard.sh"}]
#   }]
#
# Exit codes:
#   0  — allow the tool call
#   2  — block the tool call (stderr message shown to user and Claude)

set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── Parse the Bash command from stdin JSON ────────────────────────────────────
# Requires jq. If jq is absent, allow the push (fail open — don't break workflow).
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
[[ "$TOOL_NAME" == "Bash" ]] || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[[ -z "$COMMAND" ]] && exit 0

# ── Check if this is a git push ───────────────────────────────────────────────
# Match: git push, git push --force, git push origin main, etc.
# Do not match: git push --dry-run (informational only).
if ! echo "$COMMAND" | grep -qE '(^|[;&|])[[:space:]]*(git[[:space:]]+push)[[:space:]]'; then
  exit 0
fi
if echo "$COMMAND" | grep -q -- '--dry-run'; then
  exit 0
fi

# ── Find workspace and active project ─────────────────────────────────────────
WORKSPACE=$(find_workspace) || exit 0
STATE=$(active_state_file "$WORKSPACE") || exit 0

PROJECT=$(yaml_field project "$STATE")
[[ -z "$PROJECT" ]] && exit 0

# ── Find the pre-launch stage ─────────────────────────────────────────────────
# We look for a stage whose ID contains "pre-launch" or "pre_launch".
# Falls back to checking 08-pre-launch directly.
STAGE_ORDER=$(grep "^stage_order:" "$STATE" -A 50 \
  | awk '/^stage_order:/,/^[a-z]/' \
  | grep "^  - " \
  | sed 's/^  - //;s/"//g') || true

PRELAUNCH_STAGE=""
while IFS= read -r sid; do
  if [[ "$sid" == *pre*launch* || "$sid" == *pre-launch* ]]; then
    PRELAUNCH_STAGE="$sid"
    break
  fi
done <<< "$STAGE_ORDER"

# Fallback: check for 08-pre-launch by name
[[ -z "$PRELAUNCH_STAGE" ]] && PRELAUNCH_STAGE="08-pre-launch"

# ── Check pre-launch stage status ────────────────────────────────────────────
PRELAUNCH_STATUS=$(stage_status "$PRELAUNCH_STAGE" "$STATE")

if [[ "$PRELAUNCH_STATUS" != "complete" ]]; then
  cat >&2 <<EOF
🚫 Helmsman: git push blocked for project "$PROJECT"

The pre-launch stage ($PRELAUNCH_STAGE) has not been approved.
Current status: ${PRELAUNCH_STATUS:-not started}

Complete the pre-launch checklist and run /approve before pushing:
  1. Run /advance to reach the pre-launch stage (if not there yet)
  2. Review the pre-mortem and rollback plan in $PRELAUNCH_STAGE/
  3. Run /approve to mark pre-launch complete
  4. Then retry your git push

To bypass this check (not recommended):
  Set HELMSMAN_SKIP_PUSH_GUARD=1 in your environment and retry.
EOF
  exit 2
fi

exit 0
