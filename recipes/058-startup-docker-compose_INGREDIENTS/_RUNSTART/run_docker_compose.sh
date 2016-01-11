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

### Install docker-compose ###
if [[ ! -e `which docker-compose` ]]; then
    if [[ ! -e `which pip` ]]; then
        echo "Installing python-pip" >> /dev/kmsg
        apt-get update && \
            apt-get install --no-install-recommends -y python-pip
    fi

    echo "Installing docker-compose" >> /dev/kmsg
    pip install docker-compose
fi
###

MAIN_FILE="/home/pi/recovery/docker-compose.yml"

[[ -e "${MAIN_FILE}" ]] && echo "Running docker-compose -f ${MAIN_FILE} up -d" >/dev/kmsg && docker-compose -f "${MAIN_FILE}" up -d

# Run any docker-compose.yml files found in the recovery partitions /_USER/docker_runstart/ dir.
DOCKER_RUNSTART="/home/pi/recovery/_USER/docker_runstart"

[[ ! -d "${DOCKER_RUNSTART}" ]] && exit

for f in $(find ${DOCKER_RUNSTART} -name "docker-compose.yml"); do
    echo "docker-compose -f "${f}" up -d" >> /dev/kmsg
    docker-compose -f "${f}" up -d
done
