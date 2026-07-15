#!/bin/bash
# Cria aliases para scripts utilitários
# Alias criados dinamicamente a partir dos scripts disponíveis

# Scripts com os quais criar aliases (editar esta lista para adicionar novos)
scripts=(
    "backup.sh"
    "clear-dev-folders.sh"
    "git-checkout-main-and-update.sh"
    "git-delete-merged-branchs.sh"
    "refresh-envs-so.sh"
)

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"

# Função para criar alias a partir de um script
_create_alias() {
    local script_name="$1"
    local alias_name="${script_name%.sh}"  # Remove a extensão .sh
    local script_path="$CURRENT_FOLDER/$script_name"

    if [[ -f "$script_path" ]]; then
        eval "alias $alias_name='. \"$script_path\"'"
    fi
}

# Criar aliases dinamicamente
for script in "${scripts[@]}"; do
    _create_alias "$script"
done

# Limpeza
unset -f _create_alias
unset scripts script
unset CURRENT_FOLDER
