# .dev-scripts

My development environment settings and scripts.

- [How to use?](#how-to-use)
  - [1. Clone the repository into your user directory:](#1-clone-the-repository-into-your-user-directory)
  - [2. Run `profile-init.sh` when your terminal starts.](#2-run-profile-initsh-when-your-terminal-starts)
    - [Bash](#bash)
- [System-triggers](#system-triggers)
- [Settings](#settings)


## How to use?

### 1. Clone the repository into your user directory:

```bash
cd ~
git clone https://github.com/fabionaspolini/.dev-scripts.git
```

### 2. Run `profile-init.sh` when your terminal starts.

#### Bash

Create the file `~/.bashrc.d/dev-scripts-init.sh` and add `. ~/.dev-scripts/profile-init.sh`.

**Quick setup**

```bash
echo ". ~/.dev-scripts/profile-init.sh" >> ~/.bashrc.d/dev-scripts-init.sh
```

## System-triggers

- **on-login**: Executa automaticamente após login, com toda interface gráfica já carregada.
- **on-login/before-desktop-load**: Eles são executados antes de a área de trabalho carregar completamente, exatamente para definir variáveis de ambiente (export MINHA_VAR=valor) que todos os programas da sua sessão gráfica precisarão herdar.

## Settings

- [vscode](tools/vscode)
