@echo off
setlocal
title Claude Code Setup Kit - Windows installer

echo ==================================================
echo    Claude Code Setup Kit  -  Windows installer
echo ==================================================
echo.
echo Claude Code runs inside "WSL" (a built-in Linux layer for
echo Windows). This installer sets that up for you - you don't
echo need to open PowerShell or Ubuntu yourself.
echo.

REM ---------------------------------------------------------------
REM Is WSL already set up with a working Linux distro?
REM `wsl --status` returns 0 when WSL is installed with a default
REM distro, and non-zero when it is missing. We avoid parsing
REM `wsl -l` because its UTF-16 output is unreliable in batch.
REM ---------------------------------------------------------------
wsl --status >nul 2>&1
if errorlevel 1 goto INSTALL_WSL
goto RUN_KIT


:INSTALL_WSL
echo WSL is not set up yet. I'll install it now.
echo.
echo   * Windows will ask for ADMINISTRATOR permission (click Yes).
echo   * Your PC will need to RESTART when it finishes.
echo.
pause

REM Launch the WSL install in an elevated window (UAC prompt).
powershell -NoProfile -Command "Start-Process cmd -Verb RunAs -ArgumentList '/c','wsl --install -d Ubuntu ^& echo. ^& echo When this says it is done, RESTART your PC. ^& pause'"

echo.
echo ------------------------------------------------------------
echo  NEXT:
echo   1. Let the other window finish, then RESTART your PC.
echo   2. After restart, an "Ubuntu" window opens and asks you to
echo      create a username and password. Type a password (it stays
echo      hidden as you type) and press Enter.
echo   3. Double-click THIS installer again to finish the setup.
echo ------------------------------------------------------------
echo.
pause
goto END


:RUN_KIT
echo WSL is ready. Installing the Claude Code Setup Kit inside Linux...
echo (You may be asked for your Linux password - the one you created.)
echo.

REM Ensure curl exists in the distro, then run the public bootstrap.
wsl -e bash -lc "command -v curl >/dev/null 2>&1 || { sudo apt-get update && sudo apt-get install -y curl; }; curl -fsSL https://raw.githubusercontent.com/i2ryanjames/claude-code-setup-kit/main/install.sh | bash"

if errorlevel 1 (
  echo.
  echo Something went wrong during setup.
  echo Please take a screenshot of this window and send it for help.
  echo.
  pause
  goto END
)

echo.
echo ==================================================
echo   Setup finished! Last step:
echo     1. Open the "Ubuntu" app from the Start menu
echo     2. Type:  claude    and log in in your browser
echo ==================================================
echo.
pause


:END
endlocal
