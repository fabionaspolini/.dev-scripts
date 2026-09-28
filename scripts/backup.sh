#!/usr/bin/env bash

# Generic backup script to compress multiple sets of files
# Makes it easy to define new backups in the BACKUPS data structure


# Global configuration
DEST_BASE="$HOME/GoogleDrive/Backups/Automatic/$(hostname)"
RUN_DATE="$(date +%Y-%m-%d_%H-%M-%S)"
DEST="$DEST_BASE/$RUN_DATE"

# Rotation policy: keep backups from the last N days, but never fewer than MIN_FOLDERS
RETENTION_DAYS=7
MIN_FOLDERS=10

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# ============================================================================
# BACKUP STRUCTURE
# ============================================================================
# Simple format:      [dest_name]="source_path1:source_path2:..."
# Format with -C:      [dest_name]="-C|/base/path|subpath1:subpath2:file.json"
#
# The -C format uses pipe (|) as separator:
#   -C | base_directory | relative_items_separated_by_colon
#
# Simple example:
#   [bashrc.d]="$HOME/.bashrc.d"
#
# Example with -C (avoids full path in tar):
#   [qwen]="-C|$HOME/.qwen|agents:skills:settings.json"
# ============================================================================

# Add more backups as needed:
declare -A BACKUPS=(
    [home.root]="-C|$HOME|.bash_profile:.bashrc:.gitconfig:.npmrc:.zshrc:.profile:.zshrc:.p10k.zsh*"
    [home.bashrc.d]="-C|$HOME/.bashrc.d|*"
    [home.claude]="-C|$HOME/.claude|*"
    [home.qwen]="-C|$HOME/.qwen|*"
    [home.ssh]="-C|$HOME/.ssh|*"
    [home.config]="-C|$HOME/.config|systemd/user/*.service:systemd/user/*.timer:systemd/user/disabled-services/:plasma*:kglobalshortcutsrc:kdeglobals:kwin*:wireplumber:konsolerc"
    [home.local]="-C|$HOME/.local|share/plasma*:share/konsole"
    [home.kube]="-C|$HOME/.kube|config:*.config"
    [home.zsh]="-C|$HOME/.zsh|*"
    [home.zshrc.d]="-C|$HOME/.zshrc.d|*"
)

# ============================================================================
# FUNCTIONS
# ============================================================================

show_msg() {
    echo -e "${GREEN}[BACKUP]${NC} $1"
}

show_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

show_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

# Create destination directory if it doesn't exist
create_dest_directory() {
    if [ ! -d "$DEST" ]; then
        show_msg "Creating destination directory: $DEST"
        if ! mkdir -p "$DEST"; then
            show_error "Failed to create directory: $DEST"
            return 1
        fi
    fi
    return 0
}

