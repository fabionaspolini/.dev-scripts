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

# Update Konsole profile to Light or Dark based on system theme
echo "set-konsole-profile"
set-konsole-profile
if [ $? -ne 0 ]; then
    show_error_dialog --title "Autostart script error: general-actions" --msg "Failed to update Konsole profile with system theme!"
fi

echo "Execution completed."
