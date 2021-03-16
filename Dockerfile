FROM debian:buster-backports

# Root of source code to build
VOLUME /src
# Location of output package build
VOLUME /build

# Default script
COPY entrypoint.sh /entrypoint
COPY build-deb.sh /build-deb
COPY check-deb.sh /check-deb
ENTRYPOINT ["/entrypoint"]

# Environment variables
# ~ Custom logic
ENV BUILD=1
ENV CHECK=1
# No GPG signing
# Skip checking build dependencies (can fail erroneously)
ENV DPKG_BUILDPACKAGE_OPTS="--no-sign --no-check-builddeps --post-clean"
ENV LINTIAN_OPTS="--dont-check-part nmu --no-tag-display-limit --display-info --show-overrides --fail-on error --fail-on warning"

# ~ Debian
ENV DH_VERBOSE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DPKG_COLORS=always
ENV FORCE_UNSAFE_CONFIGURE=1

# Install packages via script, to minimise size:
# https://pythonspeed.com/articles/system-packages-docker/

# Install dev packages
COPY  install-dev-packages.sh /.install-dev-packages
RUN /.install-dev-packages

# Install build dependency packages
COPY  install-build-deps.sh /.install-build-deps
RUN /.install-build-deps

# Add a user with userid 1000 and name nonroot
RUN useradd --create-home -u 1000 nonroot

# Configure sudo for nonroot
COPY  sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers

# Run container as nonroot
USER nonroot
