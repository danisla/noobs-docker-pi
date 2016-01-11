#!/bin/sh

pkg_dir="/home/pi/recovery/pi-kitchen/050-docker/pkg"

for f in $(find "${pkg_dir}/deps" -name "*.deb"); do
    echo "Installing docker dependency: ${f}" >> /dev/kmsg
    dpkg -i "${f}"
done

latest=$(find ${pkg_dir} -type f -name "docker-*.deb" | sort -rn | head -1)

if test -n "${latest}"; then
    echo "Installing Docker from: ${latest}" >> /dev/kmsg
    dpkg -i "${latest}" && \
        systemctl enable docker.service
        systemctl start docker.service
else
    echo "ERROR: Docker package not found in ${pkg_dir}, skipping install." >> /dev/kmsg
    exit 1
fi
