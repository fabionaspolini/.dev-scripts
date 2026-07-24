#!/usr/bin/env bash

# Avoid reloading the library if it was already imported in the current session
[[ -n "${_PARSE_ARGS_SH_LOADED:-}" ]] && return 0
_PARSE_ARGS_SH_LOADED=true

# Generic helper to parse arguments
# Usage: parse_args "$@"
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --*)
                # Remove the leading '--' to turn it into a variable name
                local var_name="${1#--}"

                # Inject the value into the variable of the caller's scope
                if [[ $# -ge 2 && "$2" != --* ]]; then
                    printf -v "$var_name" "%s" "$2"
                    shift 2
                else
                    # If it is just a flag (for example, --verbose)
                    printf -v "$var_name" "%s" "true"
                    shift 1
                fi
                ;;
            *)
                echo "Error: Invalid parameter '$1'" >&2
                return 1
                ;;
        esac
    done
}