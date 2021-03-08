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

echo "[build-deb] Listing directory contents..."
ls -l

echo "[build-deb] Updating package list..."
apt-get update

echo "[build-deb] Installing build dependencies..."
apt-get build-dep -y ./debian/control

echo "[build-deb] Building package..."
# No GPG signing
# Skip checking build dependencies (can fail erroneously)
dpkg-buildpackage --no-sign --no-check-builddeps

echo "[build-deb] DONE!"
