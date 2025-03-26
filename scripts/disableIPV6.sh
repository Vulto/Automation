#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root. Use sudo."
    exit 1
fi

# Step 1: Disable IPv6 via sysctl
echo "Disabling IPv6 via sysctl..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Step 2: Check if IPv6 module is loaded and unload it
echo "Checking for IPv6 kernel module..."
if lsmod | grep -q "^ipv6"; then
    echo "IPv6 module is loaded. Attempting to unload..."
    if rmmod ipv6 2>/dev/null; then
        echo "Successfully unloaded IPv6 module."
    else
        echo "Warning: Could not unload IPv6 module (in use). Checking for IPv6 listeners..."
        if netstat -tuln | grep -q ":::"; then
            echo "Processes binding to IPv6 found:"
            netstat -tuln | grep ":::"
            echo "Please stop these services (e.g., 'systemctl stop <service>') and re-run the script."
        else
            echo "No obvious IPv6 listeners found, but module is still in use. Manual investigation needed."
        fi
    fi
else
    echo "IPv6 module is not loaded. Skipping unload step."
fi

# Step 3: Verify IPv6 is disabled
echo "Verifying IPv6 status..."
if ip a | grep -q "inet6"; then
    echo "Warning: IPv6 addresses still detected:"
    ip a | grep "inet6"
    echo "IPv6 disable may not be fully effective. Check services or kernel module."
else
    echo "Success: No IPv6 addresses detected."
fi
if lsmod | grep -q "^ipv6"; then
    echo "Warning: IPv6 module is still loaded."
else
    echo "Success: IPv6 module is not loaded."
fi

# Step 4: Optional - Make changes persistent (comment out if not desired)
echo "Making changes persistent (uncomment to enable)..."
cat << EOF > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
EOF
echo "blacklist ipv6" > /etc/modprobe.d/disable-ipv6.conf
echo "Persistence applied: sysctl settings in /etc/sysctl.d/99-disable-ipv6.conf and module blacklist in /etc/modprobe.d/disable-ipv6.conf."

echo "Done! IPv6 should be disabled for this session. For full immutability, consider adding 'ipv6.disable=1' to GRUB and rebooting later."
