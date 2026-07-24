CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"

for script in "$CURRENT_FOLDER"/*.sh; do
  if [[ "$script" != "$CURRENT_FOLDER/init.sh" ]]; then
    . "$script"
  fi
done

unset CURRENT_FOLDER