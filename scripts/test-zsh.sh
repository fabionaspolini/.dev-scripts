#!/usr/bin/env zsh

if [[ -n "${ZSH_VERSION:-}" ]]; then
  CURRENT_FOLDER="${${(%):-%x}:a:h}"
else
  CURRENT_FOLDER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
fi

echo "CURRENT_FOLDER: $CURRENT_FOLDER"
