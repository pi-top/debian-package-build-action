#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

# Change working directory to source
cd /src

# Update package list
apt-get update

# Install build dependencies
apt-get build-dep -y .

# Build package - no GPG signing, skip checking build dependencies (can fail erroneously)
dpkg-buildpackage --no-sign --no-check-builddeps
