# Carrega autocomplete do kubectl
if ! command -v kubectl &> /dev/null; then
    return 0
fi

alias k="kubectl"

if [ -n "${ZSH_VERSION:-}" ]; then
    source <(kubectl completion zsh)
    compdef __start_kubectl k
elif [ -n "${BASH_VERSION:-}" ]; then
    source <(kubectl completion bash)

    # Associar a conclusão do kubectl ao alias 'k'
    complete -o default -F __start_kubectl k
fi
