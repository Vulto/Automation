#!/bin/bash

# Array of package names
packages=(
  "tcpdump" 
  "fzf" 
  "tmux" 
  "nmap" 
  "neovim"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    sudo apt-get install -y "$package"
    
    if [ $? -eq 0 ]; then
        echo "$package installed successfully"
    else
        echo "Failed to install $package"
    fi
    echo ""   
    sleep 2
done

echo "All installation attempts completed"
