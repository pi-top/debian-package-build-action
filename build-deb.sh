#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

echo "[build-deb] Changing working directory to source... (/src)"
cd /src

echo "[build-deb] DEBUG: Listing directory contents..."
ls -l

echo "[build-deb] Updating package list..."
apt-get update

echo "[build-deb] Installing build dependencies..."
apt-get build-dep -y .

echo "[build-deb] Moving source files to temporary directory..."
tmp_dir_root=$(mktemp -d)
tmp_dir=$(mkdir ${tmp_dir_root}/src)
cp -r /src/* "${tmp_dir}/"

cd "${tmp_dir}"
echo "[build-deb] Building package..."
# No GPG signing
# Skip checking build dependencies (can fail erroneously)
dpkg-buildpackage --no-sign --no-check-builddeps --post-clean

echo "[build-deb] Moving build files..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     mv -- "$x" /build
   fi
done

echo "[build-deb] DONE!"
