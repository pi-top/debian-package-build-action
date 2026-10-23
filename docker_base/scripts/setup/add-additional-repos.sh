#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

set -x

# Can probably remove some of these:
support_packages=("apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg")

echo "Updating package list..."
apt-get update

echo "Installing tools to get/install APT key..."
apt-get -y install --no-install-recommends "${support_packages[@]}"

# TODO: migrate away from apt-key
# - also for OS build
# https://www.linuxuprising.com/2021/01/apt-key-is-deprecated-how-to-add.html
echo "Adding Raspberry Pi's repo..."
curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -
echo "deb [arch=armhf,amd64,arm64] http://archive.raspberrypi.org/debian/ $(lsb_release -cs) main" >/etc/apt/sources.list.d/raspi.list

# Debian wins where both archives ship a package; the Raspberry Pi archive is
# a fallback for packages Debian does not have.
cat >/etc/apt/preferences.d/raspberrypi <<'PREF'
Package: *
Pin: origin "archive.raspberrypi.org"
Pin-Priority: 100
PREF

echo "Updating package list..."
apt-get update

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
