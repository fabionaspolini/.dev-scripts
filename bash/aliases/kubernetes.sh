# Carrega autocomplete do kubectl
source <(kubectl completion bash)

# Associa a conclusão do kubectl ao alias 'k'
alias k="kubectl"
complete -o default -F __start_kubectl k