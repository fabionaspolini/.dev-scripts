#. "$(dirname -- "${BASH_SOURCE[0]}")/utils/bash-utils.sh"
#
## File functions to ignore when listing available commands
#_KAFKA_IGNORED_FUNCTIONS=("_kafka_autocomplete" "register_kafka_autocomplete" "_handle_kafka_command")
#
## Enable autocomplete for this script
#_kafka_autocomplete() {
#  local cur=${COMP_WORDS[COMP_CWORD]}
#  local opcoes
#  read -ra opcoes <<< "$(get_script_commands "${BASH_SOURCE[0]}" "${_KAFKA_IGNORED_FUNCTIONS[@]}")"
#  COMPREPLY=( $(compgen -W "${opcoes[*]}" -- "$cur") )
#}
#
#register_kafka_autocomplete() {
#  complete -F _kafka_autocomplete kafka
#  complete -F _kafka_autocomplete kafka.sh
#  complete -F _kafka_autocomplete ./kafka.sh
#}
#
## Execute user action
#_handle_kafka_command() {
#  local commands func
#  read -ra commands <<< "$(get_script_commands "${BASH_SOURCE[0]}" "${_KAFKA_IGNORED_FUNCTIONS[@]}")"
#
#  local cmd="$1"
#  for func in "${commands[@]}"; do
#    if [[ "$cmd" == "$func" ]]; then
#      "$func"
#      return
#    fi
#  done
#
#  printf "Invalid option: %s\nUse: {%s}\n" "$cmd" "$(IFS='|'; echo "${commands[*]}")"
#}
#
## If script call by user in terminal
#if [[ -z "$_KAFKA_SOURCED_FOR_INIT" ]]; then
#  _handle_kafka_command "$@"
#fi
