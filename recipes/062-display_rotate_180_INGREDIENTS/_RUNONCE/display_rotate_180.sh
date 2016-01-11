#!/bin/sh

file="/boot/config.txt"

grep -q "^display_rotate=2" "$file" && exit

echo "Adding display_rotate=2 to $file" >> /dev/kmsg

grep -q "^display_rotate.*" "$file" && sed -i -e 's/^display_rotate.*/display_rotate=2/' "$file" || echo "display_rotate=2" >> "$file"
