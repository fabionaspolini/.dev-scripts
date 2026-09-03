#!/usr/bin/env bash
set -e

ZED_DIR="$HOME/.config/zed"
ACTION=""
FORCE=false # If erro on git pull, local changes are discarded and reset to remote state

# 1. Parse command-line arguments
for arg in "$@"; do
    if [ "$arg" == "--force" ]; then
        FORCE=true
    elif [[ "$arg" =~ ^(save|discard|none)$ ]]; then
        ACTION="$arg"
    fi
done

# 2. Validate directory and Git repository
if [ ! -d "$ZED_DIR" ]; then
    echo "❌ Directory $ZED_DIR not found."
    exit 1
fi

cd "$ZED_DIR"

if [ ! -d ".git" ]; then
    echo "❌ Directory $ZED_DIR is not a Git repository. Initialize it first."
    exit 1
fi

echo "🔄 Fetching remote changes..."
git fetch origin main

echo "🔄 Pulling latest changes (rebase)..."
# Capture output and exit code to handle errors gracefully
set +e
PULL_OUTPUT=$(git pull --ff origin main 2>&1)
PULL_STATUS=$?
set -e

# 3. Handle git pull errors
if [ $PULL_STATUS -ne 0 ]; then
    echo "⚠️ Error during git pull:"
    echo -e "\n$PULL_OUTPUT\n"

    if [ "$FORCE" = true ]; then
        echo "⚠️ '--force' flag provided. Aborting rebase and discarding local changes..."
        git merge --abort 2>/dev/null || true
        git reset --hard origin/main
        git clean -fd
        echo "✅ Reset to remote state successfully."
        exit 0
    else
        echo "❌ Git pull failed due to conflicts or local changes."
        echo "👉 You must resolve this problem manually inside $ZED_DIR."
        exit 1
    fi
fi

# 4. Check for pending local modifications
if [ -n "$(git status --porcelain)" ]; then
    echo -e "\n📦 Local changes detected:"
    git status -s
    echo "--------------------------------------------------"
    # Show diff for tracked files
    git diff --color=always
    echo "--------------------------------------------------"

    # Prompt user if action was not provided via arguments
    if [ -z "$ACTION" ]; then
        while true; do
            read -p "What do you want to do with the pending changes? (save/discard/none): " USER_INPUT
            if [[ "$USER_INPUT" =~ ^(save|discard|none)$ ]]; then
                ACTION="$USER_INPUT"
                break
            else
                echo "❌ Invalid option. Please type 'save', 'discard', or 'none'."
            fi
        done
    fi

    # 5. Execute chosen action
    case "$ACTION" in
        save)
            echo "💾 Saving changes..."
            git add .
            HOSTNAME_STR=$(hostname 2>/dev/null || echo "machine")
            DATE_STR=$(date +"%Y-%m-%d %H:%M:%S")
            COMMIT_MSG="sync: configs updated at $DATE_STR [$HOSTNAME_STR]"

            git commit -m "$COMMIT_MSG"

            echo "🚀 Pushing changes to remote..."
            git push origin HEAD
            echo "✅ Sync completed successfully!"
            ;;
        discard)
            echo "🗑️ Discarding local changes..."
            git reset --hard origin/main
            git clean -fd
            echo "✅ Reverted to remote state."
            ;;
        none)
            echo "⏳ Changes left pending. No action taken."
            ;;
    esac
else
    echo "✨ No local changes detected. Everything is up to date!"
fi
