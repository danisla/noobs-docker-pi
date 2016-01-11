#!/bin/sh

# Set locale
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

cat << EOF | debconf-set-selections
locales   locales/locales_to_be_generated multiselect     en_US.UTF-8 UTF-8
EOF

rm /etc/locale.gen
dpkg-reconfigure -f noninteractive locales
update-locale LANG=en_US.UTF-8

cat << EOF | debconf-set-selections
locales   locales/default_environment_locale select       en_US.UTF-8
EOF

echo 'Reconfigured locale' >> /dev/kmsg
