#!/bin/sh

# Set timezone
echo 'GMT' > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo 'Reconfigured timezone to GMT' >> /dev/kmsg
