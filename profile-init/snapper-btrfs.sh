alias snapper-cleanup-execute="sudo systemctl start snapper-cleanup.service && \
                               while systemctl is-active --quiet snapper-cleanup.service; do sleep 0.5; done && \
                               journalctl -u snapper-cleanup.service --no-pager"
alias snapper-cleanup-status="systemctl status snapper-cleanup.service"
alias snapper-cleanup-logs="journalctl -u snapper-cleanup.service"

snapper-cleanup-pre-upgrade-snapshots() {
  local description="Pre-upgrade packages automatic"
  local numbers
  local list_output

  sudo -v

  list_output=$(sudo snapper --csvout list --columns number,description)
  numbers=$(echo "$list_output" | awk -F',' -v desc="$description" 'NR > 1 && $2 == desc { print $1 }')

  if [[ -z "$numbers" ]]; then
    echo "Nenhum snapshot com a descrição '$description' encontrado."
    return 0
  fi

  echo "Snapshots a serem removidos (descrição: '$description'):"
  echo "$numbers"
  echo "----------------------------------------"
  read -n1 -s -p "Pressione qualquer tecla para confirmar a remoção (Ctrl+C para cancelar)..."
  echo

  sudo snapper delete $numbers
}

snapper-create-snapshot() {
    local description="$1"

    if [[ -z "$description" ]]; then
        read -rp "Snapshot description [Standalone snapshot]: " description
        description="${description:-Standalone snapshot}"
    fi

    sudo snapper --config root create \
        --type single \
        --description "$description" \
        --cleanup-algorithm number

    sudo snapper --config home create \
        --type single \
        --description "$description" \
        --cleanup-algorithm number
}
