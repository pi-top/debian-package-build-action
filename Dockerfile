FROM debian:buster-backports

# Root of source code to build
VOLUME /src
# Location of output package build
VOLUME /build

# Default script
COPY build-deb.sh /build-deb
ENTRYPOINT ["/build-deb"]

# Environment variables
ENV DH_VERBOSE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DPKG_COLORS=always
ENV FORCE_UNSAFE_CONFIGURE=1

# Add a user with userid 1000 and name nonroot
RUN useradd −u 1000 nonroot

# Run container as nonroot
USER nonroot

# Install packages via script, to minimise size:
# https://pythonspeed.com/articles/system-packages-docker/

# Install dev packages
COPY  install-dev-packages.sh /.install-dev-packages
RUN /.install-dev-packages

# Install build dependency packages
COPY  install-build-deps.sh /.install-build-deps
RUN /.install-build-deps
