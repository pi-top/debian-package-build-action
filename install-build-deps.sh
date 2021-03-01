#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

repos=("pi-top-Python-SDK", "pi-top-Python-Common-Library")

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

# Update the package listing, so we know what packages exist
apt-get update

# Install wget and gnupg2 for getting/installing APT key
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

curl -fsSL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -

# Add Raspberry Pi's repo
echo "deb http://archive.raspberrypi.org/debian/ buster main" > /etc/apt/sources.list.d/raspi.list

# Update the package listing with newly added sources
apt-get update

# Install git for cloning repos
apt-get -y install git

# Install build dependencies
for repo in "${repos[@]}"; do
  git clone --depth 1 "https://github.com/pi-top/${repo}"
  apt-get build-dep -y "./${repo}"
  rm -rf "./${repo}"
done

# Delete cached files we don't need anymore
apt-get clean
rm -rf /var/lib/apt/lists/*
