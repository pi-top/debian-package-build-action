#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

set -x

NODEREPO="node_22.x"

echo "Adding NodeJS repo..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/${NODEREPO} nodistro main" >/etc/apt/sources.list.d/nodesource.list

echo "Updating package list..."
apt-get update

echo "Installing NodeJS..."
apt-get install -y nodejs

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
