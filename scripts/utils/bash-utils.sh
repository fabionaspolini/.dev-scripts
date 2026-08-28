# Returns the list of public functions defined in a script file,
# excluding those in the provided ignore list.
#
# Usage:
#   get_script_commands <script_file> [ignored_func1 ignored_func2 ...]
#
# Example:
#   read -ra cmds <<< "$(get_script_commands "$script_file" "func_to_ignore" "other_func")"
get_script_commands() {
  local script_file="$1"
  shift
  local ignored_functions=("$@")
  local all_functions func ignored
  local commands=()

  mapfile -t all_functions < <(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\(\)' "$script_file" | sed 's/().*//')

  for func in "${all_functions[@]}"; do
    ignored=false
    for ignored_func in "${ignored_functions[@]}"; do
      [[ "$func" == "$ignored_func" ]] && ignored=true && break
    done
    $ignored || commands+=("$func")
  done

  echo "${commands[@]}"
}

