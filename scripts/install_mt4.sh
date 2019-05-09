#!/usr/bin/env bash
# Script to install MT4 platform using winetricks.
[ -n "$OPT_NOERR" ] || set -e
[ -n "$OPT_TRACE" ] && set -x
CWD="$( (cd -P -- "$(dirname -- "$0")" 2>/dev/null && pwd -P) || pwd -P)"
type winetricks >/dev/null

# Load the shell functions.
. "$CWD/.funcs.inc.sh"
. "$CWD/.funcs.cmds.inc.sh"

# Activates display.
set_display

echo "Installing winhttp..." >&2
winetricks -q winhttp

echo "Installing platform..." >&2
winetricks -q -v mt4

echo "Installation successful." >&2
echo "${BASH_SOURCE[0]} done." >&2
