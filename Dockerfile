FROM debian:buster-backports

# Root of source code to build
VOLUME /src
# Location of output package build
VOLUME /build

# Copy build scripts
COPY scripts/build/install-deb-build-deps.sh /install-deb-build-deps
COPY scripts/build/build-deb.sh /build-deb
COPY scripts/build/check-deb.sh /check-deb
COPY scripts/build/entrypoint.sh /entrypoint
ENTRYPOINT ["/entrypoint"]

#########################
# Environment variables #
#########################
# Add extra printing
ENV DEBUG=1
# Disable build stages by overriding these environment variables to 0
ENV INSTALL_BUILD_DEPS=1
ENV BUILD=1
ENV CHECK=1
# Optional:
ENV BUILD_DEP_INSTALL_LOG_FILE
ENV DPKG_BUILDPACKAGE_LOG_FILE
ENV LINTIAN_LOG_FILE
# No GPG signing
# Skip checking build dependencies (can fail erroneously)
ENV DPKG_BUILDPACKAGE_OPTS="--no-sign --no-check-builddeps --post-clean"
ENV LINTIAN_OPTS="--dont-check-part nmu --no-tag-display-limit --display-info --show-overrides --fail-on error --fail-on warning"

# ~ Debian
ENV DH_VERBOSE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DPKG_COLORS=always
ENV FORCE_UNSAFE_CONFIGURE=1

# Install dev packages
COPY  scripts/setup/install-dev-packages.sh /.install-dev-packages
RUN /.install-dev-packages

# Install build dependency packages
COPY  scripts/setup/install-deb-build-deps.sh /.install-deb-build-deps
RUN /.install-deb-build-deps

# Add a user with userid 1000 and name nonroot
RUN useradd --create-home -u 1000 nonroot

# Configure sudo for nonroot
COPY  sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers

# Run container as nonroot
USER nonroot
