#!/bin/sh

DOCKER_IMAGE_DIR="/home/pi/recovery/docker_images"

for f in $(find "${DOCKER_IMAGE_DIR}" -type f -regextype posix-egrep -regex '.*(tar|gz|xz)$'); do
    SIZE=$(du -sh noobs-docker-pi | awk '{print $1}')
    echo "Import Docker image (${SIZE}) ${f}" >> /dev/kmsg
    docker load < "${f}"
done
