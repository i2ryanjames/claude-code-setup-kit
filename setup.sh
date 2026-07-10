#!/usr/bin/env bash
# setup.sh — layered installer for the claude-code-setup-kit.
#
# Safe by design:
#   - every layer is optional (you're asked before each one)
#   - never overwrites an existing file without backing it up first
#   - merges hook config into ~/.claude/settings.json additively (jq),
#     with a timestamped backup and a printed diff
#
# Run it from the repo root:   bash setup.sh
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kit"
CLAUDE_DIR="$HOME/.claude"
BIN_DIR="$HOME/.local/bin"
TS="$(date +%Y%m%d-%H%M%S)"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*"; }
skip()  { printf '  \033[2m- %s\033[0m\n' "$*"; }

ask_yn() {  # ask_yn "question" -> 0 yes / 1 no
  local reply
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy] ]]
}

# Copy $1 -> $2. If the destination exists and differs, back it up first.
install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      skip "$(basename "$dst") already installed (identical)"
      return 0
    fi
    cp "$dst" "${dst}.bak-${TS}"
    warn "$(basename "$dst") existed and differed — backed up to $(basename "$dst").bak-${TS}"
  fi
  cp "$src" "$dst"
  info "installed $dst"
}

[[ -d "$KIT_DIR" ]] || { echo "setup.sh must be run from the repo root (kit/ not found)"; exit 1; }

bold "claude-code-setup-kit installer"
echo

# ---------------------------------------------------------------- preflight
bold "Preflight — checking prerequisites"
OS="linux"
[[ "$(uname -s)" == "Darwin" ]] && OS="mac"
grep -qi microsoft /proc/version 2>/dev/null && OS="wsl"
info "platform: $OS"

MISSING=()
for cmd in git jq curl python3 node npm; do
  if command -v "$cmd" >/dev/null 2>&1; then
    info "$cmd $(command -v "$cmd")"
  else
    MISSING+=("$cmd")
    warn "$cmd is missing"
  fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  if [[ "$OS" == "mac" ]]; then
    echo "  Install the missing tools with Homebrew (see docs/02-install-mac.md):"
    echo "      brew install ${MISSING[*]}"
  else
    echo "  Install the missing tools (see docs/03-install-windows.md):"
    echo "      sudo apt update && sudo apt install -y ${MISSING[*]}"
    echo "  (node/npm are best installed via nvm — see the doc.)"
  fi
  echo "  Re-run setup.sh afterwards."
  exit 1
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) info "$BIN_DIR is on PATH" ;;
  *) warn "$BIN_DIR is not on your PATH — add this to your shell profile:
      export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac
echo

# ------------------------------------------------------- layer 1: claude code
bold "Layer 1 — Claude Code"
if command -v claude >/dev/null 2>&1; then
  info "Claude Code already installed: $(claude --version 2>/dev/null || echo present)"
else
  if ask_yn "Install Claude Code globally via npm?"; then
    npm install -g @anthropic-ai/claude-code
    info "installed — now run 'claude' in any folder and log in with your Anthropic account"
  else
    skip "skipped — install later with: npm install -g @anthropic-ai/claude-code"
  fi
fi
echo

# --------------------------------------------------------- layer 2: mcp stack
bold "Layer 2 — MCP tool stack (user scope: available in every project)"
if command -v claude >/dev/null 2>&1 && ask_yn "Add the recommended MCP servers?"; then
  add_mcp() {  # add_mcp <name> <cmd...>
    local name="$1"; shift
    if claude mcp get "$name" >/dev/null 2>&1; then
      skip "mcp '$name' already configured"
    else
      claude mcp add --scope user "$name" -- "$@" && info "added mcp '$name'"
    fi
  }
  add_mcp shadcn npx -y shadcn@latest mcp
  add_mcp magic-ui npx -y @magicuidesign/mcp
  add_mcp context7 npx -y @upstash/context7-mcp
  add_mcp playwright npx -y @playwright/mcp@latest
  add_mcp chrome-devtools npx -y chrome-devtools-mcp@latest
  if claude mcp get magic >/dev/null 2>&1; then
    skip "mcp 'magic' already configured"
  else
    read -r -p "  21st.dev API key for the 'magic' component builder (Enter to skip): " MAGIC_KEY
    if [[ -n "$MAGIC_KEY" ]]; then
      claude mcp add --scope user magic --env API_KEY="$MAGIC_KEY" -- npx -y @21st-dev/magic@latest \
        && info "added mcp 'magic'"
    else
      skip "skipped 'magic' (add later — see docs/07-mcp-stack.md)"
    fi
  fi
  echo "  Plugins (vercel, supabase, ui-ux-pro-max, figma) are installed INSIDE Claude Code"
  echo "  with /plugin — see docs/06-skills-plugins.md."
