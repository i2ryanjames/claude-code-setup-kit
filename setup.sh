#!/usr/bin/env bash
# setup.sh — layered installer for the claude-code-setup-kit.
#
# Fully automatic by default:
#   - detects your OS and installs any missing prerequisites
#   - runs every layer with sensible defaults, no per-layer prompts
#   - use --interactive (-i) to be asked before each layer
#
# Safe by design:
#   - never overwrites an existing file without backing it up first
#   - merges hook config into ~/.claude/settings.json additively (jq),
#     with a timestamped backup and a printed diff
#
# Run it from the repo root:   bash setup.sh   (or: bash setup.sh --interactive)
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/kit"
CLAUDE_DIR="$HOME/.claude"
BIN_DIR="$HOME/.local/bin"
TS="$(date +%Y%m%d-%H%M%S)"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*"; }
skip()  { printf '  \033[2m- %s\033[0m\n' "$*"; }

ask_yn() {  # ask_yn "question" -> 0 yes / 1 no  (auto-yes when AUTO=1)
  if [[ "${AUTO:-1}" == "1" ]]; then
    printf '%s (auto: yes)\n' "$1"
    return 0
  fi
  local reply
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy] ]]
}

install_file() {  # install_file <source> <dest> — back up on change, idempotent
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then
    if cmp -s "$src" "$dest"; then
      skip "$(basename "$dest") already up to date"
      return 0
    fi
    cp "$dest" "${dest}.bak-${TS}"
    info "backed up $(basename "$dest") -> $(basename "$dest").bak-${TS}"
  fi
  cp "$src" "$dest"
  info "installed $(basename "$dest")"
}

# ----------------------------------------------------- arg + mode parsing
AUTO=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --interactive|-i) AUTO=0 ;;
    --help|-h)
      cat <<'USAGE'
Usage: bash setup.sh [--interactive] [--help]
  --interactive, -i     Prompt before each layer (default: fully automatic)
  --help, -h            Show this message and exit

Environment variables:
  MAGIC_KEY             API key for the 'magic' MCP (interactive mode only)
  SETUP_CLONE_VAULT=1   In auto mode, clone the full vault starter (else: bare vault)
  SETUP_PULL_GEMMA=1    In auto mode, pull gemma4:e4b model (else: skip)
USAGE
      exit 0
      ;;
    *)
      warn "Unknown flag: $1"
      exit 2
      ;;
  esac
  shift
done

[[ -d "$KIT_DIR" ]] || { echo "setup.sh must be run from the repo root (kit/ not found)"; exit 1; }

bold "claude-code-setup-kit installer"
echo

# ---------------------------------------------------------------- preflight
bold "Preflight — checking prerequisites"

# OS detection -> OS in {mac, wsl, linux, unsupported}, PKG in {brew, apt, none}
case "$(uname -s)" in
  Darwin)
    OS="mac"
    PKG="brew"
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      OS="wsl"
    else
      OS="linux"
    fi
    if command -v apt-get >/dev/null 2>&1; then
      PKG="apt"
    else
      PKG="none"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    OS="unsupported"
    PKG="none"
    ;;
  *)
    OS="unsupported"
    PKG="none"
    ;;
esac

if [[ "$OS" == "unsupported" ]]; then
  echo "This kit must be run inside WSL 2. See docs/03-install-windows.md for setup instructions." >&2
  exit 1
fi

info "platform: $OS (package manager: $PKG)"

