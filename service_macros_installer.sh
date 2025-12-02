#!/bin/bash
# Installer for Klipper-Service-Macros following KAMP-style structure

set -euo pipefail

REPO_URL="https://github.com/Herculez3D/Klipper-Service-Macros.git"
REPO_DIR="$HOME/Klipper-Service-Macros"
CONFIG_DIR="$HOME/printer_data/config"
MACRO_DIR="$CONFIG_DIR/ServiceMacros"
USER_SETTINGS="$CONFIG_DIR/ServiceSettings.cfg"
REPO_SETTINGS="$REPO_DIR/Configuration/ServiceSettings.cfg"
MOONRAKER_CONF="$CONFIG_DIR/moonraker.conf"
UPDATE_NAME="service_macros"

merge_settings() {
    if [[ ! -f "$USER_SETTINGS" ]]; then
        cp "$REPO_SETTINGS" "$USER_SETTINGS"
        return
    fi

    TEMP_MERGED="/tmp/ServiceSettings_merged.cfg"

    awk '
        FNR==NR { 
            if ($0 ~ /^\[/) section=$0; 
            if ($0 ~ /=/) existing[section,$1]=$0; 
            next 
        }
        {
            if ($0 ~ /^\[/) section=$0;
            if ($0 ~ /=/) { key=$1;
                if ((section,key) in existing) print existing[section,key];
                else print $0;
            } else print $0;
        }
    ' "$USER_SETTINGS" "$REPO_SETTINGS" > "$TEMP_MERGED"

    mv "$TEMP_MERGED" "$USER_SETTINGS"
}

create_symlink() {
    rm -rf "$MACRO_DIR"
    ln -s "$REPO_DIR/Configuration" "$MACRO_DIR"
}

add_update_manager() {
    if grep -q "^\[update_manager $UPDATE_NAME\]" "$MOONRAKER_CONF" 2>/dev/null; then
        return
    fi

    cat <<EOF >> "$MOONRAKER_CONF"

[update_manager $UPDATE_NAME]
type: git_repo
path: $REPO_DIR
origin: $REPO_URL
install_script: service_macros_installer.sh install
update_script: service_macros_installer.sh update
uninstall_script: service_macros_installer.sh uninstall
EOF
}

install_macros() {
    if [[ -d "$REPO_DIR/.git" ]]; then
        git -C "$REPO_DIR" pull
    else
        git clone "$REPO_URL" "$REPO_DIR"
    fi

    create_symlink
    merge_settings
    add_update_manager

    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
}

update_macros() {
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        install_macros
        return
    fi

    git -C "$REPO_DIR" pull
    create_symlink
    merge_settings

    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
}

uninstall_macros() {
    rm -rf "$MACRO_DIR"
    rm -rf "$REPO_DIR"

    sed -i "/^\[update_manager $UPDATE_NAME\]/,/^$/d" "$MOONRAKER_CONF" || true

    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
}

case "${1:-}" in
    install) install_macros ;;
    update) update_macros ;;
    uninstall) uninstall_macros ;;
    *) echo "Usage: $0 {install|update|uninstall}" ;;
esac
