#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

repos=("pi-top-Python-SDK" "pi-top-Python-Common-Library" "pt-sys-oled")

# Tell apt-get we're never going to be able to give manual feedback
export DEBIAN_FRONTEND=noninteractive

# Update the package listing with newly added sources
apt-get update

# Install wget for getting control files for repos
apt-get -y install wget

# Install build dependencies
mkdir ./debian
for repo in "${repos[@]}"; do
  wget "https://raw.githubusercontent.com/pi-top/${repo}/master/debian/control" -O ./debian/control
  apt-get build-dep -y .
done
rm -rf ./debian

# Delete cached files we don't need anymore
apt-get clean
rm -rf /var/lib/apt/lists/*
