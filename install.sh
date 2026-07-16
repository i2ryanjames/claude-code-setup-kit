#!/usr/bin/env bash
# install.sh — public one-liner bootstrap for the Claude Code Setup Kit.
#
# Usage (curl-pipe-bash):
#   curl -fsSL https://raw.githubusercontent.com/i2ryanjames/claude-code-setup-kit/main/install.sh | bash
#
# What it does:
#   1. Downloads the kit tarball from GitHub.
#   2. Extracts it to a temporary directory.
#   3. Backs up any existing install at $CCK_DIR.
#   4. Moves the extracted kit into place.
#   5. Hands off to the kit's own setup.sh, forwarding any arguments.
#
# Only stock tools are used: bash, curl, tar, mktemp, uname, date, coreutils.
# No git is required — this works on bare macOS / Linux / WSL machines.
set -euo pipefail

# --------------------------------------------------------------------------
# Banner
# --------------------------------------------------------------------------
echo "Claude Code Setup Kit — bootstrap"

# --------------------------------------------------------------------------
# Configuration (env vars with defaults)
# --------------------------------------------------------------------------
CCK_REPO="${CCK_REPO:-i2ryanjames/claude-code-setup-kit}"
CCK_REF="${CCK_REF:-main}"
CCK_DIR="${CCK_DIR:-$HOME/claude-code-setup-kit}"
CCK_TARBALL_URL="${CCK_TARBALL_URL:-}"

# --------------------------------------------------------------------------
# Resolve the tarball URL.
# If CCK_TARBALL_URL is set, use it verbatim; otherwise build the standard
# GitHub "archive/refs/heads/<ref>.tar.gz" URL.
# --------------------------------------------------------------------------
if [[ -n "$CCK_TARBALL_URL" ]]; then
  url="$CCK_TARBALL_URL"
else
  url="https://github.com/${CCK_REPO}/archive/refs/heads/${CCK_REF}.tar.gz"
fi

# --------------------------------------------------------------------------
# Preflight: make sure curl and tar are available. These are the only two
# tools strictly required to get the kit onto the machine.
# --------------------------------------------------------------------------
missing=()
for cmd in curl tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: required tools not found: ${missing[*]}" >&2
  echo "Please install them and re-run this bootstrap script." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Download the tarball into a temporary directory.
# The trap cleans up the temp dir on exit (success or failure).
# --------------------------------------------------------------------------
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading kit from: $url"
if ! curl -fsSL "$url" -o "$tmp/kit.tar.gz"; then
  echo "ERROR: failed to download the kit tarball." >&2
  echo "       If the repository ($CCK_REPO) is private, this bootstrap cannot fetch it." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Extract the tarball inside the temp directory.
# --------------------------------------------------------------------------
echo "Extracting kit tarball..."
tar -xzf "$tmp/kit.tar.gz" -C "$tmp"

# --------------------------------------------------------------------------
# Locate the top-level extracted directory. GitHub archives extract into a
# folder named like "<repo>-<ref>" (e.g. claude-code-setup-kit-main).
# We look for a directory whose name contains "claude-code-setup-kit".
# If that finds nothing (e.g. a custom tarball layout), fall back to the
# first subdirectory of the temp dir.
# --------------------------------------------------------------------------
src="$(find "$tmp" -maxdepth 1 -type d -name '*claude-code-setup-kit*' | head -n1 || true)"
if [[ -z "$src" ]]; then
  src="$(find "$tmp" -maxdepth 1 -mindepth 1 -type d | head -n1 || true)"
fi

if [[ -z "$src" ]]; then
  echo "ERROR: could not locate the extracted kit directory." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# Verify the kit actually contains setup.sh before installing it.
# --------------------------------------------------------------------------
if [[ ! -f "$src/setup.sh" ]]; then
  echo "ERROR: setup.sh was not found inside the downloaded kit." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# If an existing kit directory is present, back it up with a timestamp so
# nothing is ever silently overwritten.
# --------------------------------------------------------------------------
if [[ -d "$CCK_DIR" ]]; then
  backup="${CCK_DIR}.bak-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing $CCK_DIR -> $backup"
  mv "$CCK_DIR" "$backup"
fi

# --------------------------------------------------------------------------
# Install: ensure the parent directory exists, then move the extracted kit
# into the target location.
# --------------------------------------------------------------------------
mkdir -p "$(dirname "$CCK_DIR")"
mv "$src" "$CCK_DIR"
echo "Installed kit to: $CCK_DIR"

# --------------------------------------------------------------------------
# Make the key scripts executable.
# --------------------------------------------------------------------------
chmod +x "$CCK_DIR/setup.sh"
if [[ -f "$CCK_DIR/install.sh" ]]; then
  chmod +x "$CCK_DIR/install.sh"
fi

# --------------------------------------------------------------------------
# Hand off to the kit's own setup.sh, forwarding any arguments passed to
# this bootstrap script. exec replaces the current process so setup.sh owns
# the exit code.
# --------------------------------------------------------------------------
echo "Handing off to setup.sh..."
cd "$CCK_DIR"
exec bash setup.sh "$@"
