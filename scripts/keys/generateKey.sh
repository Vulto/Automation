#!/bin/bash

GenerateKey() {
  HOSTNAME="$1"
  DOMAIN="$2"
  openssl genrsa -aes256 -out "$HOSTNAME.$DOMAIN.key" 4096
  openssl req -new -key "$HOSTNAME.$DOMAIN.key" -out "$HOSTNAME.$DOMAIN.csr" -subj "/C=BR/ST=MG/L=Piumhi/O=JDE/OU=IODC/CN=$HOSTNAME.$DOMAIN"
}

# Check for no arguments
if [ $# -eq 0 ]; then
  read -p "Use local hostname ($(hostname)) and domain ($(dnsdomainname))? (y/n): " answer
  if [ "$answer" = "y" ]; then
    GenerateKey "$(hostname)" "$(dnsdomainname)"
  else
    echo "Usage: $0 [-h <hostname> -d <domain>]"
    echo "Example: $0 -h MUPBRLUS112 -d mubrpi.net"
    exit 1
  fi
else
  # Parse flags
  while getopts "h:d:" opt; do
    case $opt in
      h) HOSTNAME="$OPTARG";;
      d) DOMAIN="$OPTARG";;
      ?) echo "Invalid option"; exit 1;;
    esac
  done

  # Ensure both -h and -d are provided
  if [ -z "$HOSTNAME" ] || [ -z "$DOMAIN" ]; then
    echo "Error: Both -h and -d are required"
    echo "Usage: $0 -h <hostname> -d <domain>"
    exit 1
  fi

  GenerateKey "$HOSTNAME" "$DOMAIN"
fi
