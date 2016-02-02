#!/bin/bash

if [ "$_" != "/bin/bash" ]; then
    # hack to force bash shell
    exec /bin/bash $0 $@
    exit
fi

echo "Current IP Address: `hostname -I`" > >(tee /dev/kmsg) 2> >(tee /dev/kmsg >&2)

[[ -e "/boot/config.txt" && -n $(grep '^disable_runstart=1' "/boot/config.txt") ]] && echo "$0 disabled by config.txt disable_runstart=1" >> /dev/kmsg && exit

function wait_for_docker() {
    timeout=${1:-30}
    count=0
    docker info >/dev/null
    while [[ $? != 0 && $count -lt $timeout ]]; do
        echo "Waiting for docker daemon" >> /dev/kmsg
        ((count=count+1))
        sleep 1
        docker info >/dev/null
    done

    [[ $count -lt $timeout ]]
}

function wait_for_network() {
    timeout=${1:-24}
    count=0
    docker info >/dev/null
    while [[ $? != 0 && $count -lt $timeout ]]; do
        echo "Waiting for network" >> /dev/kmsg
        ((count=count+1))
        sleep 1
        ping -c 1 -t 5 www.google.com > /dev/null
    done

    [[ $count -lt $timeout ]]
}

function docker_compose_pull_and_run() {
    f=$1
    echo "Running docker-compose -f ${f} pull" > >(tee /dev/kmsg) 2> >(tee /dev/kmsg >&2)
    docker-compose -f "${f}" pull > >(tee /dev/kmsg) 2> >(tee /dev/kmsg >&2)

    echo "Running docker-compose -f ${f} up -d" > >(tee /dev/kmsg) 2> >(tee /dev/kmsg >&2)
    docker-compose -f "${f}" up -d > >(tee /dev/kmsg) 2> >(tee /dev/kmsg >&2)
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

wait_for_docker || echo "Error waiting for docker" >> /dev/kmsg
wait_for_network || echo "Error waiting for network" >> /dev/kmsg

MAIN_FILE="/home/pi/recovery/docker-compose.yml"

if [[ -e "${MAIN_FILE}" ]]; then
    docker_compose_pull_and_run "${MAIN_FILE}"
 fi

# Run any docker-compose.yml files found in the recovery partitions /_USER/docker_runstart/ dir.
DOCKER_RUNSTART="/home/pi/recovery/_USER/docker_runstart"

[[ ! -d "${DOCKER_RUNSTART}" ]] && exit

for f in $(find ${DOCKER_RUNSTART} -name "docker-compose.yml"); do
    docker_compose_pull_and_run "${f}"
done

sleep 5
