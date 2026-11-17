#!/usr/bin/env bash
# Upgrades Plasma add-ons installed through KNewStuff (shown in Discover under
# "Plasma Addons"). Only KPackage-based categories are handled, since those can
# be installed from the command line with kpackagetool6. Other categories
# (icons, cursors, color schemes, ...) must still be updated via Discover.

CURRENT_FOLDER="$(dirname -- "${BASH_SOURCE[0]}")"
source "$CURRENT_FOLDER/utils/parse-args.sh"
unset CURRENT_FOLDER

yes=""
parse_args "$@"

REGISTRY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/knewstuff3"
OCS_API="https://api.kde-look.org/ocs/v1/content/data"

# knsregistry file name -> kpackagetool6 package type
declare -A PACKAGE_TYPES=(
    [plasmoids]="Plasma/Applet"
    [wallpaperplugin]="Plasma/Wallpaper"
    [kwinscripts]="KWin/Script"
)

for cmd in curl python3 kpackagetool6; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "\033[31mRequired command not found: $cmd\033[0m"
        exit 1
    fi
done

# Prints "id<TAB>name<TAB>version" for each installed item of a registry file.
list_installed() {
    python3 - "$1" <<'EOF'
import sys, xml.etree.ElementTree as ET
for item in ET.parse(sys.argv[1]).getroot().iter("stuff"):
    if (item.findtext("status") or "") != "installed":
        continue
    print("\t".join((item.findtext(f) or "").strip() for f in ("id", "name", "version")))
EOF
}

# Updates version and release date of an item in a registry file, so Discover
# stops listing it as upgradeable.
update_registry() {
    python3 - "$@" <<'EOF'
import sys, xml.etree.ElementTree as ET
path, item_id, version, release_date = sys.argv[1:5]
tree = ET.parse(path)
for item in tree.getroot().iter("stuff"):
    if (item.findtext("id") or "").strip() == item_id:
        for tag, value in (("version", version), ("releasedate", release_date)):
            node = item.find(tag)
            if node is None:
                node = ET.SubElement(item, tag)
            node.text = value
tree.write(path, encoding="UTF-8", xml_declaration=True)
EOF
}

# Prints a field from an OCS API XML response.
ocs_field() {
    grep -oPm1 "(?<=<$1>)[^<]*" <<< "$2"
}

pending=()
echo "Checking Plasma add-ons for updates..."
for category in "${!PACKAGE_TYPES[@]}"; do
    registry="$REGISTRY_DIR/$category.knsregistry"
    [[ -f "$registry" ]] || continue

    while IFS=$'\t' read -r id name version; do
        [[ -n "$id" ]] || continue
        response="$(curl -fsS "$OCS_API/$id")" || {
            echo -e "  \033[31mFailed to query '$name' ($id)\033[0m"
            continue
        }
        latest="$(ocs_field version "$response")"
        if [[ -n "$latest" && "$latest" != "$version" ]]; then
            echo -e "  \033[1m$name\033[0m: $version -> \033[33m$latest\033[0m"
            pending+=("$category"$'\t'"$id"$'\t'"$name")
        fi
    done < <(list_installed "$registry")
done

if [[ ${#pending[@]} -eq 0 ]]; then
    echo "All Plasma add-ons are up to date."
    exit 0
fi

if [[ "$yes" != "true" ]]; then
    echo -e "\033[1mPress any key to upgrade ${#pending[@]} Plasma add-on(s)...\033[0m"
    read -n1 -s
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for entry in "${pending[@]}"; do
    IFS=$'\t' read -r category id name <<< "$entry"
    echo "----------------------------------------"
    echo -e "Upgrading \033[1m$name\033[0m..."

    # Download links are signed and short-lived, so fetch them right before use.
    response="$(curl -fsS "$OCS_API/$id")" || { echo -e "\033[31mFailed to query '$name'\033[0m"; continue; }
    latest="$(ocs_field version "$response")"
    changed="$(ocs_field changed "$response")"
    link="$(ocs_field downloadlink1 "$response")"
    file_name="$(ocs_field downloadname1 "$response")"

    if [[ -z "$link" || -z "$file_name" ]]; then
        echo -e "\033[31mNo download link found for '$name'. Update it via Discover.\033[0m"
        continue
    fi

    package="$tmp_dir/$id-$file_name"
    if ! curl -fsSL -o "$package" "$link"; then
        echo -e "\033[31mFailed to download '$file_name'\033[0m"
        continue
    fi

    if kpackagetool6 --type "${PACKAGE_TYPES[$category]}" --upgrade "$package"; then
        update_registry "$REGISTRY_DIR/$category.knsregistry" "$id" "$latest" "${changed:0:10}"
        echo -e "\033[32m'$name' upgraded to $latest.\033[0m"
    else
        echo -e "\033[31mkpackagetool6 failed to upgrade '$name'\033[0m"
    fi
done

echo "----------------------------------------"
echo -e "\033[33mNote:\033[0m restart Plasma to load the new versions (log out/in, or: \033[1msystemctl --user restart plasma-plasmashell\033[0m)."
