#!/usr/bin/env zsh

if [[ -n "${ZSH_VERSION:-}" ]]; then
  CURRENT_FOLDER="${${(%):-%x}:a:h}"
else
  CURRENT_FOLDER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
fi

for script in "$CURRENT_FOLDER"/*.sh; do
  if [[ "$script" != "$CURRENT_FOLDER/init.sh" ]]; then
    # Se algum script configurar `set -e` e houver erro, o terminal do usuário será fechado!
    # Não use `set -e` em script carregados automaticamente, lembre-se que neste local todos devem ser extremamente rápidos
    # e apenas registrar aliases ou carregar funções sem executa-las.
    # echo "$script"
    . "$script"
  fi
done

unset CURRENT_FOLDER
