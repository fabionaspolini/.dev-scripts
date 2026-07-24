#!/bin/bash

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"
source "$CURRENT_FOLDER/../../bash/scripts/utils/dialogs.sh"
unset CURRENT_FOLDER

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
if [ $? -ne 0 ]; then
    show_error_dialog --title "gdrive-sync init" --msg "Erro ao executar sincronização com Google Drive!"
fi

echo "$(date) Execution completed."
