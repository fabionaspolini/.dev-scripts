# .dev-scripts

Minhas configurações e scripts para ambiente de desenvolvimento.

- [Como usar?](#como-usar)
  - [1. Clonar o repositório em sua pasta de usuário:](#1-clonar-o-repositório-em-sua-pasta-de-usuário)
  - [2. Executar `profile-init.sh` na inicialização do seu terminal.](#2-executar-profile-initsh-na-inicialização-do-seu-terminal)
    - [bash](#bash)
- [Settings](#settings)

## Como usar?

### 1. Clonar o repositório em sua pasta de usuário:

```bash
cd ~
git clone https://github.com/fabionaspolini/.dev-scripts.git
```

### 2. Executar `profile-init.sh` na inicialização do seu terminal.

#### bash

Criar arquivo `~/.bashrc.d/dev-scripts-init.sh` e adicionar `. ~/.dev-scripts/bash/profile-init.sh`.

**Quick setup**

```bash
echo ". ~/.dev-scripts/bash/profile-init.sh" >> ~/.bashrc.d/dev-scripts-init.sh
```

## Settings

- [vscode](tools/vscode)
