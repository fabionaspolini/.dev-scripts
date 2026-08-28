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

- **on-login**: Execute after successfully logging in, when the whole graphic interface is loaded. Use the **Autostart** feature from your graphic interface to link these scripts.
- **pre-login**: Execute after login, but before loading the desktop session. Environment variables defined here are applied to all graphical interface apps.
  - Create file in folder `~/.config/plasma-workspace/env/` to link for each script from here folder.
    ```bash
    echo "source $HOME/.dev-scripts/system-triggers/session/pre-login/clear-ibus.sh" >> ~/.config/plasma-workspace/env/clear-ibus.sh
    ```

## Settings

- [vscode](tools/vscode)
