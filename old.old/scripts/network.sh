

# Install network packages
sudo pacman -S networkmanager network-manager-applet nm-connection-editor \
    wpa_supplicant wireless_tools dhclient impala
sudo systemctl enable --now NetworkManager

# Bluetooth
sudo pacman -S bluez bluez-utils bluez-tools blueman bluetui
sudo systemctl enable --now bluetooth.service

# Firewall
sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable --now ufw

# Disable IPV6
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/40-ipv6.conf
sudo sysctl -p /etc/sysctl.d/40-ipv6.conf

# VPN
sudo pacman -S wireguard-tools openresolv
# wg-quick up wgus0
# sudo systemctl ....
