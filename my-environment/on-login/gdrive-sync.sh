#!/bin/bash

echo "$(date) Inicializando"


# Force alias loading by enabling alias expansion in non-interactive shells
shopt -s expand_aliases

echo "$(date) Carregar .bashrc"

# Explicitly source ~/.bashrc (which in turn activates bashrc.d)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

echo "$(date) gdrive-sync"
gdrive-sync

# Pause for console check
echo "$(date) Execution completed. Press [Enter] to close..."
