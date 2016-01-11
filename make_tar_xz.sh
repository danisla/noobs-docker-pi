#!/usr/bin/env bash

function log {
  >&2 echo "${@}"
}

boot_mnt="/mnt/img_boot"
root_mnt="/mnt/img_root"

function mount_dev() {
    src=$1
    dest=$2
    [[ ! -d "$dest" ]] && mkdir -p "$dest"
    sudo mount -o ro "$src" "$dest"
}

function build() {
    src=$1
    dest=$2
    [[ -e "${dest}.xz" ]] && rm "${dest}.xz"
    cd "${src}"
    tar cf "${dest}" . && xz ${dest} && cd - >/dev/null
}

BOOT_DEV=$1
ROOT_DEV=$2
DEST_DIR=$3

[[ -z "${BOOT_DEV}" || -z "${ROOT_DEV}" || -z "${DEST_DIR}" ]] && log "USAGE: <boot device (ex: /dev/sdb1)> <root device (ex: /dev/sdb2)> <dest dir>" && exit 1
[[ ! -b "${BOOT_DEV}" ]] && log "ERROR: device not found: ${BOOT_DEV}" && exit 1
[[ ! -b "${ROOT_DEV}" ]] && log "ERROR: device not found: ${ROOT_DEV}" && exit 1

[[ ! -d "${DEST_DIR}" ]] && mkdir -p "${DEST_DIR}"

mount_dev "${BOOT_DEV}" "${boot_mnt}"
mount_dev "${ROOT_DEV}" "${root_mnt}"

log "INFO: Building boot.tar.xz"
build "${boot_mnt}" "${DEST_DIR}/boot.tar"
[[ ! -e "${DEST_DIR}/boot.tar.xz" ]] && log "ERROR: Could not build: ${DEST_DIR}/boot.tar.xz" && exit 1

log "INFO: Building root.tar.xz, this will take a few minutes."
build "${root_mnt}" "${DEST_DIR}/root.tar"
[[ ! -e "${DEST_DIR}/root.tar.xz" ]] && log "ERROR: Could not build: ${DEST_DIR}/root.tar.xz" && exit 1

sudo umount "${boot_mnt}"
sudo umount "${root_mnt}"
