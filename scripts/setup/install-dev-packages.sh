#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

dev_packages=("debhelper" "devscripts" "dpkg-dev" "fakeroot" "lintian" "sudo")

apt_get_install_opts="-y install --no-install-recommends"
# e.g. 'buster-backports' vs 'bullseye'
if [[ "${DEBIAN_BASE_IMAGE}" == *"-"* ]]; then
  apt_get_install_opts="${apt_get_install_opts} -t ${DEBIAN_BASE_IMAGE}"
fi

debug_echo "DEBUG: print apt_get_install_opts..."
debug_echo "${apt_get_install_opts}"

debug_echo "Parsing apt-get arguments..."
IFS=' ' read -ra apt_get_install_opts_arr <<<"$apt_get_install_opts"

echo "Updating package list..."
apt-get update

echo "Installing new packages, without unnecessary recommended packages..."
apt-get "${apt_get_install_opts_arr[@]}" "${dev_packages[@]}"

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
