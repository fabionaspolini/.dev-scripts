#!/bin/bash

# Check if the argument was provided
if [ -z "$1" ]; then
    echo -e "\e[31mError: No search term provided.\e[0m"
    echo -e "Usage: $0 <search_term>"
    echo -e "Example: $0 /opt/my_software/bin"
    exit 1
fi

SEARCH_TERM="$1"

echo -e "\e[34mSearching for '$SEARCH_TERM' in environment config files and Bash scripts...\e[0m\n"

# --- 1. Standard Explicit Files (Native shell files without extensions) ---
EXPLICIT_FILES=(
    # Global
    "/etc/profile"
    "/etc/bashrc"
    "/etc/environment"

    # User / Terminal Session
    "$HOME/.bash_profile"
    "$HOME/.bashrc"
    "$HOME/.profile"
    "$HOME/.bash_login"

    # ZSH (Common alternative shell)
    "$HOME/.zshrc"
    "$HOME/.zprofile"
)

# --- 2. Directories to scan (Filtering ONLY by script extensions) ---
DIRECTORIES=(
    "/etc/profile.d"
    "/etc/environment.d"                  # Systemd global env
    "$HOME/.bashrc.d"                     # Terminal session env
    "$HOME/.config/environment.d"         # Systemd user env
    "$HOME/.config/plasma-workspace/env"  # KDE Plasma startup scripts
    "$HOME/.dev-scripts/bash/profile-init"                  # My customizations and scripts
)

FOUND=0

# Search in the standard explicit files
for FILE in "${EXPLICIT_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        # -n: line number, -I: ignore binaries
        RESULT=$(grep -rnIi --color=always "$SEARCH_TERM" "$FILE" 2>/dev/null)

        if [ -n "$RESULT" ]; then
            echo -e "\e[32m[+] Found in (Standard File): $FILE\e[0m"
            echo "$RESULT"
            echo "---------------------------------------------------"
            FOUND=1
        fi
    fi
done

# Search in directories filtering strictly by Bash script extensions (*.sh, *.bash)
# Note: Added *.conf just in case, as systemd environment.d strictly uses .conf files
for DIR in "${DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        # Using 'find' to strictly filter files by extension before grepping
        while IFS= read -r -d '' SCRIPT_FILE; do
            RESULT=$(grep -rnIi --color=always "$SEARCH_TERM" "$SCRIPT_FILE" 2>/dev/null)

            if [ -n "$RESULT" ]; then
                echo -e "\e[32m[+] Found in (Script File): $SCRIPT_FILE\e[0m"
                echo "$RESULT"
                echo "---------------------------------------------------"
                FOUND=1
            fi
        # The 'find' command filters by .sh and .bash extensions (and .conf for systemd compatibility)
        done < <(find "$DIR" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.conf" \) -print0 2>/dev/null)
    fi
done

if [ $FOUND -eq 0 ]; then
    echo -e "\e[33mNo results found for '$SEARCH_TERM' in the mapped locations.\e[0m"
fi