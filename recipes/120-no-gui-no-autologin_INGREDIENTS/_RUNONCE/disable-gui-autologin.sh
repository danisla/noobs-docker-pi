#!/bin/sh
# Disable automatic boot to desktop
systemctl set-default multi-user.target
# Disable auto-login
ln -fs /lib/systemd/system/getty@.service \
    /etc/systemd/system/getty.target.wants/getty@tty1.service
