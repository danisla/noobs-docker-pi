#!/bin/bash

if [ "$_" != "/bin/bash" ]; then
    # hack to force bash shell
    exec /bin/bash $0 $@
    exit
fi

[[ -e "/boot/config.txt" && -n $(grep '^disable_runstart=1' "/boot/config.txt") ]] && echo "$0 disabled by config.txt disable_runstart=1" >> /dev/kmsg && exit

function wait_for_docker() {
    timeout=${1:-30}
    docker info >/dev/null
    count=0
    while [[ $? != 0 && $count -lt $timeout ]]; do
        echo "Waiting for docker daemon" >> /dev/kmsg
        docker info >/dev/null
        ((count=count+1))
        sleep 1
    done

    [[ $count -lt $timeout ]]
}

IMG="danisla/rpi-earthcam:latest"
NAME="earthcam"

wait_for_docker && \
    (docker kill "${NAME}" ; docker rm -f "${NAME}") >/dev/null 2>&1

    [[ ${PULL:-false} == true ]] && docker pull "${IMG}"

    docker run -d --restart=always \
        --name ${NAME} \
        -v /opt/vc:/opt/vc:ro \
        --device dev/vchiq:/dev/vchiq \
        --device /dev/fb0:/dev/fb0 \
        --device /dev/snd:/dev/snd \
        ${IMG}
