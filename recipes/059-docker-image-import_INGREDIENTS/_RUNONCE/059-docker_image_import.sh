#!/bin/sh

DOCKER_IMAGE_DIR="/home/pi/recovery/docker_images"

for f in $(find "${DOCKER_IMAGE_DIR}" -type f -regextype posix-egrep -regex '.*(tar|gz|xz)$'); do
    echo "Import Docker image `du -sh ${f}`" >> /dev/kmsg
    docker load < "${f}"
done
