#!/usr/bin/env bash

# Create alias for each script in the current folder, excluding this file itself.
CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"

# Função para criar alias a partir de um script
_create_alias() {
    local script_name="$1"
    local alias_name="${script_name%.sh}"  # Remove a extensão .sh
    local script_path="$CURRENT_FOLDER/$script_name"

    if [[ -f "$script_path" ]]; then
        # Executar no formato sub-shell para evitar alterações no shell atual do usuário invocando o script.
        # Se executado no próprio shell (comando `source script.sh` ou `. script.sh`),
        # erros em script que atribute `set -e` fariam o shell do usuário encerrar.
        eval "alias $alias_name='$script_path'"
    fi
}

for script in "$CURRENT_FOLDER"/*.sh; do
  if [[ "$script" != "$CURRENT_FOLDER/aliases.sh" ]]; then
    _create_alias "${script##*/}"
  fi
done

# Limpeza
unset -f _create_alias
unset scripts script
unset CURRENT_FOLDER
