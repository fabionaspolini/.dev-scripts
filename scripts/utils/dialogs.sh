# Avoid reloading the library if it was already imported in the current session
[[ -n "${_DIALOGS_SH_LOADED:-}" ]] && return 0
_DIALOGS_SH_LOADED=true

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"
source "$CURRENT_FOLDER/parse-args.sh"
unset CURRENT_FOLDER

# Function to display an error window on the desktop (Windows and Linux)
show_error_dialog() {
    local title=""
    local msg=""
    parse_args "$@"

    # Simple validation of required fields
    if [[ -z "$title" || -z "$msg" ]]; then
        echo "Error: --title and --msg are required." >&2
        return 1
    fi

    # Function logic
    local OS_NAME=$(uname -s)
    if [[ "$OS_NAME" == *"Linux"* ]]; then
        # local msg="Error updating the repositories in the folder:\n$ROOT_DIR\n\nSee the log file for more details:\n$LOG_FILE"
        if command -v zenity &> /dev/null; then
            zenity --error --title="$title" --text="$msg" 2>/dev/null &
        elif command -v kdialog &> /dev/null; then
            kdialog --error "$msg" --title "$title" 2>/dev/null &
        elif command -v notify-send &> /dev/null; then
            notify-send "$title" "$msg" -u critical &
        else
            echo -e "\n\a[DESKTOP ALERT] $msg"
        fi
    elif [[ "$OS_NAME" == *"MINGW"* || "$OS_NAME" == *"MSYS"* || "$OS_NAME" == *"CYGWIN"* ]]; then
        local win_log_path=$(cygpath -w "$LOG_FILE" 2>/dev/null || echo "$LOG_FILE")
        local ps_msg="Error updating the repositories in the folder:\`n$ROOT_DIR\`n\`nSee the log file for more details:\`n$win_log_path"
        # Use PowerShell/.NET to generate a native Windows MessageBox
        powershell.exe -NoProfile -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show(\"$ps_msg\", \"$title\", \"OK\", \"Error\")" 2>/dev/null &
    fi
}

# show_error_dialog --title "message title" --msg "message body"
