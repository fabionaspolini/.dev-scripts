#!/bin/bash

# Script para fazer checkout na branch main e atualizar com git pull --prune
# Uso: ./checkout-main-and-update.sh [main-branch-name]

MAIN_BRANCH="main"

if [[ $# -gt 0 ]]; then
  MAIN_BRANCH="$1"
fi

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Erro: não está em um repositório git"
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/$MAIN_BRANCH"; then
  echo "Erro: branch '$MAIN_BRANCH' não encontrada"
  echo "Branches locais disponíveis:"
  git branch --list
  exit 1
fi

echo "Fazendo checkout na branch '$MAIN_BRANCH'..."
git checkout "$MAIN_BRANCH"

if [[ $? -ne 0 ]]; then
  echo "Erro: falha ao mudar para a branch '$MAIN_BRANCH'"
  exit 1
fi

echo "Atualizando branch '$MAIN_BRANCH' com 'git pull --prune'..."
git pull --prune
