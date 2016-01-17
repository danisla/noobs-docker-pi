#!/usr/bin/env bash

# Helper script to configure HypriotOS for the first time.

function log {
  >&2 echo "${@}"
}

function get_input() {
    msg=$1
    default=$2
    while [[ -z "$input" ]]; do
        if [[ -n "$default" ]]; then
            read -p "$msg ($default): " input
            [[ -z $input ]] && input=$default
        else
            read -p "$msg: " input
        fi
    done
    echo $input
}

function config_hypriotos_recipe() {
    boot=$1

    occidentalis="${boot}/pi-kitchen/055-hypriotos/occidentalis.txt"

    tmp_hostname=${DEFAULT_HOSTNAME:-"black-pearl-$((RANDOM % 1000 + 200))"}

    ### HypriotOS Hostname setup ###
    SD_HOSTNAME=$(get_input "Hostname" "${tmp_hostname}")
    sed -i "" -e "s/.*hostname.*=.*\$/hostname=${SD_HOSTNAME}/" "${occidentalis}" || \
        (log "ERROR: Could not update hostname" && return 1)

    if [[ $(get_input "Configure Wifi? (y/n)") == "y" ]]; then
        ### HypriotOS Wifi setup ###
        WIFI_SSID=$(get_input "Wifi SSID" "${DEFAULT_SSID}")
        sed -i "" -e "s/.*wifi_ssid.*=.*\$/wifi_ssid=${WIFI_SSID}/" "${occidentalis}" || \
            (log "ERROR: Could not update wifi_ssid" && return 1)

        WIFI_PASSWORD=$(get_input "Wifi PSK" "${DEFAULT_PSK}")
        sed -i "" -e "s/.*wifi_password.*=.*\$/wifi_password=${WIFI_PASSWORD}/" "${occidentalis}" || \
            (log "ERROR: Could not update wifi_password" && return 1)
    else
        log "INFO: Skipping wifi setup."
    fi
}

boot=$1

[[ -z "$boot" ]] && echo "USAGE: $0 <sd card root dir, ex: /Volumes/RECOVERY>" && exit 1

config_hypriotos_recipe "$boot"
