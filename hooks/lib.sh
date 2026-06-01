#!/usr/bin/env bash
# Helmsman hooks shared library.
# Source this file in every hook: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
#
# Provides: find_workspace, active_state_file, yaml_field, stage_status

# ── Workspace discovery ──────────────────────────────────────────────────────

# Returns the Helmsman workspace root (directory containing manifest.yaml).
# Priority: $HELMSMAN_WORKSPACE env var → walk up from the hook's own dir →
#           walk up from cwd. Exits with code 0 (silently) if not found so
#           callers can `|| exit 0` without noise.
find_workspace() {
  if [[ -n "${HELMSMAN_WORKSPACE:-}" && -f "$HELMSMAN_WORKSPACE/manifest.yaml" ]]; then
    echo "$HELMSMAN_WORKSPACE"
    return 0
  fi

  # Walk up from the hooks/ directory (works when the hook is called by path)
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" 2>/dev/null && pwd)"
  dir="$(dirname "$dir")"   # step out of hooks/
  if [[ -f "$dir/manifest.yaml" ]]; then
    echo "$dir"
    return 0
  fi

  # Walk up from cwd
  dir="$(pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/manifest.yaml" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  return 1
}

# ── State file discovery ─────────────────────────────────────────────────────

# Returns the path to the most recently modified state.yaml in the workspace.
# Exits 1 (silently) if none found.
active_state_file() {
  local workspace="${1:?workspace required}"
  local projects_dir="$workspace/projects"
  [[ -d "$projects_dir" ]] || return 1

  local state
  state=$(find "$projects_dir" -maxdepth 2 -name "state.yaml" -print0 2>/dev/null \
    | xargs -0 ls -t 2>/dev/null \
    | head -1)
  [[ -n "$state" ]] || return 1
  echo "$state"
}

# ── YAML helpers (pure bash, no external deps) ───────────────────────────────

# yaml_field <key> <file>  →  value of a top-level scalar key
# Strips surrounding quotes. Returns empty string if not found.
yaml_field() {
  local key="$1" file="$2"
  grep "^${key}:" "$file" 2>/dev/null \
    | head -1 \
    | sed 's/^[^:]*:[[:space:]]*//' \
    | tr -d "\"'"
}

# stage_status <stage-id> <state-file>
# Extracts the `status:` value from the given stage block.
stage_status() {
  local stage="$1" file="$2"
  # The stage key appears as `  "<stage-id>":` (2-space indent, quoted)
  # The status field appears as `    status: <value>` (4-space indent)
  awk -v s="\"$stage\":" '
    $0 ~ "^  " s { found=1; next }
    found && /^    status:/ {
      gsub(/^[[:space:]]*status:[[:space:]]*/, "")
      gsub(/"/, "")
      print
      exit
    }
    found && /^  [^ ]/ { exit }   # reached next stage — not found
  ' "$file"
}

# stage_label <stage-id> <state-file>
stage_label() {
  local stage="$1" file="$2"
  awk -v s="\"$stage\":" '
    $0 ~ "^  " s { found=1; next }
    found && /^    label:/ {
      gsub(/^[[:space:]]*label:[[:space:]]*/, "")
      gsub(/"/, "")
      print
      exit
    }
    found && /^  [^ ]/ { exit }
  ' "$file"
}