MISSING=()
for cmd in git jq curl python3 node npm; do
  if command -v "$cmd" >/dev/null 2>&1; then
    info "$cmd $(command -v "$cmd")"
  else
    MISSING+=("$cmd")
    warn "$cmd is missing"
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  info "all required tools are present"
else
  if [[ "$AUTO" == "0" ]]; then
    if ! ask_yn "Some required tools are missing (${MISSING[*]}). Attempt to install them?"; then
      echo "  Re-run setup.sh after installing them manually." >&2
      exit 1
    fi
  fi

  if [[ "$OS" == "mac" ]]; then
    if [[ "$PKG" == "brew" ]]; then
      if ! command -v brew >/dev/null 2>&1; then
        info "installing Homebrew (non-interactive)…"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
          || { warn "Homebrew installation failed"; exit 1; }
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
          eval "$(/usr/local/bin/brew shellenv)"
        fi
      fi
      # Build brew install list (node installs npm, so drop npm if listed)
      local_brew_list=()
      for m in "${MISSING[@]}"; do
        [[ "$m" == "npm" ]] && continue  # npm comes with node
        local_brew_list+=("$m")
      done
      if [[ ${#local_brew_list[@]} -gt 0 ]]; then
        info "brew install ${local_brew_list[*]}"
        brew install "${local_brew_list[@]}" || warn "brew install had issues"
      fi
    else
      PKG="none"
    fi
  fi

  if [[ "$OS" == "wsl" || "$OS" == "linux" ]]; then
    if [[ "$PKG" == "apt" ]]; then
      echo "  (sudo may prompt for your password once)"
      sudo apt-get update >/dev/null 2>&1 || warn "apt-get update had issues"
      apt_missing=()
      for m in "${MISSING[@]}"; do
        case "$m" in
          node|npm) ;;  # handled via nvm below
          *) apt_missing+=("$m") ;;
        esac
      done
      if [[ ${#apt_missing[@]} -gt 0 ]]; then
        info "sudo apt-get install -y ${apt_missing[*]}"
        sudo apt-get install -y "${apt_missing[@]}" || warn "apt-get install had issues"
      fi
      # Install node/npm via nvm if missing (apt's node is stale)
      need_nvm=0
      for m in "${MISSING[@]}"; do
        [[ "$m" == "node" || "$m" == "npm" ]] && need_nvm=1
      done
      if [[ "$need_nvm" == 1 ]]; then
        info "installing nvm (Node Version Manager)…"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash || warn "nvm install had issues"
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts || warn "nvm install --lts had issues"
      fi
    else
      PKG="none"
    fi
  fi

  if [[ "$PKG" == "none" ]]; then
    warn "no supported package manager found — manual installation required"
    if [[ "$OS" == "mac" ]]; then
      echo "  See docs/02-install-mac.md for instructions." >&2
    else
      echo "  See docs/03-install-windows.md for instructions." >&2
    fi
    echo "  Re-run setup.sh afterwards." >&2
    exit 1
  fi

  # Re-check all required commands after bootstrap
  STILL_MISSING=()
  for cmd in git jq curl python3 node npm; do
    command -v "$cmd" >/dev/null 2>&1 || STILL_MISSING+=("$cmd")
  done
  if [[ ${#STILL_MISSING[@]} -gt 0 ]]; then
    warn "these tools are still missing after install: ${STILL_MISSING[*]}"
    if [[ "$OS" == "mac" ]]; then
      echo "  See docs/02-install-mac.md for manual instructions." >&2
    else
      echo "  See docs/03-install-windows.md for manual instructions." >&2
    fi
    exit 1
  fi
fi

# --------------------------------------------------------- PATH auto-wiring
case ":$PATH:" in
  *":$BIN_DIR:"*)
    info "$BIN_DIR is on PATH"
    profile=""
    ;;
  *)
    if [[ "${SHELL:-}" == *zsh ]]; then
      profile="$HOME/.zshrc"
    else
      profile="$HOME/.bashrc"
    fi
    touch "$profile"
    if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$profile"; then
      [[ -s "$profile" ]] && cp "$profile" "${profile}.bak-${TS}"  # back up only when we actually modify
      printf '\n# added by claude-code-setup-kit\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$profile"
      info "PATH wired in $profile — open a new terminal or run: source $profile"
    else
      info "PATH export already present in $profile"
    fi
    # Make ~/.local/bin usable for the rest of this run
    export PATH="$HOME/.local/bin:$PATH"
    ;;
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
      claude mcp add --transport stdio --scope user "$name" -- "$@" && info "added mcp '$name'"
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
    if [[ "$AUTO" == "0" ]]; then
      read -r -p "  21st.dev API key for the 'magic' component builder (Enter to skip): " MAGIC_KEY
    else
      MAGIC_KEY="${MAGIC_KEY:-}"
    fi
    if [[ -n "$MAGIC_KEY" ]]; then
      claude mcp add --transport stdio --scope user magic --env API_KEY="$MAGIC_KEY" -- npx -y @21st-dev/magic@latest \
        && info "added mcp 'magic'"
    else
      skip "skipped 'magic' (add later — see docs/07-mcp-stack.md)"
    fi
  fi
  echo "  Plugins are auto-installed in Layer 5 (see docs/06-skills-plugins.md)."
else
  skip "skipped MCP stack (docs/07-mcp-stack.md has the manual commands)"
fi
echo

# ------------------------------------------------------ layer 3: second brain
bold "Layer 3 — Second brain (Obsidian-compatible knowledge vault)"
if ask_yn "Set up the knowledge vault at ~/claude-obsidian?"; then
  if [[ -d "$HOME/claude-obsidian" ]]; then
    skip "~/claude-obsidian already exists — leaving it untouched"
  else
    clone_vault=0
    if [[ "$AUTO" == "0" ]]; then
      if ask_yn "  Clone the full claude-obsidian starter (github.com/AgriciDaniel/claude-obsidian)? 'n' creates a bare vault"; then
        clone_vault=1
      fi
    fi
    [[ "${SETUP_CLONE_VAULT:-}" == "1" ]] && clone_vault=1
    if [[ "$clone_vault" == 1 ]]; then
      git clone https://github.com/AgriciDaniel/claude-obsidian "$HOME/claude-obsidian"
      info "cloned starter vault"
    else
      mkdir -p "$HOME/claude-obsidian/wiki"
      printf '# Wiki index\n\nCatalog of all pages in this vault. One line per page.\n' \
        > "$HOME/claude-obsidian/wiki/index.md"
      info "created bare vault at ~/claude-obsidian/wiki"
    fi
  fi
  [[ -f "$HOME/claude-obsidian/wiki/hot.md" ]] \
    && skip "wiki/hot.md already exists" \
    || install_file "$KIT_DIR/templates/hot-starter.md" "$HOME/claude-obsidian/wiki/hot.md"
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
      if command -v brew >/dev/null 2>&1; then
        if [[ "$AUTO" == "0" ]]; then
          if ask_yn "  Install Ollama via Homebrew?"; then
            brew install --cask ollama-app || warn "could not install Ollama via brew"
          fi
        else
          info "installing Ollama via Homebrew…"
          brew install --cask ollama-app || warn "could not install Ollama via brew"
        fi
      else
        warn "install Ollama from https://ollama.com/download then re-run this layer"
      fi
    else
      if [[ "$AUTO" == "0" ]]; then
        if ask_yn "  Install Ollama via the official install script?"; then
          curl -fsSL https://ollama.com/install.sh | sh || warn "Ollama install script failed"
        fi
      else
        info "installing Ollama via official install script…"
        curl -fsSL https://ollama.com/install.sh | sh || warn "Ollama install script failed"
      fi
    fi
  else
    info "ollama already installed"
  fi

  if command -v ollama >/dev/null 2>&1; then
    pull_gemma=0
    if [[ "$AUTO" == "0" ]]; then
      if ask_yn "  Pull the free local model gemma4:e4b (~10 GB download)?"; then
        pull_gemma=1
      fi
    fi
    [[ "${SETUP_PULL_GEMMA:-}" == "1" ]] && pull_gemma=1
    if [[ "$pull_gemma" == 1 ]]; then
      ollama pull gemma4:e4b || warn "could not pull gemma4:e4b"
    else
      skip "skipped gemma4:e4b pull"
      echo "  To pull gemma4:e4b later: ollama pull gemma4:e4b"
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

# ----------------------------------------------------- layer 5: claude plugins
bold "Layer 5 — Claude Code plugins"
if ! command -v claude >/dev/null 2>&1; then
  skip "Claude Code not installed — skipping plugins"
else
  add_marketplace() {  # non-fatal: never aborts the installer
    local src="$1"
    if claude plugin marketplace list 2>/dev/null | grep -qiF "$src"; then
      skip "marketplace $src already added"
    else
      claude plugin marketplace add "$src" >/dev/null 2>&1 && info "added marketplace $src" || warn "could not add marketplace $src (skipping)"
    fi
  }

  install_plugin() {  # non-fatal: never aborts the installer
    local p="$1"
    if claude plugin list 2>/dev/null | grep -qiF "${p%@*}"; then
      skip "plugin ${p%@*} already installed"
    else
      claude plugin install "$p" >/dev/null 2>&1 && info "installed plugin $p" || warn "could not install plugin $p (skipping)"
    fi
  }

  if ask_yn "Add Claude Code plugins?"; then
    # exact marketplace slugs may drift — failures are non-fatal by design
    add_marketplace "anthropics/skills"
    add_marketplace "nextlevelbuilder/ui-ux-pro-max-skill"
    install_plugin "ui-ux-pro-max"
    install_plugin "vercel"
    install_plugin "supabase"
    install_plugin "figma"
  else
    skip "skipped plugins layer"
  fi
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

if [[ "${INSTALL_SESSION_HOOK:-0}" == 1 || "${INSTALL_STOP_HOOKS:-0}" == 1 ]]; then
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
cat <<EOF
  1. Open a new terminal: source ${profile:-~/.bashrc} (or restart your terminal)
  2. Run: claude
     (log in via your browser and select a workspace)
  3. If you installed Layer 4 (delegation harness):
     - Start Ollama app (or 'ollama serve' in another terminal)
     - Run: ollama signin
     - Test: ask-gemma "say hello"  and  ask-glm "say hello"
  4. Optional: pull the Gemma model if you skipped it earlier:
     ollama pull gemma4:e4b
  5. Edit any [BRACKETED PLACEHOLDERS] in ~/.claude/CLAUDE.md
  6. Read docs/00-overview.md for how the pieces fit together.
EOF
