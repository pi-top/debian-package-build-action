#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


tmp_dir_root=$(mktemp -d)

echo "[build-deb] Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir="${tmp_dir_root}/src"
mkdir "${tmp_dir}"
cp -r /src/* "${tmp_dir}/"

echo "[build-deb] Changing working directory to temporary directory..."
cd "${tmp_dir}"

echo "[build-deb] Updating package list..."
sudo apt-get update

echo "[build-deb] Installing build dependencies..."
sudo apt-get build-dep -y .

echo "[build-deb] DEBUG: Listing temporary directory contents BEFORE building..."
ls -l

echo "[build-deb] DEBUG: print DPKG_BUILDPACKAGE_OPTS..."
echo "${DPKG_BUILDPACKAGE_OPTS}"

echo "[build-deb] Building package..."
dpkg-buildpackage ${DPKG_BUILDPACKAGE_OPTS}

echo "[build-deb] DEBUG: Listing temporary directory contents AFTER building..."
ls -l

echo "[build-deb] Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     sudo mv -- "$x" /build
   fi
done

echo "[build-deb] DEBUG: Listing /build directory contents..."
ls -l /build

echo "[build-deb] DONE!"
