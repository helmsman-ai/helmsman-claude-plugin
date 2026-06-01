#!/usr/bin/env bash
# Helmsman — validate-manifests hook
#
# Event:   PostToolUse (matcher: Write|Edit)
# Purpose: After any Write or Edit to a plugin.json, compare the two manifest
#          files for divergence and check that every registered path exists on
#          disk. Outputs a report to stdout so Claude sees it as context.
#
# Configure in .claude/settings.json:
#   "PostToolUse": [{
#     "matcher": "Write|Edit",
#     "hooks": [{"type": "command", "command": "/path/to/hooks/validate-manifests.sh"}]
#   }]
#
# Requires: jq (exits 0 silently if absent)
# Exit 0 always — this hook never blocks.

set -euo pipefail

# ── Require jq ────────────────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  exit 0
fi

# ── Parse file path from stdin JSON ──────────────────────────────────────────
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0

# Only run when a plugin.json was touched
[[ "$FILE_PATH" == *plugin.json ]] || exit 0

# ── Locate helmsman directory ─────────────────────────────────────────────────
# Walk up from the edited file to find the directory containing plugin.json and
# .claude-plugin/plugin.json.
HELMSMAN_DIR=""
dir="$(dirname "$FILE_PATH")"
while [[ "$dir" != "/" ]]; do
  if [[ -f "$dir/plugin.json" && -d "$dir/.claude-plugin" ]]; then
    HELMSMAN_DIR="$dir"
    break
  fi
  # Also accept: we're already inside .claude-plugin/
  parent="$(dirname "$dir")"
  if [[ -f "$parent/plugin.json" && -d "$parent/.claude-plugin" ]]; then
    HELMSMAN_DIR="$parent"
    break
  fi
  dir="$parent"
done

if [[ -z "$HELMSMAN_DIR" ]]; then
  # Fall back: try the hook's own parent directory
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  HELMSMAN_DIR="$(dirname "$SCRIPT_DIR")"
fi

MAIN_MANIFEST="$HELMSMAN_DIR/plugin.json"
PLUGIN_MANIFEST="$HELMSMAN_DIR/.claude-plugin/plugin.json"

[[ -f "$MAIN_MANIFEST" && -f "$PLUGIN_MANIFEST" ]] || exit 0

# ── Comparison helpers ────────────────────────────────────────────────────────

# Extract a top-level array field as a sorted newline-separated list.
extract_sorted() {
  local file="$1" field="$2"
  jq -r --arg f "$field" '.[$f] // [] | .[]' "$file" 2>/dev/null | sort
}

# Print items in $1 but not in $2 (both are sorted lists passed as variables).
only_in() {
  comm -23 <(echo "$1") <(echo "$2") 2>/dev/null
}

ISSUES=()
MISSING_FILES=()

# ── Section-by-section diff ───────────────────────────────────────────────────
for section in agents commands skills modes; do
  MAIN_LIST=$(extract_sorted "$MAIN_MANIFEST" "$section")
  PLUGIN_LIST=$(extract_sorted "$PLUGIN_MANIFEST" "$section")

  IN_MAIN_ONLY=$(only_in "$MAIN_LIST" "$PLUGIN_LIST")
  IN_PLUGIN_ONLY=$(only_in "$PLUGIN_LIST" "$MAIN_LIST")

  if [[ -n "$IN_MAIN_ONLY" ]]; then
    while IFS= read -r entry; do
      ISSUES+=("  [plugin.json only] $section: $entry")
    done <<< "$IN_MAIN_ONLY"
  fi

  if [[ -n "$IN_PLUGIN_ONLY" ]]; then
    while IFS= read -r entry; do
      ISSUES+=("  [.claude-plugin/plugin.json only] $section: $entry")
    done <<< "$IN_PLUGIN_ONLY"
  fi
done

# ── File existence check (union of both manifests) ────────────────────────────
ALL_PATHS=$(jq -r '
  (.agents // []) + (.commands // []) + (.skills // []) + (.modes // []) | .[]
' "$MAIN_MANIFEST" "$PLUGIN_MANIFEST" 2>/dev/null | sort -u)

while IFS= read -r rel_path; do
  [[ -z "$rel_path" ]] && continue
  abs_path="$HELMSMAN_DIR/${rel_path#./}"
  if [[ ! -e "$abs_path" ]]; then
    MISSING_FILES+=("  $rel_path  →  $abs_path")
  fi
done <<< "$ALL_PATHS"

# ── Output ────────────────────────────────────────────────────────────────────
if [[ ${#ISSUES[@]} -eq 0 && ${#MISSING_FILES[@]} -eq 0 ]]; then
  echo "[Helmsman] plugin.json manifests are in sync and all registered paths exist."
  exit 0
fi

echo "[Helmsman] plugin.json validation found issues:"
echo ""

if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo "Manifest divergence (entries present in one file but not the other):"
  for issue in "${ISSUES[@]}"; do
    echo "$issue"
  done
  echo ""
fi

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
  echo "Registered paths that do not exist on disk:"
  for mf in "${MISSING_FILES[@]}"; do
    echo "$mf"
  done
  echo ""
fi

echo "Fix: update both plugin.json and .claude-plugin/plugin.json to match, and ensure all referenced files exist."

exit 0
