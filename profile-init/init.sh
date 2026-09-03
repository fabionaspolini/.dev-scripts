CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"

for script in "$CURRENT_FOLDER"/*.sh; do
  if [[ "$script" != "$CURRENT_FOLDER/init.sh" ]]; then
    # Se algum script configurar `set -e` e houver erro, o terminal do usuário será fechado!
    # Não use `set -e` em script carregados automaticamente, lembre-se que neste local todos devem ser extremamente rápidos
    # e apenas registrar aliases ou carregar funções sem executa-las.
    . "$script"
  fi
done

unset CURRENT_FOLDER
