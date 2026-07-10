#!/usr/bin/env bash
# Stop hook: fire-and-forget GLM review of TRACKED uncommitted changes.
# Every time Claude finishes a turn with an uncommitted diff, a free/cheap
# second pair of eyes (GLM via ask-glm) reviews it in the background.
# Skips silently when:
#   - stop_hook_active (re-entry guard)
#   - cwd not a git repo
#   - no TRACKED diff (untracked-only changes are ignored — they're either
#     local-only helpers or already reviewed in a prior run)
# Logs full output to ~/.claude/logs/glm-review-<ts>.log
# Returns immediately — never blocks Claude.

set -uo pipefail

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | /usr/bin/jq -r '.cwd // ""')
ACTIVE=$(printf '%s' "$INPUT" | /usr/bin/jq -r '.stop_hook_active // false')

[ "$ACTIVE" = "true" ] && exit 0
[ -z "$CWD" ] && exit 0
[ ! -d "$CWD" ] && exit 0
cd "$CWD" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Tracked changes only. If git diff (unstaged) AND git diff --cached (staged)
# are both empty, skip — anything in `git status` is untracked-only.
if git diff --quiet && git diff --cached --quiet; then
  exit 0
fi

ASK_GLM_BIN="${ASK_GLM_BIN:-$HOME/.local/bin/ask-glm}"
[ ! -x "$ASK_GLM_BIN" ] && ASK_GLM_BIN=$(command -v ask-glm || true)
[ -z "$ASK_GLM_BIN" ] && exit 0

LOG_DIR="${HOME}/.claude/logs"
mkdir -p "$LOG_DIR"
TS=$(date +%Y%m%d-%H%M%S)
LOG="${LOG_DIR}/glm-review-${TS}.log"

DIFF=$( { git diff; git diff --cached; } | head -c 60000 )

# Write the prompt to a temp file to avoid shell-quoting issues (diffs can
# contain quotes/backticks/$) when handing it off to the detached subshell.
PROMPT_FILE=$(mktemp "${TMPDIR:-/tmp}/glm-review-prompt.XXXXXX")
{
  printf '%s\n' "You are a strict senior code reviewer. Review this uncommitted diff for real bugs (correctness, security, data-loss). Report only genuine issues with file:line; if none, reply CLEAN."
  printf '\n%s\n' "$DIFF"
} > "$PROMPT_FILE"

# Fire-and-forget. Detached, won't keep the parent alive.
nohup bash -c "
  perl -e 'alarm shift; exec @ARGV' 180 '$ASK_GLM_BIN' < '$PROMPT_FILE' > '$LOG' 2>&1
  rm -f '$PROMPT_FILE'
" >/dev/null 2>&1 &
disown 2>/dev/null || true

exit 0
