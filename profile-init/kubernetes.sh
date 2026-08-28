# Carrega autocomplete do kubectl
source <(kubectl completion bash)

alias k="kubectl"

# Associar a conclusão do kubectl ao alias 'k'
complete -o default -F __start_kubectl k
