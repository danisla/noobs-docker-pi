#!/bin/sh

file="/boot/config.txt"

grep -q "^gpu_mem=512" "$file" && exit

echo "Adding gpu_mem=512 to $file" >> /dev/kmsg

grep -q "^gpu_mem.*" "$file" && sed -i -e 's/^gpu_mem.*/gpu_mem=512/' "$file" || echo "gpu_mem=512" >> "$file"
