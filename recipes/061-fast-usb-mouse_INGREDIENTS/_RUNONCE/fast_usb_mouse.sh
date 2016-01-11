#!/bin/sh

file="/boot/config.txt"

grep -q "^usbhid.mousepoll=0" "$file" && exit

echo "Adding usbhid.mousepoll=0 to $file" >> /dev/kmsg

grep -q "^usbhid.mousepoll.*" "$file" &>/dev/null && sed -i -e 's/^usbhid.mousepoll.*/usbhid.mousepoll=0/' "$file" || echo "usbhid.mousepoll=0" >> "$file"
