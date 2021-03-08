FROM debian:buster-backports

# Install packages via script, to minimise size:
# https://pythonspeed.com/articles/system-packages-docker/

# Install dev packages
COPY  install-dev-packages.sh /.install-dev-packages
RUN /.install-dev-packages

# Install build dependency packages
COPY  install-build-deps.sh /.install-build-deps
RUN /.install-build-deps

# Default script
COPY build-deb.sh /build-deb
ENTRYPOINT ["/build-deb"]

# Environment variables
ENV DH_VERBOSE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DPKG_COLORS=always
ENV FORCE_UNSAFE_CONFIGURE=1

# Root of source code to build
VOLUME /src
