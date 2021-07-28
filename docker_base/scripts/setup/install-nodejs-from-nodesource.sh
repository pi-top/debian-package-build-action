#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

set -x

NODEREPO="node_16.x"

echo "Adding NodeJS repo..."
curl -fsSLk https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

echo "deb https://deb.nodesource.com/${NODEREPO} $(lsb_release -cs) main" >/etc/apt/sources.list.d/nodesource.list

echo "Updating package list..."
apt-get update

echo "Installing NodeJS, without unnecessary recommended packages..."
apt-get install -y nodejs

echo "Deleting cached files we don't need anymore..."
apt-get clean
rm -rf /var/lib/apt/lists/*
