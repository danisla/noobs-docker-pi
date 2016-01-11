#!/bin/sh

echo 'Setting permissions on /root/.ssh' >> /dev/kmsg
! test -d /root/.ssh && mkdir -p /root/.ssh && chmod 0600 /root/.ssh

echo 'Updating /root/.ssh/authorized_keys' >> /dev/kmsg
cat /home/pi/recovery/pi-kitchen/046-openssh-root-pubkey-only/authorized_keys >> /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
