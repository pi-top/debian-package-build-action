FROM debian:buster-backports

# Install packages via script, to minimise size:
# https://pythonspeed.com/articles/system-packages-docker/

# Install dev packages
COPY  install-dev-packages.sh .
RUN ./install-dev-packages.sh

# Install build dependency packages
COPY  install-build-deps.sh .
RUN ./install-build-deps.sh
