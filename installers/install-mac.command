#!/bin/bash
# install-mac.command — double-click installer for the Claude Code Setup Kit (macOS).
#
# HOW TO USE: just double-click this file in Finder.
# If macOS blocks it the first time ("unidentified developer"), right-click the
# file, choose "Open", then click "Open" in the dialog. You only do that once.

clear
cat <<'BANNER'
==================================================
   Claude Code Setup Kit  —  Mac installer
==================================================

This sets up Claude Code and everything around it.
Nothing to type — just follow the prompts.
You may be asked for your Mac password along the way
(that is normal; it lets the installer add tools).

BANNER

read -r -p "Press Return to begin (or close this window to cancel)... " _
echo

# Download and run the public bootstrap. It handles OS detection, prerequisites,
# and the full setup automatically.
if curl -fsSL https://raw.githubusercontent.com/i2ryanjames/claude-code-setup-kit/main/install.sh | bash; then
  echo
  echo "--------------------------------------------------"
  echo "  All set! Next steps were printed just above."
  echo "  The short version:"
  echo "    1. Quit and reopen Terminal"
  echo "    2. Type:  claude    and log in in your browser"
  echo "--------------------------------------------------"
else
  echo
  echo "Something went wrong during setup."
  echo "Please take a screenshot of this window and send it for help."
fi

echo
read -r -p "Press Return to close this window... " _
