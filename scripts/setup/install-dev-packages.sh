#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

# Can probably remove some of these:
support_packages=("apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg")

dev_packages=("sudo" "dpkg-dev" "debhelper" "lintian" "fakeroot")

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

echo "Updating package list..."
apt-get update

echo "Installing tools to get/install APT key..."
apt-get -y -t buster-backports install --no-install-recommends "${support_packages[@]}"

echo "Adding Raspberry Pi's repo..."
curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -
echo "deb [arch=armhf,amd64,arm64] http://archive.raspberrypi.org/debian/ buster main" > /etc/apt/sources.list.d/raspi.list

echo "Adding pi-top's repo..."
curl --insecure https://apt.pi-top.com/pt-apt.asc | apt-key add
echo "deb [arch=armhf,amd64,arm64] http://apt.pi-top.com/pi-top-os sirius main contrib non-free" > /etc/apt/sources.list.d/pi-top.list

echo "Updating package list..."
apt-get update

echo "Installing security updates..."
apt-get -y upgrade

echo "Installing new packages, without unnecessary recommended packages..."
apt-get -y -t buster-backports install --no-install-recommends "${dev_packages[@]}"

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
