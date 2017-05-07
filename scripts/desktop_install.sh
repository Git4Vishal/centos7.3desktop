#!/bin/sh
sudo yum -y groupinstall "X Window System"
sudo yum -y install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts
sudo unlink /etc/systemd/system/default.target
sudo ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
sudo yum -y groupinstall "Development Tools"
sudo yum install -y telnet
sudo yum install -y net-tools
sudo yum install -y ntp
sudo yum install -y curl
sudo yum install -y wget
sudo yum install -y firefox
sudo reboot