# Rotate old backups: keeps folders from the last RETENTION_DAYS days,
# guaranteeing a minimum of MIN_FOLDERS folders even if that exceeds the deadline
rotate_backups() {
    if [ ! -d "$DEST_BASE" ]; then
        return 0
    fi

    local folders=()
    while IFS= read -r -d '' folder; do
        folders+=("$folder")
    done < <(find "$DEST_BASE" -mindepth 1 -maxdepth 1 -type d -print0 | sort -zr)

    local total=${#folders[@]}
    if [ "$total" -le "$MIN_FOLDERS" ]; then
        return 0
    fi

    local cutoff_date
    cutoff_date=$(date -d "-${RETENTION_DAYS} days" +%Y-%m-%d)

    local i
    for ((i = 0; i < total; i++)); do
        # Always preserve the MIN_FOLDERS most recent
        if [ "$i" -lt "$MIN_FOLDERS" ]; then
            continue
        fi

        local folder="${folders[$i]}"
        local folder_name
        folder_name=$(basename "$folder")
        local folder_date="${folder_name%%_*}"

        if [[ "$folder_date" < "$cutoff_date" ]]; then
            show_msg "Removing old backup: $folder_name"
            rm -rf "$folder"
        fi
    done
}

# Validate whether a path exists (supports glob patterns)
validate_path() {
    local path="$1"
    # If it contains a glob, expand it
    if [[ "$path" == *'*'* || "$path" == *'?'* || "$path" == *'['* ]]; then
        local expanded=()
        # shellcheck disable=SC2206
        expanded=($path)
        if [ ${#expanded[@]} -gt 0 ] && [ -e "${expanded[0]}" ]; then
            return 0
        fi
        return 1
    fi
    if [ ! -e "$path" ]; then
        return 1
    fi
    return 0
}

# Expand glob pattern into an array of valid paths
expand_glob() {
    local pattern="$1"
    local results=()

    if [[ "$pattern" == *'*'* || "$pattern" == *'?'* || "$pattern" == *'['* ]]; then
        local dotglob_was_off=false
        shopt -q dotglob || dotglob_was_off=true
        shopt -s dotglob  # Make '*' also match hidden files/dirs (.git, .idea, etc.)

        # shellcheck disable=SC2206
        results=($pattern)

        if [ "$dotglob_was_off" = true ]; then
            shopt -u dotglob
        fi

        # Filter only existing ones
        local valid=()
        for r in "${results[@]}"; do
            if [ -e "$r" ]; then
                valid+=("$r")
            fi
        done
        echo "${valid[@]}"
    else
        if [ -e "$pattern" ]; then
            echo "$pattern"
        fi
    fi
}

# Run an individual backup
run_backup() {
    local backup_name="$1"
    local source_paths="$2"
    local file_name="${backup_name}.tar.gz"
    local full_path="$DEST/$file_name"

    local use_c_flag=false
    local base_directory=""
    local relative_items_str=""
    local valid_paths=()

    # Detect format: with -C or simple
    if [[ "$source_paths" == "-C|"* ]]; then
        use_c_flag=true
        IFS='|' read -r _ base_directory relative_items_str <<< "$source_paths"

        # Validate base directory
        if [ ! -d "$base_directory" ]; then
            show_error "Base directory not found: $base_directory"
            return 1
        fi

        # Split relative items by ':'
        local IFS=':'
        set -f  # Disable glob expansion
        local items=($relative_items_str)
        set +f
        unset IFS

        show_msg "Validating source files (-C mode: $base_directory)..."
        for item in "${items[@]}"; do
            local pattern="$base_directory/$item"
            local expanded
            expanded=$(expand_glob "$pattern")

            if [ -n "$expanded" ]; then
                local added=0
                for file in $expanded; do
                    # Store path relative to base_directory for -C to work
                    local relative="${file#$base_directory/}"
                    valid_paths+=("$relative")
                    show_msg "✓ Found: $relative"
                    ((added++))
                done
            else
                show_warning "✗ Not found: $item"
            fi
        done
    else
        # Simple format (absolute paths, possibly with glob)
        local IFS=':'
        set -f  # Disable glob expansion
        local paths=($source_paths)
        set +f
        unset IFS

        show_msg "Validating source files..."
        for path in "${paths[@]}"; do
            local expanded
            expanded=$(expand_glob "$path")

            if [ -n "$expanded" ]; then
                for file in $expanded; do
                    valid_paths+=("$file")
                    show_msg "✓ Found: $file"
                done
            else
                show_warning "✗ Not found: $path"
            fi
        done
    fi

    # Check that we have at least one valid path
    if [ ${#valid_paths[@]} -eq 0 ]; then
        show_error "No valid file or directory found for: $backup_name"
        return 1
    fi

    # Create backup file
    show_msg "Creating backup file: $file_name"

    local tar_result=false
    if [ "$use_c_flag" = true ]; then
        tar -czf "$full_path" -C "$base_directory" "${valid_paths[@]}" 2>&1 > /dev/null && tar_result=true
    else
        tar -czf "$full_path" "${valid_paths[@]}" 2>&1 > /dev/null && tar_result=true
    fi

    if [ "$tar_result" = true ]; then
        # Display information about the created file
        if [ -f "$full_path" ]; then
            local size=$(du -h "$full_path" | cut -f1)
            show_msg "Backup completed successfully!"
            show_msg "File: $file_name"
            show_msg "Size: $size"
            show_msg "Path: $full_path"
            return 0
        else
            show_error "Backup file was not created"
            return 1
        fi
    else
        show_error "Failed to create backup file: $file_name"
        return 1
    fi
}

# ============================================================================
# MAIN PROGRAM
# ============================================================================

main() {
    show_section "STARTING BACKUPS"

    # Validate destination directory
    if ! create_dest_directory; then
        show_error "Could not create destination directory"
        return 1
    fi

    # Check if there are backups configured
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        show_error "No backups configured"
        return 1
    fi

    show_msg "Total backups to run: ${#BACKUPS[@]}"

    local total_backups=${#BACKUPS[@]}
    local backups_success=0
    local backups_failed=0

    # Run each backup
    for backup_name in "${!BACKUPS[@]}"; do
        show_section "BACKUP: $backup_name"

        if run_backup "$backup_name" "${BACKUPS[$backup_name]}"; then
            ((backups_success++))
        else
            ((backups_failed++))
        fi

        echo ""
    done

    # Final summary
    show_section "FINAL SUMMARY"
    show_msg "Total: $total_backups | Success: $backups_success | Failed: $backups_failed"

    # Rotate old backups
    show_section "ROTATING OLD BACKUPS"
    rotate_backups

    if [ $backups_failed -gt 0 ]; then
        return 1
    fi

    return 0
}

main
#exit $?
