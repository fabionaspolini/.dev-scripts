upgrade-all-packages() {
    echo "Upgrading all packages..."

    echo -e "\033[1mPress any key to upgrade packages using dnf...\033[0m"
    read -n1 -s
    sudo dnf upgrade --refresh

    echo "----------------------------------------"
    echo -e "\033[1mPress any key to upgrade packages using pkcon...\033[0m"
    read -n1 -s
    pkcon refresh && pkcon update

    echo "----------------------------------------"
    echo -e "\033[1mPress any key to upgrade packages using flatpak...\033[0m"
    read -n1 -s
    flatpak update

    echo "----------------------------------------"
    echo -e "\033[1mPress any key to upgrade packages using snap...\033[0m"
    read -n1 -s
    sudo snap refresh

    echo "----------------------------------------"
    echo "Finishing package upgrades."
}