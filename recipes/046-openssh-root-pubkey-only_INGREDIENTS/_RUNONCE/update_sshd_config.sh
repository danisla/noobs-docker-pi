#!/bin/sh

file="/etc/ssh/sshd_config"

echo "Updating $file" >> /dev/kmsg

grep -q "^UsePAM.*" "$file" && sed -i -e 's/^UsePAM.*/UsePAM no/' "$file" || echo "UsePAM no" >> "$file"
grep -q "^PasswordAuthentication.*" "$file" && sed -i -e 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$file" || echo "PasswordAuthentication no" >> "$file"
