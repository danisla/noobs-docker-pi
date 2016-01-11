#!/usr/bin/env bash

# Helper script to download docker deb file and save it to the SD card installed recipe dir.

function log {
  >&2 echo "${@}"
}

DOCKER_DEB_URL=${DOCKER_DEB_URL:-"http://downloads.hypriot.com/docker-hypriot_1.9.1-1_armhf.deb"}

DEST=$1
[[ -z "$DEST" ]] && echo "USAGE: $0 <dest sd root dir, ex: /Volumes/RECOVERY> [<docker deb url: ${DOCKER_DEB_URL}>]" && exit 1

function get_docker_deps() {
    root=$1

    MIRROR="http://http.us.debian.org/debian/pool/main"
    DEBS="/libn/libnfnetlink/libnfnetlink0_1.0.1-3_armhf.deb /i/iptables/libxtables10_1.4.21-2+b1_armhf.deb /i/iptables/iptables_1.4.21-2+b1_armhf.deb"
    for deb in $DEBS; do
        url="${MIRROR}/${deb}"
        TMP_FILE="/tmp/$(basename $url)"
        if [[ ! -e "${TMP_FILE}" ]]; then
            log "INFO: Downloading $url to ${TMP_FILE}"
            curl -s -L -o "${TMP_FILE}" "${url}" || (log "ERROR: could not download ${URL}" && return 1)
        fi
        rsync "${TMP_FILE}" "${root}/pi-kitchen/050-docker/pkg/deps"
    done
}

function get_docker_deb() {
    root=$1
    url=$2

    TMP_FILE="/tmp/$(basename $url)"
    if [[ ! -e "${TMP_FILE}" ]]; then
        log "INFO: Downloading ${url} to ${TMP_FILE}"
        curl -s -L -o "${TMP_FILE}" "${url}" || (log "ERROR: could not download ${URL}" && return 1)
    fi

    rsync "${TMP_FILE}" "${root}/pi-kitchen/050-docker/pkg/"
}

get_docker_deps "$1"
get_docker_deb "$1" "${2:-$DOCKER_DEB_URL}"