else
  skip "skipped MCP stack (docs/07-mcp-stack.md has the manual commands)"
fi
echo

# ------------------------------------------------------ layer 3: second brain
bold "Layer 3 — Second brain (Obsidian-compatible knowledge vault)"
if ask_yn "Set up the knowledge vault at ~/claude-obsidian?"; then
  if [[ -d "$HOME/claude-obsidian" ]]; then
    skip "~/claude-obsidian already exists — leaving it untouched"
  elif ask_yn "  Clone the full claude-obsidian starter (github.com/AgriciDaniel/claude-obsidian)? 'n' creates a bare vault"; then
    git clone https://github.com/AgriciDaniel/claude-obsidian "$HOME/claude-obsidian"
    info "cloned starter vault"
  else
    mkdir -p "$HOME/claude-obsidian/wiki"
    printf '# Wiki index\n\nCatalog of all pages in this vault. One line per page.\n' \
      > "$HOME/claude-obsidian/wiki/index.md"
    info "created bare vault at ~/claude-obsidian/wiki"
  fi
  [[ -f "$HOME/claude-obsidian/wiki/hot.md" ]] \
    && skip "wiki/hot.md already exists" \
    || { cp "$KIT_DIR/templates/hot-starter.md" "$HOME/claude-obsidian/wiki/hot.md"; info "installed wiki/hot.md starter"; }
  install_file "$KIT_DIR/hooks/session-start-hotcache.sh" "$CLAUDE_DIR/hooks/session-start-hotcache.sh"
  chmod +x "$CLAUDE_DIR/hooks/session-start-hotcache.sh"
  INSTALL_SESSION_HOOK=1
else
  skip "skipped second brain (docs/08-second-brain.md)"
  INSTALL_SESSION_HOOK=0
fi
echo

# ------------------------------------------- layer 4: GLM delegation harness
bold "Layer 4 — Delegation harness (Ollama + GLM/Gemma + subagents)"
INSTALL_STOP_HOOKS=0
if ask_yn "Install the delegation harness?"; then
  if ! command -v ollama >/dev/null 2>&1; then
    if [[ "$OS" == "mac" ]]; then
      if command -v brew >/dev/null 2>&1 && ask_yn "  Install Ollama via Homebrew?"; then
        brew install --cask ollama
      else
        warn "install Ollama from https://ollama.com/download then re-run this layer"
      fi
    else
      if ask_yn "  Install Ollama via the official install script?"; then
        curl -fsSL https://ollama.com/install.sh | sh
      fi
    fi
  else
    info "ollama already installed"
  fi

  if command -v ollama >/dev/null 2>&1; then
    if ask_yn "  Pull the free local model gemma4:e4b (~10 GB download)?"; then
      ollama pull gemma4:e4b
    fi
    echo "  For the GLM/Kimi cloud models, sign in once:  ollama signin"
    echo "  (they run as glm-5.2:cloud and kimi-k2.7-code:cloud — no local download)"
  fi

  for f in ask-glm ask-gemma glm-do; do
    install_file "$KIT_DIR/bin/$f" "$BIN_DIR/$f"
    chmod +x "$BIN_DIR/$f"
  done
  for f in gemma-helper.md glm-helper.md glm-coder.md; do
    install_file "$KIT_DIR/agents/$f" "$CLAUDE_DIR/agents/$f"
  done
  install_file "$KIT_DIR/hooks/glm-review.sh" "$CLAUDE_DIR/hooks/glm-review.sh"
  install_file "$KIT_DIR/hooks/wiki-doc-nudge.sh" "$CLAUDE_DIR/hooks/wiki-doc-nudge.sh"
  chmod +x "$CLAUDE_DIR/hooks/glm-review.sh" "$CLAUDE_DIR/hooks/wiki-doc-nudge.sh"
  INSTALL_STOP_HOOKS=1

  echo "  Protect sensitive repos from autonomous edits — add to your shell profile:"
  echo "      export GLM_DO_FORBIDDEN_PATHS=\"\$HOME/my-private-repo\""
