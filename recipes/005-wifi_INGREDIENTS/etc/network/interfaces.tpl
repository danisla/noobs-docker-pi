auto lo
iface lo inet loopback

iface eth0 inet dhcp

iface default inet dhcp

auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-ssid $ssid
wpa-psk $psk
wpa-keymgmt WPA-PSK
wpa-pairwise CCMP
wpa-group CCMP
wpa-proto WPA RSN
wpa-scan-ssid 1
wpa-ap-scan 1

allow-hotplug wlan1
iface wlan1 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
