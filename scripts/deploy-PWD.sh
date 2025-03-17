#!/bin/bash

#Deploy form:

RED="\[\033[01;31m\]"
GREEN="\[\033[01;32m\]"
CLEAR="\[\033[00m\]"

PS1="[[ $UID = 1000 ]] && PS1="\n $GREEN \h $CLEAR \w  \n      → " || PS1="\n \e[1;31m # [ \w ] \e[m \n    ""

PROJECT="MUSIC"
HOSTNAME="MUPBRPWD204"
DOMAIN="mubrsa.net"
GATEWAY="10.17.51.225"
VLAN=1213
IP="10.17.51.238"
MASK="255.255.255.224"
DNS="10.17.53.6"
DNS2="10.17.53.6"

# Userspace:

user="administrador"
pass="@EGEsAdmin"
ShellPath=`cat /etc/shells | grep -m 1 bash`
chsh -s /bin/to/shell username

# Networkctl
# Get interface names:
Interfaces=`networkctl list --no-legend | awk '{print $1}'`

# Create loopback network file (This will always be the same for any machine)

cat > /etc/systemd/network/00-lo.network

[Match]
Name=lo

[Network]
Address=127.0.0.1/8
LinkLocalAddressing=ipv4

[Link]
RequiredforOnline=yes

> /etc/systemd/network/10-(interface-name).network

[Match]
Name=enp2s0

[Network]
Address=(correct ip accordly to the environment)/Mask
Gateway=
DNS=
IPv6AcceptRA=no
LinkLocalAddressing=no


[Link]
RequiredforOnline=yes

NTP:
	 America/Bahia - timedatectl set-timezone America/Bahia 
	timedatectl set-ntp true 
	hwclock --syshoc


edit fstab to mount fileserver folder at boot
	mount -t cifs "//10.17.54.54/MFT/FileTransfer/EGE Files" /mnt/fileserver/ -o username=j.sa.admt1,password='U-FgX2Ec!ee3nM'

cp /mnt/fileserver/zscaler-cert* /usr/share/ca-certificates/

update-ca-certificates

Realm ingress
	Transfer realm packages
	apt install
	realm ingress

apt update -y 
apt upgrade -y

apt install -y

Run a set of commands and send to LSUS.

hostnamectl
realm list
networkctl status (run in for loop)


