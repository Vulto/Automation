#!/bin/bash

# Automatic network interface configuration script

# Exit on any error
set -e

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Configuration variables - modify these as needed
ETHERNET_IP="192.168.1.100"        # Your desired static IP
ETHERNET_NETMASK="255.255.255.0"   # Your subnet mask
ETHERNET_GATEWAY="192.168.1.1"     # Your gateway
ETHERNET_DNS="8.8.8.8"            # Your DNS server

# Function to convert netmask to CIDR
mask_to_cidr() {
    local mask=$1
    local bits=0
    IFS='.' read -r -a octets <<< "$mask"
    for octet in "${octets[@]}"; do
        while [ $octet -gt 0 ]; do
            bits=$((bits + (octet & 1)))
            octet=$((octet >> 1))
        done
    done
    echo "$bits"
}

# Get the MAC address of the non-loopback interface
ETHERNET_MAC=$(ip link | grep -B1 "link/ether" | grep -v "lo:" | awk '/ether/ {print $2}' | head -n1)
if [ -z "$ETHERNET_MAC" ]; then
    echo "Could not detect Ethernet MAC address!"
    exit 1
fi

CIDR_PREFIX=$(mask_to_cidr "$ETHERNET_NETMASK")

# Install systemd-networkd if not present
if ! command -v systemctl >/dev/null 2>&1; then
    echo "Systemd not found!"
    exit 1
fi

if ! systemctl status systemd-networkd >/dev/null 2>&1; then
    echo "Installing systemd-networkd..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y systemd-networkd
    elif command -v yum >/dev/null 2>&1; then
        yum install -y systemd-networkd
    else
        echo "Package manager not recognized!"
        exit 1
    fi
fi

# Enable and start systemd-networkd
systemctl enable systemd-networkd
systemctl start systemd-networkd

# Configure loopback interface (20- priority)
cat > /etc/systemd/network/20-lo.network << EOF
[Match]
Name=lo

[Network]
Address=127.0.0.1/8
IPv6AcceptRA=no
LinkLocalAddressing=no

[Link]
ActivationPolicy=always-up
EOF

# Create .link file to rename interface to eth0 (01- priority)
cat > /etc/systemd/network/01-eth0.link << EOF
[Match]
MACAddress=$ETHERNET_MAC

[Link]
Name=eth0
EOF

# Configure Ethernet interface (21- priority) matching by name
cat > /etc/systemd/network/21-eth0.network << EOF
[Match]
Name=eth0

[Link]
RequiredForOnline=yes

[Network]
Address=$ETHERNET_IP/$CIDR_PREFIX
Gateway=$ETHERNET_GATEWAY
DNS=$ETHERNET_DNS
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF

# Set permissions
chmod 644 /etc/systemd/network/20-lo.network
chmod 644 /etc/systemd/network/01-eth0.link
chmod 644 /etc/systemd/network/21-eth0.network

# Disable IPv6
if ! grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/systemd/network/20-lo.network/etc/sysctl.conf
else
    sed -i 's/net.ipv6.conf.all.disable_ipv6.*/net.ipv6.conf.all.disable_ipv6 = 1/' /etc/sysctl.conf
fi

if ! grep -q "net.ipv6.conf.default.disable_ipv6" /etc/sysctl.conf; then
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
else
    sed -i 's/net.ipv6.conf.default.disable_ipv6.*/net.ipv6.conf.default.disable_ipv6 = 1/' /etc/sysctl.conf
fi

# Apply sysctl changes
sysctl -p

# Restart networking
systemctl restart systemd-networkd

echo "Network configuration completed!"
echo "Loopback configured with 127.0.0.1/8"
echo "Ethernet (MAC: $ETHERNET_MAC) renamed to eth0 and configured with $ETHERNET_IP/$CIDR_PREFIX"
echo "IPv6 fully disabled"
echo "Files created:"
echo "  /etc/systemd/network/01-eth0.link (matches by MAC)"
echo "  /etc/systemd/network/20-lo.network"
echo "  /etc/systemd/network/21-eth0.network (matches by Name=eth0)"
