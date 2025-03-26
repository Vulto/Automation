#!/bin/bash
# This script will setup a EGE PWD Machine configuration
# The script is structured in several functions wich can be called as arguments.
# 
# Install packages
# Set hostname
# 		NTP
#			bashrc
#			hosts file
#			resolv.conf
#			sources.list
#	Configure Network interfaces
#	Copy binaries dwm, sx, surf
# Compile
# Test
# Silence boot
# Auto login user "operador" and set root as non auto xorg executer
# 

if [[ $UID != 0 ]]; then
  echo "This script requires root permission"
  exit
fi
 
namehost="MUPBRPWD204"
NtpRegion="America/Sao_Paulo"
domain="mubrsa.net"
gtw="10.17.51.225"
vlan=1213
ip="10.17.51.238"
mask="255.255.255.224"
dns="10.17.53.6"
dns2="10.17.53.6"
user="administrator"
pass="@EGEsAdmin"

usage() {
  echo "placeholder"
}

InstallBasic () {
	apt install neovim tmux tcpdump ssh
}

SetHostname() {
# Should be like this, HOSTNAME is already being used by the system
	hostnamectl set-hostname $namehost
}

NTP() {
	timedatectl set-ntp true
	timedatectl set-timezone $NtpRegion
	timedatectl set-ntp true 
	hwclock --syshoc
}

CopyFiles() {
# Copy files override original files
	scp -f $files $user@$ip 
}

CompileAndInstall() {
  echo "placeholder"
}

Test() {
# Test if userspace is configured
  echo "placeholder"
}

SilenceBoot() {
  echo "placeholder"
}

AutoLoginUser() {
  echo "placeholder"
}

SetRsyslog() {
  echo "placeholder"
}

DisplayInfo() {
  hostnamectl
  timedatectl
  networkctl status eth0
  exit
}

case "$1" in

	"-h")
		usage					      ;;
	
	"-s")
		SetHostname		      ;;

	"-l")
		NTP                 ;;

	"--copy-files")
		CopyFiles				  	;;

	"--CompileAndInstall")
		CompileAndInstall		;;

  "--display-info")     
      DisplayInfo       ;;

	*)
		usage					      ;;

esac

#edit fstab to mount fileserver folder at boot
#mount -t cifs "//10.17.54.54/MFT/FileTransfer/EGE Files" /mnt/fileserver/ -o username=j.sa.admt1,password='U-FgX2Ec!ee3nM'

#if [ $? == 0 ] then;
#	echo "File server folder mounted!"
#else
#	echo "Failed to mount folder!"
#fi
	
#cp /mnt/fileserver/zscaler-cert* /usr/share/ca-certificates/

#update-ca-certificates

# Realm ingress
#dpkg -i /mnt/fileserver/packages/*

#realm join $DOMAIN -U $USER

#apt update -y && apt upgrade -y

#realm list
#exec check_ifaces.sh
