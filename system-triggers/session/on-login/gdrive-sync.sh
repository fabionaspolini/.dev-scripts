#!/usr/bin/env bash

# Force alias loading by enabling alias expansion in non-interactive shells
shopt -s expand_aliases

# Explicitly source ~/.bashrc (which in turn activates bashrc.d)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"
source "$CURRENT_FOLDER/../../../scripts/utils/dialogs.sh"
unset CURRENT_FOLDER

echo "gdrive-sync"
gdrive-sync
if [ $? -ne 0 ]; then
    show_error_dialog --title "Autostart script error: gdrive-sync" --msg "Failed to synchronize Google Drive!"
    exit 1
fi

echo "Execution completed."
