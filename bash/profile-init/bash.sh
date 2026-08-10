alias dev-scripts-update="git -C ~/.dev-scripts pull"

show-envs() {
    local pattern="${1:-}"
    local entries

    entries=$(printf '%s\n' "$PATH" | tr ':' '\n' | sort)

    if [ -n "$pattern" ]; then
        printf '%s\n' "$entries" | grep -i -- "$pattern"
    else
        printf '%s\n' "$entries"
    fi
}
