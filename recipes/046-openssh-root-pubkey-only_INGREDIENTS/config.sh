#!/usr/bin/env bash

function log {
  >&2 echo "${@}"
}

function add_pub_key() {
    boot=$1

    keys_file="${boot}/pi-kitchen/046-openssh-root-pubkey-only/authorized_keys"

    if [[ -s "${DEFAULT_SSH_PUB_KEY}" ]]; then
        log "INFO: Adding key to authorized_keys file from DEFAULT_SSH_PUB_KEY: ${DEFAULT_SSH_PUB_KEY}"
        cat "${DEFAULT_SSH_PUB_KEY}" >> "${keys_file}"
    else
        # Generate new key.
        ssh-keygen -t rsa -b 2048 -P '' -f ./id_rsa

        log "INFO: Adding ./id_rsa.pub to authorized_keys file."
        cat "./id_rsa.pub" >> "${keys_file}"
    fi
}

boot=$1

[[ -z "$boot" ]] && echo "USAGE: $0 <sd card root dir, ex: /Volumes/RECOVERY>" && exit 1

add_pub_key "$boot"
