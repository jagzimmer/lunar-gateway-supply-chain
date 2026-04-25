#!/bin/bash
# install_gurobi_license.command
# Installs the Gurobi WLS license by copying gurobi.lic to ~/gurobi.lic
# Double-click this file in Finder to run, or run in Terminal.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SRC="$SCRIPT_DIR/gurobi.lic"
DEST="$HOME/gurobi.lic"

echo "=============================================="
echo " Gurobi WLS License Installer"
echo "=============================================="
echo "Source : $SRC"
echo "Target : $DEST"
echo ""

if [ ! -f "$SRC" ]; then
  echo "ERROR: $SRC not found."
  echo "Make sure gurobi.lic sits next to this script."
  exit 1
fi

# Back up any existing license
if [ -f "$DEST" ]; then
  BK="$DEST.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Existing ~/gurobi.lic found — backing up to:"
  echo "  $BK"
  cp "$DEST" "$BK"
fi

cp "$SRC" "$DEST"
chmod 600 "$DEST"
echo "License installed to $DEST"
echo ""

# Show the file contents (credentials trimmed)
echo "----- Installed license -----"
grep -E "^(WLSACCESSID|LICENSEID)" "$DEST" || true
echo "WLSSECRET=**** (hidden)"
echo "-----------------------------"
echo ""

# Try to verify with gurobi_cl if it's on PATH
if command -v gurobi_cl >/dev/null 2>&1; then
  echo "Running 'gurobi_cl --license' to verify..."
  echo ""
  gurobi_cl --license || true
else
  echo "NOTE: gurobi_cl was not found on PATH."
  echo "Open a new Terminal after installing Gurobi, or run:"
  echo "  /Library/gurobi1301/macos_universal2/bin/gurobi_cl --license"
fi

echo ""
echo "Done. You can close this window."
read -p "Press Enter to exit..."
