#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

NODEREPO="node_16.x"
DISTRO="buster"

# Can probably remove some of these:
support_packages=("apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg")

dev_packages=("debhelper" "devscripts" "dpkg-dev" "fakeroot" "lintian" "sudo")

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

echo "Adding NodeJS repo..."
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

echo "deb https://deb.nodesource.com/${NODEREPO} ${DISTRO} main" >/etc/apt/sources.list.d/nodesource.list

echo "Updating package list..."
apt-get update

echo "Installing NodeJS, without unnecessary recommended packages..."
apt-get install -y nodejs

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
