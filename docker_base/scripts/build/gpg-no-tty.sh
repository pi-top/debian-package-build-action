#!/bin/bash

gpg \
  --no-tty \
  -v \
  --pinentry-mode loopback \
  --batch \
  --passphrase="${SIGNING_PASSPHRASE}" \
  $@
