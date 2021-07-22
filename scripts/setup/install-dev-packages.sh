#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

set -x

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

echo "Updating package list..."
apt-get update

echo "Determining base image..."
if [[ -z "${DEBIAN_BASE_IMAGE:-}" ]]; then
  echo "DEBIAN_BASE_IMAGE not set"
  if [[ -n "${1:-}" ]]; then
    DEBIAN_BASE_IMAGE="${1}"
  else
    echo "No command line argument - installing lsb-release..."
    apt-get -y install --no-install-recommends lsb-release
    DEBIAN_BASE_IMAGE="$(lsb_release -cs)"
  fi
fi
echo "Base image: ${DEBIAN_BASE_IMAGE}"

# Can probably remove some of these:
support_packages=("apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg")

dev_packages=("debhelper" "devscripts" "dpkg-dev" "fakeroot" "lintian" "sudo")

echo "Installing tools to get/install APT key..."
apt-get -y install --no-install-recommends -t "${DEBIAN_BASE_IMAGE}" "${support_packages[@]}"

echo "Adding Raspberry Pi's repo..."
curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -
echo "deb [arch=armhf,amd64,arm64] http://archive.raspberrypi.org/debian/ $(lsb_release -cs) main" >/etc/apt/sources.list.d/raspi.list

echo "Adding pi-top's repo..."
curl --insecure https://apt.pi-top.com/pt-apt.asc | apt-key add
echo "deb [arch=armhf,amd64,arm64] http://apt.pi-top.com/pi-top-os sirius main contrib non-free" >/etc/apt/sources.list.d/pi-top.list

echo "Updating package list..."
apt-get update

echo "Installing security updates..."
apt-get -y upgrade

echo "Installing new packages, without unnecessary recommended packages..."
apt-get -y install --no-install-recommends -t "${DEBIAN_BASE_IMAGE}" "${dev_packages[@]}"

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
