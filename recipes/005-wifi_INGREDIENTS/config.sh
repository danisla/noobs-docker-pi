#!/usr/bin/env bash

# Helper script to configure 005-wifi recipe for the first time.

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

function setup_wifi() {
    boot=$1

    dest_dir="${boot}/pi-kitchen/005-wifi/etc/network"

    [[ ! -d "${dest_dir}" ]] && mkdir -p "${dest_dir}"

    ### 005-wifi setup ###
    ssid=$(get_input "Wifi SSID" "${DEFAULT_SSID}")
    psk=$(get_input "Wifi PSK" "${DEFAULT_PSK}")

    cat "${dest_dir}/interfaces.tpl" | sed -e 's/\$ssid/'"$ssid"'/' -e 's/\$psk/'"$psk"'/' > "${dest_dir}/interfaces"
}

boot=$1

[[ -z "$boot" ]] && echo "USAGE: $0 <sd card root dir, ex: /Volumes/RECOVERY>" && exit 1

setup_wifi "$boot"
