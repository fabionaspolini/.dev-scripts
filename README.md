# .dev-scripts

My development environment settings and scripts.

- [How to use?](#how-to-use)
  - [1. Clone the repository into your user directory:](#1-clone-the-repository-into-your-user-directory)
  - [2. Run `profile-init.sh` when your terminal starts.](#2-run-profile-initsh-when-your-terminal-starts)
    - [Bash](#bash)
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

## Settings

- [vscode](tools/vscode)
