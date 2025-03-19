#!/bin/bash

#Deploy form:


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

exec setup_ifaces.sh


#	NTP:
#	America/Bahia
timedatectl set-timezone America/Bahia 
timedatectl set-ntp true 
hwclock --syshoc


#edit fstab to mount fileserver folder at boot
mount -t cifs "//10.17.54.54/MFT/FileTransfer/EGE Files" /mnt/fileserver/ -o username=j.sa.admt1,password='U-FgX2Ec!ee3nM'

if [ $? == 0 ] then;
	echo "File server folder mounted!"
else
	echo "Failed to mount folder!"
fi
	
cp /mnt/fileserver/zscaler-cert* /usr/share/ca-certificates/

update-ca-certificates

# Realm ingress
dpkg -i /mnt/fileserver/packages/*

realm join $DOMAIN -U $USER

apt update -y && apt upgrade -y

# Run a set of commands and send to LSUS.

hostnamectl
realm list
exec check_ifaces.sh
