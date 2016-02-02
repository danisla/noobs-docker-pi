#!/usr/bin/env bash

function log {
  >&2 echo "${@}"
}

boot_mnt="/mnt/img_boot"
root_mnt="/mnt/img_root"

declare -a offsets

function compute_offsets() {
    img=$1
    parts=($(fdisk -lu "${img}" | sed 's/\*//g' | awk '/\.img[0-9]/ {print $2}'))
    for i in `seq 0 1`; do
        start=${parts[$i]}
        ((offsets[$i]=start*512))
    done
}

function mount_img_part() {
    img=$1
    index=$2
    dest=$3
    [[ ! -d "$dest" ]] && mkdir -p "$dest"
    mount -o ro,loop,offset=${offsets[$index]} "${img}" "${dest}"
}

function build() {
    src=$1
    dest=$2

    [[ -e "${dest}.tar" ]] && rm "${dest}.tar"
    [[ -e "${dest}.xz" ]] && rm "${dest}.xz"

    cd "${src}"
    tar cf "${dest}" . && xz ${dest} && cd - >/dev/null
}

SRC_IMG=$1
DEST_DIR=$2

[[ -z "${SRC_IMG}" || -z "${DEST_DIR}" ]] && log "USAGE: <src img> <dest dir>" && exit 1
[[ ! -s "${SRC_IMG}" ]] && log "ERROR: img not found: ${SRC_IMG}" && exit 1

[[ ! -d "${DEST_DIR}" ]] && mkdir -p "${DEST_DIR}"

compute_offsets "$SRC_IMG"

mount_img_part "${SRC_IMG}" 0 "${boot_mnt}"
mount_img_part "${SRC_IMG}" 1 "${root_mnt}"

log "INFO: Building boot.tar.xz"
build "${boot_mnt}" "${DEST_DIR}/boot.tar"
[[ ! -e "${DEST_DIR}/boot.tar.xz" ]] && log "ERROR: Could not build: ${DEST_DIR}/boot.tar.xz" && exit 1

log "INFO: Building root.tar.xz, this will take a few minutes."
build "${root_mnt}" "${DEST_DIR}/root.tar"
[[ ! -e "${DEST_DIR}/root.tar.xz" ]] && log "ERROR: Could not build: ${DEST_DIR}/root.tar.xz" && exit 1

umount "${boot_mnt}"
umount "${root_mnt}"
