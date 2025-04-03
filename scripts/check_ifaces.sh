#!/bin/bash

for interface in $(networkctl list --no-legend | awk '{print $2}'); do
    echo "Checking interface: $interface"
    networkctl status "$interface"
    echo "------------------------"
done
