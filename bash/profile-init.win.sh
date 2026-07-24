# Utilizar para inicializar profile do git bash no Windows

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"

. "$CURRENT_FOLDER"/profile-init.sh
. "$CURRENT_FOLDER"/wsl-aliases.win.sh

unset CURRENT_FOLDER