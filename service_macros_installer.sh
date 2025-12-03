#!/bin/bash
# Final V2.0.0-Beta Installer (with per-file chmod)

set -euo pipefail

USER_HOME="/home/voron"
VERSION="V2.0.0-Beta"
REPO_URL="https://github.com/Herculez3D/Klipper-Service-Macros.git"
REPO_DIR="$USER_HOME/Klipper-Service-Macros"

CONFIG_DIR="$USER_HOME/printer_data/config"
MACRO_DIR="$CONFIG_DIR/ServiceMacros"
USER_SETTINGS="$CONFIG_DIR/ServiceSettings.cfg"
REPO_SETTINGS="$REPO_DIR/Configuration/ServiceSettings.cfg"

MOONRAKER_CONF="$CONFIG_DIR/moonraker.conf"
MOONRAKER_ASVC="$USER_HOME/printer_data/moonraker.asvc"
UPDATE_NAME="service_macros"

info(){ echo "[INFO] $1"; }
warn(){ echo "[WARN] $1"; }
error(){ echo "[ERROR] $1"; exit 1; }

set_readonly_flags() {
    info "Setting ServiceMacros/*.cfg files to read-only..."
    chmod 444 "$MACRO_DIR/Service_Main.cfg" || warn "Could not lock Service_Main.cfg"
    chmod 444 "$MACRO_DIR/Service_Checks.cfg" || warn "Could not lock Service_Checks.cfg"
    chmod 444 "$MACRO_DIR/Service_Nozzle.cfg" || warn "Could not lock Service_Nozzle.cfg"
    chmod 444 "$MACRO_DIR/Service_Probe.cfg" || warn "Could not lock Service_Probe.cfg"
    info "Read-only permissions applied."
}

merge_settings(){
    if [[ ! -f "$REPO_SETTINGS" ]]; then error "Template missing."; fi
    if [[ ! -f "$USER_SETTINGS" ]]; then
        cp "$REPO_SETTINGS" "$USER_SETTINGS"
        chmod 644 "$USER_SETTINGS"
        return
    fi

    TEMP="/tmp/merged.cfg"
    awk '
        FNR==NR { if ($0 ~ /^\[/) section=$0; if ($0 ~ /=/) existing[section,$1]=$0; next }
        { if ($0 ~ /^\[/) section=$0;
          if ($0 ~ /=/) { key=$1;
            if ((section,key) in existing) print existing[section,key];
            else print $0;
          } else print $0 }
    ' "$USER_SETTINGS" "$REPO_SETTINGS" > "$TEMP"
    mv "$TEMP" "$USER_SETTINGS"
    chmod 644 "$USER_SETTINGS"
}

mirror_structure(){
    rm -rf "$MACRO_DIR" || true
    mkdir -p "$MACRO_DIR"
    cp -r "$REPO_DIR/Configuration/ServiceMacros/"* "$MACRO_DIR"/
    set_readonly_flags
}

clean_old_configs(){
    sed -i "/^\[update_manager $UPDATE_NAME\]/,/^$/d" "$MOONRAKER_CONF" || true
    sed -i '/service_macros/d' "$MOONRAKER_ASVC" || true
}

add_update_manager(){
    clean_old_configs
cat <<EOF >> "$MOONRAKER_CONF"

[update_manager $UPDATE_NAME]
type: git_repo
path: $REPO_DIR
origin: $REPO_URL
primary_branch: $VERSION
install_script: service_macros_installer.sh
is_system_service: False
EOF
}

prompt_reboot(){
    read -p "Reboot now? (Y/N): " ans
    [[ "$ans" =~ ^[Yy]$ ]] && sudo reboot
}

install_macros(){
    mkdir -p "$CONFIG_DIR"
    if [[ -d "$REPO_DIR/.git" ]]; then
        git -C "$REPO_DIR" fetch
        git -C "$REPO_DIR" checkout "$VERSION"
        git -C "$REPO_DIR" pull
    else
        git clone -b "$VERSION" "$REPO_URL" "$REPO_DIR"
    fi
    mirror_structure
    merge_settings
    add_update_manager
    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
    prompt_reboot
}

update_macros(){
    if [[ ! -d "$REPO_DIR/.git" ]]; then install_macros; return; end
    git -C "$REPO_DIR" fetch
    git -C "$REPO_DIR" checkout "$VERSION"
    git -C "$REPO_DIR" pull
    mirror_structure
    merge_settings
    add_update_manager
    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
    prompt_reboot
}

uninstall_macros(){
    rm -rf "$MACRO_DIR" "$REPO_DIR"
    sed -i "/^\[update_manager $UPDATE_NAME\]/,/^$/d" "$MOONRAKER_CONF" || true
    sed -i '/service_macros/d' "$MOONRAKER_ASVC" || true
    sudo systemctl restart moonraker || true
    sudo systemctl restart klipper || true
    prompt_reboot
}

case "${1:-}" in
    install) install_macros ;;
    update) update_macros ;;
    uninstall) uninstall_macros ;;
    *) echo "Usage: $0 {install|update|uninstall}" ;;
esac
