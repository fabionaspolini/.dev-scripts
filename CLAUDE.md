# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# .dev-scripts

Personal collection of bash scripts for development environment setup (aliases, shell functions, system triggers, and tool settings). Being migrated to support both bash and zsh simultaneously (see compatibility section below).

## Instructions for generated content

- All code, comments, commit messages, and generated content must be written in English, regardless of the language used in the conversation with the user.
- **Never commit explicit secrets** (API keys, tokens, passwords, private keys, connection strings with credentials, etc.) to any file in this repository, in any format — scripts, Markdown, settings, or otherwise. This repo is a personal dotfiles collection and may be public; secrets belong in environment variables, a local untracked file, or a secrets manager, referenced by name/path instead of value. If a task seems to require hardcoding a real secret, stop and flag it instead of writing it to a file.

## Structure

- `profile-init/*.sh` — functions and aliases automatically loaded into the shell via `profile-init.sh` → `profile-init/init.sh`, which sources every `*.sh` in the folder (except `init.sh`).
- `scripts/utils/*.sh` — reusable utility libraries (argument parsing, dialogs, bash helpers). Not loaded automatically; each script that needs one sources it explicitly.
- `scripts/*.sh` — standalone scripts, not loaded automatically (backup, git helpers, sync, etc.). `scripts/init.sh`, when sourced (e.g. by `profile-init.sh`), creates an alias with the same name (minus `.sh`) for each script in the folder, pointing to its absolute path — the script runs in a sub-shell via that alias, so a `set -e` inside it won't kill the user's shell. Every new file created in this folder must start with a shebang (e.g. `#!/usr/bin/env bash`).
- `system-triggers/session/{on-login,pre-login}/*.sh` — scripts tied to graphical session hooks (autostart / `~/.config/plasma-workspace/env/`).
- `settings/` — tool configurations (e.g. vscode).

## bash/zsh compatibility

- **Resolving the script's own directory**: `BASH_SOURCE[0]` doesn't exist in zsh. Pattern used in already-migrated files (`profile-init.sh`, `profile-init/init.sh`, `scripts/init.sh`):
  ```bash
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    CURRENT_FOLDER="${${(%):-%x}:a:h}"
  else
    CURRENT_FOLDER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  fi
  ```
  (the variable name may differ per script, e.g. `DEV_TOOLS_DIR`). Always `unset` the variable at the end of a script that gets sourced into the interactive shell.
- **`complete`/`compctl`/`compdef` and `source <(...)`**: bash's autocomplete facilities (`complete`, `COMPREPLY`, `COMP_WORDS`) don't exist in zsh, which uses `compctl`/`compdef` instead. When migrating a completion script, branch with `if [[ -n "${ZSH_VERSION:-}" ]]; then ... elif [[ -n "${BASH_VERSION:-}" ]]; then ... fi`, keeping the original bash logic in the bash branch. See `profile-init/dotnet.sh` and `profile-init/kubernetes.sh` as examples.
- Not every script in `profile-init/` has been migrated yet — when touching a script in that directory, check whether it uses `BASH_SOURCE`, `complete`, or another bash-only construct before assuming it's already compatible.

## Code conventions

- **Reload guard**: libraries that may be sourced more than once (in `scripts/utils/`) start with a variable-based guard, following the pattern:
  ```bash
  [[ -n "${_NAME_SH_LOADED:-}" ]] && return 0
  _NAME_SH_LOADED=true
  ```
- **Argument parsing**: use `scripts/utils/parse-args.sh` (`parse_args "$@"`) instead of manual parsing. It injects `--flag value` as a variable `flag="value"` into the caller's scope, and a standalone `--flag` (with no following value) becomes `flag="true"`. Declare the variables with `local` before calling `parse_args`.
- **Scripts in `profile-init/`**: never use `set -e` (an error would kill the user's terminal, since the script is sourced into the interactive session). They must be fast — only register aliases/functions, without running heavy logic at load time.
- **Destructive/sensitive interactive confirmations**: use `read -n1 -s` for a "press any key" prompt before an action, or `read -rp` with a numbered menu (`1) option A`, `2) option B`) when there's an explicit choice — and allow that choice to also come via argument (`parse_args`), skipping the prompt when already provided.
- **Terminal visual feedback**: manual ANSI bold/color codes (`\033[1m...\033[0m`, `\033[33m` for yellow) in `echo -e`, and `echo "----------------------------------------"` as a separator between steps of a long script.
- **Function names**: kebab-case (e.g. `upgrade-all-packages`, `show-paths-env`, `fix-keyboard-ibus-errors`), not snake_case or camelCase.
