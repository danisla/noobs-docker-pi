#!/bin/sh

file="/boot/config.txt"

grep -q "^rotate_display=2" "$file" && exit

echo "Adding rotate_display=2 to $file" >> /dev/kmsg

grep -q "^rotate_display.*" "$file" && sed -i -e 's/^rotate_display.*/rotate_display=2/' "$file" || echo "rotate_display=2" >> "$file"
