#!/usr/bin/env bash
# Script to install MT platform using xdotool..
CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
DTMP=$(mktemp -d)
EXEFILE=mt4setup.exe
SP4URL="http://web.archive.org/web/20160129053851/http://download.microsoft.com/download/E/6/A/E6A04295-D2A8-40D0-A0C5-241BFECD095E/W2KSP4_EN.EXE"
WURL="https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
export WINEDLLOVERRIDES="mscoree,mshtml=,winebrowser.exe="

# Check the dependencies.
type wget xdotool xwininfo wine ar >&2

# Load the shell functions.
. "$CWD/.funcs.inc.sh"

echo "Installing winhttp..." >&2
mkdir -p "$HOME/.cache/winetricks/win2ksp4/"
wget -O "$HOME/.cache/winetricks/win2ksp4/W2KSP4_EN.EXE" -ct3 --content-disposition "$SP4URL"
sh -s winhttp < <(wget -qO- $WURL)

echo "Downloading MT4 installer..." >&2
[ ! -f "$HOME/$EXEFILE" ] \
  && wget -O "$HOME/$EXEFILE" -ct3 --content-disposition ${MT_URL:-"https://www.xm.co.uk/download/xmuk-mt4"}

echo "Starting MT4 Setup in Wine..." >&2
[ -f "$HOME/$EXEFILE" ]
wine "$HOME/$EXEFILE" &

# Prints information of the window status in the background.
live_stats &

echo "Waiting for Wine to initialize..."
while ! WID=$(xdotool search --name "4 Setup"); do
  sleep 5
  winedbg --command "info wnd" | grep Meta || true
done

echo "Title: $(xdotool getwindowname $WID)..."

echo "Sending installer keystrokes..." >&2
xdotool key --window $WID --delay 500 space

echo "Waiting for installer to finish..." >&2
xwininfo -id $WID -tree
while pgrep -l mt4setup; do sleep 5; done

echo "Waiting for MT4 platform to start..." >&2
while ! WID=$(xdotool search --name "MT4"); do
  winedbg --command "info wnd $WID"
  sleep 5
done
xwininfo -id $WID -tree

# Close running MT4 instance, first the two login popup window, secondly application itself.
echo "Closing application..." >&2
xdotool key --window $WID --delay 500 Escape Escape Alt+f x
while winedbg --command "info wnd" | grep "MetaQuotes"; do
  echo "Waiting for application to exit..."
  sleep 5
done
wineserver -k

find "$HOME" /opt -name terminal.exe -print -quit
echo "Installation successful." >&2
echo "${BASH_SOURCE[0]} done." >&2
