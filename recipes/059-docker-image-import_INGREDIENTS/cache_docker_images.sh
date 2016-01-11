#!/usr/bin/env bash

# Helper script to save local docker images to a tarball on the SD card.

function log {
  >&2 echo "${@}"
}

function cache_docker_images() {
    dest=$1
    img_list_file=$2

    # Attempts to save docker images to compressed tar.gz file. If the image hasn't already been pulled, 'docker pull <image>' is called.
    # `docker pull` isn't always called so that if you are building an image locally, it will prefer that.

    [[ ! -e `which docker` ]] && log "ERROR: cannot cache docker images because docker is not installed." && return 1

    [[ ! -d "${dest}" ]] && mkdir -p "${dest}"

    function save_image() {
        img=$1
        dest_img=$2
        pull=${3:-false}

        $pull && ( ( log "INFO: Pulling '${img}'" && docker pull "${img}" ; [[ $? -ne 0 ]] && log "ERROR: Could not pull docker image: ${img}" && return 1 ) )

        log "INFO: Saving compressed docker image of ${img} to ${dest_img}"

        test -z $((docker save "${img}" | gzip - > "${dest_img}") 2>/dev/null)
    }

    failed=0
    while read img; do
        dest_img="${dest:-/tmp}/${img/\//_}.tar.gz"
        dest_img="${dest_img/:/_}"

        # Skip existing image.
        [[ -e "${dest_img}" ]] && continue

        pull=false
        for i in `seq 2`; do
            save_image "${img}" "${dest_img}" $pull
            if [[ $? -ne 0 ]]; then
                if [[ $i -eq 1 ]]; then
                    log "WARN: Could not save image: ${img}, trying docker pull first."
                    pull=true
                    continue
                else
                    log "ERROR: Could not save docker image: ${img}"
                    rm -f ${dest_img}
                    failed=1
                fi
            else
                break
            fi
        done
    done < "${img_list_file}"

    return $failed
}

############################################

SD_ROOT=$1
IMG_LIST=$2

[[ -z "$SD_ROOT" || -z "$IMG_LIST" ]] && echo "USAGE: $0 <dest sd root dir, ex: /Volumes/RECOVERY> <image list file>]" && exit 1

DOCKER_IMAGE_DIR="${SD_ROOT}/docker_images"

cache_docker_images "$DOCKER_IMAGE_DIR" "$IMG_LIST"
