#!/bin/bash
# Stop hook: nudge Claude to document a just-completed job to the Obsidian wiki
# (~/claude-obsidian/wiki). The nudge is a decision:block with instructions;
# Claude judges whether a substantive job actually finished.
#
# Two gates keep this from taxing every turn:
#   1. stop_hook_active=true  -> already continuing from a Stop hook; stay silent
#      (prevents nudge loops within a single stop cycle).
#   2. per-session cooldown   -> fire at most once per COOLDOWN seconds per
#      session, so trivial back-to-back turns don't each pay a forced nudge.
#      Re-arms after the cooldown so a job that finishes later in a long session
#      still gets caught. Tune COOLDOWN below (seconds).
COOLDOWN=2700   # 45 min

IN=$(cat)
if echo "$IN" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

SID=$(echo "$IN" | jq -r '.session_id // "default"' 2>/dev/null || echo default)
MARKER="/tmp/wiki-doc-nudge.${SID}.last"
NOW=$(date +%s)
if [ -f "$MARKER" ]; then
  LAST=$(cat "$MARKER" 2>/dev/null || echo 0)
  [ "$LAST" -eq "$LAST" ] 2>/dev/null || LAST=0
  if [ $((NOW - LAST)) -lt "$COOLDOWN" ]; then
    exit 0
  fi
fi
echo "$NOW" > "$MARKER"

cat <<'EOF'
{"decision":"block","reason":"[wiki-doc nudge] Only if this turn produced DURABLE, REUSABLE knowledge worth re-reading months from now — new system/subsystem architecture, a non-obvious gotcha that will recur, or a significant decision + rationale — capture it: update the relevant ~/claude-obsidian/wiki page (or create one, add to index.md), OR if it's an active work thread, add/update ONE lean line in MEMORY.md. Prefer updating an existing page over creating a new one. Then stop. SKIP (just stop, no output — this is the common case) if ANY of: simple Q&A/conversation; job still mid-phase or awaiting review; already documented this session; OR the change is a routine bugfix, UI tweak, refactor, or small/single-file change whose commit message + diff already ARE the record (git history covers these — do NOT write a page for them). The test: would I need to re-read this to make a future decision, AND is it not already captured by git or existing docs? If no, skip."}
EOF