else
  skip "skipped delegation harness (docs/10-delegation-harness.md)"
fi
echo

# ------------------------------------------------- CLAUDE.md + memory starter
bold "Templates — global CLAUDE.md and memory index"
if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
  skip "~/.claude/CLAUDE.md already exists — compare with kit/templates/CLAUDE.md.template yourself"
elif ask_yn "Install the delegation-ladder CLAUDE.md template as ~/.claude/CLAUDE.md?"; then
  install_file "$KIT_DIR/templates/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
  warn "edit the [BRACKETED PLACEHOLDERS] in ~/.claude/CLAUDE.md before relying on it"
fi
echo

# ---------------------------------------------------------------- hooks merge
bold "Wiring hooks into ~/.claude/settings.json"
SETTINGS="$CLAUDE_DIR/settings.json"
mkdir -p "$CLAUDE_DIR"
[[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"

if [[ "$INSTALL_SESSION_HOOK" == 1 || "$INSTALL_STOP_HOOKS" == 1 ]]; then
  cp "$SETTINGS" "${SETTINGS}.bak-${TS}"
  info "backed up settings.json -> settings.json.bak-${TS}"

  merge_hook() {  # merge_hook <event> <command> [timeout]
    local event="$1" cmd="$2" timeout="${3:-}"
    local hook_json
    if [[ -n "$timeout" ]]; then
      hook_json=$(jq -n --arg c "$cmd" --argjson t "$timeout" '{type:"command",command:$c,timeout:$t}')
    else
      hook_json=$(jq -n --arg c "$cmd" '{type:"command",command:$c}')
    fi
    local tmp
    tmp=$(mktemp)
    # Append only if no existing hook for this event already runs this command.
    jq --arg ev "$event" --arg c "$cmd" --argjson h "$hook_json" '
      .hooks //= {} | .hooks[$ev] //= [{"matcher":"","hooks":[]}] |
      if ([.hooks[$ev][].hooks[]?.command] | index($c)) then .
      else .hooks[$ev][0].hooks += [$h] end
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  }

  [[ "$INSTALL_SESSION_HOOK" == 1 ]] && \
    merge_hook SessionStart '$HOME/.claude/hooks/session-start-hotcache.sh'
  if [[ "$INSTALL_STOP_HOOKS" == 1 ]]; then
    merge_hook Stop '$HOME/.claude/hooks/glm-review.sh'
    merge_hook Stop '$HOME/.claude/hooks/wiki-doc-nudge.sh' 10
  fi

  echo "  settings.json changes:"
  diff "${SETTINGS}.bak-${TS}" "$SETTINGS" | sed 's/^/    /' || true
  info "hooks merged (existing hooks were preserved)"
else
  skip "no hooks to wire (layers 3 and 4 were skipped)"
fi
echo

# -------------------------------------------------------------------- report
bold "Done. Next steps"
cat <<'EOF'
  1. Open a NEW terminal (so PATH changes apply) and run:  claude
  2. If you installed Layer 4: start Ollama, run 'ollama signin', then test:
       ask-gemma "say hello"
       ask-glm  "say hello"
  3. Read docs/00-overview.md for how the pieces fit together, and
     docs/04-first-session.md for your first steps inside Claude Code.
EOF
