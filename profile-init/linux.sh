alias fix-keyboard-ibus-errors="ibus restart"

alias la="eza -la"
alias ll="eza -ll"

show-paths-env() {
    local pattern="${1:-}"
    local entries

    entries=$(printf '%s\n' "$PATH" | tr ':' '\n' | sort)

    if [ -n "$pattern" ]; then
        printf '%s\n' "$entries" | grep -i -- "$pattern"
    else
        printf '%s\n' "$entries"
    fi
}
