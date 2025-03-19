#!/bin/bash

# Define the network file path
NETWORK_FILE="/etc/systemd/network/00-lo.network"
DRY_RUN=false

# Check for dry-run flag
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    NETWORK_FILE="/tmp/00-lo.network.test"
    echo "Dry run: Writing to $NETWORK_FILE"
fi

# Check if script is run as root (unless dry-run)
if [[ $EUID -ne 0 && "$DRY_RUN" == false ]]; then
    echo "Error: This script must be run as root to write to $NETWORK_FILE" >&2
    exit 1
fi

# Backup existing file (if it exists and not dry-run)
if [[ -f "$NETWORK_FILE" && "$DRY_RUN" == false ]]; then
    cp "$NETWORK_FILE" "$NETWORK_FILE.bak"
    echo "Backup created at $NETWORK_FILE.bak"
fi

# Create or overwrite the network file
cat << EOF > "$NETWORK_FILE"
[Match]
Name=lo

[Network]
Address=127.0.0.1/8
LinkLocalAddressing=ipv4

[Link]
RequiredForOnline=yes
EOF

# Set permissions (unless dry-run)
if [[ "$DRY_RUN" == false ]]; then
    chmod 644 "$NETWORK_FILE"
fi

# Verify file creation
if [[ ! -f "$NETWORK_FILE" ]]; then
    echo "Error: Failed to create $NETWORK_FILE" >&2
    exit 1
fi

# Restart systemd-networkd (unless dry-run)
if [[ "$DRY_RUN" == false ]]; then
    systemctl restart systemd-networkd
    echo "systemd-networkd restarted"
fi

echo "Loopback network configuration created at $NETWORK_FILE"
