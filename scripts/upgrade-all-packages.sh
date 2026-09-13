CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"
source "$CURRENT_FOLDER/utils/parse-args.sh"
unset CURRENT_FOLDER

local snapshot=""
parse_args "$@"

if [[ -z "$snapshot" ]]; then
    echo -e "\033[1mDo you want to create a btrfs snapshot before upgrading?\033[0m"
    echo "  1) Create snapshot and upgrade packages"
    echo "  2) Only upgrade packages"
    echo "  3) Exit"
    choice=""
    read -rp "Choose an option [1/2/3]: " choice
    case "$choice" in
        1) snapshot="true" ;;
        2) snapshot="false" ;;
        *)  echo "Exiting..."
            exit 0 ;;
    esac
fi

if [[ "$snapshot" == "true" ]]; then
    echo "Creating btrfs snapshot..."
    sudo snapper --config root create \
        --type pre \
        --description "Pre-upgrade packages automatic" \
        --cleanup-algorithm number
    echo "Snapshot created."
fi

echo "Upgrading all packages..."

echo -e "\033[1mPress any key to upgrade packages using \033[33mdnf\033[0m\033[1m...\033[0m"
read -n1 -s
sudo dnf upgrade --refresh

echo "----------------------------------------"
echo -e "\033[1mPress any key to upgrade packages using \033[33mpkcon\033[0m\033[1m...\033[0m"
read -n1 -s
pkcon refresh && pkcon update

echo "----------------------------------------"
echo -e "\033[1mPress any key to upgrade packages using \033[33mflatpak\033[0m\033[1m...\033[0m"
read -n1 -s
flatpak update

# echo "----------------------------------------"
# echo -e "\033[1mPress any key to upgrade packages using \033[33msnap\033[0m\033[1m...\033[0m"
# read -n1 -s
# sudo snap refresh

echo "----------------------------------------"
echo "Finishing package upgrades."
