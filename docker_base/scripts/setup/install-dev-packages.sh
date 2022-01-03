#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

set -x

debug_echo() {
  if [[ "${DEBUG}" -eq 1 ]]; then
    echo "[build-deb] $1"
  fi
}

dev_packages=("debhelper" "debsigs" "devscripts" "dpkg-dev" "fakeroot" "lintian" "sudo")

apt_get_install_opts="-y install --no-install-recommends"

# Get dev packages from backports if available
backports_list_file="/etc/apt/sources.list.d/backports.list"
if [[ -f "${backports_list_file}" ]]; then
  backports_repo_name="$(awk '{print $3}' "${backports_list_file}")"
  apt_get_install_opts="${apt_get_install_opts} -t ${backports_repo_name}"
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
