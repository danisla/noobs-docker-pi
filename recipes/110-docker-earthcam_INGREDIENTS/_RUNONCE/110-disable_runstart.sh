#!/bin/sh

file="/boot/config.txt"

grep -q "^disable_runstart=1" "$file" && exit

echo "Adding disable_runstart=1 to $file" >> /dev/kmsg

grep -q "^disable_runstart.*" "$file" &>/dev/null && sed -i -e 's/^disable_runstart.*/disable_runstart=1/' "$file" || echo "disable_runstart=1" >> "$file"
