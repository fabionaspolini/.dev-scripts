alias fix-keyboard-ibus-errors="ibus restart"

upgrade-all-packages() {
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
}