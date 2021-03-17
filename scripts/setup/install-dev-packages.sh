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

# Update the package listing, so we know what packages exist
apt-get update

# Install wget and gnupg for getting/installing APT key
apt-get -y -t buster-backports install --no-install-recommends "${support_packages[@]}"

# Add Raspberry Pi's repo
curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -
echo "deb http://archive.raspberrypi.org/debian/ buster main" > /etc/apt/sources.list.d/raspi.list

# Add pi-top's repo
curl https://apt.pi-top.com/pt-apt.asc | apt-key add
echo "deb http://apt.pi-top.com/pi-top-os sirius main contrib non-free" > /etc/apt/sources.list.d/pi-top.list

# Update the package listing, so we know what package exist
apt-get update

# Install security updates
apt-get -y upgrade

# Install new packages, without unnecessary recommended packages
apt-get -y -t buster-backports install --no-install-recommends "${dev_packages[@]}"


# Delete cached files we don't need anymore
apt-get clean
rm -rf /var/lib/apt/lists/*
