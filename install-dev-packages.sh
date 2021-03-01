#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

support_packages=("apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg")
dev_packages=("dpkg-dev" "debhelper" "lintian")

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

# Update the package listing, so we know what packages exist
apt-get update

# Install wget and gnupg for getting/installing APT key
apt-get -y -t buster-backports install --no-install-recommends "${support_packages[@]}"

curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -

# Add Raspberry Pi's repo
echo "deb http://archive.raspberrypi.org/debian/ buster main" > /etc/apt/sources.list.d/raspi.list

# Update the package listing, so we know what package exist
apt-get update

# Install security updates
apt-get -y upgrade

# Install new packages, without unnecessary recommended packages
apt-get -y -t buster-backports install --no-install-recommends "${dev_packages[@]}"


# Delete cached files we don't need anymore
apt-get clean
rm -rf /var/lib/apt/lists/*
